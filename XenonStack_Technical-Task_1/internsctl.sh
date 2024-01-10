#!/bin/bash


manual() {
    echo "internsctl - Custom Command"
    echo "Usage: internsctl [COMMAND] [OPTIONS] [ARGUMENTS]"
    echo "Commands:"
    echo "  man                           Display manual"
    echo "  --version                     Display version"
    echo "  --help                        Show available commands"
    echo "  cpu getinfo                   Display CPU information"
    echo "  memory getinfo                Display memory information"
    echo "  user create <username>        Create a new user"
    echo "  user list                     List regular users"
    echo "  user list --sudo-only         List users with sudo privileges"
    echo "  file getinfo [options] <file> Display file information"
    echo "Options for 'file getinfo':"
    echo "  --size, -s                    Print size"
    echo "  --permissions, -p              Print file permissions"
    echo "  --owner, -o                   Print file owner"
    echo "  --last-modified, -m            Print last modified"
}


createUser()
{
    if id "$1" &>/dev/null; then
    echo "User $1 already exists"
    else
    sudo useradd -m "$1"
    fi
}

list_regular_users() {
    getent passwd | grep -E '(/bin/bash|/bin/sh)' | cut -d: -f1
}

list_sudo_users() {
    getent group sudo | cut -d: -f4 | tr ',' '\n'
}

get_file_info() {
    if [ -z "$2" ]; then
        file="$1"
    else
        file="$2"
    fi

    if [ ! -f "$file" ]; then
            echo "File '$file' does not exist."
            exit 1
        fi

    file_info=$(stat -c "File: %n\nAccess: %A\nSize(B): %s\nOwner: %U\nModify: %y" "$file")

    if [ "$1" = "--size" ] || [ "$1" = "-s" ]; then
        echo -e "$file_info" | awk '/Size\(B\):/ {print $2}'
    elif [ "$1" = "--permissions" ] || [ "$1" = "-p" ]; then
        echo -e "$file_info" | awk '/Access:/ {print $2}'
    elif [ "$1" = "--owner" ] || [ "$1" = "-o" ]; then
        echo -e "$file_info" | awk '/Owner:/ {print $2}'
    elif [ "$1" = "--last-modified" ] || [ "$1" = "-m" ]; then
        echo -e "$file_info" | awk '/Modify:/ {$1=""; print substr($0,2)}'
    else
        echo -e "$file_info"
    fi
}

version="0.1.0"
if [ "$1" = "man" ] || [ "$1" = "internsctl" ]; then
    manual
elif [ "$1" = "--version" ]; then
    echo "Version: $version"
elif [ "$1" = "--help" ]; then
    manual

#easy level
elif [ "$1" = "cpu" ] && [ "$2" = "getinfo" ]; then
    lscpu
elif [ "$1" = "memory" ] && [ "$2" = "getinfo" ]; then
    free

#Intermediate level
elif [ "$1" = "user" ] && [ "$2" = "create" ]; then
    if [ -z "$3" ]; then
    echo "Usage: internsctl user create <username>"
    else
    createUser "$3"
    fi    
elif [ "$1" = "user" ] && [ "$2" = "list" ]; then
    list_regular_users
elif [ "$1" = "user" ] && [ "$2" = "list" ] && [ "$3" = "--sudo-only" ]; then
    list_sudo_users

#Advanced level
elif [ "$1" = "file" ] && [ "$2" = "getinfo" ]; then
    if [ -z "$3" ]; then
        echo "Usage: internsctl file getinfo [options] <file-name>"
    else
        get_file_info "$3" "$4"
    fi

else
    echo "Invalid command. Use 'man internsctl' for manual"
fi