# Shell options. Mirrors the prezto defaults worth keeping plus German's tweaks.
# Adapted from Prezto (MIT); see LICENSE for copyright and license notices.

# Directory
setopt AUTO_CD              # `cd` by typing a directory name.
setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Don't push duplicate directories.
setopt PUSHD_SILENT         # Don't print the directory stack after pushd/popd.
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given.
setopt CDABLE_VARS          # cd to a named variable's value.
setopt MULTIOS              # Write to multiple descriptors.
setopt EXTENDED_GLOB        # Use extended globbing syntax.
setopt NUMERIC_GLOB_SORT    # Sort filenames numerically when it makes sense.
setopt CLOBBER              # Make > and >> work as expected.

# General
setopt COMBINING_CHARS      # Combine zero-length punctuation chars with the base.
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shells.
setopt RC_QUOTES            # Allow 'Henry''s Garage' instead of 'Henry'\''s Garage'.
setopt RM_STAR_SILENT       # Do not query before `rm *` ...
setopt RM_STAR_WAIT         # ... but wait 10s if you do.
unsetopt CORRECT            # Do not autocorrect command spelling.
unsetopt CORRECT_ALL        # Do not autocorrect argument spelling.
unsetopt HUP                # Do not HUP running jobs on shell exit.
unsetopt BEEP               # No beeps.

# Jobs
setopt LONG_LIST_JOBS NOTIFY
unsetopt BG_NICE HUP CHECK_JOBS

PS2=''                      # Drop the "heredoc>" continuation prompt.
