Installation Instructions 

Flash Your SD Card with Raspberry Pi Imager 
- Slect Raspberry Pi OS Bookworm
- Enable SSH



sudo rpi-eeprom-update -a
sudo dphys-swapfile swapoff && sudo nano /etc/dphys-swapfile && sudo dphys-swapfile setup && sudo dphys-swapfile swapon
