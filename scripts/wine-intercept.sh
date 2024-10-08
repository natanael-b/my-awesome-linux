#!/usr/bin/env bash
#
# Translations:
#
#   - C     -> suggestAlternative -> `You are trying to install ${1}\nBut this is a Windows-only software :(\n\nDo you want to install ${2} instead?`
#   - C     -> suggestNative      -> `You are trying to install ${1}\nThis version is Windows-only\n\nDo you want to install the correct version?`
#   - C     -> suggestWine        -> `You are trying to install ${1}\nIt needs Wine to work and this takes a while on first app\n\nDo you want to continue?`
#   - C     -> unknown            -> `You are trying to install ${1}\nUnfortunately we do not recognize this file :(`
#   - C     -> sucess             -> `Installation was successful`
#   - C     -> fail               -> `Installation failed :(`
#   - C     -> title              -> `Install`
#
#   - pt_BR -> suggestAlternative -> `Você está tentando instalar o ${1}\nSó que esse é um software apenas para Windows :(\n\nDeseja instalar o ${2} no lugar?`
#   - pt_BR -> suggestNative      -> `Você está tentando instalar o ${1}\nEssa versão é apenas Windows\n\nDeseja instalar a versão certa?`
#   - pt_BR -> suggestWine        -> `Você está tentando instalar o ${1}\nEle precisa do Wine pra funcionar e isso leva um tempinho no primeiro app\n\nDeseja prosseguir?`
#   - pt_BR -> unknown            -> `Você está tentando instalar o ${1}\nInfelizmente não reconhecemos esse arquivo :(`
#   - pt_BR -> sucess             -> `A instalação foi um sucesso\n`
#   - pt_BR -> fail               -> `A instalação falhou :(\n`
#   - pt_BR -> title              -> `Instalação - `
#
#  Apps:
#
#   > Notepad++         #   npp.*.(exe|msi)                # suggestWine           # 
#   > XnView MP         #   XnViewMP-win.*.exe             # suggestWine           # 
#   > XnView Classic    #   XnView-win-small.exe           # suggestWine           # 
#   > XnConvert         #   XnConvert-win.*.exe            # suggestWine           # 
#   > XnResize          #   XnRetro.exe                    # suggestWine           # copy-directory
#   > XnSketch          #   XnRetro.exe                    # suggestWine           # copy-directory
#   > PhotoScape        #   PhotoScapeSetup_V3-7.exe       # suggestWine           #
#   > Sumatra PDF       #   SumatraPDF-.*-install.exe      # suggestWine           # csd.reg
#   > Scratch           #   scratch.*.setup.*.(exe|msi)    # suggestNative         # edu.mit.Scratch
#   > Paint.NET         #   paint.net.*.exe                # suggestAlternative    # Pinta $ com.github.PintaProject.Pinta
#   > WinRAR            #   winrar-.*.exe                  # suggestAlternative    # Ark $ org.kde.ark
#   > Mozilla Firefox   #   firefox\\s+setup.*.(exe|msi)   # suggestNative         #
#   > Internet Explorer #   (eie11|ie11).*.(exe|msi)       # suggestNative         # com.microsoft.Edge
#   > Brave Browser     #   (eie11|ie11).*.(exe|msi)       # suggestNative         # com.brave.Browser
#   > Microsoft Edge    #   microsoftedgesetup.*.(exe|msi) # suggestNative         # com.microsoft.Edge
#   > Opera             #   opera(.*.|)setup.*.(exe|msi)   # suggestNative         # com.opera.Opera
#   > Thunderbird Mail  #   thunderbird.*.(exe|msi)        # suggestNative         # org.mozilla.Thunderbird
#   > Dropbox           #   dropbox.*.exe                  # suggestNative         # com.dropbox.Client
#   > Skype             #   skype.*.exe                    # suggestNative         # com.skype.Client
#   > Adobe Reader      #   reader.*.exe                   # suggestAlternative    # Okular $ org.kde.okular
#   > Adobe Reader      #   acrordr.*.exe                  # suggestAlternative    # Okular $ org.kde.okular

