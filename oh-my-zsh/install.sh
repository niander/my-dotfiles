   
#install oh my zsh
#curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh

# Make zsh default shell
which zsh > /dev/null 2>&1 && sudo chsh -s $(which zsh)

