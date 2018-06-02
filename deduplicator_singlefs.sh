#!/bin/bash

determineFSroot() {
    df . | tail -n 1 | awk '{ print $6 }'
}

deduplicateFiles() {
    if [ "$#" -eq 2 ]
    then \
        if [ -f "$1" ] && [ -f "$2" ] && [ `stat -c %i "$1"` -ne `stat -c %i "$2"` ]
        then \
            if cmp "$1" "$2"
            then \
                echo "File $2 will be deleted!"
                rm -f "$2"
            else \
                echo "Something went wrong, files $1 and $2 have different content!"
            fi
        else \
            echo "Files $1 and $2 may be hardlinks or not regular files, doing nothing."
        fi
    else \
        echo "Invalid number of arguments given."
        echo "Accepting only 2 filename parameters."
    fi
}

deduplicateMultipleFilesWrapper() {
    originalfile=""
    redundantfile=""
    while read line
    do \
        [ -z "$line" ] && break
        if [ -z "$originalfile" ]
        then \
            originalfile="$line"
        else \
            redundantfile="$line"
            echo "Original file is: $originalfile"
            echo "Redundant file is: $redundantfile"
            echo "Doing deduplication..."
            deduplicateFiles "$originalfile" "$redundantfile"
            echo "Deduplication done."
        fi
    done
}

userid=`id -u`
fsrootdir=`determineFSroot`
filesystemname=`echo $fsrootdir | tr -d "/"`
sha256sumfilename=".${filesystemname}_sha256sums.txt"
sha256sumfilenewname=".${filesystemname}_sha256sums_new.txt"
deduplicatedfilename=".duplicate_sums.txt" # WARNING: should be changed some time

if [ `uname -o` != "GNU/Linux" ]
then \
    echo "This script heavily relies on GNU versions of tools."
    echo "It should NEVER be run on anything but GNU/Linux without adjusting."
    exit 1
fi

if [ "$fsrootdir" != "$PWD" ]
then \
    cd "$fsrootdir"
fi

if [ "$fsrootdir" == "$PWD" ] && [ "$userid" -eq `stat -c %u "$fsrootdir"` ] && stat -c %A "$fsrootdir" | grep -oE '^drwx' >/dev/null
then \
    if [ ! -e "$sha256sumfilename" ]
    then \
        echo "Creating file ${fsrootdir}/${sha256sumfilename} containing SHA256 checksums of all files..."
        find . -xdev -type f -and -not -name "$sha256sumfilename" -and -not -name "$sha256sumfilenewname" | xargs -d"\n" sha256sum > "$sha256sumfilename"
        echo "File containing SHA256 checksums of all files created."
    else \
        if [ -f "$sha256sumfilename" ]
        then \
            echo "Updating file ${fsrootdir}/${sha256sumfilename} containing SHA256 checksums of all files..."
            cat /dev/null > "$sha256sumfilenewname" # create an empty new sum file
            find . -xdev -type f -and -not -name "$sha256sumfilename" -and -not -name "$sha256sumfilenewname" \
                | while read line
                    do \
                        foundFileNameInSumFile=`grep -F "$line" "$sha256sumfilename"`
                        if [ -n "$foundFileNameInSumFile" ]
                        then \
                            echo "$foundFileNameInSumFile" | head -n 1 >> "$sha256sumfilenewname"
                        else \
                            sha256sum "$line" >> "$sha256sumfilenewname"
                        fi
                    done
            mv -f "$sha256sumfilenewname" "$sha256sumfilename"
            echo "File containing SHA256 checksums of all files updated."
        fi
    fi

    
    if [ ! -e "$deduplicatedfilename" ] || [ `stat -c %Y "$deduplicatedfilename"` -lt `stat -c %Y "$sha256sumfilename"` ]
    then \
        echo "Creating file ${fsrootdir}/${deduplicatedfilename} containing SHA256 checksums of all duplicates..."
        cat "$sha256sumfilename" | awk '{print $1}' | sort | uniq -d > "$deduplicatedfilename"
        echo "File containing SHA256 checksums of all duplicates created."
    fi

    if [ -f "$deduplicatedfilename" ]
    then \
        for duplicateFileSum in `cat "$deduplicatedfilename"`
        do \
            grep -E "^$duplicateFileSum" "$sha256sumfilename" | awk '{ for (i=2; i<NF; i++) printf "%s",$i OFS; if(NF) printf "%s",$NF ORS }' | deduplicateMultipleFilesWrapper
        done
    fi    
else \
    echo "We are not the owner of this filesystem: $fsrootdir , exiting"
    exit 1
fi
