#
# NSI script for octave windows
# $Id$
#

# http://nsis.sourceforge.net/Docs

# Sort out command line parameters

!ifndef VERSION
!error "Start MakeNSIS with /DVERSION=2.1.xx [/DMINOR=-yyyymmdd] [/DROOT=C:\cygwin] octave.nsi"
!endif
!ifndef MINOR
!define MINOR ""
!endif
!ifndef ROOT
!define ROOT "C:\cygwin"
!endif

# Product and version
!define MUI_PRODUCT "GNU Octave ${VERSION}"
!define MUI_VERSION "${VERSION}${MINOR}"


!define STARTMENU

!include "${NSISDIR}\Contrib\Modern UI\System.nsh"

!define MUI_LICENSEPAGE
!define MUI_COMPONENTSPAGE
!define MUI_DIRECTORYPAGE

!define MUI_ABORTWARNING

!define MUI_UNINSTALLER
!define MUI_UNCONFIRMPAGE

!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_LANGUAGE "Spanish"

CrcCheck On

OutFile "octave-${MUI_VERSION}-inst.exe"
Icon "octave.ico"
UninstallIcon "octave.ico"

# ****************** Localization ***********************

LicenseData /LANG=${LANG_ENGLISH} "..\..\COPYING.GPL"
LicenseData /LANG=${LANG_SPANISH} "..\..\COPYING.GPL-spanish"

; The default caption is a language dependent string saying
;     ${MUI_PRODUCT} ${VERSION} Setup
; Since our ${MUI_PRODUCT} includes ${VERSION}, we need to
; set the caption by hand for each of our languages.
Caption /LANG=${LANG_ENGLISH} "${MUI_PRODUCT} Setup"
Caption /LANG=${LANG_SPANISH} "Instalación de ${MUI_PRODUCT}"

LangString TITLE_Section1 ${LANG_ENGLISH} "${MUI_PRODUCT}"
LangString TITLE_Section1 ${LANG_SPANISH} "${MUI_PRODUCT}"

LangString TITLE_Section2 ${LANG_ENGLISH} "Start Menu Icons"
LangString TITLE_Section2 ${LANG_SPANISH} "Iconos de Menú de Inicio"

LangString TITLE_Section3 ${LANG_ENGLISH} "Desktop Icons"
LangString TITLE_Section3 ${LANG_SPANISH} "Iconos de Escritorio"

LangString DESC_Section1 ${LANG_ENGLISH} "Install the ${MUI_PRODUCT} for Windows binary distribution including gnuplot, epstk and the octave-forge extensions."
LangString DESC_Section1 ${LANG_SPANISH} "Instalar la version ejecutable the ${MUI_PRODUCT} para Windows la cual incluye gnuplot, epstk y las extensiones de octave-forge."

LangString DESC_Section2 ${LANG_ENGLISH} "Add a ${MUI_PRODUCT} folder to the Start Menu."
LangString DESC_Section2 ${LANG_SPANISH} "Agregar una carpeta de ${MUI_PRODUCT} al Menú de Inicio."

LangString DESC_Section3 ${LANG_ENGLISH} "Add a ${MUI_PRODUCT} icon to the Desktop."
LangString DESC_Section3 ${LANG_SPANISH} "Agregar un icono de ${MUI_PRODUCT} al Escritorio."

LangString UninstallLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\Uninstall ${MUI_PRODUCT}.lnk"
LangString UninstallLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Desinstalar ${MUI_PRODUCT}.lnk"

LangString ManualLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT} Manual (HTML).lnk"
LangString ManualLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Manual de ${MUI_PRODUCT} (HTML).lnk"

LangString FunctionLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\OctaveForge Quick Reference (HTML).url"
LangString FunctionLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Refencia Rápida de OctaveForge (HTML).url"

LangString EpstkLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\Epstk Manual (HTML).url"
LangString EpstkLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Manual de Epstk (HTML).url"

