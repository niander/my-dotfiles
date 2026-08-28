# Add each topic folder to fpath for autoloaded functions and completions.
for topic_folder ($DOTFILES/* $DOTFILES_LOCAL/*(N))
do
  if [[ -d $topic_folder ]]
  then
    fpath=($topic_folder $fpath)
  fi
done
