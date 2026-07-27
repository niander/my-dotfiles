# Stamp each command with the time it was submitted, right-aligned on the line
# it was typed on. A prompt escape can't do this: the prompt is expanded before
# the line is typed, so it would record when the prompt appeared instead.
# Lives here rather than in zsh/ because oh-my-zsh's lib and plugins redefine
# the zle-line-finish widget outright, dropping hooks registered before them.

autoload -Uz add-zsh-hook add-zle-hook-widget

typeset -g _timestamp_width=8
typeset -g _timestamp_screen_lines=0

# Screen rows the input occupied, known only while zle is still up. Continued
# constructs accept one line at a time, so rows accumulate until a command runs.
_timestamp_line_finish() { (( _timestamp_screen_lines += BUFFERLINES )) }

# Lines abandoned without running a command leave rows behind; clear them at the
# top-level prompt, which continuation lines do not reach.
_timestamp_precmd() { _timestamp_screen_lines=0 }

# Repaint the right edge of the line the prompt was on, which sits as many rows
# above the cursor as the input occupied. Bails out on input that wrapped: its
# first row is full by definition, so a stamp there would land on typed text.
_timestamp_preexec() {
  local rows=$_timestamp_screen_lines
  local -a lines=("${(f)1}")
  (( rows == $#lines )) || return
  (( ${#lines[1]} + _timestamp_width + 4 < COLUMNS )) || return
  print -Pn "\e[${rows}A\e[$((COLUMNS - _timestamp_width + 1))G%F{8}%D{%H:%M:%S}%f\e[${rows}B\r"
}

add-zle-hook-widget line-finish _timestamp_line_finish
add-zsh-hook precmd _timestamp_precmd
add-zsh-hook preexec _timestamp_preexec
