
continue="no"
reboot="yes"
crontab="yes"
wallet="Im-empty"
sudo="yes"
resume_dir=""

current_dir=$(pwd)
current_user=$(whoami)

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--continue)
            continue="yes"
            shift
            ;;
        -ns|--no-sudo-crontab)
            sudo="no"
            shift
            ;;
        -nr|--no-reboot)
            reboot="no"
            shift
            ;;
        -nc|--no-crontab)
            crontab="no"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done




check.home() {
    current_dir=$(pwd)
    home_directory=$(eval echo ~)

    if [ "$current_dir" != "$home_directory" ]; then
        echo "Error: It is recommended that you execute this script in your home directory."
        read -p "You are currently in $current_dir. Continue? (y/n): " answer

        if [ "$answer" != "y" ] && [ "$answer" != "Y" ] && [ "$answer" != "yes" ] && [ "$answer" != "Yes" ]; then
            printf "\nExiting script.\n"
            exit 1
        fi
    fi
}

save.wallet() {
read -p "Paste your XMR wallet address here:" wallet
sed -i "s/^wallet=.*/wallet=\"$wallet\"/" "$current_dir/install.sh"
}






#Update
update.run() {
sudo apt-get update -y
sudo apt-get upgrade -y
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



build.xmrig() {
git clone https://github.com/xmrig/xmrig.git
mkdir -p $current_dir/xmrig/build/
cmake -B $current_dir/xmrig/build $current_dir/xmrig/
sleep 1
printf "\nThis will take a while, grab a coffee\n\n"
sleep 2
make --directory $current_dir/xmrig/build/

sleep 1
printf "\nBuild done\n"
sleep 1
clear
printf "\nBuild done\n"

}

############Auto crontab not implemented yet################
addto.crontab(){
    # Define the cron job line
    cron_line="@reboot /usr/bin/screen -dmS xmrig /bin/bash $current_dir/xmrig/build/xmrig > /dev/null 2>&1"

    # Check if sudo flag is provided
    if [ -n "$sudo" ]; then
        # Add the line to the root crontab using sudo
        ($sudo crontab -l ; echo "$cron_line") | $sudo crontab -
        echo "Cron job added to root crontab successfully."
    else
        # Add the line to the user's crontab
        (crontab -l ; echo "$cron_line") | crontab -
        echo "Cron job added to user crontab successfully."
    fi

}



#Clearing bashrc#
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


run.xmrig(){
/usr/bin/screen -dmS xmrig $current_dir/xmrig/build/xmrig > /dev/null 2>&1
}



#Make the config.json file
make.config(){
touch $current_dir/xmrig/build/config.json
printf "\n"

printf "
{
    \"api\": {
        \"id\": null,
        \"worker-id\": null
    },
    \"http\": {
        \"enabled\": false,
        \"host\": \"127.0.0.1\",
        \"port\": 0,
        \"access-token\": null,
        \"restricted\": true
    },
    \"autosave\": true,
    \"background\": false,
    \"colors\": true,
    \"title\": true,
    \"randomx\": {
        \"init\": -1,
        \"init-avx2\": -1,
        \"mode\": \"auto\",
        \"1gb-pages\": false,
        \"rdmsr\": true,
        \"wrmsr\": true,
        \"cache_qos\": false,
        \"numa\": true,
        \"scratchpad_prefetch_mode\": 1
    },
    \"cpu\": {
        \"enabled\": true,
        \"huge-pages\": true,
        \"huge-pages-jit\": false,
        \"hw-aes\": null,
        \"priority\": null,
        \"memory-pool\": false,
        \"yield\": true,
        \"max-threads-hint\": 100,
        \"asm\": true,
        \"argon2-impl\": null,
        \"cn/0\": false,
        \"cn-lite/0\": false
    },
    \"opencl\": {
        \"enabled\": false,
        \"cache\": true,
        \"loader\": null,
        \"platform\": \"AMD\",
        \"adl\": true,
        \"cn/0\": false,
        \"cn-lite/0\": false
    },
    \"cuda\": {
        \"enabled\": false,
        \"loader\": null,
        \"nvml\": true,
        \"cn/0\": false,
        \"cn-lite/0\": false
    },
    \"donate-level\": 1,
    \"donate-over-proxy\": 1,
    \"log-file\": null,
    \"pools\": [
        {
            \"algo\": null,
            \"coin\": null,
            \"url\": \"gulf.moneroocean.stream:20128\",
            \"user\": \"$wallet\",
            \"pass\": \"Scriptmachine\",
            \"rig-id\": null,
            \"nicehash\": false,
            \"keepalive\": false,
            \"enabled\": true,
            \"tls\": true,
            \"tls-fingerprint\": null,
            \"daemon\": false,
            \"socks5\": null,
            \"self-select\": null,
            \"submit-to-origin\": false
        }
    ],
    \"print-time\": 60,
    \"health-print-time\": 60,
    \"dmi\": true,
    \"retries\": 5,
    \"retry-pause\": 5,
    \"syslog\": false,
    \"tls\": {
        \"enabled\": true,
        \"protocols\": null,
        \"cert\": null,
        \"cert_key\": null,
        \"ciphers\": null,
        \"ciphersuites\": null,
        \"dhparam\": null
    },
    \"dns\": {
        \"ipv6\": false,
        \"ttl\": 30
    },
    \"user-agent\": null,
    \"verbose\": 0,
    \"watch\": true,
    \"pause-on-battery\": false,
    \"pause-on-active\": false
}

" > $current_dir/xmrig/build/config.json
clear

printf "\nSuccessfully created config in $current_dir/xmrig/build/config.json\n"

}



if [ "$continue" = "no" ]; then
    printf "\nThis script installs the Xmrig Monero miner on your machine\n"
    check.home
    save.wallet
    update.run
    saveto.bashrc
    if [ "$reboot" = "yes" ]; then
        sys.restart
    else
        printf "\nNo reboot option chosen\n"
    fi
elif [ "$continue" = "yes" ]; then
    printf "\nWelcome back\n"
    sleep 1
    printf "\nResuming Xmrig install script\n"
    printf "\nEnter your root password:\n"
    sudo echo 
    sleep 1
    build.xmrig
    bashrc.clear
    make.config
    run.xmrig
    printf "\nInstall complete, screen logs are in $current_dir/xmrig/build/xmlog.txt\n"
    printf "\nDo \"screen -R xmrig\" to access the xmrig console\n"
fi


: <<'COMMENT'
Want to do:
- Debugging mode to run one function at a time
- Record all cli into a log.txt
- Make redundancy so that config.json does not get cat twice
    -nvm fixed it
    -some redundancy wouldnt hurt
- Make the code pretty
- Make outputs and printfs prettier
COMMENT