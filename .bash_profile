#!/bin/bash

# Configure node to have a bit more space by default
NODE_OPTIONS=--max-old-space-size=8192

# Misc, rarely used
alias pwd='cd'
alias unalias='alias /d $1'
alias vi='vim $*'

# Make ks default to -la and add some colors
alias ls='ls -la --show-control-chars -F --color $*'

# Folder shortcuts
alias dev='cd ~/dev'
alias pro='cd ~/dev/projects'
alias note='code ~/dev/notes'

# Windows specific
alias e.='explorer .'

# Git related
alias gl='git log --oneline --all --graph --decorate  $*'
alias gst='git status $*q'
alias gct='clear & git status $*'
alias gco='git checkout $*'
alias gls='git log --oneline'
alias gbr='git branch --sort=-committerdate | head -n 10'

echo "Hello Seb, here's your shortcuts:"
echo '---------------------------------'
echo 'gls - git long single lines'
echo 'gst - git status alias'
echo 'gct - clear screen + git status'
echo 'gco - git checkout alias'
echo 'gbr - Show last 10 banches used'
echo
echo 'dev - goes to dev folder'
echo 'pro - goes to dev/projects folder'
echo 'note - opens dev/notes in vscode'
echo '---------------------------------'

if [ -f "./.bash_profile_env" ];
then
	. "./.bash_profile_env"
	echo "Loaded environment profile!"
	echo '---------------------------------'
fi