LangString RefcardLink ${LANG_ENGLISH} "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT} Quick Reference (PDF).lnk"
LangString RefcardLink ${LANG_SPANISH} "$SMPROGRAMS\${MUI_PRODUCT}\Refencia Rápida de ${MUI_PRODUCT} (PDF).lnk"

; The following strings are used by "Function .onInit".  If you are
; adding a new language, be sure to add new tests therein, otherwise
; the English language messages will be used.

!define PreviousCygwinEnglish "A previous installation of cygwin was detected. This package is not to be used from within a cygwin enviroment. Click OK if you want to continue anyway or CANCEL if you want to abort the installation process."
!define PreviousCygwinSpanish "Se detectó una versión de cygwin instalada. Este paquete no fue diseñado para funcionar dentro de un ambiente de cygwin. Presione Aceptar si desea continuar o Cancelar si desea detener el preceso de instalación."

!define PreviousOctaveEnglish "A previous version of Octave for Windows was detected. Please uninstall any previous version before running this installer. Click OK if you want to continue anyway or CANCEL if you want to abort the installation process."
!define PreviousOctaveSpanish "Se detectó una versión anterior de Octave para Windows. Por favor desinstale cualquier versión anterior antes de ejecutar este instalador. Presione Aceptar si desea continuar o Cancelar si desea detener el proceso de instalación."

!define GenuineIntelEnglish "This version of Octave for Windows is optimized for Intel x86 processors and is known to cause troubles with other architectures. Click OK if you want to continue anyway or CANCEL if you want to abort the installation process."
!define GenuineIntelSpanish "Esta versión de Octave para Windows ha sido optimizada para procesadores Intel x86 y puede no funcionar correctamente sobre otros procesadores. Presione Aceptar si desea continuar o Cancelar si desea detener el proceso de instalación."

# ****************** End Localization ***********************

# This is the command to start octave.
!define OctaveStart "rxvt.exe --keysym.0xFF50 '^a' --keysym.0xFF57 '^e' --keysym.0xFFFF '^f^h' -fn 'Lucida Console-12' -tn linux -title '${MUI_PRODUCT}' -geometry 80x25 -sl 400 -sr -e /bin/start_octave.sh"


InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"

