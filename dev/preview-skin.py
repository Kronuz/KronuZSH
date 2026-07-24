#!/usr/bin/env python3
"""Preview a KronuZSH prompt skin and verify its terminal integration.

A skin is a snippet that sets PROMPT_KRONUZ_PS1 / PROMPT_KRONUZ_RPS1 /
PROMPT_KRONUZ_TRANSIENT (see ../skins). This renders one in a throwaway,
fully isolated shell (its own HOME, ZDOTDIR and demo git repo), then:

  * prints the live PS1, the right prompt (RPS1) and the collapsed transient
    prompt, both as raw ANSI (--raw) and as a stripped, readable preview, and
  * asserts the OSC 133 A/B/C/D shell-integration marks and iTerm's OSC 1337
    still survive the skin. A skin that breaks them exits non-zero.

The skin loads the real way: written to the isolated $HOME/.zshrc.local, which
runcoms/zshrc sources last. Nothing touches your own shell or config.

    dev/preview-skin.py                 # the built-in default layout
    dev/preview-skin.py skins/*.zsh     # every bundled skin
    dev/preview-skin.py --raw skins/minimal.zsh
"""

from __future__ import annotations

import argparse
import fcntl
import os
import pty
import re
import select
import struct
import subprocess
import sys
import tempfile
import termios
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

OSC_MARKS = ("133;A", "133;B", "133;C", "133;D", "1337")
_CSI = re.compile(rb"\x1b\[[0-9;?]*[A-Za-z]")
_OSC = re.compile(rb"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)")
_CHARSET = re.compile(rb"\x1b[()][AB0]")


def make_demo_repo(path: str) -> None:
    """A small repo with a branch, a staged file, a modified file and an
    untracked one, so the git segment has something interesting to show."""
    env = {
        **os.environ,
        "GIT_CONFIG_GLOBAL": "/dev/null",
        "GIT_CONFIG_SYSTEM": "/dev/null",
    }

    def git(*args: str) -> None:
        subprocess.run(
            ["git", "-C", path, *args],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            env=env,
        )

    os.makedirs(path, exist_ok=True)
    git("init", "-qb", "main")
    git("config", "user.email", "you@example.com")
    git("config", "user.name", "you")
    git("remote", "add", "origin", "git@github.com:you/project.git")
    with open(os.path.join(path, "README.md"), "w") as fh:
        fh.write("hello\n")
    git("add", "README.md")
    git("commit", "-qm", "init")
    with open(os.path.join(path, "README.md"), "a") as fh:
        fh.write("more\n")  # unstaged change
    with open(os.path.join(path, "new.py"), "w") as fh:
        fh.write("x = 1\n")
    git("add", "new.py")  # staged change
    with open(os.path.join(path, "scratch.txt"), "w") as fh:
        fh.write("tmp\n")  # untracked


def strip(b: bytes) -> str:
    s = _OSC.sub(b"", b)
    s = _CSI.sub(b"", s)
    s = _CHARSET.sub(b"", s)
    return s.decode("utf-8", "replace")


