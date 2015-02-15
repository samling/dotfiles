#!/bin/bash

# This script is used to quickly configure a Debian-based Linux host to intercept and decrypt SSL
# communications to and from a device or browser.
#
# Prerequisites:
# 
# Android: You must copy mitmproxy-ca-cert.cer from ~/.mitmproxy to your device's sdcard
# (sometimes sdcard2), enable pin lock, and then install the cert from the Security menu.
# Then, change your wireless gateway to the machine running mitmproxy.

cleanup()
{
    sudo sysctl -w net.ipv4.ip_forward=0
    sudo iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
    sudo iptables -t nat -D PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8080

    sudo iptables-save

    return $?
}

ctrl_c()
{
    echo ""
    echo "Reverting changes and shutting down..."
    echo ""

    cleanup

    exit $?
}

trap ctrl_c SIGINT

    sudo sysctl -w net.ipv4.ip_forward=1
    sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j REDIRECT --to-port 8080
    sudo iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 443 -j REDIRECT --to-port 8080

    sudo iptables-save

    echo ""
    echo "Done! Now run: mitmproxy -T --host and set the gateway of the device with mitmproxy-ca-cert.cer installed to the IP of this machine."
while true; do
    echo ""
    echo "Press ctrl-c to exit."
    sleep 10000
done
