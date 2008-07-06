# Octave NSIS Installation script

!define OCTAVE_VERSION "3.0.0"
!define OCTAVE_RELEASE "2"

!define PRODUCT_NAME "GNU Octave"
!define PRODUCT_VERSION "${OCTAVE_VERSION}"

!define PACKAGE_ROOT "c:\programs\msys\1.0\opt\octave_mingw32_gcc42\${OCTAVE_VERSION}-${OCTAVE_RELEASE}"

;!define SMFOLDERNAME "GNU Octave ${OCTAVE_VERSION}"

!include MUI2.nsh

SetCompressor /SOLID lzma
SetCompressorDictSize 16
SetDatablockOptimize on

; This file is required on startup of installer 
; to detect the CPU features present on the target system
; and to select the ATLAS library section accordingly
ReserveFile "${PACKAGE_ROOT}\bin\cpufeature.exe"

; Welcome Page
!insertmacro MUI_PAGE_WELCOME

; License page
!define MUI_LICENSEPAGE_TEXT_BOTTOM "Click Next to continue."
!define MUI_LICENSEPAGE_BUTTON "Next >"
!insertmacro MUI_PAGE_LICENSE "..\..\..\COPYING.GPL"

; Detect CPU Type
; Page custom DetectCPUType

; Directory page
!insertmacro MUI_PAGE_DIRECTORY

; Components page
!define MUI_COMPONENTSPAGE_TEXT_TOP "Review the components that will be installed. Click Install to start the installation."
!define MUI_COMPONENTSPAGE_TEXT_COMPLIST  "Review the components that will be installed.$\r$\nMIND: The appropriate ATLAS Libraries for this machine have already been selected by the installer.$\r$\nCHANGE ONLY WITH CAUTION"

; The default text
;!define MUI_COMPONENTSPAGE_TEXT_TOP "Check the components you want to install an duncheck the components you don't want to install. Click Install to start the installation"
;!define MUI_COMPONENTSPAGE_TEXT_COMPLIST  "Select components to install"

!insertmacro MUI_PAGE_COMPONENTS

; Start menu page
var SMFOLDERNAME
;!define MUI_STARTMENUPAGE_NODISABLE
!define MUI_STARTMENUPAGE_DEFAULTFOLDER "GNU Octave ${OCTAVE_VERSION}"
;!define MUI_STARTMENUPAGE_REGISTRY_ROOT "${PRODUCT_UNINST_ROOT_KEY}"
;!define MUI_STARTMENUPAGE_REGISTRY_KEY "${PRODUCT_UNINST_KEY}"
;!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "${PRODUCT_STARTMENU_REGVAL}"
!insertmacro MUI_PAGE_STARTMENU "Startmenu" $SMFOLDERNAME

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish Page
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Language files
!insertmacro MUI_LANGUAGE "English"

Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"

OutFile "Octave-${OCTAVE_VERSION}-${OCTAVE_RELEASE}_i686-pc-mingw32_gcc-4.2.1_setup.exe"

InstallDir "$PROGRAMFILES\Octave\${OCTAVE_VERSION}"

ShowInstDetails show

ShowUnInstDetails show

XPStyle off

ComponentText

Function SetUserContext

   Push $0
   ClearErrors
   UserInfo::GetName
   IfErrors noadmin
   UserInfo::GetAccountType
   Pop $0
   StrCmp $0 "Admin" admin noadmin
admin:
   SetShellVarContext all
   Goto done
noadmin:
   SetShellVarContext current
   Goto done
done:
   Pop $0
   
FunctionEnd

Function un.SetUserContext

   Push $0
   ClearErrors
   UserInfo::GetName
   IfErrors noadmin
   UserInfo::GetAccountType
   Pop $0
   StrCmp $0 "Admin" admin noadmin
admin:
   SetShellVarContext all
   Goto done
noadmin:
   SetShellVarContext current
   Goto done
done:
   Pop $0
   
FunctionEnd

