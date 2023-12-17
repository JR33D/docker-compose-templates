clear
echo "###########################################"
echo "###      Installing Portainer Agent     ###"
echo "###########################################"
echo ""
echo "    1. Preparing to install Portainer Agent"
echo "    2. Creating the folder structure for Portainer."
echo "    3. You can find Portainer-Agent files in ./docker/portainer"

#sudo docker volume create portainer_data
mkdir -p docker/portainer
cd docker/portainer
curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/portainer/portainer-ce-agent-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
echo ""

sudo docker-compose up -d

echo ""
echo "    From Portainer or Portainer-CE add this Agent instance via the 'Endpoints' option in the left menu."
echo "       ####     Use the IP address of this server and port 9001"
echo ""
echo ""
sleep 3s
cd