#
#
ME=$(readlink -f "${0}")
PATTERNS=$(grep "^#   > " "${ME}")

function sanitize(){
  echo "${1}" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//'
}

function translate(){
    local language=$(echo "${LANG}" | cut -d\. -f1)
    local messageID="${1}"
    local message=$(grep -m1 "${language}.*${messageID}" "${ME}" | cut -d\` -f2)
          message=$(sanitize "${message}")
    
    [ ! "${message}" = "" ] && {
        echo "${message}"
        return
    }

    message=$(grep -m1 "${language}.*${messageID}" "${ME}" | cut -d\` -f2)
    sanitize "${message}"
}

title=$(translate "title")" - "$(basename "${1}" | sed -E 's/(.{32})(.{1,})$/\1.../')

function confirm() {
  yad --title="${title}" --text="${1}\n" --borders=32 --button=gtk-yes:0  --button=gtk-no:1 --fixed --center --width=480
}

function unknown(){
   local message=$(translate "unknown" | sed "s|\${1}|${1}|;s|\${2}|${2}|")
   yad --title="${title}" --text="${message}\n" --borders=32 --button=gtk-yes:0  --button=gtk-close:1 --fixed --center --width=480
}

function fail(){
   local message=$(translate "fail" | sed "s|\${1}|${1}|;s|\${2}|${2}|")
   yad --title="${title}" --text="${message}\n" --borders=32 --button=gtk-yes:0  --button=gtk-close:1 --fixed --center --width=480
}

function success(){
   local message=$(translate "success" | sed "s|\${1}|${1}|;s|\${2}|${2}|")
   yad --title="${title}" --text="${message}\n" --borders=32 --button=gtk-yes:0  --button=gtk-ok:1 --fixed --center --width=480
}

#----------------------------------------------------------------------------------------------------------------------------------------

while IFS= read -r line; do
    appname=$(echo "${line}" | cut -d\# -f2 | sed 's|   > ||')
    filename_pattern=$(echo "${line}" | cut -d\# -f3)
    operation=$(echo "${line}" | cut -d\# -f4)
    extra_args=$(echo "${line}" | cut -d\# -f5)

    appname=$(sanitize "${appname}")
    filename_pattern=$(sanitize "${filename_pattern}")
    operation=$(sanitize "${operation}")
    extra_args=$(sanitize "${extra_args}")

    grep -qPi "${filename_pattern}" <<< "${1}" || continue ;

    [ "${operation}" = "suggestWine" ] && {
        flatpak list | grep -q "org.winehq.Wine" && {
          flatpak run org.winehq.Wine "${1}"
          exit
        }

        message=$(translate "suggestWine" | sed "s|\${1}|${1}|;s|\${2}|${2}|")
        confirm "${message}" || exit

        flatpak install "org.winehq.Wine" -y && flatpak run org.winehq.Wine "${1}" && { success; } || { fail; }
        exit
    }

    [ "${operation}" = "suggestNative" ] && {
        message=$(translate "suggestNative" | sed "s|\${1}|${appname}|")
        confirm "${message}" || exit

        flatpak install "${extra_args}" -y && { success; } || { fail; }
        exit
    }

    [ "${operation}" = "suggestAlternative" ] && {
        alternativeName=$(cut -d\$ -f1 <<< "${extra_args}")
        alternativePackage=$(cut -d\$ -f2 <<< "${extra_args}")

        alternativeName=$(sanitize "${alternativeName}")
        alternativePackage=$(sanitize "${alternativePackage}")

        message=$(translate "suggestAlternative" | sed "s|\${1}|${appname}|;s|\${2}|${alternativeName}|")
        confirm "${message}" || exit

        flatpak install "${alternativePackage}" -y && { success; } || { fail; }
        exit
    }
done <<< "${PATTERNS}"

unknown "${1}"