Section "Octave" SEC_OCTAVE

  ; octave executables
  SetOutPath "$INSTDIR\bin"
  File /r /x blas.dll /x cblas.dll /x lapack.dll "${PACKAGE_ROOT}\bin\*.*"
  
  SetOutPath "$INSTDIR\doc"
  File /r "${PACKAGE_ROOT}\doc\*.*"
  SetOutPath "$INSTDIR\include"
  File /r "${PACKAGE_ROOT}\include\*.*"
  SetOutPath "$INSTDIR\info"
  File /r "${PACKAGE_ROOT}\info\*.*"
  SetOutPath "$INSTDIR\lib"
  File /r /x libblas.dll.a /x libcblas.dll.a /x liblapack.dll.a "${PACKAGE_ROOT}\lib\*.*"
  SetOutPath "$INSTDIR\libexec"
  File /r "${PACKAGE_ROOT}\libexec\*.*"
  SetOutPath "$INSTDIR\license"
  File /r "${PACKAGE_ROOT}\license\*.*"
  SetOutPath "$INSTDIR\man"
  File /r "${PACKAGE_ROOT}\man\*.*"
  SetOutPath "$INSTDIR\mingw32"
  File /r "${PACKAGE_ROOT}\mingw32\*.*"
  SetOutPath "$INSTDIR\MSYS"
  File /r "${PACKAGE_ROOT}\MSYS\*.*"
  SetOutPath "$INSTDIR\share"
  File /r "${PACKAGE_ROOT}\share\*.*"
  SetOutPath "$INSTDIR\staticlib"
  File /r /x libblas.a /x libcblas.a /x liblapack.a "${PACKAGE_ROOT}\staticlib\*.*"
  SetOutPath "$INSTDIR\tools"
  File /r "${PACKAGE_ROOT}\tools\*.*"
   
   ; Shortcut's "Start In" Property ssems to be defined by the current output path...
   SetOutPath "$INSTDIR\bin"
   
   ; Shortcuts
   !insertmacro MUI_STARTMENU_WRITE_BEGIN Startmenu
   CreateDirectory "$SMPROGRAMS\$SMFOLDERNAME"
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Octave.lnk" "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe" "" "$INSTDIR\bin\octave.ico" 0
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\WGnuplot.lnk" "$INSTDIR\bin\wgnuplot.exe" 
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Notepad++.lnk" "$INSTDIR\tools\notepad++\notepad++.exe" 
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Uninstall.lnk" "$INSTDIR\uninstaller.exe"
   
   CreateDirectory "$SMPROGRAMS\$SMFOLDERNAME\Documentation"
   CreateDirectory "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF"
   CreateDirectory "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML"
   
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\Gnuplot.lnk" "$INSTDIR\doc\gnuplot\gnuplot.pdf"
   
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\Octave.lnk" "$INSTDIR\doc\pdf\octave.pdf"
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\FAQ.lnk" "$INSTDIR\doc\pdf\octave-faq.pdf"
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\Quick Reference Card.lnk" "$INSTDIR\doc\pdf\refcard-a4.pdf"
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\Octave C++ API.lnk" "$INSTDIR\doc\pdf\liboctave.pdf"
   
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML\Octave.lnk" "$INSTDIR\doc\HTML\interpreter\index.html"
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML\Octave C++ API.lnk" "$INSTDIR\doc\HTML\liboctave\index.html"
   CreateShortCut "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML\FAQ.lnk" "$INSTDIR\doc\HTML\faq\Octave-FAQ.html"
   
   CreateShortCut "$DESKTOP\Octave.lnk" "$INSTDIR\bin\octave-${OCTAVE_VERSION}.exe" "" "$INSTDIR\bin\octave.ico" 0
   
   ; write some reg settings to have nice default look-and-feel
   
   WriteRegStr   HKCU "Console\Octave" "FaceName" "Lucida Console"
   WriteRegDWORD HKCU "Console\Octave" "FontFamily" 0x36
   WriteRegDWORD HKCU "Console\Octave" "FontSize" 0x000c0000
   WriteRegDWORD HKCU "Console\Octave" "FontWeight" 0x190
   WriteRegDWORD HKCU "Console\Octave" "FullScreen" 0x0
   WriteRegDWORD HKCU "Console\Octave" "InsertMode" 0x1
   WriteRegDWORD HKCU "Console\Octave" "QuickEdit" 0x1
   WriteRegDWORD HKCU "Console\Octave" "ScreenBufferSize" 0x0bb80078
   WriteRegDWORD HKCU "Console\Octave" "WindowSize" 0x00280078
   
   !insertmacro MUI_STARTMENU_WRITE_END
   
   ; Uninstaller
   WriteUninstaller $INSTDIR\uninstaller.exe
   
SectionEnd

#SectionGroup /e "Tools" SRCGRP_TOOLS

#Section "Notepad++" SEC_NOTEPADPP
#  SetOutPath "$INSTDIR\tools\notepad++"
#  File /r "${PACKAGE_ROOT}\tools\notepad++\*.*"
#SectionEnd

#Section "MinGW32" SEC_MINGW32
#  SetOutPath "$INSTDIR\mingw32"
#  File /r "${PACKAGE_ROOT}\tools\mingw32\*.*"
#SectionEnd

