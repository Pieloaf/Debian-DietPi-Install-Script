# SCRIPT


echo -e "\033[0;31m[WARNING]:\033[0m This installer is going to remove all data on the system"
echo -e "\033[0;31m[WARNING]:\033[0m Make sure to backup any data you want to keep"

while true; do
    echo -e "\033[1;33m[INFO]:\033[0m Start DietPi installation? (y/n)"
    read yn 
    case $yn in
        [Yy]* ) sleep 1; echo -e "\033[1;33m[INFO]:\033[0m Starting now.."; break;;
        [Nn]* ) echo -e "\033[0;33m[ABORT]:\033[0m Script stopped."; exit;;
        * );;
    esac
done


echo -e "\033[1;33m[INFO]:\033[0m Fetching updates and insalling \"wget\""

eval "apt update"
eval "apt-get install wget -y"

echo -e "\033[1;33m[INFO]:\033[0m Fetching current \"PREP_SYSTEM_FOR_DIETPI.sh\" from GitHub.."

wget https://raw.githubusercontent.com/MichaIng/DietPi/master/PREP_SYSTEM_FOR_DIETPI.sh -O PREP_SYSTEM_FOR_DIETPI.sh
chmod +x PREP_SYSTEM_FOR_DIETPI.sh

echo -e "\033[1;33m[INFO]:\033[0m Starting script: \"PREP_SYSTEM_FOR_DIETPI.sh\""

./PREP_SYSTEM_FOR_DIETPI.sh

rm PREP_SYSTEM_FOR_DIETPI.sh


echo -e "\033[1;33m[INFO]:\033[0m Changing directory to root"

cd /

echo -e "\033[1;33m[INFO]:\033[0m Checking for swap partition position.."
cmd_text="blkid | grep -oP '(?<=/dev/mapper/vg00-lv00:).*'"
cmd_out=$(eval "$cmd_text")

swap="TYPE=\"swap\""


if [[ $cmd_out == *$swap ]]
then 
        echo -e "\033[1;33m[INFO]:\033[0m Swap in front of root";
        lv_num="01"
else
        echo -e "\033[1;33m[INFO]:\033[0m Swap behind of root";
        lv_num="00"; fi

eval "apt update"
eval "apt install initramfs-tools -y"
eval "apt install lvm2 -y"
eval "apt autopurge"
sed -i '\|[[:blank:]]/[[:blank:]]|s|UUID=\"[^\"]*\"|/dev/mapper/vg00-lv${lv_num}|' /etc/fstab
eval "update-initramfs -u"

if [[ $lv_num == "01" ]]
then
        eval "/boot/dietpi/func/dietpi-set_swapfile 0";
        eval "mkswap /dev/mapper/vg00-lv00";
        eval "swapon /dev/mapper/vg00-lv00";
        eval "echo '/dev/mapper/vg00-lv00 none swap sw' >> /etc/fstab";
fi

echo -e "\033[0;31m[WARNING]:\033[0m Please keep in mind that there is a chance your system might not be able to boot after this"

while true; do
    echo -e "\033[1;33m[INFO]:\033[0m Reboot now? (y/n)";
    read yn;
    case $yn in
        [Yy]* ) echo -e "\033[1;33m[INFO]:\033[0m Rebooting now.."; reboot; break;;
        [Nn]* ) echo -e "\033[0;33m[ABORT]:\033[0m Script stopped."; exit;;
        * );;
    esac
done
