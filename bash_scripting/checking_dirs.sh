#showusage.sh

#!/bin/sh

show_usage() {
    echo "Użycie: $0 katalog_źródłowy katalog_docelowy" 1>&2        #Użycie: showusage katalog_źródłowy katalog_docelowy
    exit 1
}

if [ $# -ne 2 ]; then
    show_usage
else # Są dwa argumenty
    if [ -d $1 ]; then
        source_dir=$1
    else
        echo 'Nieprawidłowy katalog źródłówy' 1>&2
        show_usage
    fi
    if [ -d $2 ]; then
        dest_dir=$2
    else
        echo 'Nieprawidłowy katalog docelowy' 1>&2
        show_usage
    fi
fi

printf "Katalogiem źródłowym jest ${source_dir}\n"
printf "Katalogiem docelowym jest ${dest_dir}\n"