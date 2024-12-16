# Source .bashrc only if the shell is interactive.
if [[ $- == *i* ]] && [[ -f ~/.bashrc ]]; then
  source ~/.bashrc
fi
