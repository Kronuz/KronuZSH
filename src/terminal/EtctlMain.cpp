/*
 * etctl: the client-side control CLI for backgrounded `et --ctl` sessions.
 *
 * It is a thin, stateless translator: each invocation resolves a session's local
 * control socket (~/.et/ctl/<name>.sock), sends one native control frame, and
 * prints the response.  The transport carries ET's own vocabulary (raw input
 * bytes, a TerminalInfo resize); the richer verbs here (writeln, key,
 * interrupt, eof, expect, observe) are ergonomic sugar composed from it.
 */
#include <algorithm>
#include <csignal>
#include <fstream>
#include <map>
#include <regex>
#include <sstream>

#include <sys/ioctl.h>

#include <cxxopts.hpp>

#include "ControlPaths.hpp"
#include "ControlProtocol.hpp"
#include "ETerminal.pb.h"
#include "Headers.hpp"

using namespace et;

namespace {

/*
 * Ctrl-C handling.  et-lib's easyloggingpp installs a crash handler that catches
 * SIGINT and aborts with a "CRASH HANDLED" backtrace; but here Ctrl-C is the
 * normal way to stop a blocking verb (run, expect, wait, read --follow, sniff
 * --follow).  main() runs after easyloggingpp's static init, so we replace its
 * handler with one that exits cleanly using the conventional code 130.  The
 * interactive attach/observe verbs put the terminal in raw mode (ISIG off), so
 * there Ctrl-C arrives as a byte -- forwarded to the remote, or (in observe) a
 * local quit -- and this signal never fires.
 */
void onInterrupt(int) { _exit(130); }
void installInterruptHandler() {
  struct sigaction sa = {};
  sigemptyset(&sa.sa_mask);
  sa.sa_handler = onInterrupt;
  sigaction(SIGINT, &sa, nullptr);
}

/*
 * Window-size tracking for attach/observe.  The session has its own logical size
 * (default 132x24); a viewer's terminal is usually a different width.  Because
 * attach/observe replay the raw byte stream (no virtual screen), cursor-addressed
 * output (a zsh prompt redraw, vim) is computed for the session's size and renders
 * wrong at a different width.  So we push the local size to the session on start
 * and on every SIGWINCH (unless --no-resize).  The handler only sets a flag; the
 * attach loop does the actual send.
 */
volatile sig_atomic_t g_winchPending = 0;
void onWinch(int) { g_winchPending = 1; }

// One-line description for a subcommand (shown above its Usage:).
string descFor(const string& cmd) {
  if (cmd == "open") return "Start a new control session (exec `et --ctl ...`).";
  if (cmd == "sessions") return "List local control sessions.";
  if (cmd == "gc")
    return "Remove dead session sockets (and, with --idle, end idle sessions).";
  if (cmd == "info") return "Show session status (liveness, link, size, cursor).";
  if (cmd == "kill") return "Force-stop a session's local daemon.";
  if (cmd == "read") return "Read session output without consuming it.";
  if (cmd == "sniff") return "Tap the byte exchange (sent input + received output).";
  if (cmd == "wait") return "Wait until the session output goes quiet.";
  if (cmd == "write") return "Inject raw input bytes (stdin, or a hidden secret).";
  if (cmd == "writeln")
    return "Inject a line of input (or a hidden password).";
  if (cmd == "key")
    return "Inject named keys (arrows, function keys, interrupt/eof, ...).";
  if (cmd == "run") return "Run a command; print its clean output, exit with its code.";
  if (cmd == "expect") return "Wait for a pattern to appear in the output.";
  if (cmd == "resize") return "Set the session's terminal size.";
  if (cmd == "observe") return "Watch the live screen, read-only (Ctrl-C/Ctrl-] to detach).";
  if (cmd == "attach") return "Attach interactively (Ctrl-] to detach).";
  return "";
}

/*
 * Build the cxxopts parser for a subcommand (drives both parsing and --help).
 * Positionals go in a hidden group so help({""}) lists only real options; the
 * synopsis after the program name is set via custom_help.
 */
cxxopts::Options buildOptions(const string& cmd) {
  cxxopts::Options o("etctl " + cmd, descFor(cmd));
  o.add_options()("h,help", "Print help");
  auto pos = o.add_options("positional");
  string synopsis = "NAME";
  if (cmd == "sessions") {
    synopsis = "";
  } else if (cmd == "info") {
    pos("NAME", "session name or socket path", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME";
  } else if (cmd == "attach" || cmd == "observe") {
    o.add_options()
        ("cursor", "Start at byte offset N (default: oldest retained)",
         cxxopts::value<long long>())
        ("tail", "Start at the current head (only show new output)")
        ("no-resize",
         "Don't match the session's size to this terminal (by default attach "
         "and observe resize the session on start and on every window change)");
    pos("NAME", "session name or socket path", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME [OPTION...]";
  } else if (cmd == "kill") {
    o.add_options()(
        "wait",
        "Block until the session has actually ended (default 10s, --wait=S)",
        cxxopts::value<double>()->implicit_value("10"));
    pos("NAME", "session name or socket path", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME [--wait[=S]]";
  } else if (cmd == "read") {
    o.add_options()
        ("cursor", "Start at byte offset N (default: oldest retained)",
         cxxopts::value<long long>())
        ("strip", "Remove ANSI escape sequences")
        ("follow", "Tail new output until interrupted (Ctrl-C)")
        ("timeout", "Wait up to S seconds for new output, then return",
         cxxopts::value<double>());
    pos("NAME", "session", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME [OPTION...]";
  } else if (cmd == "sniff") {
    o.add_options()
        ("cursor", "Start at byte offset N (default: oldest retained)",
         cxxopts::value<long long>())
        ("tail", "Start at the current head (only show new records)")
        ("follow", "Keep streaming the exchange until interrupted (Ctrl-C)");
    pos("NAME", "session", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME [OPTION...]";
  } else if (cmd == "wait") {
    o.add_options()
        ("idle", "Required quiet period in seconds",
         cxxopts::value<double>()->default_value("0.5"))
        ("timeout", "Seconds before giving up",
         cxxopts::value<double>()->default_value("30"));
    pos("NAME", "session", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME [OPTION...]";
  } else if (cmd == "write") {
    o.add_options()("secret",
                    "Read one hidden line via getpass (no newline added)");
    pos("NAME", "session", cxxopts::value<string>());
    o.parse_positional({"NAME"});
    synopsis = "NAME [--secret]";
  } else if (cmd == "writeln") {
    o.add_options()("secret",
                    "Read the line hidden via getpass (e.g. a password)");
    pos("NAME", "session", cxxopts::value<string>())(
        "TEXT", "text to send", cxxopts::value<string>());
    o.parse_positional({"NAME", "TEXT"});
    synopsis = "NAME [TEXT] [--secret]";
  } else if (cmd == "key") {
    pos("NAME", "session", cxxopts::value<string>())(
        "KEYS", "keys to send", cxxopts::value<vector<string>>());
    o.parse_positional({"NAME", "KEYS"});
    synopsis = "NAME KEY...";
  } else if (cmd == "run") {
    o.add_options()("timeout", "Seconds before giving up",
                    cxxopts::value<double>()->default_value("60"));
    pos("NAME", "session", cxxopts::value<string>())(
        "CMD", "command to run", cxxopts::value<string>());
    o.parse_positional({"NAME", "CMD"});
    synopsis = "NAME CMD [OPTION...]";
  } else if (cmd == "expect") {
    o.add_options()
        ("timeout", "Seconds before giving up",
         cxxopts::value<double>()->default_value("30"))
        ("from-start", "Also scan retained scrollback, not just new output")
        ("exact", "Match PATTERN as a literal substring, not a regex")
        ("cursor", "Scan output from byte offset N (capture it before writing "
                   "to avoid races)",
         cxxopts::value<long long>());
    pos("NAME", "session", cxxopts::value<string>())(
        "PATTERN", "regex (or literal with --exact)", cxxopts::value<string>());
    o.parse_positional({"NAME", "PATTERN"});
    synopsis = "NAME PATTERN [OPTION...]";
  } else if (cmd == "resize") {
    pos("NAME", "session", cxxopts::value<string>())(
        "ROWS", "rows", cxxopts::value<int>())(
        "COLS", "columns", cxxopts::value<int>());
    o.parse_positional({"NAME", "ROWS", "COLS"});
    synopsis = "NAME ROWS COLS";
  } else if (cmd == "gc") {
    o.add_options()
        ("idle",
         "Also end live sessions idle longer than DUR (e.g. 30m, 6h; "
         "default 8h)",
         cxxopts::value<string>()->implicit_value("8h"))
        ("force", "Stop idle sessions outright, skipping the graceful eof");
    synopsis = "[--idle [DUR]] [--force]";
  }
  o.positional_help("");
  o.custom_help(synopsis);
  return o;
}

// Top-level overview: ET-style header + Usage + a flat, ordered command list.
void printOverview() {
  fprintf(stderr,
          "Control backgrounded Eternal Terminal (et --ctl) sessions\n"
          "Usage:\n"
          "  etctl <command> [args]\n"
          "\n"
          "  Open a reconnectable session in the background, then read its "
          "output and\n"
          "  send it input. Run 'etctl <command> --help' for a command's "
          "options.\n"
          "  NAME is a session name (under ~/.et/ctl, or $ETCTL_HOME) or a "
          "socket path.\n"
          "\n"
          "  open NAME   start a session named NAME if not already running\n"
          "  kill        force-stop a session daemon (key NAME eof ends it cleanly)\n"
          "\n"
          "  run         run a command; capture clean output + exit code\n"
          "  read        read output (non-destructive)\n"
          "  expect      wait for a pattern in the output\n"
          "  write       inject raw input (or a hidden secret)\n"
          "  writeln     inject a line (or a hidden password)\n"
          "\n"
          "  key         inject named keys (arrows, interrupt, eof, ...)\n"
          "  wait        wait until output goes quiet\n"
          "\n"
          "  resize      set terminal size\n"
          "  sniff       tap the byte exchange (sent + received)\n"
          "  observe     watch the live screen (read-only)\n"
          "  attach      attach interactively (Ctrl-] to detach)\n"
          "\n"
          "  sessions    list local control sessions\n"
          "  info        show session status\n"
          "  gc          remove dead session sockets\n"
          "\n"
          "  -h, --help     show this overview (or `etctl <command> --help`)\n"
          "  -v, --version  print the etctl version\n");
}

string resolveSocketPath(const string& nameOrPath) {
  struct stat st;
  if (::stat(nameOrPath.c_str(), &st) == 0 && S_ISSOCK(st.st_mode)) {
    return nameOrPath;
  }
  return control_paths::socketPathForName(nameOrPath);
}

int connectControl(const string& name) {
  string path = resolveSocketPath(name);
  int fd = ::socket(AF_UNIX, SOCK_STREAM, 0);
  if (fd < 0) {
    return -1;
  }
  sockaddr_un addr;
  memset(&addr, 0, sizeof(addr));
  addr.sun_family = AF_UNIX;
  if (path.size() >= sizeof(addr.sun_path)) {
    ::close(fd);
    return -1;
  }
  strncpy(addr.sun_path, path.c_str(), sizeof(addr.sun_path) - 1);
  if (::connect(fd, (sockaddr*)&addr, sizeof(addr)) < 0) {
    ::close(fd);
    return -1;
  }
  return fd;
}

/*
 * One request, one response.  Returns false if the session is unreachable or
 * replied with an error; prints a diagnostic unless `quiet` (streaming readers
 * pass quiet and report their own clean "session ended" instead).
 */
bool oneShot(const string& name, uint8_t opcode, const string& payload,
             uint8_t* respOpcode, string* respPayload, bool quiet = false) {
  int fd = connectControl(name);
  if (fd < 0) {
    if (!quiet)
      fprintf(stderr, "etctl: cannot reach session '%s' (%s)\n", name.c_str(),
              strerror(errno));
    return false;
  }
  bool ok = false;
  try {
    control_proto::writeFrame(fd, opcode, payload);
    ok = control_proto::readFrame(fd, respOpcode, respPayload);
  } catch (const std::exception& e) {
    if (!quiet)
      fprintf(stderr, "etctl: io error talking to '%s': %s\n", name.c_str(),
              e.what());
  }
  ::close(fd);
  if (!ok) {
    if (!quiet) fprintf(stderr, "etctl: no response from '%s'\n", name.c_str());
    return false;
  }
  if (*respOpcode == CTL_ERR) {
    if (!quiet) fprintf(stderr, "etctl: %s\n", respPayload->c_str());
    return false;
  }
  return true;
}

string stripAnsi(const string& in) {
  // CSI sequences, OSC sequences, and lone escapes / carriage returns.
  static const std::regex csi("\x1b\\[[0-9;?]*[ -/]*[@-~]");
  static const std::regex osc("\x1b\\][^\x07\x1b]*(\x07|\x1b\\\\)");
  static const std::regex other("\x1b[@-Z\\\\-_]");
  string s = std::regex_replace(in, osc, "");
  s = std::regex_replace(s, csi, "");
  s = std::regex_replace(s, other, "");
  s.erase(std::remove(s.begin(), s.end(), '\r'), s.end());
  return s;
}

// Escape bytes the way Python shows a bytes literal, so `sniff` output is both
// human-readable and unambiguous: every byte round-trips, and because newlines
// become "\n" each record stays on a single line.  The result is a valid Python
// bytes-literal body, so a consumer can recover the exact bytes with e.g.
// ast.literal_eval("b'" + payload + "'").
string escapeBytes(const string& in) {
  static const char* kHex = "0123456789abcdef";
  string out;
  for (unsigned char c : in) {
    if (c == '\\') {
      out += "\\\\";
    } else if (c == '\'') {
      out += "\\'";
    } else if (c == '\n') {
      out += "\\n";
    } else if (c == '\r') {
      out += "\\r";
    } else if (c == '\t') {
      out += "\\t";
    } else if (c >= 0x20 && c < 0x7f) {
      out += (char)c;
    } else {
      out += "\\x";
      out += kHex[c >> 4];
      out += kHex[c & 0xf];
    }
  }
  return out;
}

// Named keys -> the byte sequences a real terminal would send.
string keyToBytes(const string& key) {
  if (key == "enter" || key == "return") return "\r";
  if (key == "tab") return "\t";
  if (key == "esc" || key == "escape") return "\x1b";
  if (key == "space") return " ";
  if (key == "backspace") return "\x7f";
  if (key == "interrupt") return "\x03";  // Ctrl-C
  if (key == "eof") return "\x04";         // Ctrl-D (EOF on input)
  if (key == "up") return "\x1b[A";
  if (key == "down") return "\x1b[B";
  if (key == "right") return "\x1b[C";
  if (key == "left") return "\x1b[D";
  if (key == "home") return "\x1b[H";
  if (key == "end") return "\x1b[F";
  if (key == "pageup") return "\x1b[5~";
  if (key == "pagedown") return "\x1b[6~";
  if (key == "delete" || key == "del") return "\x1b[3~";
  if (key == "insert") return "\x1b[2~";
  if (key.size() >= 2 && (key[0] == 'f' || key[0] == 'F')) {
    int n = atoi(key.c_str() + 1);
    switch (n) {
      case 1: return "\x1bOP";
      case 2: return "\x1bOQ";
      case 3: return "\x1bOR";
      case 4: return "\x1bOS";
      case 5: return "\x1b[15~";
      case 6: return "\x1b[17~";
      case 7: return "\x1b[18~";
      case 8: return "\x1b[19~";
      case 9: return "\x1b[20~";
      case 10: return "\x1b[21~";
      case 11: return "\x1b[23~";
      case 12: return "\x1b[24~";
      default: break;
    }
  }
  // ^X style control char, e.g. "^c" -> 0x03.
  if (key.size() == 2 && key[0] == '^') {
    char c = (char)(toupper(key[1]) - '@');
    return string(1, c);
  }
  // A single character is sent literally (e.g. vim's "i", "x", ":").
  if (key.size() == 1) {
    return key;
  }
  return "";  // unknown key name
}

string readAllStdin() {
  string data;
  char buf[4096];
  ssize_t rc;
  while ((rc = ::read(STDIN_FILENO, buf, sizeof(buf))) > 0) {
    data.append(buf, rc);
  }
  return data;
}

// --- commands ---------------------------------------------------------------

// Quiet liveness check: a socket that accepts a connection has a live daemon.
bool sessionAlive(const string& name) {
  int fd = connectControl(name);
  if (fd < 0) {
    return false;
  }
  ::close(fd);
  return true;
}

// Block until a session stops accepting connections (its daemon has exited and
// unlinked the socket), or the timeout elapses.  Returns true if it is gone.
// This makes "end then recreate the same NAME" deterministic: teardown is
// otherwise asynchronous (eof/kill return before the daemon finishes dying), so
// a too-soon `open` can see the still-live daemon and no-op.
bool waitSessionGone(const string& name, double secs) {
  const auto deadline =
      std::chrono::steady_clock::now() +
      std::chrono::milliseconds((long long)(secs * 1000));
  while (sessionAlive(name)) {
    if (std::chrono::steady_clock::now() >= deadline) {
      return false;
    }
    ::usleep(100 * 1000);
  }
  return true;
}

int64_t sessionField(const string& name, const string& key);  // defined below
int cmdWrite(const string& name, const string& bytes, bool secret);  // defined below
int cmdKill(const string& name, double waitSecs);                    // defined below

// Fetch a session's full info as a key=value map (one CTL_INFO round-trip).
std::map<string, string> sessionInfo(const string& name) {
  std::map<string, string> m;
  uint8_t op = 0;
  string payload;
  if (!oneShot(name, CTL_INFO, "", &op, &payload)) {
    return m;
  }
  std::istringstream ss(payload);
  string line;
  while (std::getline(ss, line)) {
    size_t eq = line.find('=');
    if (eq != string::npos) {
      m[line.substr(0, eq)] = line.substr(eq + 1);
    }
  }
  return m;
}

string humanizeDuration(int64_t s) {
  if (s < 0) s = 0;
  int64_t d = s / 86400;
  int64_t h = (s % 86400) / 3600;
  int64_t m = (s % 3600) / 60;
  int64_t sec = s % 60;
  char buf[64];
  if (d) {
    snprintf(buf, sizeof(buf), "%lldd%lldh", (long long)d, (long long)h);
  } else if (h) {
    snprintf(buf, sizeof(buf), "%lldh%lldm", (long long)h, (long long)m);
  } else if (m) {
    snprintf(buf, sizeof(buf), "%lldm%llds", (long long)m, (long long)sec);
  } else {
    snprintf(buf, sizeof(buf), "%llds", (long long)sec);
  }
  return string(buf);
}

// Parse a duration like "30m", "6h", "2d", "90s", or a bare number (seconds).
int64_t parseDuration(const string& s, int64_t fallback) {
  if (s.empty()) return fallback;
  char* end = nullptr;
  const double n = strtod(s.c_str(), &end);
  if (end == s.c_str()) return fallback;
  int64_t mult = 1;
  switch (*end) {
    case 'm': mult = 60; break;
    case 'h': mult = 3600; break;
    case 'd': mult = 86400; break;
    default: mult = 1; break;  // 's' or none
  }
  return (int64_t)(n * (double)mult);
}

int cmdGc(int argc, char** argv) {
  bool idle = false, force = false;
  int64_t idleSecs = 8 * 3600;  // default --idle threshold (8h)
  for (int i = 2; i < argc; i++) {
    const string a = argv[i];
    if (a == "-h" || a == "--help") {
      printf(
          "etctl gc [--idle [DUR]] [--force]\n"
          "  Remove dead session sockets (a daemon that has exited leaves a\n"
          "  stale socket).  With --idle, also end live sessions idle longer\n"
          "  than DUR (default 8h; e.g. 30m, 6h, 2d): eof first, then a forced\n"
          "  stop if it doesn't exit within a few seconds.  --force skips the\n"
          "  graceful eof and stops idle sessions outright.\n");
      return 0;
    } else if (a == "--idle") {
      idle = true;
      if (i + 1 < argc && argv[i + 1][0] != '-') {
        idleSecs = parseDuration(argv[++i], idleSecs);
      }
    } else if (a.rfind("--idle=", 0) == 0) {
      idle = true;
      idleSecs = parseDuration(a.substr(strlen("--idle=")), idleSecs);
    } else if (a == "--force" || a == "--kill") {
      force = true;
    }
  }

  // First, reap live sessions idle past the threshold (so their sockets go
  // dead and get swept below). eof is graceful; fall back to a forced stop.
  if (idle) {
    const string eof(1, '\004');  // Ctrl-D ends the remote shell cleanly
    const int64_t now = (int64_t)time(NULL);
    for (const string& name : control_paths::listSessionNames()) {
      if (!sessionAlive(name)) continue;
      const int64_t last = sessionField(name, "lastActivity");
      if (last <= 0 || (now - last) < idleSecs) continue;
      if (force) {
        printf("stopping idle session: %s\n", name.c_str());
        cmdKill(name, 0.0);
      } else {
        printf("ending idle session: %s\n", name.c_str());
        cmdWrite(name, eof, false);
        if (!waitSessionGone(name, 3.0)) {
          cmdKill(name, 0.0);  // didn't exit gracefully: force-stop
        }
      }
    }
  }

  // Sweep dead sockets: originally-dangling ones plus any just reaped.
  for (const string& name : control_paths::listSessionNames()) {
    if (sessionAlive(name)) continue;
    const string path = control_paths::socketPathForName(name);
    if (::unlink(path.c_str()) == 0) {
      printf("removed dead socket: %s\n", name.c_str());
    } else if (errno != ENOENT) {
      fprintf(stderr, "etctl gc: could not remove %s: %s\n", path.c_str(),
              strerror(errno));
    }
  }
  return 0;
}

int cmdSessions() {
  vector<string> names = control_paths::listSessionNames();
  struct Row {
    string name, host, status, up, idle;
  };
  vector<Row> rows;
  const int64_t now = (int64_t)time(NULL);
  for (const string& name : names) {
    std::map<string, string> in = sessionInfo(name);
    if (in.empty()) {
      rows.push_back({name, "-", "dead", "-", "-"});
      continue;
    }
    const bool connected = in["connected"] == "1";
    int64_t created = in.count("created") ? atoll(in["created"].c_str()) : -1;
    int64_t last = in.count("lastActivity") ? atoll(in["lastActivity"].c_str()) : -1;
    rows.push_back({name,
                    in.count("host") && !in["host"].empty() ? in["host"] : "-",
                    connected ? "connected" : "disconnected",
                    created > 0 ? humanizeDuration(now - created) : "-",
                    last > 0 ? humanizeDuration(now - last) : "-"});
  }
  if (rows.empty()) {
    return 0;
  }
  // Size each column to its widest cell (header included) for a clean table.
  size_t wN = 4, wH = 4, wS = 6, wU = 2;  // NAME HOST STATUS UP
  for (const Row& r : rows) {
    wN = std::max(wN, r.name.size());
    wH = std::max(wH, r.host.size());
    wS = std::max(wS, r.status.size());
    wU = std::max(wU, r.up.size());
  }
  printf("%-*s  %-*s  %-*s  %-*s  %s\n", (int)wN, "NAME", (int)wH, "HOST",
         (int)wS, "STATUS", (int)wU, "UP", "IDLE");
  for (const Row& r : rows) {
    printf("%-*s  %-*s  %-*s  %-*s  %s\n", (int)wN, r.name.c_str(), (int)wH,
           r.host.c_str(), (int)wS, r.status.c_str(), (int)wU, r.up.c_str(),
           r.idle.c_str());
  }
  return 0;
}

int cmdInfo(const string& name) {
  uint8_t op = 0;
  string payload;
  if (!oneShot(name, CTL_INFO, "", &op, &payload)) {
    return 1;
  }
  fputs(payload.c_str(), stdout);
  return 0;
}

int cmdRead(const string& name, int64_t cursor, bool strip, bool follow,
            double timeoutSec) {
  auto emit = [&](const ScrollbackRead& r) {
    if (r.truncated) {
      fprintf(stderr,
              "etctl: warning: cursor fell behind; output gap skipped\n");
    }
    const string out = strip ? stripAnsi(r.data) : r.data;
    if (!out.empty()) {
      fwrite(out.data(), 1, out.size(), stdout);
      fflush(stdout);
    }
  };

  if (follow) {
    while (true) {
      uint8_t op = 0;
      string payload;
      if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
                   &payload, /*quiet=*/true)) {
        fprintf(stderr, "[session ended]\n");
        return 0;
      }
      ScrollbackRead r = control_proto::decodeReadResp(payload);
      emit(r);
      cursor = r.nextCursor;
      ::usleep(150 * 1000);
    }
  }

  if (timeoutSec > 0) {
    /*
     * Wait up to timeoutSec for new output; once it starts, keep reading until
     * a brief quiet gap, then return (etch read() semantics).
     */
    const auto deadline =
        std::chrono::steady_clock::now() +
        std::chrono::milliseconds((long long)(timeoutSec * 1000));
    auto lastData = std::chrono::steady_clock::now();
    bool got = false;
    while (std::chrono::steady_clock::now() < deadline) {
      uint8_t op = 0;
      string payload;
      if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
                   &payload)) {
        return 1;
      }
      ScrollbackRead r = control_proto::decodeReadResp(payload);
      cursor = r.nextCursor;
      if (!r.data.empty()) {
        emit(r);
        got = true;
        lastData = std::chrono::steady_clock::now();
      } else if (got && std::chrono::steady_clock::now() - lastData >
                            std::chrono::milliseconds(300)) {
        break;  // output settled
      }
      ::usleep(50 * 1000);
    }
    fprintf(stderr, "next-cursor: %lld\n", (long long)cursor);
    return 0;
  }

  // Single non-blocking read.
  uint8_t op = 0;
  string payload;
  if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
               &payload)) {
    return 1;
  }
  ScrollbackRead r = control_proto::decodeReadResp(payload);
  emit(r);
  fprintf(stderr, "next-cursor: %lld\n", (long long)r.nextCursor);
  return 0;
}

int cmdWrite(const string& name, const string& bytes, bool secret = false) {
  uint8_t op = 0;
  string payload;
  if (!oneShot(name, secret ? CTL_WRITE_SECRET : CTL_WRITE, bytes, &op,
               &payload)) {
    return 1;
  }
  return 0;
}

int cmdResize(const string& name, int rows, int cols) {
  TerminalInfo ti;
  ti.set_row(rows);
  ti.set_column(cols);
  ti.set_width(0);
  ti.set_height(0);
  string payload;
  ti.SerializeToString(&payload);
  uint8_t op = 0;
  string resp;
  if (!oneShot(name, CTL_RESIZE, payload, &op, &resp)) {
    return 1;
  }
  return 0;
}

int cmdKill(const string& name, double waitSecs) {
  uint8_t op = 0;
  string payload;
  if (!oneShot(name, CTL_KILL, "", &op, &payload)) {
    return 1;
  }
  if (waitSecs > 0 && !waitSessionGone(name, waitSecs)) {
    fprintf(stderr, "etctl: session '%s' still alive %.0fs after kill\n",
            name.c_str(), waitSecs);
    return 1;
  }
  return 0;
}

int64_t sessionField(const string& name, const string& key) {
  uint8_t op = 0;
  string payload;
  if (!oneShot(name, CTL_INFO, "", &op, &payload)) {
    return -1;
  }
  const string prefix = key + "=";
  std::istringstream ss(payload);
  string line;
  while (std::getline(ss, line)) {
    if (line.rfind(prefix, 0) == 0) {
      return atoll(line.c_str() + prefix.size());
    }
  }
  return -1;
}

int64_t sessionHeadCursor(const string& name) {
  return sessionField(name, "headCursor");
}

int cmdExpect(const string& name, const string& pattern, double timeoutSec,
              bool fromStart, bool exact, int64_t startCursor) {
  std::regex re;
  if (!exact) {
    try {
      re = std::regex(pattern);
    } catch (const std::exception& e) {
      fprintf(stderr, "etctl: bad pattern: %s\n", e.what());
      return 2;
    }
  }
  // An explicit --cursor wins; else --from-start scans all retained output;
  // else watch for output produced from now on.  Capturing a cursor (info
  // headCursor) before sending input and passing it here avoids the race where
  // the awaited text lands between the write and a head-anchored expect.
  int64_t cursor =
      startCursor >= 0 ? startCursor : (fromStart ? 0 : sessionHeadCursor(name));
  if (cursor < 0) cursor = 0;
  string acc;
  const auto deadline =
      std::chrono::steady_clock::now() +
      std::chrono::milliseconds((long long)(timeoutSec * 1000));
  while (std::chrono::steady_clock::now() < deadline) {
    uint8_t op = 0;
    string payload;
    if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
                 &payload)) {
      return 2;
    }
    ScrollbackRead r = control_proto::decodeReadResp(payload);
    cursor = r.nextCursor;
    acc += stripAnsi(r.data);
    bool matched = exact ? (acc.find(pattern) != string::npos)
                         : std::regex_search(acc, re);
    if (matched) {
      fwrite(acc.data(), 1, acc.size(), stdout);
      if (acc.empty() || acc.back() != '\n') printf("\n");
      fprintf(stderr, "next-cursor: %lld\n", (long long)cursor);
      return 0;
    }
    ::usleep(100 * 1000);
  }
  fprintf(stderr, "etctl: timed out waiting for %s%s%s\n", exact ? "\"" : "/",
          pattern.c_str(), exact ? "\"" : "/");
  return 1;
}

