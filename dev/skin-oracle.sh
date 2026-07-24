#!/usr/bin/env bash
# Byte-identical skin oracle.
#
# Renders the built-in default layout AND every skin in skins/ with
# `dev/preview-skin.py --raw`, keeps only the raw-escape and OSC lines, and normalises
# the one volatile field (the wall clock) to [TIME]. The result is a stable digest of
# exactly what every layout paints -- colours, attributes, glyphs, segment structure --
# plus each layout's OSC 133 A/B/C/D + iTerm 1337 verdict.
#
# WHEN: run it around ANY change that could affect prompt rendering but is meant to
# preserve it -- a palette/array rename or refactor (e.g. the $kz unification), a
# glyph/colour reshuffle, a segment-composition tweak. A pure refactor MUST leave the
# digest byte-identical; a behavioural change shows up as a precise diff you can inspect.
# (For prompt-lifecycle / OSC-protocol changes, use dev/check-prompt-streams.zsh instead,
# which drives the full failure/success/blank/exit matrix.)
#
# HOW:
#   dev/skin-oracle.sh > /tmp/before.txt      # capture the baseline first
#   # ... edit lib/prompt.zsh and/or skins/*.zsh ...
#   dev/skin-oracle.sh > /tmp/after.txt       # capture again
#   diff /tmp/before.txt /tmp/after.txt && echo "byte-identical"
# The summary line (sha + OSC tally) is printed to stderr so stdout stays a clean,
# diffable digest. Every layout must report PASS; the sha must match for a pure refactor.
set -u
cd "$(dirname "$0")/.." || exit 1

digest="$(
  for skin in "" skins/*.zsh; do
    python3 dev/preview-skin.py --raw $skin 2>&1 | grep -E 'raw:|OSC|==='
  done | sed -E 's/\[[0-9]{1,2}:[0-9]{2}:[0-9]{2}\]/[TIME]/g'
)"
printf '%s\n' "$digest"

layouts=$(printf '%s\n' "$digest" | grep -c '^=== ')
passes=$(printf '%s\n' "$digest" | grep -c 'PASS')
sha=$(printf '%s' "$digest" | (shasum 2>/dev/null || sha1sum) | cut -c1-12)
printf 'skin-oracle: %s layouts, OSC PASS %s/%s, sha %s\n' "$layouts" "$passes" "$layouts" "$sha" >&2
[ "$passes" = "$layouts" ]
