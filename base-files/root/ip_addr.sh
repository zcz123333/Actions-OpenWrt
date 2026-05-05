#!/bin/bash
uci set network.lan.proto='static'
uci set network.lan.ipaddr='192.168.5.11'
uci set network.lan.netmask='255.255.255.0'
#uci set network.lan.gateway='192.168.5.1'
#uci set network.lan.dns='192.168.5.1'
uci set network.lan.delegate='0'
uci commit network
#uci set dhcp.lan.ignore='0'
#uci commit dhcp