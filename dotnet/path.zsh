if [[ -x $HOME/.dotnet/dotnet ]]
then
  export DOTNET_ROOT=$HOME/.dotnet
  export PATH="$HOME/.dotnet:$PATH"
fi

if [[ -d $HOME/.dotnet/tools ]]
then
  export PATH="$HOME/.dotnet/tools:$PATH"
fi
