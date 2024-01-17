#Update and upgrade

continue="no"
reboot="no"
crontab="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--continue)
            ="yes"
            shift
            ;;
    case "$1" in
        -r|--reboot)
            ="yes"
            shift
            ;;
    case "$1" in
        -r|--crontab)
            ="yes"
            shift
            ;;
    esac
done

main.run() {
#Update

}



saveto.bashrc(){
# Get the current working directory
current_dir=$(pwd)

# Get the username
current_user=$(whoami)

# Define the path to the script file
script_file="$current_dir/install.sh"

# Check if the script file exists
if [ -f "$script_file" ]; then
    # Backup the existing .bashrc as .bashrc.original
    if [ "$current_user" = "root" ]; then
        bashrc_backup="/root/.bashrc.original"
        echo "Backing up existing .bashrc to $bashrc_backup"
        cp "/root/.bashrc" "$bashrc_backup"
    else
        bashrc_backup="/home/$current_user/.bashrc.original"
        echo "Backing up existing .bashrc to $bashrc_backup"
        cp "/home/$current_user/.bashrc" "$bashrc_backup"
    fi

    # Append the script execution line to the user's .bashrc
    if [ "$current_user" = "root" ]; then
        echo "/bin/bash $script_file -c" >> "/root/.bashrc"
        echo "Script execution line appended to .bashrc for root user"
    else
        echo "/bin/bash $script_file -c" >> "/home/$current_user/.bashrc"
        echo "Script execution line appended to .bashrc for user: $current_user"
    fi
else
    echo "Script file not found: $script_file"
fi
}


continue.run() {



}




Update

Install

DNS

Save Bashrc

reboot?

clone

make

build

run

crontab