#Section "MSYS" SEC_MSYS
#  SetOutPath "$INSTDIR\MSYS"
#  File /r "${PACKAGE_ROOT}\tools\MSYS\*.*"
#SectionEnd

#SectionGroupEnd

!if 1

SectionGroup /e "ATLAS Libraries" SECGRP_ATLAS

Section /o "Generic" SEC_ATLAS_GENERIC

   SetOutPath "$INSTDIR\bin"
   File "${PACKAGE_ROOT}\bin\blas.dll"
   File "${PACKAGE_ROOT}\bin\cblas.dll"
   File "${PACKAGE_ROOT}\bin\lapack.dll"
   SetOutPath "$INSTDIR\lib"
   File "${PACKAGE_ROOT}\lib\libblas.dll.a"
   File "${PACKAGE_ROOT}\lib\libcblas.dll.a"
   File "${PACKAGE_ROOT}\lib\liblapack.dll.a"
   SetOutPath "$INSTDIR\staticlib"
   File "${PACKAGE_ROOT}\staticlib\libblas.a"
   File "${PACKAGE_ROOT}\staticlib\libcblas.a"
   File "${PACKAGE_ROOT}\staticlib\liblapack.a"
   
SectionEnd

Section /o "MMX (PII)" SEC_ATLAS_P2

   SetOutPath "$INSTDIR\bin"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P2\bin\*.*"
   SetOutPath "$INSTDIR\lib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P2\lib\*.*"
   SetOutPath "$INSTDIR\staticlib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P2\staticlib\*.*"
   
SectionEnd

Section /o "SSE (PIII)" SEC_ATLAS_P3

   SetOutPath "$INSTDIR\bin"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P3\bin\*.*"
   SetOutPath "$INSTDIR\lib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P3\lib\*.*"
   SetOutPath "$INSTDIR\staticlib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P3\staticlib\*.*"
   
SectionEnd

Section /o "SSE2 (P4)" SEC_ATLAS_P4

   SetOutPath "$INSTDIR\bin"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P4\bin\*.*"
   SetOutPath "$INSTDIR\lib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P4\lib\*.*"
   SetOutPath "$INSTDIR\staticlib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_P4\staticlib\*.*"
   
SectionEnd

Section /o "SSE3 (Core2Duo)" SEC_ATLAS_CORE2DUO

   SetOutPath "$INSTDIR\bin"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_Core2Duo\bin\*.*"
   SetOutPath "$INSTDIR\lib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_Core2Duo\lib\*.*"
   SetOutPath "$INSTDIR\staticlib"
   File "${PACKAGE_ROOT}\ATLAS\ARCH_Core2Duo\staticlib\*.*"
   
SectionEnd

#Section /o "ATLAS_PD" SEC_ATLAS_PENTIUMD
#
#   SetOutPath "$INSTDIR\bin"
#   File "${PACKAGE_ROOT}\ATLAS\ARCH_PentiumD\bin\*.*"
#   SetOutPath "$INSTDIR\lib"
#   File "${PACKAGE_ROOT}\ATLAS\ARCH_PentiumD\lib\*.*"
#   SetOutPath "$INSTDIR\staticlib"
#   File "${PACKAGE_ROOT}\ATLAS\ARCH_PentiumD\staticlib\*.*"
#   
#SectionEnd

SectionGroupEnd

!endif

Section Uninstall

   !insertmacro MUI_STARTMENU_GETFOLDER "Startmenu" $SMFOLDERNAME

   Delete "$DESKTOP\Octave.lnk"

   Delete "$SMPROGRAMS\$SMFOLDERNAME\Octave.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\WGnuplot.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Notepad++.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Uninstall.lnk"

   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\Gnuplot.lnk"
   
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\Octave.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\FAQ.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\Quick Reference Card.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF\Octave C++ API.lnk"

   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML\Octave.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML\Octave C++ API.lnk"
   Delete "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML\FAQ.lnk"


   RMDir "$SMPROGRAMS\$SMFOLDERNAME\Documentation\HTML"
   RMDir "$SMPROGRAMS\$SMFOLDERNAME\Documentation\PDF"
   RMDir "$SMPROGRAMS\$SMFOLDERNAME\Documentation"
   RMDir "$SMPROGRAMS\$SMFOLDERNAME"

   RMDir /r "$INSTDIR"

SectionEnd

; http://download.intel.com/design/processor/applnots/24161832.pdf

Function checkCPUfeature
   
