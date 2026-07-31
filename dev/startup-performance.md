# Startup performance

KronuZSH compiles the zsh files it loads and generates the `fzf` and `zoxide`
initialization once during install. The optimization keeps startup synchronous: the
first command gets completion, syntax highlighting, autosuggestions, and the Git
prompt, exactly like every command after it.

## Benchmark

Measured on an Intel Mac with zsh 5.9.2, inside a Git repository, using 16 iterations
of [`zsh-bench`](https://github.com/romkatv/zsh-bench):

```sh
zsh-bench --iters 16 --login no --git yes
```

| Configuration | First prompt | First command | Command | Input | Capabilities |
| --- | ---: | ---: | ---: | ---: | --- |
| Text sources, generated integrations per shell | 188.8 ms | 209.2 ms | 15.3 ms | 9.0 ms | all four |
| Compiled sources and install-time generated integrations | 147.3-150.3 ms | 167.6-170.4 ms | 14.9-15.2 ms | 8.6-9.2 ms | all four |

Across two final 16-iteration runs, the startup path moved **38.5-41.5 ms** earlier:
20.4-22.0% less time to the first prompt and 18.5-19.9% less time to the first
command. The steady-state command and input differences are run-to-run noise.

## Why there is no deferred plugin loading

`zsh-defer` was tested against the same configuration after compilation. Deferring
fast-syntax-highlighting changed first-prompt latency from 158.0 ms to 153.9 ms, a
4.2 ms shift, but the first command had no syntax highlighting. Deferring completion,
autosuggestions, keybindings, aliases, functions, or environment changes creates the
same race in a more damaging place.

The shell does not claim work is finished while it is still moving pieces behind the
prompt. Compilation removes parsing work. Install-time generation removes process
launches. Both preserve the first command's behavior.

This matches the failure mode described in
[`zsh-bench`'s deferred-initialization analysis](https://github.com/romkatv/zsh-bench#deferred-initialization):
first-prompt timing alone rewards an incomplete shell. Keep the capability fields next
to the latency numbers.
