# Server Set-Up & Security-Hardening Script 2.0
This script will let you set up and security-harden an Ubuntu 20.04 Server. You can choose different modules to install, such as a webserver, a MySQL database, a mailserver, a standalone Jitsi server or a Tor relay. You will be guided through the installation by a User interface. For more infromation, please refer to the documentation.

This is a follow-up project to the SSSHS 1.0 found here: https://github.com/SSSHS

## Requirements
You need:
* A linux server with Ubuntu-Server 20.04x64 running (you can get a  a virtual private server (VPS) from https://us.ovhcloud.com or from any other provider such as Amazon)
* Your own domain(s) and already configured to the extern IP Address of the server (This can usually be done on the website of your domain provider)
* Minimal linux knowledge

## Instructions
This shows you how to run this script on your server:
```
# Clone the repository:
git clone https://github.com/SSSHS-2-0/ script.git
```
If you cloned the project got to the script folder and run it:
```
# Run the project as root user in the main direcoty of this repository
./setup.sh
```
You can find the manual for this script on: https://github.com/SSSHS-2-0/manual

## About Us
The purpose of the Server Set-Up & Security-Hardening Script 2.0 is to help the user to set up an internet server easily and independently. This project was created by us as a project 1 for our computer science studies at the Bern University of Applied Science (BFH)

Contact Information:

Students:

* Samuel Imboden:  imboden.samuel@protonmail.ch
* Anna Albrecht: ak.albrecht@protonmail.ch

Project Supervisor:

 * Simon Kramer: https://www.simon-kramer.ch/
