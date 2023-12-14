#!/bin/bash

addDockerAptRepository()
{
    
    echo "########################################"
    echo "###     Adding Docker Repository     ###"
    echo "########################################"
    echo ""
    echo ""

    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl gnupg
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
}

getDocker()
{
    echo "########################################"
    echo "###        installing Docker         ###"
    echo "########################################"
    echo ""
    echo ""
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
}

installPortainerCe()
{
        echo "########################################"
        echo "###      Installing Portainer-CE     ###"
        echo "########################################"
        echo ""
        echo "    1. Preparing to Install Portainer-CE"
        echo ""
        echo "    2. Creating the folder structure for Portainer."
        echo "    3. You can find Portainer-CE files in ./docker/portainer"

        sudo docker volume create portainer_data >> ~/docker-script-install.log 2>&1
        mkdir -p docker/portainer/portainer_data
        cd docker/portainer
        curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/portainer/portainer-ce-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
        echo ""

        if [[ "$OS" == "1" ]]; then
          docker-compose up -d
        else
          sudo docker-compose up -d
        fi

        echo ""
        echo "    Navigate to your server hostname / IP address on port 9000 and create your admin account for Portainer-CE"

        echo ""
        echo ""
        echo ""
        sleep 3s
        cd
}

installPortainerAgent() {
    echo "###########################################"
    echo "###      Installing Portainer Agent     ###"
    echo "###########################################"
    echo ""
    echo "    1. Preparing to install Portainer Agent"
    echo "    2. Creating the folder structure for Portainer."
    echo "    3. You can find Portainer-Agent files in ./docker/portainer"

    sudo docker volume create portainer_data
    mkdir -p docker/portainer
    cd docker/portainer
    curl https://raw.githubusercontent.com/JR33D/docker-compose-templates/main/portainer/portainer-ce-agent-compose.yml -o docker-compose.yml >> ~/docker-script-install.log 2>&1
    echo ""
    
    if [[ "$OS" == "1" ]]; then
        docker-compose up -d
    else
        sudo docker-compose up -d
    fi

    echo ""
    echo "    From Portainer or Portainer-CE add this Agent instance via the 'Endpoints' option in the left menu."
    echo "       ####     Use the IP address of this server and port 9001"
    echo ""
    echo ""
    echo ""
    sleep 3s
    cd
}

createDockerNetworks()
{
    echo "################################################"
    echo "######      Creating Docker Networks     #######"
    echo "################################################"

    sudo docker network create web-public
    sleep 2s
    sudo docker network create web-private
    sleep 2s
    sudo docker network create socket-proxy
    sleep 2s
    # move to home directory of user
    cd
}

chooseApps()
{
    clear
    echo "We can install Docker-CE, Docker-Compose, and Portainer-CE/Agent."
    echo "Please select 'y' for each item you would like to install."
    echo "NOTE: Without Docker you cannot use Docker-Compose, or Portainer-CE."
    echo "      Without Docker-compose you cannot user Portainer."
    echo ""
    
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    ISCOMP=$( (docker-compose -v ) 2>&1 )

    #### Try to check whether docker is installed and running - don't prompt if it is
    if [[ "$ISACT" != "active" ]]; then
        read -rp "Docker-CE (y/n): " DOCK
    else
        echo "Docker appears to be installed and running."
        echo ""
        echo ""
    fi

    if [[ "$ISCOMP" == *"command not found"* ]]; then
        read -rp "Docker-Compose (y/n): " DCOMP
    else
        echo "Docker-compose appears to be installed."
        echo ""
        echo ""
    fi

    read -rp "Portainer-CE (y/n): " PTAIN

    if [[ "$PTAIN" == [yY] ]]; then
        echo ""
        echo ""
        PS3="Please choose either Portainer-CE or just Portainer Agent: "
        select _ in \
            " Full Portainer-CE (Web GUI for Docker, Swarm, and Kubernetes)" \
            " Portainer Agent - Remote Agent to Connect from Portainer-CE" \
            " Nevermind -- I don't need Portainer after all."
        do
            PORT="$REPLY"
            case $REPLY in
                1) startInstall ;;
                2) startInstall ;;
                3) startInstall ;;
                *) echo "Invalid selection, please try again..." ;;
            esac
        done
    fi
    
    startInstall
}

startInstall() 
{
    clear
    echo "#######################################################"
    echo "###         Preparing for Installation              ###"
    echo "#######################################################"
    echo ""
    sleep 3s

    addDockerAptRepository ;;

    getDocker ;;

    ##########################################
    #### Test if Docker Service is Running ###
    ##########################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACt" != "active" ]]; then
        echo "Giving the Docker service time to start..."
        while [[ "$ISACT" != "active" ]] && [[ $X -le 10 ]]; do
            sudo systemctl start docker >> ~/docker-script-install.log 2>&1
            sleep 10s &
            pid=$! # Process Id of the previous running command
            spin='-\|/'
            i=0
            while kill -0 $pid 2>/dev/null
            do
                i=$(( (i+1) %4 ))
                printf "\r${spin:$i:1}"
                sleep .1
            done
            printf "\r"
            ISACT=`sudo systemctl is-active docker`
            let X=X+1
            echo "$X"
        done
    fi

   createDockerNetworks ;;

    if [[ "$PORT" == "1" ]]; then
        installPortainerCe ;;
    fi

    if [[ "$PORT" == "2" ]]; then
       installPortainerAgent ;;
    fi

    echo "All docker applications have been added to the docker network web-private"
    echo ""
    echo "If you add more docker applications to this server, make sure to add them to the correct network."

    exit 1
}

clear
chooseApps ;;