int cmdSniff(const string& name, bool follow, int64_t startCursor, bool tail) {
  // Tap the byte exchange, one record per line: "» <input>" / "« <output>".
  // Both directions are escaped (Python bytes-literal style) so the dump is
  // unambiguous and a script can recover the exact bytes per line.  The cursor
  // lives in the transcript's own offset space (distinct from the scrollback's,
  // so it is not the headCursor `info` reports): -1 (default) is the oldest
  // retained record, an explicit --cursor offset starts there, and --tail starts
  // at the current head so only new records show.
  int64_t cursor = startCursor;
  if (tail) {
    // Read once just to learn the current transcript head, discarding records.
    uint8_t op = 0;
    string payload;
    if (!oneShot(name, CTL_SNIFF, control_proto::encodeCursor(-1), &op,
                 &payload)) {
      return 1;
    }
    cursor = control_proto::decodeTranscriptResp(payload).nextCursor;
  }
  bool any = false;
  do {
    uint8_t op = 0;
    string payload;
    if (!oneShot(name, CTL_SNIFF, control_proto::encodeCursor(cursor), &op,
                 &payload)) {
      return 1;
    }
    TranscriptRead tr = control_proto::decodeTranscriptResp(payload);
    if (tr.truncated && !any) {
      fprintf(stderr, "etctl: warning: sniff cursor fell behind; gap skipped\n");
    }
    for (const TranscriptRecord& rec : tr.records) {
      any = true;
      const char* mark = rec.dir == '>' ? "\xc2\xbb" : "\xc2\xab";  // » / «
      printf("%s %s\n", mark, escapeBytes(rec.bytes).c_str());
    }
    fflush(stdout);
    cursor = tr.nextCursor;
    if (follow) {
      ::usleep(150 * 1000);
    }
  } while (follow);
  // Report where to resume (transcript-space), so a script can pass it back via
  // --cursor.  Only meaningful for a one-shot read; --follow never returns here.
  fprintf(stderr, "next-cursor: %lld\n", (long long)cursor);
  return 0;
}

