# 
# NSI script for octave windows
# $Id$
#

# http://www.nullsoft.com/free/nsis/makensis.htm 

Name "GNU Octave 2.1.42 + octave-forge + gnuplot 3.8.0 + epstk"
OutFile "octave-2.1.42-p6.exe"
Icon "C:\Program Files\GNU Octave\octave.ico"
CRCCheck on


DirText "Please select a location to install GNU Octave + octave-forge"
InstallDir "$PROGRAMFILES\GNU Octave"

LicenseText "You must read the following license before installing:"
LicenseData "C:\Program Files\GNU Octave\Copying.txt"

ComponentText "Select whom to install octave for:"
InstType "Install for All Users"
InstType "Install for Current User"
InstType /NOCUSTOM

SetOverwrite on
AutoCloseWindow false
ShowInstDetails show
ShowUninstDetails show

UninstallText "This will uninstall GNU Octave. Hit next to continue."

Section "Octave Files"
SectionIn 1 2
  SetOutPath $INSTDIR
  File /r "C:\Program Files\GNU Octave\*.*"
# File "C:\WINNT\system32\notepad.exe"
  WriteUninstaller "$INSTDIR\uninstall.exe"

  CreateShortCut "$INSTDIR\GNU Octave 2.1.42.lnk" "$INSTDIR\bin\run.exe" `rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -fn "Lucida Console-12" -tn linux -title "GNU Octave 2.1.42" -geometry 80x25 -sl 400 -sr -e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0
  CreateShortCut "$INSTDIR\GNU Octave 2.1.42 (cmd).lnk" "$INSTDIR\bin\sh.exe" `-e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0

  WriteRegStr HKCR ".m" "" "m-file"
  WriteRegStr HKCR "m-file" "" "m-file"
  WriteRegStr HKCR "m-file\Shell\open\command" "" '"$WINDIR\notepad.exe" "%1"'

  WriteRegStr HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/" "native" "$INSTDIR"
  WriteRegDWORD HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/" "flags" "a"
  WriteRegStr HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/bin" "native" "$INSTDIR/bin"
  WriteRegDWORD HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/bin" "flags" "a"
  WriteRegStr HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/lib" "native" "$INSTDIR/lib"
  WriteRegDWORD HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/lib" "flags" "a"
  WriteRegStr HKLM "SOFTWARE\GNU Octave\Cygwin\Program Options" "temp" "temp"
  DeleteRegValue HKLM "SOFTWARE\GNU Octave\Cygwin\Program Options" "temp"
  
  WriteRegStr HKU ".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/" "native" "$INSTDIR"
  WriteRegDWORD HKU ".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/" "flags" "a"
  WriteRegStr HKU ".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/bin" "native" "$INSTDIR/bin"
  WriteRegDWORD HKU ".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/bin" "flags" "a"
  WriteRegStr HKU ".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/lib" "native" "$INSTDIR/lib"
  WriteRegDWORD HKU ".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/lib" "flags" "a"
  WriteRegStr HKU ".DEFAULT\Software\GNU Octave\Cygwin\Program Options" "temp" "temp"
  DeleteRegValue HKU ".DEFAULT\Software\GNU Octave\Cygwin\Program Options" "temp"

  WriteRegStr HKCU "Software\GNU Octave\Cygwin\mounts v2\/" "cygdrive prefix" "/cygdrive"
  WriteRegDWORD HKCU "Software\GNU Octave\Cygwin\mounts v2\/" "cygdrive flags" "22"
  WriteRegStr HKCU "Software\GNU Octave\Cygwin\Program Options" "temp" "temp"
  DeleteRegValue HKCU "Software\GNU Octave\Cygwin\Program Options" "temp"
SectionEnd

; optional section
Section "Start Menu All Users"
SectionIn 1
  SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\GNU Octave 2.1.42"
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\Uninstall GNU Octave 2.1.42.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\GNU Octave 2.1.42.lnk" "$INSTDIR\bin\run.exe" `rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -fn "Lucida Console-12" -tn linux -title "GNU Octave 2.1.42" -geometry 80x25 -sl 400 -sr -e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\GNU Octave 2.1.42 (cmd).lnk" "$INSTDIR\bin\sh.exe" `-e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0

  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\Manual - GNU Octave 2.1.42.lnk" "$INSTDIR\html\octave_toc.html"
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\Manual - EPSTK (Graphics).lnk" "$INSTDIR\html\epstk\index.html"

  CreateShortCut "$DESKTOP\GNU Octave 2.1.42.lnk" "$INSTDIR\bin\run.exe" `rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -fn "Lucida Console-12" -tn linux -title "GNU Octave 2.1.42" -geometry 80x25 -sl 400 -sr -e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0
SectionEnd

Section "Start Menu This User"
SectionIn 2
# SetShellVarContext all
  CreateDirectory "$SMPROGRAMS\GNU Octave 2.1.42"
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\Uninstall GNU Octave 2.1.42.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\GNU Octave 2.1.42.lnk" "$INSTDIR\bin\run.exe" `rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -fn "Lucida Console-12" -tn linux -title "GNU Octave 2.1.42" -geometry 80x25 -sl 400 -sr -e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\GNU Octave 2.1.42 (cmd).lnk" "$INSTDIR\bin\sh.exe" `-e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0

  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\Manual - GNU Octave 2.1.42.lnk" "$INSTDIR\html\octave_toc.html"
  CreateShortCut "$SMPROGRAMS\GNU Octave 2.1.42\Manual - EPSTK (Graphics).lnk" "$INSTDIR\html\epstk\index.html"

  CreateShortCut "$DESKTOP\GNU Octave 2.1.42.lnk" "$INSTDIR\bin\run.exe" `rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -fn "Lucida Console-12" -tn linux -title "GNU Octave 2.1.42" -geometry 80x25 -sl 400 -sr -e /bin/start_octave.sh` "$INSTDIR\octave.ico" 0
SectionEnd

Section "-Local Config" # hidden because of -
SectionIn 1 2 
# CreateDirectory "C:\jnkeroo"
  Exec "$INSTDIR\bin\sh.exe -e /bin/install_octave.sh"
SectionEnd


Section "Uninstall"
  DeleteRegKey HKCR ".m"
  DeleteRegKey HKCR "m-file"
  DeleteRegKey HKCR "m-file\Shell\open\command"
  DeleteRegKey HKLM "SOFTWARE\GNU Octave"
  DeleteRegKey HKU ".DEFAULT\Software\GNU Octave"
  DeleteRegKey HKCU "Software\GNU Octave"
  Delete "$DESKTOP\GNU Octave 2.1.42.lnk"
  Delete "$SMPROGRAMS\GNU Octave 2.1.42\*.*"
  Delete "$INSTDIR\*.*"
  RMDir "$SMPROGRAMS\GNU Octave 2.1.42"
  RMDir /r "$INSTDIR"
SectionEnd
