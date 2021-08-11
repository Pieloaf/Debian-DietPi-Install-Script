# SCRIPT

WARN="\033[0;31m[WARNING]:\033[0m"
Y_INFO="\033[1;33m[INFO]:\033[0m"
G_INFO="\033[0;32m[INFO]:\033[0m"
ABORT="\033[0;33m[ABORT]:\033[0m"

echo -e "${WARN} This installer is going to remove all data on the system"
echo -e "${WARN} Make sure to backup any data you want to keep"

while true; do
    echo -e "${Y_INFO} Start DietPi installation? (y/n)"
    read yn 
    case $yn in
        [Yy]* ) sleep 1; echo -e "${Y_INFO} Starting now.."; break;;
        [Nn]* ) echo -e "${ABORT} Script stopped."; exit;;
        * );;
    esac
done


echo -e "${Y_INFO} Fetching updates and insalling \"wget\""

eval "apt update"
eval "apt-get install wget -y"

echo -e "${Y_INFO} Fetching current \"PREP_SYSTEM_FOR_DIETPI.sh\" from GitHub.."

wget https://raw.githubusercontent.com/MichaIng/DietPi/master/PREP_SYSTEM_FOR_DIETPI.sh -O PREP_SYSTEM_FOR_DIETPI.sh
chmod +x PREP_SYSTEM_FOR_DIETPI.sh

echo -e "${Y_INFO} Starting script: \"PREP_SYSTEM_FOR_DIETPI.sh\""

./PREP_SYSTEM_FOR_DIETPI.sh

rm PREP_SYSTEM_FOR_DIETPI.sh


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

echo -e "${WARN} Please keep in mind that there is a chance your system might not be able to boot after this"

while true; do
    echo -e "${Y_INFO} Reboot now? (y/n)";
    read yn;
    case $yn in
        [Yy]* ) echo -e "${G_INFO} Username: root \n${G_INFO} Password: dietpi\n${Y_INFO} Rebooting now.."; sleep 3; reboot; break;;
        [Nn]* ) echo -e "${ABORT} Script stopped."; exit;;
        * );;
    esac
done