; Files and registry keys
Section $(TITLE_Section1) Section1

  CreateDirectory $INSTDIR\tmp
  CreateDirectory $INSTDIR\octave_files
  SetOutPath $INSTDIR\bin
  File /r "${ROOT}\opt\octave\bin\*.*"
  File "${ROOT}\opt\octave-support\*.*"
  File "install_octave.sh"
  File "start_octave.sh"
  File "octave.ico"
  SetOutPath $INSTDIR\opt\octave\share
  File /r "${ROOT}\opt\octave\share\*.*"
  SetOutPath $INSTDIR\opt\octave\libexec
  File /r "${ROOT}\opt\octave\libexec\*.*"
  SetOutPath $INSTDIR\opt\octave\doc
  File /r "${ROOT}\opt\octave\doc\*.*"
  WriteUninstaller "$INSTDIR\uninstall.exe"

  ;Write language to the registry (for the uninstaller)
  WriteRegStr HKCU "Software\GNU Octave" "Installer Language" $LANGUAGE

  ;File associations --- don't conflict with matlab's entries
  ClearErrors
  ReadRegStr $1 HKCR "" ".m"
  StrCmp $1 "matfile" Matlab NoMatlab
  NoMatlab:
  WriteRegStr HKCR ".m" "" "octfile"
  Matlab:
  WriteRegStr HKCR "octfile" "" "Octave Script File"
  WriteRegStr HKCR "octfile\DefaultIcon" "" "$INSTDIR\bin\octave.ico"
  WriteRegStr HKCR "octfile\Shell\open\command" "" '"$WINDIR\notepad.exe" "%1"'

  ;Cygwin's registry entries
  WriteRegStr HKLM \
	"SOFTWARE\GNU Octave\Cygwin\mounts v2\/" "native" "$INSTDIR"
  WriteRegDWORD HKLM \
	"SOFTWARE\GNU Octave\Cygwin\mounts v2\/" "flags" "a"
  WriteRegStr HKLM \
	"SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/bin" "native" "$INSTDIR/bin"
  WriteRegDWORD HKLM \
	"SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/bin" "flags" "a"
  WriteRegStr HKLM \
	"SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/lib" "native" "$INSTDIR/lib"
  WriteRegDWORD HKLM \
	"SOFTWARE\GNU Octave\Cygwin\mounts v2\/usr/lib" "flags" "a"
  WriteRegStr HKLM \
	"SOFTWARE\GNU Octave\Cygwin\Program Options" "temp" "temp"
  DeleteRegValue HKLM \
	"SOFTWARE\GNU Octave\Cygwin\Program Options" "temp"

  WriteRegStr HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/" "native" "$INSTDIR"
  WriteRegDWORD HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/" "flags" "a"
  WriteRegStr HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/bin" \
	"native" "$INSTDIR/bin"
  WriteRegDWORD HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/bin" "flags" "a"
  WriteRegStr HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/lib" \
	"native" "$INSTDIR/lib"
  WriteRegDWORD HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\mounts v2\/usr/lib" "flags" "a"
  WriteRegStr HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\Program Options" "temp" "temp"
  DeleteRegValue HKU \
	".DEFAULT\Software\GNU Octave\Cygwin\Program Options" "temp"

  WriteRegStr HKCU \
	"Software\GNU Octave\Cygwin\mounts v2\/" "cygdrive prefix" "/cygdrive"
  WriteRegDWORD HKCU \
	"Software\GNU Octave\Cygwin\mounts v2\/" "cygdrive flags" "22"
  WriteRegStr HKCU \
	"Software\GNU Octave\Cygwin\Program Options" "temp" "temp"
  DeleteRegValue HKCU \
	"Software\GNU Octave\Cygwin\Program Options" "temp"

  ;Uninstaller registry entries
  WriteRegStr HKLM \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\GNU Octave" \
	"DisplayName" "${MUI_PRODUCT}"
  WriteRegStr HKLM \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\GNU Octave" \
	"DisplayIcon" "$INSTDIR\bin\octave.ico"
  WriteRegStr HKLM \
	"Software\Microsoft\Windows\CurrentVersion\Uninstall\GNU Octave" \
	"UninstallString" "$INSTDIR\uninstall.exe"
SectionEnd

; Start menu shortcuts
Section "$(TITLE_Section2)" Section2
  CreateDirectory "$SMPROGRAMS\${MUI_PRODUCT}"
  CreateShortCut $(UninstallLink) \
	"$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT}.lnk" \
	"$INSTDIR\bin\run.exe" "${OctaveStart}" "$INSTDIR\bin\octave.ico" 0
  CreateShortCut $(ManualLink) \
	"$INSTDIR\opt\octave\doc\octave_toc.html"
  CreateShortCut $(RefcardLink) \
	"$INSTDIR\opt\octave\doc\refcard-letter.pdf"
  WriteINIStr $(FunctionLink) "InternetShortcut" "URL" \
	"http://octave.sourceforge.net/index/index.html"
  WriteINIStr $(EpstkLink) "InternetShortcut" "URL" \
	"http://epstk.sourceforge.net/epstk/quickref/index.html"
SectionEnd

; Desktop shortcuts
Section "$(TITLE_Section3)" Section3
  CreateShortCut "$DESKTOP\${MUI_PRODUCT}.lnk" \
	"$INSTDIR\bin\run.exe" "${OctaveStart}" "$INSTDIR\bin\octave.ico" 0
SectionEnd

; Post-installation configuration
Section "-Local Config"
  Exec "$INSTDIR\bin\sh.exe -e /bin/install_octave.sh"
SectionEnd

!insertmacro MUI_SECTIONS_FINISHHEADER

