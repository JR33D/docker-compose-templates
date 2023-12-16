clear
echo "########################################"
echo "###      Installing Portainer-CE     ###"
echo "########################################"
echo ""
echo "    1. Preparing to Install Portainer-CE"
echo "    2. Creating the folder structure for Portainer."
echo "    3. You can find Portainer-CE files in ./docker/portainer"

#sudo docker volume create portainer_data >> ~/docker-script-install.log 2>&1
mkdir -p docker/portainer/portainer_data
cd docker/portainer
curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/portainer/portainer-ce-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
echo ""

sudo docker-compose up -d

echo ""
echo "   Navigate to your server hostname / IP address on port 9000 and create your admin account for Portainer-CE"
echo ""
echo ""
echo ""
sleep 3s
cd