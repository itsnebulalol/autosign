#!/usr/bin/env bash

set -e

_exit_handler() {
    if [ $? -eq 0 ]; then
        rm -rf tmp/funny tmp2 "$(pwd)/ldid"
        exit
    fi

    echo "[-] An error occurred"
    rm -rf tmp/funny tmp2 "$(pwd)/ldid"

    exit 1;
}
trap _exit_handler EXIT

# Find ldid or download it
kernel=$(uname)
rm -rf tmp/funny tmp2
mkdir -p tmp/funny tmp2
ldid_in_path="$(command -v ldid)"
if [ "$ldid_in_path" != "" ]; then
    ldid="$ldid_in_path"
    echo "[*] Found ldid at $ldid"
else
    exit
fi

# Signing function
function sign() {
    filetype="$(file "$1" | awk '{ print $2 }')"
    path_in_deb=$(echo $1 | sed 's/tmp\/funny//')
    if [[ "$1" = *".app" ]]; then
        touch tmp2/.repackage_needed

        mode=$(stat -c "%a" $1)
        "$2" -s $1
        chmod $mode $1 || true
        echo "[*] Resigned app $path_in_deb"
    elif [[ "$filetype" = *"Mach-O" && "$1" != *".app"* ]]; then
        touch tmp2/.repackage_needed

        mode=$(stat -c "%a" $1)
        "$2" -s $1
        chmod $mode $1 || true
        echo "[*] Resigned binary $path_in_deb"
    fi
}
export -f sign

dpkg-deb -R "$1" tmp/funny

# Sign stuff if needed
echo "[*] Signing files in deb, this may take awhile on bigger debs..."
find tmp/funny/ ! -wholename "*.app/*" -exec bash -c "sign \"{}\" $ldid" \; || true

if [ ! -f "tmp2/.repackage_needed" ]; then
    echo "[*] Nothing needed to be signed, exiting!"
    rm -rf tmp/funny tmp2 "$(pwd)/ldid"
    exit
fi

# Repackage, since its needed
echo "[*] Building deb, this may take a minute..."
dpkg-deb -Zxz -b tmp/funny "$1" > /dev/null
echo "[*] Deb resigned!"

rm -rf tmp/funny tmp2 "$(pwd)/ldid"
