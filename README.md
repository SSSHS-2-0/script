# Mail Server Set-Up & Security-Hardening Script

This script allows you to set up a secure environment which inludes a mail- and webserver. In addition it also configures a secure DNS resolver and an authoritative nameserver for your domain. It sets up a firewall and hardens your SSH daemon.

The whole process is guided so it needs minimal information to set up your environment.

## Requirements
You need:
* A linux server (Ubuntu 18.06x64 is currently supported)
* Your own domain
* Minimal linux knowledge

## Instructions
This shows you how to run this script on your server:
```
# Download and run the project
curl -Ls https://github.com/ifrido/BTI7301/releases/download/1.0/v1.0.tgz | tar xz && cd v1.0/src/ && ./setup.sh
```
If you want to download the project and run it later on:
```
# Download the project
curl -Ls https://github.com/ifrido/BTI7301/releases/download/1.0/v1.0.tgz | tar xz
```
If you downloaded the project and want to run it:
```
# Run the project
cd v1.0/src/ && ./v1.0/src/setup.sh
```
