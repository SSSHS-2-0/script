# Mail Server Set-Up & Security-Hardening Script 2.0
This script will let you set up and security-harden an Ubuntu 20.04 Server. You can choose different modules to install, such as a webserver, a MySQL database, a mailserver, a standalone Jitsi server or a Tor relay. You will be guided trough the installation by a User interface. For more infromation, please refer to the documentation.

This is a follow-up project to the SSSHS 1.0 found here: https://github.com/SSSHS


## Requirements
You need:
* A linux server with Ubuntu 20.04x64 running
* Your own domain(s)
* Minimal linux knowledge

## Instructions
This shows you how to run this script on your server:
```
# Download and run the project
curl -Ls https://github.com/SSSHS-2-0/script.git | tar xz && cd script && ./setup.sh
```
If you want to download the project and run it later on:
```
# Download the project
curl -Ls https://github.com/SSSHS-2-0/script.git | tar xz
```
If you downloaded the project and want to run it:
```
# Run the project as root user in the main direcoty of this repository
./setup.sh
```