int cmdWait(const string& name, double idleSec, double timeoutSec) {
  // Return once the session output has been quiet for idleSec, or fail after
  // timeoutSec. Useful after sending input, to let an app settle before reading.
  int64_t cursor = sessionHeadCursor(name);
  if (cursor < 0) cursor = 0;
  const auto start = std::chrono::steady_clock::now();
  auto lastData = start;
  while (true) {
    auto now = std::chrono::steady_clock::now();
    if (now - start >
        std::chrono::milliseconds((long long)(timeoutSec * 1000))) {
      fprintf(stderr, "etctl: wait timed out after %.1fs\n", timeoutSec);
      return 1;
    }
    uint8_t op = 0;
    string payload;
    if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
                 &payload)) {
      return 2;
    }
    ScrollbackRead r = control_proto::decodeReadResp(payload);
    cursor = r.nextCursor;
    if (!r.data.empty()) {
      lastData = now;
    } else if (now - lastData >=
               std::chrono::milliseconds((long long)(idleSec * 1000))) {
      return 0;
    }
    ::usleep(50 * 1000);
  }
}

int cmdAttach(const string& name, bool readOnly, int64_t startCursor,
              bool resize) {
  /*
   * Best-effort interactive attach: stream output to stdout and (unless
   * read-only) forward stdin as input.  The local terminal renders full-screen
   * apps.  In read-only mode keystrokes are swallowed -- only Ctrl-C or Ctrl-]
   * detach -- so an observer can watch without disturbing the session.
   *
   * startCursor selects where to begin: -1 (default) replays the retained
   * scrollback so an observer sees recent context, an explicit offset starts
   * there, and the head cursor (via --tail) shows only what comes next.
   *
   * On start and on every SIGWINCH we push the local terminal size to the
   * session (both attach and observe), so the remote shell and full-screen apps
   * lay out for the viewer's actual width; otherwise cursor-addressed redraws
   * sized for the session's default 80x24 paint over the wrong lines here.
   */
  int64_t cursor = startCursor;

  termios orig;
  bool raw = false;
  if (isatty(STDIN_FILENO) && tcgetattr(STDIN_FILENO, &orig) == 0) {
    termios t = orig;
    cfmakeraw(&t);
    tcsetattr(STDIN_FILENO, TCSANOW, &t);
    raw = true;
  }

  // Match the session to this terminal up front, then on each resize (below),
  // unless --no-resize was passed.
  if (raw && resize) {
    struct sigaction sa = {};
    sigemptyset(&sa.sa_mask);
    sa.sa_handler = onWinch;
    sa.sa_flags = SA_RESTART;
    sigaction(SIGWINCH, &sa, nullptr);
    g_winchPending = 1;  // force the initial size sync on the first loop pass
  }
  /*
   * Ctrl-] detaches locally without forwarding it or ending the session.  In
   * attach (read-write) mode every other key (Ctrl-C, Ctrl-D, ...) is forwarded
   * to the remote, so use Ctrl-] to leave; in observe (read-only) mode input is
   * swallowed and Ctrl-C also detaches, since there is nothing to forward it to.
   */
  const char kDetach = 0x1d;   // Ctrl-]
  const char kIntr = 0x03;     // Ctrl-C (a local quit in read-only observe)
  const char* detachHint = readOnly ? "Ctrl-C or Ctrl-]" : "Ctrl-]";
  fprintf(stderr, "[etctl %s '%s' -- press %s to detach]\r\n",
          readOnly ? "observe" : "attach", name.c_str(), detachHint);

  int rc = 0;
  bool detached = false;
  while (!detached) {
    // A pending SIGWINCH (or the initial sync): push the live terminal size to
    // the session so its layout matches what we render here.
    if (g_winchPending) {
      g_winchPending = 0;
      struct winsize ws;
      if (ioctl(STDIN_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_row > 0) {
        TerminalInfo ti;
        ti.set_row(ws.ws_row);
        ti.set_column(ws.ws_col);
        ti.set_width(ws.ws_xpixel);
        ti.set_height(ws.ws_ypixel);
        string rzPayload, rzResp;
        ti.SerializeToString(&rzPayload);
        uint8_t rzOp = 0;
        oneShot(name, CTL_RESIZE, rzPayload, &rzOp, &rzResp, /*quiet=*/true);
      }
    }
    uint8_t op = 0;
    string payload;
    if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
                 &payload, /*quiet=*/true)) {
      fprintf(stderr, "\r\n[session ended]\r\n");
      rc = 0;
      break;
    }
    ScrollbackRead r = control_proto::decodeReadResp(payload);
    cursor = r.nextCursor;
    if (!r.data.empty()) {
      fwrite(r.data.data(), 1, r.data.size(), stdout);
      fflush(stdout);
    }

    fd_set rfds;
    FD_ZERO(&rfds);
    FD_SET(STDIN_FILENO, &rfds);
    timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 100 * 1000;
    if (select(STDIN_FILENO + 1, &rfds, NULL, NULL, &tv) > 0 &&
        FD_ISSET(STDIN_FILENO, &rfds)) {
      char buf[4096];
      ssize_t n = ::read(STDIN_FILENO, buf, sizeof(buf));
      if (n > 0) {
        /*
         * Forward up to a detach byte; anything after it is dropped and we
         * leave without sending it to the remote.  In read-only observe the
         * bytes are never forwarded, and Ctrl-C counts as a detach too.
         */
        ssize_t k = 0;
        while (k < n && buf[k] != kDetach && !(readOnly && buf[k] == kIntr)) {
          k++;
        }
        if (k > 0 && !readOnly) {
          cmdWrite(name, string(buf, k));
        }
        if (k < n) {
          detached = true;
          fprintf(stderr, "\r\n[detached]\r\n");
        }
      } else if (n == 0) {
        break;  // local stdin closed
      }
    }
  }

  if (raw) {
    tcsetattr(STDIN_FILENO, TCSANOW, &orig);
  }
  return rc;
}

