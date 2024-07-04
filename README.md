## You Lost your Helium Seed phrase
**F**irst of all. I very hate to tell you but if you lost the seed phrase or Solana private key, that’s it. There is no recovery. The app is very clear about this during setup. that is why it comes with a card to write your phrase down on. Take care of your seed phrases next time.

Read the YELLOW WARNING BOX here: https://docs.helium.com/wallets/wallet-seed-phrase


Flash Raspberry Pi Image to Your SD Card with RPI Imager Download here
https://www.raspberrypi.com/software/

**Install and run it** 

**Flash Your SD Card with Raspberry Pi Imager**
Choose ***Raspberry Pi 4*** Board, 
Select OS ***Raspberry Pi OS (bookworm) 64bit*** (minimal or desktop is on your call)
Setup User Name, Password, Wifi connection and ***Enable SSH*** 


After Flashing and Verification Completed, Remove SD Card and insert to your SenseCAP M1 sd card slot


Use your favorite SSH application on your PC such as Terminus, Putty etc. then Connect to SenseCAP M1 IP address Enter your Username and Password


After Complete SSH Login

Videos: https://www.youtube.com/watch?v=oBwm2GigIec

## Configuration and Install

**RPi Board Config** 

    sudo raspi-config 
Then Enable VNC, SPI, I2C and Serial port via **Interface** Menu of The configuration tool. Don't Reboot it Yet

**Update RPi EEPROM**
  
    sudo rpi-eeprom-update -a


**Increased Swap file to 2GB**

    sudo dphys-swapfile swapoff

    sudo nano /etc/dphys-swapfile

Edit Following Line

> CONF_SWAPSIZE=2048

And Hit Ctrl+X and Ctrl+Y then run

`sudo dphys-swapfile setup`

    sudo dphys-swapfile swapon

**Update to latest Kernel, Software and Lib**

    sudo apt update && sudo apt upgrade -y

**Install Docker, Rootless Permission and Reboot**

    curl -sSL https://get.docker.com | sh && sudo usermod -aG docker $USER && sudo reboot

**Clean Up APT Installation after Reboot**

    sudo apt autoremove -y

**Clone Project Repo** 

    git clone https://github.com/hereismeaw/SenseCAPM1-Chirpstack.git
    
**Configure LoRaWAN EUID Of WM1302/1303 Module**

Due to Debian 12 The *GPIO sysfs* is deprecated and superseded by *libgpiod*. In this repo this is  my pre-compiled binary for RPi 4 for RPi OS Debian 12 based Works on WM1302 WM1303 module 

    cd SenseCAPM1-Chirpstack/packet_forwarder
    sudo chmod +x reset_lgw.sh && sudo chmod +x lora_pkt_fwd && sudo chmod +x spectral_scan
    ./lora_pkt_fwd -c global_conf_as923_th.json
*

> **For WM1303 Module use file "global_conf_as923_th_sx1303.json" instead

* 
Watch For *"Concentrator EUI"* Line 
ex. 

> "INFO: concentrator EUI: 0xXXXXXXXXYYYYYYYY"
>Note It! 

Edit LoRaWAN Driver Config 

    nano global_conf_as923_th.json
Look at Line 80 

> "gateway_ID": "AA555A0000000000",

Fill your *"Concentrator EUI"*  And Hit Ctrl+X and Ctrl+Y

**Create LoRaWAN Driver Systemd** 
	
    sudo nano /etc/systemd/system/lora_pkt_fwd.service
    
Copy And Paste Following Line 

    [Unit]
    Description=Southern IoT AS923 LoraWAN Packet Forwarder Version 01.07.2024 Copyrighted
    After=network-online.target
    Wants=network-online.target
    [Service]
    Type=simple
    WorkingDirectory=/home/pi/SenseCAPM1-Chirpstack/packet_forwarder
    ExecStart=/home/pi/SenseCAPM1-Chirpstack/packet_forwarder/lora_pkt_fwd -c /home/pi/SenseCAPM1-Chirpstack/packet_forwarder/global_conf_as923_th.json
    Restart=always
    RestartSec=30
    StandardOutput=syslog
    StandardError=syslog
    SyslogIdentifier=lora_pkt_fwd
    User=pi
    [Install]
    WantedBy=multi-user.target

**Reload systemd Daemon**

    sudo systemctl daemon-reload
