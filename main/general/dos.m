## dos ('cmd')
##    Execute a dos command if running under Windows.  Do nothing if running
##    under a different operating system.  The command output will be echoed
##    to the console.
##
## [status, text] = dos ('cmd', '-echo')
##    Capture the output and exit status of a command.  The command output
##    will not be echoed unless '-echo' is specified.
##
## [status, text] = dos ('cmd 2>&1')
##    Captures stderr as well as stdout.
##
## dos('cmd &')
##    Runs cmd in the background, returning immediately to Octave.

## This program is granted to the public domain.

function dos