int cmdAttach(const string& name, bool readOnly, int64_t startCursor,
              bool resize);

/*
 * run(): send a command and collect its clean stdout + real exit code, the way
 * etch.run does.  We frame the command with unique start/end sentinels and parse
 * the exit code the shell prints after it.  This assumes a cooperating
 * line-oriented shell on the far side; full-screen output is for read/observe.
 * (Validated against a live et session, not the in-process echo harness, which
 * does not execute commands.)
 */
/*
 * Run a command and collect its clean output + real exit code.  If `bodyOut` is
 * non-null the body is captured there (for internal callers like put); otherwise
 * it is written to stdout.
 */
int runCommand(const string& name, const string& command, double timeoutSec,
               string* bodyOut) {
  string tag;
  std::random_device rd;
  static const char* kHex = "0123456789abcdef";
  for (int i = 0; i < 8; i++) tag.push_back(kHex[rd() % 16]);
  const string startMark = "ETCTL_S_" + tag;
  const string endMark = "ETCTL_E_" + tag;

  int64_t cursor = sessionHeadCursor(name);
  if (cursor < 0) cursor = 0;

  // printf the start marker, run the command, printf the end marker + $?.
  string framed = "printf '%s\\n' '" + startMark + "'; " + command +
                  "; printf '" + endMark + ":%d\\n' \"$?\"\n";
  if (cmdWrite(name, framed) != 0) {
    return 2;
  }

  // The end marker is "<endMark>:<code>\n". Anchoring on the trailing newline
  // (\r? tolerates the PTY's ONLCR) ensures we only match once the *whole* exit
  // code has arrived; without it, a chunked read could match a truncated code.
  std::regex endRe(endMark + ":([0-9]+)\\r?\\n");
  string acc;
  const auto deadline =
      std::chrono::steady_clock::now() +
      std::chrono::milliseconds((long long)(timeoutSec * 1000));
  while (std::chrono::steady_clock::now() < deadline) {
    uint8_t op = 0;
    string payload;
    if (!oneShot(name, CTL_READ, control_proto::encodeCursor(cursor), &op,
                 &payload)) {
      return 2;
    }
    ScrollbackRead r = control_proto::decodeReadResp(payload);
    cursor = r.nextCursor;
    acc += stripAnsi(r.data);

    std::smatch m;
    if (std::regex_search(acc, m, endRe)) {
      int code = atoi(m[1].str().c_str());
      /*
       * The real end marker is where the regex matched (the echoed command line
       * contains "<endMark>:%d", which has no digit after the ':' and never
       * matches here).
       */
      size_t endPos = (size_t)m.position(0);
      /*
       * The real start marker is printed on its own line ("<startMark>\n"); the
       * echoed command instead contains "'<startMark>'", so anchoring on the
       * trailing newline skips the echo and the interactive prompt before it.
       */
      const string startLine = startMark + "\n";
      size_t sp = acc.find(startLine);
      size_t bodyStart =
          (sp != string::npos && sp + startLine.size() <= endPos)
              ? sp + startLine.size()
              : 0;
      string body = acc.substr(bodyStart, endPos - bodyStart);
      if (bodyOut) {
        *bodyOut = body;
      } else {
        fwrite(body.data(), 1, body.size(), stdout);
      }
      return code;
    }
    ::usleep(80 * 1000);
  }
  fprintf(stderr, "etctl: run timed out after %.1fs\n", timeoutSec);
  return 124;
}

