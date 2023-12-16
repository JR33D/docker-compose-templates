#!/bin/bash
# Script copied and modified from https://gitlab.com/bmcgonag/docker_installs/-/blob/main/install_docker_nproxyman.sh
installApps()
{
        echo "    1. Installing System Updates..."
        (sudo apt update  && sudo apt upgrade -y) > ~/docker-script-install.log 2>&1 &
        ## Show a spinner for activity progress
        pid=$   # Process ID of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .25
        done
        printf "\r"

        echo "    2. Install Prerequisite Packages..."
        (sudo apt install curl wget git -y) >> ~/docker-script-install.log 2>&1
        ## Spinner time...
        pid=$   # Process ID of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .25
        done
        printf "\r"

        echo "    3. Installing Docker-CE (Community Edition)..."
        sleep 2s

        
        curl -fsSL https://get.docker.com | sh >> ~/docker-script-install.log 2>&1
        # Time to spin
        pid=$   # Process ID of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .25
        done
        printf "\r"

        echo "      - docker-ce version is now:"
        DOCKERV=$(docker -v)
        echo "          "${DOCKERV}
        sleep 3s

            
        echo "    5. Starting Docker Service"
        sudo systemctl start docker >> ~/docker-script-install.log 2>&1


        # add current user to docker group so sudo isn't needed
        echo ""
        echo "  - Attempting to add the currently logged in user to the docker group..."

        sleep 2s
        sudo usermod -aG docker "${USER}" >> ~/docker-script-install.log 2>&1
        echo "  - You'll need to log out and back in to finalize the addition of your user to the docker group."
        echo ""
        echo ""
        sleep 3s

        echo "############################################"
        echo "######     Install Docker-Compose     ######"
        echo "############################################"

        # install docker-compose
        echo ""
        echo "    1. Installing Docker-Compose..."
        echo ""
        echo ""
        sleep 2s

        ######################################
        ###     Install Raspbian / Arm64   ###
        ######################################

        echo "    1. Installing dependencies..."
        (sudo apt-get install -y libffi-dev libssl-dev python3-dev python3 python3-pip) >> ~/docker-script-install.log 2>&1
        # Show our spinner
        pid=$   # Process ID of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .25
        done
        printf "\r"

        (sudo apt install docker-compose) >> ~/docker-script-install.log 2>&1
        # Show the spinner again...
        pid=$   # Process ID of the previous running command
        spin='-\|/'
        i=0
        while kill -0 $pid 2>/dev/null
        do
            i=$(( (i+1) %4 ))
            printf "\r${spin:$i:1}"
            sleep .25
        done
        printf "\r"

        echo "      - Docker Compose Version is now: " 
        DOCKCOMPV=$(docker-compose --version)
        echo "        "${DOCKCOMPV}
        echo ""
        echo ""
        sleep 3s

    ##########################################
    #### Test if Docker Service is Running ###
    ##########################################
    ISACT=$( (sudo systemctl is-active docker ) 2>&1 )
    if [[ "$ISACT" != "active" ]]; then
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

    echo "################################################"
    echo "######      Creating Docker Networks     #######"
    echo "################################################"

    echo "Creating 'web-public' docker network"
    sudo docker network create web-public
    sleep 2s
    echo "Creating 'web-private' docker network"
    sudo docker network create web-private
    sleep 2s
    echo "Creating 'socket-proxy' docker network"
    sudo docker network create socket-proxy
    sleep 2s
    # move to home directory of user
    cd

    echo "Docker has been setup, Run additional scripts to add applications."
    echo "When adding more docker applications to this server, make sure to add them to the correct network."

    exit 1
}

clear
echo ""
echo ""
echo "Let's figure out which OS / Distro you are running."
echo ""
echo ""
echo "    From some basic information on your system, you appear to be running: "
echo "        --  OS Name        " $(lsb_release -i)
echo "        --  Description        " $(lsb_release -d)
echo "        --  OS Version        " $(lsb_release -r)
echo "        --  Code Name        " $(lsb_release -c)
echo ""
echo "------------------------------------------------------"
echo ""

installApps