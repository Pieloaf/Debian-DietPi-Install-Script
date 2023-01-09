#------------------------------------------------------------------------------------------------
# Optimise current Debian install and prepare DietPi installation for ionos/vm servers
# Script is made to work for Debian installs on ionos/vm servers
# but relies heavily on the premade installer from DietPi itself:
# https://github.com/MichaIng/DietPi/blob/master/.build/images/dietpi-installer
#------------------------------------------------------------------------------------------------


WARN="\033[0;31m[WARNING]:\033[0m"
Y_INFO="\033[1;33m[INFO]:\033[0m"
G_INFO="\033[0;32m[INFO]:\033[0m"
ABORT="\033[0;33m[ABORT]:\033[0m"

# Warnings for the user the beginning
echo -e "${WARN} This installer is going to remove all data on your system"
echo -e "${WARN} Make sure to backup any data you want to keep before launching script"
echo -e "${WARN} Interrupting the script while it is running can break your entire system"

while true; do
    echo -e "${Y_INFO} Start Custom-DietPi installation? (y/n)"
    read yn 
    case $yn in
        [Yy]* ) sleep 1; echo -e "${Y_INFO} Starting now.."; break;;
        [Nn]* ) echo -e "${ABORT} Script aborted"; exit;;
        * );;
    esac
done

echo -e "${Y_INFO} Fetching current \"dietpi-installer.sh\" from GitHub.."

# wget needs to be installed if pulled via curl
wget https://raw.githubusercontent.com/MichaIng/DietPi/master/.build/images/dietpi-installer -O dietpi-installer.sh
chmod +x dietpi-installer.sh

echo -e "${Y_INFO} Starting script: \"dietpi-installer.sh\""

./dietpi-installer.sh

echo -e "${Y_INFO} Cleaning script: \"dietpi-installer.sh\""
rm dietpi-installer.sh


# Change to root folder since the installer breaks if youre in specific directories
echo -e "${Y_INFO} Changing directory to root"
cd /

echo -e "${Y_INFO} Checking for swap partition position.."
cmd_text="blkid | grep -oP '(?<=/dev/mapper/vg00-lv00:).*'"
cmd_out=$(eval "$cmd_text")

swap="TYPE=\"swap\""

if [[ $cmd_out == *$swap ]]
then 
        echo -e "${Y_INFO} Swap in front of root";
        lv_num="01"
else
        echo -e "${Y_INFO} Swap behind of root";
        lv_num="00"; fi

eval "apt update"
eval "apt install initramfs-tools -y"
eval "apt install lvm2 -y"
eval "apt autopurge -y"
sed -i '\|[[:blank:]]/[[:blank:]]|s|UUID=\"[^\"]*\"|/dev/mapper/vg00-lv${lv_num}|' /etc/fstab
eval "update-initramfs -u"

if [[ $lv_num == "01" ]]
then
        eval "/boot/dietpi/func/dietpi-set_swapfile 0";
        eval "mkswap /dev/mapper/vg00-lv00";
        eval "swapon /dev/mapper/vg00-lv00";
        eval "echo '/dev/mapper/vg00-lv00 none swap sw' >> /etc/fstab";
fi

# Ask user about a reboot and give warning infos
echo -e "${WARN} Please keep in mind that there is a chance your system might not be able to boot after this"
while true; do
    echo -e "${Y_INFO} Reboot now? (y/n)";
    read yn;
    case $yn in
        [Yy]* ) echo -e "${G_INFO} Username: root \n${G_INFO} Password: dietpi\n${Y_INFO} Rebooting now.."; sleep 3; reboot; break;;
        [Nn]* ) echo -e "${ABORT} Script aborted"; exit;;
        * );;
    esac
done
