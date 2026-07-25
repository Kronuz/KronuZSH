#!/usr/bin/env python3
"""Generate literal-ANSI upstream/KronuZSH skin comparisons.

The representative fixture is ~/project on branch main with staged, modified,
untracked, ahead and stashed state. Dynamic upstream fields are fixed so the output
is byte-stable. Redirect stdout to dev/skin-captures.ansi.
"""

from __future__ import annotations

import importlib.util
import os
import re
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
    "af-magic": (
        "%F{237}"
        + ("-" * 240)
        + "%f\n%F{32}~/project %F{75}(%F{78}main%F{214}*%F{75})%f %F{105}»%f ",
        "%F{237}kronuz@kronuz%f",
    ),
    "agnoster": (
        (
            "%K{blue}%F{black} ~/project %K{yellow}%F{blue}%F{black}"
            "  main ± %k%F{yellow}%f "
        ),
        "",
    ),
    "asciiship": (
        "~/project [on branch main + ! ? >] via py3.12 *\n$ ",
        "",
    ),
    "bira": (
        (
            "╭─%B%F{green}kronuz@kronuz%f%b %B%F{blue}~/project %f%b"
            "%F{yellow}‹main%F{red}●%F{yellow}› %f\n╰─%B$%b "
        ),
        "",
    ),
    "cloud": (
        (
            "%B%F{cyan}☁  %B%F{green}project %B%F{cyan}%F{green}[%F{cyan}main"
            "%F{green}] %F{yellow}⚡ %f %B%F{blue} % %f%b"
        ),
        "",
    ),
    "dst": (
        (
            "\n%F{magenta}kronuz%f@%F{yellow}kronuz%f: %B%F{blue}~/project%f%b"
            " %F{green}main%F{red}!%f\n$ "
        ),
        "%F{green}[18:00:00]%f",
    ),
    "fino": (
        (
            "╭─%F{40}kronuz %F{239}at %F{33}kronuz %F{239}in %B%F{226}~/project%b"
            " %F{239}on%f %F{255}main%F{202}✘✘✘%f\n╰─±%f "
        ),
        "",
    ),
    "geometry": (
        " %F{default}▲%f %F{blue}~/project%f ",
        "⇡ %F{242}main%f %F{green}1s%f %F{144}●%f %F{red}⬡%f",
    ),
    "gitster": ("%F{green}➜%f ~/project main %F{green}✓%f ", ""),
    "zim-minimal": ("%F{green}λ%f ", "~/project main ✓"),
    "s1ck94": ("%F{green}❯%f ", "~/project main ✗ ↑ ↓"),
    "sorin": ("%B%F{blue}~/project%f%b ", "(py3.12) %F{green}main%f %F{red}✗%f"),
    "eriner": ("%K{cyan}%F{black} ~/project %k%F{yellow} main ±%f ", ""),
    "magicmace": ("%F{green}kronuz%f %F{blue}[~/project]%f [main * ↑ ↓]── ", ""),
    "hometown": ("18:00:00 ~/project (main ± ↑ ↓ $)\n% ", ""),
    "itchy": (
        "%F{cyan}kronuz@kronuz%f %F{yellow}~/project%f\n%F{green}☺%f  ",
        "main %F{red}✗%f",
    ),
    "kiwi": (
        (
            "%B%F{green}┌[%F{cyan}kiwish-4.2%F{green}]-(%F{white}~/project"
            "%F{green})-[%f%F{white}git:%B%F{white}main%B%F{green}]-\n└> % %f%b"
        ),
        "",
    ),
    "lambda-mod": (
        (
            "\n%B%F{green}λ%f%b %B%F{yellow}kronuz%f%b %F{magenta}[~/project]%f"
            " at %F{blue} main%f %B%F{green}+%F{blue}!%F{cyan}?%f%b\n"
            "%B%F{cyan}→%f%b "
        ),
        " %B%F{white}[%F{blue}0123456%F{white}]%f%b",
    ),
    "lukerandall": (
        (
            "%B%F{green}kronuz@kronuz%f%b %B%F{blue}~/project%f%b "
            "%F{yellow}(main %% + *)%f %B»%b "
        ),
        "",
    ),
    "pi": (
        (
            " %B%F{green}π%f%b: %F{blue}project%f %B%F{green}main%f%b"
            " %F{yellow}✗%f %F{magenta}❯%f "
        ),
        "",
    ),
    "pygmalion": (
        (
            "%F{magenta}kronuz%F{cyan}@%F{yellow}kronuz%F{red}:%F{cyan}~/project"
            "%F{red}|%f%F{green}main%F{yellow}⚡%f %F{cyan}⇒%f  "
        ),
        "",
    ),
    "pure": (
        (
            "%F{blue}~/project%f %F{242}main%F{218}*%f %F{cyan}⇡%f"
            " %F{cyan}≡%f\n%F{magenta}❯%f "
        ),
        "",
    ),
    "powerlevel10k": (
        "%F{blue}~/project%f on %F{green}main%f %F{yellow}✘%f\n%F{green}❯%f ",
        "(py3.12) 18:00:00",
    ),
    "spaceship": (
        "%F{cyan}➜%f %F{green}~/project%f on %F{blue}main%f %F{red}✗%f\n%F{green}❯%f ",
        "",
    ),
    "starship": (
        "%F{blue}➜%f %F{cyan}~/project%f %F{magenta} main%f %F{red}✘%f\n%F{green}❯%f ",
        "",
    ),
    "liquidprompt": (
        "%F{blue}~/project%f %F{cyan}(main %F{red}✗%F{green} +%F{yellow} ?%F{cyan})%f\n%F{green}$%f ",
        "%*",
    ),
    "robbyrussell": (
        (
            "%B%F{green}➜%f%b  %F{cyan}project%f %B%F{blue}git:(%F{red}"
            "main%F{blue})%f%b %F{yellow}✗%f "
        ),
        "",
    ),
    "sobole": (
        "%B%F{blue}~/project%f%b %F{green}main%f %F{red}✗%f\n%F{black}»%f ",
        "",
    ),
    "steeef": (
        (
            "\n%F{135}kronuz%f at %F{166}kronuz%f in %F{118}~/project%f "
            "(%F{81}main%F{166}●%F{118}●%F{161}●%f) \n$ "
        ),
        "",
    ),
    "sunaku": (
        "%F{green}+%F{magenta}!%F{yellow}?%fmain %F{green}~/project%f> ",
        "",
    ),
    "typewritten": (
        "%F{blue}❯%f ",
        (
            "%F{magenta}project%f -> %F{magenta}main%f %F{green}+%f"
            " %F{blue}?%f %F{yellow}!%f %F{blue}|•%f %F{yellow}$%f"
        ),
    ),
    "ys": (
        (
            "\n%B%F{blue}#%f%b %F{cyan}kronuz%f @ %F{green}kronuz %f"
            "in %B%F{yellow}~/project%f%b on%F{blue} git:%F{cyan}main"
            " %F{red}x%f [18:00:00] \n%B%F{red}$ %f%b"
        ),
        "",
    ),
    "zsh-redhat": ("[kronuz@kronuz project]$ ", ""),
    "zsh-suse": ("kronuz@kronuz:~/project/ > ", ""),
    "zsh-walters": ("kronuz@kronuz:~/project> ", ""),
    "zsh-zefram": ("[5.9.2]kronuz@kronuz:%B~/project%b> ", ""),
}


