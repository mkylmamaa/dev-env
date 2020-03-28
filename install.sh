#/bin/zsh

# print usage if no arguments supplied
#if [[ $# -eq 0 ]] ; then
	#echo "Usage: $0 <dev root>"
	#exit 1
#fi

# parse arguments
#DEV_ROOT=$1

# install programs
if [ -x "$(command -v brew)" ]; then
	brew install zsh
	brew install vim
	brew install tmux
	brew install reattach-to-user-namespace
	brew install spc
	brew install the_silver_searcher
elif [ -x "$(command -v apt-get)" ]; then
	sudo apt-get update
	sudo apt-get upgrade
	sudo apt-get -y install zsh
	sudo apt-get -y install vim
	sudo apt-get -y install tmux
	sudo apt-get -y install supercat
	sudo apt-get -y install curl
	sudo apt-get -y install silversearcher-ag
else
	echo "Homebrew or apt-get has to exist."
	exit 1
fi

# make sure submodules are up to date
git submodule init
git submodule update

# install config files & scripts
cp -R .spcrc ~/
cp -R .tmux ~/
if [[ "$OSTYPE" == "darwin"* ]]; then
	sed "s|^#OSXSPECIFIC ||g; s|{ZSH_PATH}|$(which zsh)|g" .tmux.conf > ~/.tmux.conf
else
	sed "s|{ZSH_PATH}|$(which zsh)|g" .tmux.conf > ~/.tmux.conf
fi
cp -R .vim ~/
cp .vimrc ~/
cp .zshrc ~/
cp .zshrc.autocd ~/

# add oh-my-zsh & powerlevel9k theme
git clone https://github.com/mkylmamaa/oh-my-zsh.git ~/.oh-my-zsh
git clone https://github.com/mkylmamaa/powerlevel9k.git ~/.oh-my-zsh/custom/themes/powerlevel9k
git clone https://github.com/mkylmamaa/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/mkylmamaa/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# install powerline fonts
#git clone https://github.com/mkylmamaa/fonts.git

# set permissions in case they were not preserved
chmod 600 ~/.vimrc
chmod 600 ~/.tmux.conf
chmod 600 ~/.zshrc
chmod 600 ~/.zshrc.autocd
chmod -R 700 ~/.oh-my.zsh
chmod -R 700 ~/.spcrc
chmod -R 700 ~/.tmux
chmod -R 700 ~/.vim

# set tmux as the default shell
chsh -s $(which tmux)

# install powerline fonts
if [ -x "$(command -v PowerShell.exe)" ]; then
	(cd fonts && PowerShell.exe -ExecutionPolicy Bypass -File "install.ps1")
	echo "Please choose the desired font for your shell in Properties->Font!"
fi