def render(
    skin: str | None, home: str, repo_dir: str, cols: int = 240
) -> tuple[dict[str, bytes], dict[str, bool]]:
    """Run one isolated interactive shell and return the rendered prompt
    layers plus which OSC marks appeared during a real command cycle.

    The harness loads only the prompt engine (lib/prompt.zsh) plus gitstatus,
    not the whole framework: every skin and OSC-integration code path lives in
    prompt.zsh, so this is faithful for previewing and OSC verification, while
    skipping the slow, HOME-sensitive parts (compinit) that a throwaway shell
    trips over. The skin is sourced after prompt_kronuz_setup, exactly as a real
    ~/.zshrc.local would be. iTerm is announced so the iTerm OSC path is tested."""
    skin_line = f'source "{os.path.abspath(skin)}"\n' if skin else ""
    zshrc = (
        f'export KRONUZSH="{REPO}"\n'
        'source "$KRONUZSH/runcoms/zshenv" 2>/dev/null\n'
        "setopt PROMPT_SUBST\n"
        'source "$KRONUZSH/plugins/gitstatus/gitstatus.plugin.zsh"\n'
        "gitstatus_start -s -1 -u -1 -c -1 -d -1 KRONUZ 2>/dev/null\n"
        'source "$KRONUZSH/lib/prompt.zsh"\n'
        "prompt_kronuz_setup\n"
        f"{skin_line}"
    )
    with open(os.path.join(home, ".zshrc"), "w") as fh:
        fh.write(zshrc)

    env = {
        **os.environ,
        "HOME": home,
        "ZDOTDIR": home,
        "KRONUZSH": REPO,
        "TERM": "xterm-256color",
        "COLORTERM": "truecolor",
        "TERM_PROGRAM": "iTerm.app",
        "LC_TERMINAL": "iTerm2",
        "ITERM_SESSION_ID": "w0t0p0:preview",
        "LC_ALL": "en_US.UTF-8",
    }

    pid, fd = pty.fork()
    if pid == 0:
        os.execvpe("zsh", ["zsh", "-i"], env)
    fcntl.ioctl(fd, termios.TIOCSWINSZ, struct.pack("HHHH", 60, cols, 0, 0))

    buf = bytearray()

    def drain(t: float = 0.4) -> None:
        end = time.time() + t
        while time.time() < end:
            r, _, _ = select.select([fd], [], [], 0.05)
            if r:
                try:
                    d = os.read(fd, 65536)
                except OSError:
                    break
                if not d:
                    break
                buf.extend(d)
                end = time.time() + t

    def send(s: str) -> None:
        os.write(fd, s.encode())

    drain(2.0)  # let the engine load and gitstatusd come up
    send(f"cd {repo_dir}\r")
    drain(1.0)
    send("true\r")
    drain(1.5)
    send("true\r")
    drain(1.5)
    raw_cycle = bytes(buf)

    # Render the three layers. The markers are control bytes held in shell
    # variables, so the echoed command line (ZLE stays active under the full
    # framework) never contains them -- only the printed output does.
    send(
        "MPS=$'\\x01PS1\\x02'; MRP=$'\\x01RPS1\\x02'; MTR=$'\\x01TRANS\\x02'; MEND=$'\\x01END\\x02'\r"
    )
    drain(0.4)
    mark = len(buf)
    for var, expr in (
        ("MPS", "${(e)${(e)PROMPT_KRONUZ_PS1-$DEFAULT_PROMPT_KRONUZ_PS1}}"),
        ("MRP", "${(e)${(e)PROMPT_KRONUZ_RPS1-$DEFAULT_PROMPT_KRONUZ_RPS1}}"),
        ("MTR", "${(e)${(e)PROMPT_KRONUZ_TRANSIENT-$DEFAULT_PROMPT_KRONUZ_TRANSIENT}}"),
    ):
        send(f'print -n ${var}; print -rP -- "{expr}"; print -n $MEND\r')
        drain(0.7)
    send("exit\r")
    drain(0.4)
    os.close(fd)
    tail = bytes(buf[mark:])

    def between(label: str) -> bytes:
        m = re.search(rb"\x01" + label.encode() + rb"\x02(.*?)\x01END\x02", tail, re.S)
        return (m.group(1) if m else b"").replace(b"\r", b"").strip(b"\n")

    layers = {label: between(label) for label in ("PS1", "RPS1", "TRANS")}
    osc = {mk: (b"\x1b]" + mk.encode()) in raw_cycle for mk in OSC_MARKS}
    return layers, osc


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Preview a KronuZSH prompt skin and verify OSC integration."
    )
    ap.add_argument(
        "skins", nargs="*", help="skin .zsh files (none = the built-in default layout)"
    )
    ap.add_argument(
        "--raw", action="store_true", help="also print the raw ANSI of each layer"
    )
    args = ap.parse_args()

    targets: list[str | None] = list(args.skins) or [None]
    failed = False
    with tempfile.TemporaryDirectory(prefix="kronuz-skin-") as tmp:
        for skin in targets:
            home = tempfile.mkdtemp(prefix="home-", dir=tmp)
            repo_dir = os.path.join(
                home, "project"
            )  # under HOME, so pwd shows ~/project
            make_demo_repo(repo_dir)
            layers, osc = render(skin, home, repo_dir)
            name = os.path.basename(skin) if skin else "DEFAULT layout"
            print(f"\n=== {name} ===")
            for label in ("PS1", "RPS1", "TRANS"):
                v = layers[label]
                preview = strip(v).replace("\n", " \u23ce ") or "(empty)"
                print(f"  {label:<5} {preview}")
                if args.raw:
                    sys.stdout.flush()
                    sys.stdout.buffer.write(b"        raw: " + v + b"\n")
                    sys.stdout.buffer.flush()
            ok = all(osc[m] for m in OSC_MARKS)
            failed = failed or not ok
            report = " ".join(f"{m}={'ok' if osc[m] else 'MISSING'}" for m in OSC_MARKS)
            print(f"  OSC   {report}  =>  {'PASS' if ok else 'FAIL'}")
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
