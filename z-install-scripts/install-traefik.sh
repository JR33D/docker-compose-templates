clear
echo "###########################################"
echo "###      Installing Traefik Proxy       ###"
echo "###########################################"
echo ""
echo "    1. Preparing to install Traefik Proxy"
echo "    2. Creating the folder structure for Traefik."
echo "    3. You can find Portainer-Agent files in ./docker/traefik"

#sudo docker volume create traefik_data
mkdir -p docker/traefik
cd docker/traefik
echo "downloading traefik compose file...."
curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/traefik/traefik-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1

echo "downloading traefik configuration...."
curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/traefik/traefik.yml -o traefik.yml >> ~/docker-script-install.log 2>&1
echo ""


mkdir -p letsencrypt
cd letsencrypt
echo "downloading default tls options file...."
curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/traefik/letsencrypt/default-tls-options.yml -o default-tls-options.yml >> ~/docker-script-install.log 2>&1
echo ""
cd ..


sudo docker stack deploy --compose-file docker-compose.yml traefik

echo ""
echo "  Navigate to your server hostname / IP address on port 8080 to see traefik dashboard."
echo ""
sleep 3s
cd