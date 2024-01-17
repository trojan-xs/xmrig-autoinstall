#Update and upgrade

continue="no"
reboot="no"
crontab="no"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--continue)
            continue="yes"
            shift
            ;;
    case "$1" in
        -r|--reboot)
            reboot="yes"
            shift
            ;;
    case "$1" in
        -r|--crontab)
            crontab="yes"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done


#Update
Update.run() {
Sudo apt-get update -y
Sudo apt-get upgrade -y
sudo apt install curl git net-tools screen nmap jq build-essential cmake libuv1-dev libssl-dev libhwloc-dev resolvconf -y

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


#Restart
sys.restart() {
printf "\nServer rebooting. Login with same user after reboot to continue install\n"
sleep 2
printf "\nServer Rebooting. Press Ctrl C to abort\n"
sleep 5
echo Rebooting
sleep 5
sudo reboot
}



continue.run() {
git clone https://github.com/xmrig/xmrig.git
if [ "$current_user" = "root" ]; then
    bashrc_backup="/root/.bashrc.original"
 else
    mkdir /home/$current_user/.bashrc.original"

}







### Clearing bashrc ###
bashrc.clear(){
printf "\nClearing bashrc\n"
sleep 3
# Get the username
current_user=$(whoami)

# Determine the home directory based on the user
if [ "$current_user" = "root" ]; then
    home_directory="/root"
else
    home_directory="/home/$current_user"
fi

# Define the paths
bashrc_file="$home_directory/.bashrc"
bashrc_backup="$home_directory/.bashrc.original"

# Check if .bashrc.original backup exists
if [ -f "$bashrc_backup" ]; then
    # Backup exists, delete current .bashrc and rename .bashrc.original
    rm "$bashrc_file"
    mv "$bashrc_backup" "$bashrc_file"
    printf "\nRestored .bashrc from backup.\n"
else
    # Backup does not exist
    printf "\nNo .bashrc.original backup found. No changes made.\n"
fi
}