#!/bin/bash
#=======================================================================
#          FILE:  var_replacer.sh
#         USAGE:  ./var_replacer.sh <english/russian>
#       EXAMPLE:  ./var_replacer.sh english
#         NOTES:  This script replaces all language vars in wifi-autopwner.sh
#                 with the corresponding strings in LANGUAGE.txt
#        AUTHOR: j0nk0
#       CREATED: 17.09.2018
#      REVISION: 0.0.1
#=======================================================================
declare -A Lang

#Set language
case $1 in
 english|English|ENGLISH) LANGUAGE=English ;;
 russian|Russian|RUSSIAN) LANGUAGE=Russian ;;
 *) echo "No or wrong language given, taking default: english" ;LANGUAGE=English ;;
esac
echo "Using language: $LANGUAGE"

langfile="$(dirname $0)/$LANGUAGE.txt"
wifi_autopwner="$(dirname $0)/../wifi-autopwner.sh"

! [ -f $langfile ] && echo "Cannot find: $langfile" && exit
! [ -f $wifi_autopwner ] && echo "Cannot find: $wifi_autopwner" && exit

#Backup $wifi_autopwner
echo "Backing up: $wifi_autopwner"
cp --verbose --backup=numbered $wifi_autopwner $(echo $wifi_autopwner)_bak

#Replace "::" to "_"
sed -i 's/\:\:/_/g' $langfile

for i in $(seq 1 $(cat $langfile | wc -l)); do
	#                                    | cut text       | Replace ( w. \[ | Replace ) w. \] | Replace / w. \/
	text="$(grep "Strings$i\_" $langfile | cut -d "_" -f2 | sed 's/(/\\[/g' | sed 's/)/\\]/g' | sed -r 's|\/|\\/|g')"
	echo "GrepBefore"
	echo "Replacing: Strings$i with:"
	echo "$text"
	sed -i "s/\${Lang\[Strings$i\]}/$text/g" $wifi_autopwner
	echo ""
done

#Replace "_" back to "::"
sed -i 's/_/\:\:/g' $langfile

echo "Done"