Function .onInit
  Push Tahoma
  Push 8

  ; Ask for language before doing anything else
  !insertmacro MUI_LANGDLL_DISPLAY
  Push 2F
  LangDLL::LangDialog "Installer Language" "Please select a language."
  Pop $LANGUAGE
  StrCmp $LANGUAGE "cancel" 0 +2
    Abort

  ; We may be Intel-specific, especially if compiled against ATLAS.
  ClearErrors
  ReadRegStr $1 HKLM "HARDWARE\DESCRIPTION\System\CentralProcessor\0\" "VendorIdentifier"
  StrCmp $1 "GenuineIntel" Continue0 Error0
  Error0:
    ; Language specific strings don't work in .onInit, so simulate the effect.
    StrCpy $0 "${GenuineIntelEnglish}"
    StrCmp $LANGUAGE ${LANG_SPANISH} 0 +2
	StrCpy $0 "${GenuineIntelSpanish}"
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $0 IDOK Continue0
    Abort
  Continue0:

  ; Detect an existing Octave installation
  ClearErrors
  ReadRegDWORD $1 HKLM "SOFTWARE\GNU Octave\Cygwin\mounts v2\/" flags
  IfErrors Continue1 Error1
  Error1:
    ; Language specific strings don't work in .onInit, so simulate the effect.
    StrCpy $0 "${PreviousOctaveEnglish}"
    StrCmp $LANGUAGE ${LANG_SPANISH} 0 +2
	StrCpy $0 "${PreviousOctaveSpanish}"
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $0 IDOK Continue1
    Abort
  Continue1:

  ; Detect an existing Cygwin installation
  ClearErrors
  ReadRegDWORD $1 HKLM "SOFTWARE\Cygnus Solutions\Cygwin\mounts v2\/" flags
  IfErrors Continue2 Error2
  Error2:
    ; Language specific strings don't work in .onInit, so simulate the effect.
    StrCpy $0 "${PreviousCygwinEnglish}"
    StrCmp $LANGUAGE ${LANG_SPANISH} 0 +2
	StrCpy $0 "${PreviousCygwinSpanish}"
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION $0 IDOK Continue2
    Abort
  Continue2:

FunctionEnd

!insertmacro MUI_FUNCTIONS_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${Section1} $(DESC_Section1)
!insertmacro MUI_DESCRIPTION_TEXT ${Section2} $(DESC_Section2)
!insertmacro MUI_DESCRIPTION_TEXT ${Section3} $(DESC_Section3)
!insertmacro MUI_FUNCTIONS_DESCRIPTION_END

Section "Uninstall"
  ClearErrors

  ; Clear file associations
  ReadRegStr $1 HKCR "" ".m"
  StrCmp $1 "octfile" NoMatlab Matlab
  NoMatlab:
  DeleteRegKey HKCR ".m"
  Matlab:
  DeleteRegKey HKCR "octfile\DefaultIcon"
  DeleteRegKey HKCR "octfile\Shell\open\command"
  DeleteRegKey HKCR "octfile"

  ; Clean up registry
  DeleteRegKey HKLM "SOFTWARE\GNU Octave"
  DeleteRegKey HKU ".DEFAULT\Software\GNU Octave"
  DeleteRegKey HKCU "Software\GNU Octave"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\GNU Octave"
  ;; The following used value is now stored in GNU Octave, which is cleaned above.
  ; DeleteRegKey HKCU "Software\${MUI_PRODUCT}" "Installer Language"

  ; Clean up start menu
  Delete "$DESKTOP\${MUI_PRODUCT}.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\*.*"
  Delete "$INSTDIR\*.*"
  RMDir "$SMPROGRAMS\${MUI_PRODUCT}"

  ; Clean up files
  RMDir /r "$INSTDIR"

  ;Display the Finish header
  !insertmacro MUI_UNFINISHHEADER
SectionEnd

Function un.onInit
  ;Get language from registry
  ReadRegStr $LANGUAGE HKCU "Software\GNU Octave" "Installer Language"
FunctionEnd
