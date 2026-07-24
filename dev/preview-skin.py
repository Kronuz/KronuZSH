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
import shutil
import struct
import sys
import tempfile
import termios
import time

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

OSC_MARKS = ("133;A", "133;B", "133;C", "133;D", "1337")
_CSI = re.compile(rb"\x1b\[[0-9;?]*[A-Za-z]")
_OSC = re.compile(rb"\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)")
_CHARSET = re.compile(rb"\x1b[()][AB0]")


def make_demo_dir(path: str) -> None:
    """Just a directory to sit in, so the pwd segment reads ~/project. The git
    segment's state comes from dev/fake-gitstatus.zsh, not from a repo on disk."""
    os.makedirs(path, exist_ok=True)


def strip(b: bytes) -> str:
    s = _OSC.sub(b"", b)
    s = _CSI.sub(b"", s)
    s = _CHARSET.sub(b"", s)
    return s.decode("utf-8", "replace")


def render(
    skin: str | None, home: str, repo_dir: str, fallback: bool = False, cols: int = 240
) -> tuple[dict[str, bytes], dict[str, bool]]:
    """Run one isolated interactive shell and return the rendered prompt
    layers plus which OSC marks appeared during a real command cycle.

    The harness loads only the prompt engine (lib/prompt.zsh) plus a fake gitstatus
    (dev/fake-gitstatus.zsh), not the whole framework: every skin and OSC-integration
    code path lives in prompt.zsh, so this is faithful for previewing and OSC
    verification, while skipping the slow, HOME-sensitive parts (compinit) that a
    throwaway shell trips over. The fake makes the git segment render synchronously from
    a fixed snapshot, so there is no daemon or async query to wait on and every run looks
    the same. The skin is sourced after prompt_kronuz_setup, exactly as a real
    ~/.zshrc.local would be. iTerm is announced so the iTerm OSC path is tested."""
    skin_line = f'source "{os.path.abspath(skin)}"\n' if skin else ""
    if fallback:
        # No gitstatus_query defined -> the segment takes the direct-git fallback, which
        # we point at the fake git so it renders without a repo on disk.
        git_setup = f'export PROMPT_KRONUZ_GIT_CMD="{REPO}/dev/fake-git"\n'
    else:
        git_setup = f'source "{REPO}/dev/fake-gitstatus.zsh"\n'
    zshrc = (
        f'export KRONUZSH="{REPO}"\n'
        'source "$KRONUZSH/runcoms/zshenv" 2>/dev/null\n'
        "setopt PROMPT_SUBST\n"
        f"{git_setup}"
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

    def read_some(timeout: float) -> bool:
        r, _, _ = select.select([fd], [], [], max(0.0, timeout))
        if not r:
            return False
        try:
            d = os.read(fd, 65536)
        except OSError:
            return False
        if not d:
            return False
        buf.extend(d)
        return True

    def wait_for(token: bytes, timeout: float = 10.0, frm: int = 0) -> int:
        """Read until `token` appears at/after `frm`, returning the index just
        past it (or -1 on timeout). Returns the moment the token lands, so the
        harness paces itself to the shell instead of to fixed sleeps."""
        end = time.time() + timeout
        while True:
            i = buf.find(token, frm)
            if i != -1:
                return i + len(token)
            if time.time() >= end:
                return -1
            read_some(min(0.2, end - time.time()))

    def send(s: str) -> None:
        os.write(fd, s.encode())

    target = os.path.basename(repo_dir).encode()

    # Sentinels are emitted via $'...' so they only appear in the shell's output:
    # the echoed command line shows the literal `$'\x1e...'`, never the control byte.
    # 1. Wait until ZLE is actually reading a line before typing: input sent earlier is
    #    dropped. zsh enables bracketed paste (`\x1b[?2004h`) right before each read, so
    #    the first one is the definitive "ready for input" signal.
    wait_for(b"\x1b[?2004h", timeout=15)

    # 2. Enter the demo repo. cd is resent every iteration (idempotent) in case the very
    #    first keystroke still races ZLE, and we confirm arrival by the reported basename.
    for _ in range(20):
        frm = len(buf)
        send(
            f"builtin cd {repo_dir} 2>/dev/null; print -n $'\\x1eP:'${{PWD:t}}$'\\x1e'\r"
        )
        j = wait_for(b"\x1eP:", timeout=1.5, frm=frm)
        if j != -1:
            k = buf.find(b"\x1e", j)
            if bytes(buf[j:k]) == target:
                break
        time.sleep(0.03)

    # 3. Run one command and wait for its completion mark, so raw_cycle is guaranteed to
    #    contain a full A/B/C/D + 1337 cycle for the OSC check. (Git is synchronous via
    #    the fake, so there is nothing async to wait on.)
    frm = len(buf)
    send("builtin true\r")
    wait_for(b"\x1b]133;D", timeout=2.0, frm=frm)
    raw_cycle = bytes(buf)

    # 4. Render the three layers. Inline $'\x01LABEL\x02' markers bound each printed
    #    body; the echoed command (ZLE stays active) holds only the literal `$'...'`.
    def grab(label: str, expr: str) -> None:
        frm = len(buf)
        send(
            f"print -n $'\\x01{label}\\x02'; print -rP -- \"{expr}\"; print -n $'\\x01END\\x02'\r"
        )
        wait_for(b"\x01END\x02", timeout=3.0, frm=frm)

    grab("PS1", "${(e)${(e)PROMPT_KRONUZ_PS1-$DEFAULT_PROMPT_KRONUZ_PS1}}")
    grab("RPS1", "${(e)${(e)PROMPT_KRONUZ_RPS1-$DEFAULT_PROMPT_KRONUZ_RPS1}}")
    grab(
        "TRANS", "${(e)${(e)PROMPT_KRONUZ_TRANSIENT-$DEFAULT_PROMPT_KRONUZ_TRANSIENT}}"
    )
    send("exit\r")
    os.close(fd)
    try:
        os.waitpid(pid, 0)  # reap the shell so gitstatusd is torn down before cleanup
    except OSError:
        pass
    tail = bytes(buf)

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
    ap.add_argument(
        "--fallback",
        action="store_true",
        help="exercise the direct-git fallback (no daemon) with the fake git",
    )
    args = ap.parse_args()

    targets: list[str | None] = list(args.skins) or [None]
    failed = False
    tmp = tempfile.mkdtemp(prefix="kronuz-skin-")
    try:
        for skin in targets:
            home = tempfile.mkdtemp(prefix="home-", dir=tmp)
            repo_dir = os.path.join(
                home, "project"
            )  # under HOME, so pwd shows ~/project
            make_demo_dir(repo_dir)
            layers, osc = render(skin, home, repo_dir, fallback=args.fallback)
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
    finally:
        # gitstatusd can briefly outlive its shell; don't let a stray file fail the run.
        shutil.rmtree(tmp, ignore_errors=True)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