int cmdRun(const string& name, const string& command, double timeoutSec) {
  return runCommand(name, command, timeoutSec, nullptr);
}

int cmdOpen(int argc, char** argv) {
  /*
   * etctl open NAME [et-args...]  ->  et --ctl --name NAME [et-args...]
   *
   * NAME is a positional (consistent with the other verbs); etctl owns it and
   * translates it to et's --name.  The call is idempotent: if NAME is already a
   * live session, do nothing.  That makes `open` a cheap "ensure this session
   * exists" step you can safely run before driving it, which is the clean
   * version of etch's autospawn -- the connection details live only here, not on
   * every command.
   */
  if (argc < 3) {
    fprintf(stderr,
            "etctl open: NAME required (etctl open NAME [et-args...])\n");
    return 2;
  }
  string name = argv[2];

  // Respect a custom socket override for the liveness check, and note the
  // requested destination (the trailing positional) so we can guard against
  // reusing a name that points at a different host.
  string checkTarget = name;
  string requestedDest;
  string userCommand;
  vector<bool> skip(argc, false);
  for (int i = 3; i < argc; i++) {
    string a = argv[i];
    if (a == "--ctl-socket" && i + 1 < argc) {
      checkTarget = argv[i + 1];
      i++;
    } else if (a.rfind("--ctl-socket=", 0) == 0) {
      checkTarget = a.substr(strlen("--ctl-socket="));
    } else if (a == "--name" && i + 1 < argc) {
      i++;  // skip et's --name value, it isn't the destination
    } else if ((a == "-c" || a == "--command") && i + 1 < argc) {
      // Pull out a user-supplied connect command so we can merge it with our
      // own setup (below) rather than fight over et's single -c.  Marking its
      // tokens to skip also keeps the value from being mistaken for the
      // destination by the bare-positional branch.
      userCommand = argv[i + 1];
      skip[i] = true;
      skip[i + 1] = true;
      i++;
    } else if (a.rfind("--command=", 0) == 0) {
      userCommand = a.substr(strlen("--command="));
      skip[i] = true;
    } else if (!a.empty() && a[0] != '-') {
      requestedDest = a;  // last bare positional wins (et's destination)
    }
  }
  if (sessionAlive(checkTarget)) {
    // Reusing a live session is the point of idempotent open -- but only if it
    // is the same host.  A name pointing at a different host is almost always a
    // collision (two actors picked the same name), so fail loudly instead of
    // silently driving the wrong box.
    const string existingHost = sessionInfo(checkTarget)["host"];
    auto hostPart = [](string s) {
      size_t at = s.find('@');
      if (at != string::npos) s = s.substr(at + 1);
      size_t colon = s.find(':');
      if (colon != string::npos) s = s.substr(0, colon);
      return s;
    };
    const bool looksLikeDest = requestedDest.find('@') != string::npos ||
                               requestedDest.find('.') != string::npos;
    if (looksLikeDest && !existingHost.empty() &&
        hostPart(requestedDest) != hostPart(existingHost)) {
      fprintf(stderr,
              "etctl: session '%s' is connected to %s, not %s -- pick a "
              "different name (e.g. add a unique suffix)\n",
              name.c_str(), existingHost.c_str(), requestedDest.c_str());
      return 2;
    }
    fprintf(stderr, "etctl: session '%s' already running (%s)\n", name.c_str(),
            existingHost.empty() ? "?" : existingHost.c_str());
    return 0;
  }

  string etPath = "et";
  string self = argv[0];
  size_t slash = self.find_last_of('/');
  if (slash != string::npos) {
    string sibling = self.substr(0, slash + 1) + "et";
    if (::access(sibling.c_str(), X_OK) == 0) {
      etPath = sibling;  // prefer the et next to this etctl (dev/build trees)
    }
  }
  // Stamp every control session with ETCTL_SESSION=<name> via et's connect-time
  // command (which runs once in the persistent --ctl shell).  This lets the
  // remote shell -- prompt, scripts, anything -- know it is being driven by
  // etctl, and which session it is.  A user-supplied -c is merged in after it.
  string setupCommand = "export ETCTL_SESSION='" + name + "'";
  if (!userCommand.empty()) {
    setupCommand += "; " + userCommand;
  }

  vector<char*> args;
  args.push_back(strdup(etPath.c_str()));
  args.push_back(strdup("--ctl"));
  args.push_back(strdup("--name"));
  args.push_back(strdup(name.c_str()));
  for (int i = 3; i < argc; i++) {
    if (skip[i]) continue;  // user's -c is folded into setupCommand below
    args.push_back(strdup(argv[i]));
  }
  args.push_back(strdup("--command"));
  args.push_back(strdup(setupCommand.c_str()));
  args.push_back(nullptr);
  execvp(args[0], args.data());
  fprintf(stderr, "etctl open: could not exec et (%s): %s\n", etPath.c_str(),
          strerror(errno));
  return 127;
}

}  // namespace

