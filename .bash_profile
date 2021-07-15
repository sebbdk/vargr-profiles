#!/bin/bash

NODE_OPTIONS=--max-old-space-size=8192

echo "Hello Seb, here's your shortcuts:"
echo '---------------------------------'
echo 'gls - git long single lines'
echo 'gst - git status alias'
echo 'gct - clear screen + git status'
echo 'gco - git checkout alias'
echo 'gbr - Show last 10 banches used'
echo '---------------------------------'

alias e.='explorer .'
alias gl='git log --oneline --all --graph --decorate  $*'
alias ls='ls -la --show-control-chars -F --color $*'
alias pwd='cd'
alias unalias='alias /d $1'
alias vi='vim $*'
alias gst='git status $*q'
alias gct='clear & git status $*'
alias gco='git checkout $*'
alias gls='git log --oneline'
alias gbr='git branch --sort=-committerdate | head -n 10'

if [ -f "./.bash_profile_env" ];
then
	. "./.bash_profile_env"
	echo "Loaded environment profile!"
	echo '---------------------------------'
fi
