# Title: Detect Local Drives
# Author: deguix
# Source: NSIS archive >Browse >Useful Functions >Disk, Path & File Functions
#
# Function to detect available local drives and return their letters
# (with colon and foward slash, like C:/). As my Search File Function,
# this function uses the callback function, for each drive detected.
#
# Calling sequence:
#   !include "DetectDrives.nsi"
#
#   Push "DriveTypes"
#   Push $0
#   GetFunctionAddress $0 "Callback"
#   Exch $0
#   Call DetectDrives
#
# Drive Types:
#
#   Three drive types are available:
#
#     Hard Drives
#     CDROM Drives
#     Diskette Drives
#
#   Separate multiple drive types by '&' (but keep the above order!).
#
#   E.g.,
#      Hard Drives & Diskette Drives
#      CDROM Drives & Diskette Drives
#      Hard Drives & CDROM Drives & Diskette Drives
#
#   To select all, you may also use:
#      All Local Drives
#
# Callback function:
#
#    * On entry, $R0 contains the drive letter detected.
#
#    * On return, push "Stop" to stop, or "Continue" to continue searching.
#
#    * Do not push any other values on the stack without popping them later.
#
#    * Use any variables, but $R0 through $R4 will be overwritten.
#
# Notes:
#   Uses the system and kernel32 plugins repeatedly.  You may get better 
#   performance if you have the following in your .nsi file:
# 
#      SetPluginUnload alwaysoff
#
#   This clue is from reading the docs, not from any tests. YMMV.

Function DetectDrives

Exch
Exch $R0
Exch
Exch $R1
Push $R2
Push $R3
Push $R4
StrCpy $R4 $R1

# Memory for paths
 
System::Alloc 1024 
Pop $R1 

# Get drives 

System::Call 'kernel32::GetLogicalDriveStringsA(i, i) i(1024, R1)' 

enumok: 

# One more drive? 

System::Call 'kernel32::lstrlenA(t) i(i R1) .R2' 
IntCmp $R2 0 enumex 

# Now, search for drives according to user conditions

System::Call 'kernel32::GetDriveTypeA(t) i (i R1) .R3' 

StrCmp $R0 "Hard Drives" 0 +2
StrCmp $R3 3 0 enumnext

StrCmp $R0 "CDROM Drives" 0 +2
StrCmp $R3 5 0 enumnext

StrCmp $R0 "Diskette Drives" 0 +2
StrCmp $R3 2 0 enumnext

StrCmp $R0 "Hard Drives & CDROM Drives" 0 +3
StrCmp $R3 3 +2 0
StrCmp $R3 5 0 enumnext

StrCmp $R0 "Hard Drives & Diskette Drives" 0 +3
StrCmp $R3 3 +2 0
StrCmp $R3 2 0 enumnext

StrCmp $R0 "CDROM Drives & Diskette Drives" 0 +3
StrCmp $R3 5 +2 0
StrCmp $R3 2 0 enumnext

StrCmp $R0 "Hard Drives & CDROM Drives & Diskette Drives" +2 0
StrCmp $R0 "All Local Drives" 0 +4
StrCmp $R3 3 +3 0
StrCmp $R3 5 +2 0
StrCmp $R3 2 0 enumnext

# Get drive path string 

System::Call '*$R1(&t1024 .R3)' 

# Prepare variables for the Callback function

Push $R4
Push $R3
Push $R2
Push $R1
Push $R0

StrCpy $R0 $R3

# Call the Callback function

Call $R4

# Return variables

Push $R5
Exch
Pop $R5

Exch
Pop $R0
Exch
Pop $R1
Exch
Pop $R2
Exch
Pop $R3
Exch
Pop $R4

StrCmp $R5 "Stop" 0 +3
  Pop $R5
  Goto enumex

Pop $R5

enumnext: 

# Next drive path

IntOp $R1 $R1 + $R2 
IntOp $R1 $R1 + 1 
goto enumok 

# End Search

enumex:
 
# Free memory used for paths

System::Free $R1 

# Return original user variables

Pop $R4
Pop $R3
Pop $R2
Pop $R1
Pop $R0

FunctionEnd
