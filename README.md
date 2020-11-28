# wireguard-config-generator 

Software to confgure a private wireguard VPN cloud server.

This software aims to automatically configure a private VPN server on your own VPS.  The
purpose is not anonymity, because all of your traffic will be transmitted to the Internet
from your VPS instance, and will show that machine's IP address as its source.  The aim is
to secure your data from monitoring or interference by your local network, including WIFI,
such as a coffee shop or hotel, as well as your ISP or phone service provider, or any
actors who have infiltrated these systems.

Currently the software supports creating a VULTR cloud server.  
Support for other cloud providers may be added in the future.

Prerequisites:
-------------
Create an account with VULTR at http://www.vultr.com
Generate an API key in your vultr account.

The scripts create a single VPS that costs $5.00/month.
The bandwith limit is 1TB for this server.

Local System Dependencies
-------------------------
docker
docker-compose
make
