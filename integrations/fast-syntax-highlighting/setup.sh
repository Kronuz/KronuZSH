# fast-syntax-highlighting: apply the Kronuz theme. fsh's `fast-theme` resolves the
# .ini and writes the styles to its work dir ($FAST_WORK_DIR/current_theme.zsh, under
# ~/.cache), which fsh auto-loads at every shell start. Needs zsh + the fsh plugin,
# so we run it through zsh (this file is POSIX sh, sourced by ../setup.sh at install).
# Idempotent: re-running just re-writes the same theme.
_kronuz_fsh_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd -P)"
_kronuz_fsh_plugin="$_kronuz_fsh_dir/../../plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
if command -v zsh >/dev/null 2>&1 && [ -r "$_kronuz_fsh_plugin" ]; then
  if zsh -fc "source '$_kronuz_fsh_plugin'; fast-theme '$_kronuz_fsh_dir/Kronuz.ini' -q" >/dev/null 2>&1; then
    echo "applied fast-syntax-highlighting Kronuz theme"
  fi
fi
unset _kronuz_fsh_dir _kronuz_fsh_plugin
