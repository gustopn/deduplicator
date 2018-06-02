#!/bin/bash

removeEmptyDirFunc() {
    if [ -n "$1" ]
    then \
        if [ -d "$1" ]
        then \
            cd -- "./${1}"
        else \
            echo "String $1 is not a directory"
            return 1
        fi
    fi

    for filehandle in *
    do \
        if [ -d "$filehandle" ]
        then \
            if ( removeEmptyDirFunc "$filehandle" )
            then \
                echo "In directory $PWD removing empty directory: $filehandle"
                rmdir -- "./${filehandle}"
            fi
        fi
    done
    
    if [ `/bin/ls -1 | wc -l` -eq 0 ] && [ `/bin/ls -a1 | wc -l` -eq 2 ]
    then \
        return 0
    else \
        return 1
    fi
}

removeEmptyDirFunc