checksse3:
   StrCpy $1 0
   ExecWait '"$TEMP\cpufeature.exe" -f sse3' $1
   StrCmp $1 1 0 checksse2
   !insertmacro SetSectionFlag  ${SEC_ATLAS_CORE2DUO} ${SF_SELECTED}
   StrCpy $9 ${SEC_ATLAS_CORE2DUO}
   goto cpuend
checksse2:
   StrCpy $1 0
   ExecWait '"$TEMP\cpufeature.exe" -f sse2' $1
   StrCmp $1 1 0 checksse
   !insertmacro SetSectionFlag  ${SEC_ATLAS_P4} ${SF_SELECTED}
   StrCpy $9 ${SEC_ATLAS_P4}
   goto cpuend
checksse:
   StrCpy $1 0
   ExecWait '"$TEMP\cpufeature.exe" -f sse' $1
   StrCmp $1 1 0 checkmmx
   !insertmacro SetSectionFlag  ${SEC_ATLAS_P3} ${SF_SELECTED}
   StrCpy $9 ${SEC_ATLAS_P3}
   goto cpuend
checkmmx:
   StrCpy $1 0
   ExecWait '"$TEMP\cpufeature.exe" -f mmx' $1
   StrCmp $1 1 0 setgeneric
   !insertmacro SetSectionFlag  ${SEC_ATLAS_P2} ${SF_SELECTED}
   StrCpy $9 ${SEC_ATLAS_P2}
   goto cpuend
setgeneric:
  !insertmacro SetSectionFlag  ${SEC_ATLAS_GENERIC} ${SF_SELECTED}
  StrCpy $9 ${SEC_ATLAS_GENERIC}
cpuend:

FunctionEnd   
   
Function .onSelChange

   !insertmacro StartRadioButtons $9
      !insertmacro RadioButton ${SEC_ATLAS_GENERIC}
      !insertmacro RadioButton ${SEC_ATLAS_P2}
      !insertmacro RadioButton ${SEC_ATLAS_P3}
      !insertmacro RadioButton ${SEC_ATLAS_P4}
      !insertmacro RadioButton ${SEC_ATLAS_CORE2DUO}
   !insertmacro EndRadioButtons

FunctionEnd

Function .onInit

   Call DetectWinVer
   
   File /oname=$TEMP\cpufeature.exe "${PACKAGE_ROOT}\bin\cpufeature.exe"
   Call checkCPUfeature
   
   !insertmacro SetSectionFlag  ${SEC_OCTAVE} ${SF_RO}
   
   Call SetUserContext
   
FunctionEnd

Function un.onInit

   Call un.SetUserContext

FunctionEnd

Function DetectWinVer
  Push $0
  Push $1
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" CurrentVersion
  IfErrors is_error is_winnt
is_winnt:
  StrCpy $1 $0 1
  StrCmp $1 6 is_winxp
  StrCmp $1 5 0 is_error
  StrCmp $0 "5.0" is_win2k
  StrCmp $0 "5.1" is_winxp
  StrCmp $0 "5.2" is_winxp64
  Goto is_error
is_win2k:
  Goto done
is_winxp64:
is_winxp:
  Goto done
is_error:
  StrCpy $1 $0
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion" ProductName
  IfErrors 0 +4
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion" Version
  IfErrors 0 +2
  StrCpy $0 "Unknown"
  MessageBox MB_ICONSTOP|MB_OK "This version of Octave cannot be installed on this system.$\r$\nSupported systems are Windows 2000 and Windows XP.$\r$\n$\r$\nCurrent system: $0 (version: $1)"
  Abort
done:
  Pop $1
  Pop $0
FunctionEnd

; Section descriptions
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_OCTAVE} "Octave core files & libraries, dependency libraries, development files, mingw32 gcc, MSYS environment, notepad++ text editor and gnuplot"
   !insertmacro MUI_DESCRIPTION_TEXT ${SECGRP_ATLAS} "Linear Algebra Libraries"
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ATLAS_GENERIC} "Generic BLAS+LAPACK. Works on all systems"
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ATLAS_P2} "BLAS+LAPACK with MMX. Works on Pentium II"
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ATLAS_P3} "BLAS+LAPACK with SSE. Works on Pentium III"
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ATLAS_P4} "BLAS+LAPACK with SSE2. Works on e.g. Pentium 4"
   !insertmacro MUI_DESCRIPTION_TEXT ${SEC_ATLAS_CORE2DUO} "BLAS+LAPACK with SSE3. Works on e.g. Core2Duo, Pentium D, Pentium 4E"
!insertmacro MUI_FUNCTION_DESCRIPTION_END
