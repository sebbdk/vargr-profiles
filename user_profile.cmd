:: use this file to run your own startup commands
:: use in front of the command to prevent printing the command

:: uncomment this to have the ssh agent load when cmder starts
:: call "%GIT_INSTALL_ROOT%/cmd/start-ssh-agent.cmd" /k exit

:: uncomment the next two lines to use pageant as the ssh authentication agent
:: SET SSH_AUTH_SOCK=/tmp/.ssh-pageant-auth-sock
:: call "%GIT_INSTALL_ROOT%/cmd/start-ssh-pageant.cmd"

:: you can add your plugins to the cmder path like so
:: set "PATH=%CMDER_ROOT%\vendor\whatever;%PATH%"

:: arguments in this batch are passed from init.bat, you can quickly parse them like so:
:: more useage can be seen by typing "cexec /?"

:: %ccall% "/customOption" "command/program"

:: @echo off
set NODE_OPTIONS=--max-old-space-size=8192

cd %HOMEPATH%

echo Hello Seb, here's your shortcuts:
echo ---------------------------------
echo gls - git long single lines
echo gst - git status alias
echo gct - clear screen + git status
echo gco - git checkout alias
echo gbr - Show last 10 banches used
echo gbr - Show last 10 banches used
echo.
echo dev - goes to dev folder
echo pro - goes to dev/projects folder
echo note - opens dev/notes in vscode
echo ---------------------------------