int main(int argc, char** argv) {
  if (argc < 2) {
    printOverview();
    return 2;
  }
  string cmd = argv[1];

  // Make Ctrl-C exit cleanly instead of tripping easyloggingpp's crash handler.
  installInterruptHandler();

  if (cmd == "-h" || cmd == "--help") {
    printOverview();
    return 0;
  }
  if (cmd == "-v" || cmd == "--version" || cmd == "version") {
    printf("etctl version %s\n", ET_VERSION);
    return 0;
  }
  if (cmd == "help") {
    if (argc > 2 && !descFor(argv[2]).empty()) {
      fputs(buildOptions(argv[2]).help({""}).c_str(), stdout);
    } else {
      printOverview();
    }
    return 0;
  }
  if (cmd == "open") {
    for (int i = 2; i < argc; i++) {
      string a = argv[i];
      if (a == "-h" || a == "--help") {
        printf(
            "etctl open NAME [et-args...]\n"
            "  Ensure a control session named NAME exists: if it's already\n"
            "  running, do nothing; otherwise start it with `et --ctl --name\n"
            "  NAME <et-args>` (e.g. host, --ctl-socket PATH, -t tunnels). See\n"
            "  `et --help`. Idempotent, so it's safe to run before each use.\n");
        return 0;
      }
    }
    return cmdOpen(argc, argv);
  }
  if (cmd == "gc") {
    return cmdGc(argc, argv);
  }
  if (descFor(cmd).empty()) {
    fprintf(stderr, "etctl: unknown command '%s'\n", cmd.c_str());
    printOverview();
    return 2;
  }

  cxxopts::Options opts = buildOptions(cmd);
  cxxopts::ParseResult res;
  try {
    res = opts.parse(argc - 1, argv + 1);
  } catch (const std::exception& e) {
    fprintf(stderr, "etctl %s: %s\n", cmd.c_str(), e.what());
    return 2;
  }
  if (res.count("help")) {
    fputs(opts.help({""}).c_str(), stdout);
    return 0;
  }

  if (cmd == "sessions") return cmdSessions();

  if (!res.count("NAME")) {
    fprintf(stderr, "etctl %s: missing session NAME\n", cmd.c_str());
    return 2;
  }
  string name = res["NAME"].as<string>();

  if (cmd == "info") return cmdInfo(name);
  if (cmd == "kill")
    return cmdKill(name, res.count("wait") ? res["wait"].as<double>() : 0.0);
  if (cmd == "observe" || cmd == "attach") {
    int64_t cursor = res.count("tail")     ? sessionHeadCursor(name)
                     : res.count("cursor") ? res["cursor"].as<long long>()
                                           : -1;
    return cmdAttach(name, /*readOnly=*/cmd == "observe", cursor,
                     /*resize=*/res.count("no-resize") == 0);
  }
  if (cmd == "read") {
    int64_t cursor = res.count("cursor") ? res["cursor"].as<long long>() : -1;
    double timeout = res.count("timeout") ? res["timeout"].as<double>() : 0.0;
    return cmdRead(name, cursor, res.count("strip") > 0, res.count("follow") > 0,
                   timeout);
  }
  if (cmd == "sniff") {
    int64_t cursor = res.count("cursor") ? res["cursor"].as<long long>() : -1;
    return cmdSniff(name, res.count("follow") > 0, cursor, res.count("tail") > 0);
  }
  if (cmd == "wait") {
    return cmdWait(name, res["idle"].as<double>(), res["timeout"].as<double>());
  }
  if (cmd == "write") {
    string bytes;
    bool secret = res.count("secret") > 0;
    if (secret) {
      char* pw = getpass("input (hidden): ");
      bytes = pw ? string(pw) : string();
    } else {
      bytes = readAllStdin();
    }
    return cmdWrite(name, bytes, secret);
  }
  if (cmd == "writeln") {
    string text = res.count("TEXT") ? res["TEXT"].as<string>() : string();
    bool secret = res.count("secret") > 0;
    if (secret) {
      char* pw = getpass("input (hidden): ");
      text = pw ? string(pw) : string();
    }
    return cmdWrite(name, text + "\n", secret);
  }
  if (cmd == "key") {
    string bytes;
    for (const string& k : res["KEYS"].as<vector<string>>()) {
      string b = keyToBytes(k);
      if (b.empty()) {
        fprintf(stderr, "etctl: unknown key '%s'\n", k.c_str());
        return 2;
      }
      bytes += b;
    }
    return cmdWrite(name, bytes);
  }
  if (cmd == "run") {
    if (!res.count("CMD")) {
      fprintf(stderr, "etctl run: missing CMD\n");
      return 2;
    }
    return cmdRun(name, res["CMD"].as<string>(), res["timeout"].as<double>());
  }
  if (cmd == "expect") {
    if (!res.count("PATTERN")) {
      fprintf(stderr, "etctl expect: missing PATTERN\n");
      return 2;
    }
    return cmdExpect(name, res["PATTERN"].as<string>(),
                     res["timeout"].as<double>(), res.count("from-start") > 0,
                     res.count("exact") > 0,
                     res.count("cursor") ? res["cursor"].as<long long>() : -1);
  }
  if (cmd == "resize") {
    if (!res.count("ROWS") || !res.count("COLS")) {
      fprintf(stderr, "etctl resize: NAME ROWS COLS\n");
      return 2;
    }
    return cmdResize(name, res["ROWS"].as<int>(), res["COLS"].as<int>());
  }

  fprintf(stderr, "etctl: unhandled command '%s'\n", cmd.c_str());
  return 2;
}
