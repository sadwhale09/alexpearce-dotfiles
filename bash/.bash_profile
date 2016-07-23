# Start fish shell
# Start bash with the NOFISH environment variable set to disable
if [ -z "$NOFISH" ] && [ -f "$HOME/usr/bin/fish" ]; then
  ~/usr/bin/fish
  # Exit from bash immediately if fish exited successfully
  if [ $? -eq 0 ]; then
    exit
  fi
  echo 'Fish exited with an error, dropping to bash shell'
fi