**Start LoRaWAN Driver Now**

    sudo systemctl start lora_pkt_fwd.service

**Check LoRaWAN Driver Status** 

    sudo systemctl status lora_pkt_fwd.service
    
   *If no error so you are good to go!* 

**Make LoRaWAN Driver Autostart On Boot**

    sudo systemctl enable lora_pkt_fwd.service


**Install Chripstack Docker (This repo are using my pre configured AS923 Frequency for Thailand)**

**Before We Start. What is Chirpstack?** 

 [ChirpStack](https://github.com/chirpstack) is an open-source LoRaWAN(R) Network Server which can be used to set up LoRaWAN networks. ChirpStack provides a web-interface for the management of gateways, devices and tenants as well to set up data integrations with the major cloud providers, databases and services commonly used for handling device data. ChirpStack provides a gRPC based API that can be used to integrate or extend ChirpStack.

    cd ~/SenseCAPM1-Chirpstack/chirpstack-docker

    docker compose up -d

Wait for 3-5 mins for Chirpstack to boot up then Browse to your SenseCAP M1 IP Address on port 8080

> Default Login/Password : admin/admin ,, ex. 192.168.1.69:8080

Go to Gateways Menu on The Left, Add Your Gateway with Name, Gateway ID same as Packet Forwarder

**(Optional) Import All LoRaWAN Device in Profile Template into Chirpstack**

    sudo make import-lorawan-devices




For Documentation and other binaries

[](https://github.com/chirpstack/chirpstack#documentation-and-binaries)

Please refer to the [ChirpStack](https://www.chirpstack.io/docs/) website for documentation, API and pre-compiled binaries.


**Install Node-Red and Start**

    cd ~/
    bash <(curl -sL https://raw.githubusercontent.com/node-red/linux-installers/master/deb/update-nodejs-and-nodered)
    
Config Installation

> Are you really sure you want to do this ? [y/N] ? **y**
> Would you like to install the Pi-specific nodes ? [y/N] ? **y**
> Running Node-RED install for user pi at /home/pi 
> Settings file ‣ /home/pi/.node-red/settings.js (hit Enter)

**Auto Start Node-Red On Boot**
```
sudo systemctl enable nodered.service
```
Node Red running on port 1880, Use your favorite browser

> ex. 192.168.1.69:1880

## PS

- People Install Desktop Version. You can use your favorite VNC client to control desktop mode on your hotspot such as RealVNC etc.

 

## For Advanced user who want to Connect to multiple LNS Simultaneously 

Install **ChirpStack Packet Multiplexer**

The ChirpStack Packet Multiplexer utility forwards the [Semtech packet-forwarder](https://github.com/lora-net/packet_forwarder) UDP data to multiple endpoints. It makes it possible to connect a single LoRa gateway to multiple networks. It is part of [ChirpStack](https://www.chirpstack.io).

**Ready? Go!** 
```
sudo apt install apt-transport-https dirmngr
```
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1CE2AFD36DBCCA00
```
```
sudo echo "deb https://artifacts.chirpstack.io/packages/3.x/deb stable main" | sudo tee /etc/apt/sources.list.d/chirpstack.list
```
```
sudo apt update && sudo apt install chirpstack-packet-multiplexer
```

To complete the installation, update the configuration file which is located at 

> /etc/chirpstack-packet-multiplexer/chirpstack-packet-multiplexer.toml

The Configuration Template I provided in this repo.


## Bonus

You with this you can Install **Mysterium** node on your SenseCAP M1

**What is a Mysterium Network Node?** 
**Network nodes are devices, such as this Raspberry Pi, which help power and maintain Mysterium distributed network**. Any user of the network can pay to connect to your node, providing them with a VPN service, access to the open internet and a secure line of communication.

Run Following command

    sudo -E bash -c "$(curl -s https://raw.githubusercontent.com/mysteriumnetwork/node/master/install.sh)"

In addition to downloading and installing our Node on your Raspberry Pi, this command will also install additional required dependencies like WireGuard if you don't have it already.

Reboot and Wait for 5-10 minutes for myst node to Start then browse to SenseCAP M1 IP Address with port 4449 in your favorite browser or use VNC connect to your hotspot 
ex.

> 192.168.1.69:4449


## Made in Phatthalung, Thailand!!