def sgr(prompt: str) -> bytes:
    env = {
        **os.environ,
        "TERM": "xterm-256color",
        "COLORTERM": "truecolor",
    }
    return subprocess.run(
        ["zsh", "-fc", 'print -nrP -- "$1"', "capture", prompt],
        check=True,
        env=env,
        stdout=subprocess.PIPE,
    ).stdout


def line(label: str, left: bytes, right: bytes) -> bytes:
    return label.encode().ljust(12) + left + (b"    RPROMPT " + right if right else b"")


def normalize_dynamic(value: bytes) -> bytes:
    value = re.sub(rb"\b\d\d:\d\d:\d\d\b", b"18:00:00", value)
    value = re.sub(rb"\[(?:\d+\.)+\d+\]", b"[5.9.2]", value)
    return value


def main() -> None:
    tmp = tempfile.mkdtemp(prefix="kronuz-skin-captures-")
    no_color = os.environ.pop("NO_COLOR", None)
    try:
        out = sys.stdout.buffer
        out.write(b"KronuZSH skin fidelity -- literal ANSI/SGR captures\n")
        out.write(
            b"fixture: ~/project, main, staged + modified + untracked + ahead + stash\n"
        )
        out.write(b"view with: less -R dev/skin-captures.ansi\n")
        for name, (up_left, up_right) in ORIGINALS.items():
            home = tempfile.mkdtemp(prefix="home-", dir=tmp)
            project = os.path.join(home, "project")
            preview.make_demo_dir(project)
            layers, _ = preview.render(
                os.path.join(ROOT, "skins", f"{name}.zsh"), home, project
            )
            out.write(f"\n=== {name} ===\n".encode())
            out.write(
                line(
                    "ORIGINAL",
                    normalize_dynamic(sgr(up_left)),
                    normalize_dynamic(sgr(up_right)),
                )
                + b"\n"
            )
            out.write(
                line(
                    "KRONUZSH",
                    normalize_dynamic(layers["PROMPT"]),
                    normalize_dynamic(layers["RPROMPT"]),
                )
                + b"\n"
            )
    finally:
        if no_color is not None:
            os.environ["NO_COLOR"] = no_color
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
