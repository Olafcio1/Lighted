#!/bin/bash
tput reset
clear
trap "" SIGINT

function log() {
	if [[ "$1" == "--type" ]]; then
		case $2 in
			"info") ;;
			"warn") ;;
			"error") ;;
			*) log "E2: Unkown log type \"$2\"!"
		esac
		text="$3"
	else
		text="$@"
	fi
	echo -n "$(tput setab 1)$(tput setaf 255)$(tput bold)$text$(tput sgr0)"
	read -s -n 1
}
function on() {
	set $1="$($2)"
}
function quit() {
	if [[ "$1" == "-f" ]]; then
		tput reset
		clear
		exit 0
	else
		if [[ "$file" == "" ]]; then
			echo -n "Save to file (Y/n)? "
			read
			REPLY="$(echo $REPLY | tr '[:upper:]' '[:lower:]')"
			case ${REPLY} in
				"yes" | "ye" | "y") save ;;
				"no" | "n") quit -f ;;
				*) log "E3: Unkown response \"${REPLY}\" for question \"Save to file\"!"
			esac
		fi
	fi
}
line="1"
fullcontent=""
displaycontent=""

content=""
content_fixed=""

OnProgramLoad=""
OnNewLineStart=""
OnBeforeQuit=""
OnBeforeForceQuit=""
OnBeforeSave=""
OnAfterSave=""
OnBeforePrintContentAgain=""
OnAfterPrintContentAgain=""

if [[ ! -d "$HOME/.lighted" ]]; then mkdir $HOME/.lighted; fi
if [[ ! -f "$HOME/.lighted/config" ]]; then touch $HOME/.lighted/config; echo "# vi: ft=bash" > $HOME/.lighted/config; fi
if [[ -f "$HOME/.lighted/config" ]]; then . $HOME/.lighted/config; fi

$OnProgramLoad
while [ 1 ]; do
	$OnNewLineStart
	echo -n "$(tput setaf 2)$line$(tput sgr0) "
	read content
	if [[ "$(echo $content | cut -c -1)" == ":" ]]; then
		content_fixed="$(echo $content | cut -c 2-)"
		if [[ "$(echo $content_fixed | cut -c -1)" == "!" ]]; then
			content_fixed="$(echo $content_fixed | cut -c 2-)"
			echo $($content_fixed)
			read -s -n 1
		else
			case $content_fixed in
				"") ;;
				"q") $OnBeforeQuit; quit ;;
				"q!") $OnBeforeQuit; $OnBeforeForceQuit; quit -f ;;
				"w") $OnBeforeSave; save; $OnAfterSave ;;
				"wq" | "x") $OnBeforeSave; save; $OnAfterSave; $OnBeforeQuit; quit ;;
				"wq!" | "x!") $OnBeforeSave; save; $OnAfterSave; $OnBeforeQuit; $OnBeforeForceQuit; quit -f ;;
				*) log "E1: Unkown command"
			esac
		fi
	else
		if [[ "$fullcontent" == "" ]]; then
			fullcontent="$content"
			displaycontent="$(tput setaf 2)$line$(tput sgr0) $content"
		else
			fullcontent+="
$content"
			displaycontent+="
$(tput setaf 2)$line$(tput sgr0) $content"
		fi
		line="$(( $line + 1 ))"
	fi
	clear
	$OnBeforePrintContentAgain
	echo "$displaycontent"
	$OnAfterPrintContentAgain
done
