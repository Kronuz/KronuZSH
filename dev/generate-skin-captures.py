#!/usr/bin/env python3
"""Generate literal-ANSI upstream/KronuZSH skin comparisons.

The representative fixture is ~/project on branch main with staged, modified,
untracked, ahead and stashed state. Dynamic upstream fields are fixed so the output
is byte-stable. Redirect stdout to dev/skin-captures.ansi.
"""

from __future__ import annotations

import importlib.util
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PREVIEW = os.path.join(ROOT, "dev", "preview-skin.py")

spec = importlib.util.spec_from_file_location("preview_skin", PREVIEW)
assert spec and spec.loader
preview = importlib.util.module_from_spec(spec)
spec.loader.exec_module(preview)

# Prompt-level ANSI transcribed from the pinned upstream defaults in
# dev/skin-fidelity.md. `print -P` below converts these to literal SGR bytes.
ORIGINALS = {
    "agnoster": (
        "%K{blue}%F{black} ~/project %K{yellow}%F{blue}%F{black}"
        "  main ± %k%F{yellow}%f ",
        "",
    ),
    "geometry": (
        " %F{default}▲%f %F{blue}~/project%f ",
        "⇡ %F{242}main%f %F{green}1s%f %F{144}●%f %F{red}⬡%f",
    ),
    "lambda-mod": (
        "\n%B%F{green}λ%f%b %B%F{yellow}kronuz%f%b %F{magenta}[~/project]%f"
        " at %F{blue} main%f %B%F{green}+%F{blue}!%F{cyan}?%f%b\n"
        "%B%F{cyan}→%f%b ",
        " %B%F{white}[%F{blue}0123456%F{white}]%f%b",
    ),
    "pi": (
        " %B%F{green}π%f%b: %F{blue}project%f %B%F{green}main%f%b"
        " %F{yellow}✗%f %F{magenta}❯%f ",
        "",
    ),
    "pure": (
        "%F{blue}~/project%f %F{242}main%F{218}*%f %F{cyan}⇡%f"
        " %F{cyan}≡%f\n%F{magenta}❯%f ",
        "",
    ),
    "robbyrussell": (
        "%B%F{green}➜%f%b  %F{cyan}project%f %B%F{blue}git:(%F{red}"
        "main%F{blue})%f%b %F{yellow}✗%f ",
        "",
    ),
    "sobole": (
        "%B%F{blue}~/project%f%b %F{green}main%f %F{red}✗%f\n"
        "%F{black}»%f ",
        "",
    ),
    "typewritten": (
        "%F{blue}❯%f ",
        "%F{magenta}project%f -> %F{magenta}main%f %F{green}+%f"
        " %F{blue}?%f %F{yellow}!%f %F{blue}|•%f %F{yellow}$%f",
    ),
}


def sgr(prompt: str) -> bytes:
    return subprocess.run(
        ["zsh", "-fc", 'print -nrP -- "$1"', "capture", prompt],
        check=True,
        stdout=subprocess.PIPE,
    ).stdout


def line(label: str, left: bytes, right: bytes) -> bytes:
    return label.encode().ljust(12) + left + (b"    RPROMPT " + right if right else b"")


def main() -> None:
    tmp = tempfile.mkdtemp(prefix="kronuz-skin-captures-")
    no_color = os.environ.pop("NO_COLOR", None)
    try:
        out = sys.stdout.buffer
        out.write(b"KronuZSH skin fidelity -- literal ANSI/SGR captures\n")
        out.write(b"fixture: ~/project, main, staged + modified + untracked + ahead + stash\n")
        out.write(b"view with: less -R dev/skin-captures.ansi\n")
        for name, (up_left, up_right) in ORIGINALS.items():
            home = tempfile.mkdtemp(prefix="home-", dir=tmp)
            project = os.path.join(home, "project")
            preview.make_demo_dir(project)
            layers, _ = preview.render(
                os.path.join(ROOT, "skins", f"{name}.zsh"), home, project
            )
            out.write(f"\n=== {name} ===\n".encode())
            out.write(line("ORIGINAL", sgr(up_left), sgr(up_right)) + b"\n")
            out.write(line("KRONUZSH", layers["PROMPT"], layers["RPROMPT"]) + b"\n")
    finally:
        if no_color is not None:
            os.environ["NO_COLOR"] = no_color
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
