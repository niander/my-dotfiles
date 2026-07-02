if [[ -d $HOME/.dotnet ]]
then
  export PATH="$HOME/.dotnet:$PATH"
fi

if [[ -d $HOME/.dotnet/tools ]]
then
  export PATH="$HOME/.dotnet/tools:$PATH"
fi
