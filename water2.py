#!/usr/bin/python

import socket
import time
# addressing information of target
IPADDR = '192.168.0.8'
PORTNUM = 8530

# enter the data content of the UDP packet as hex
PACKETDATAON = '0142accf232bc4ee104CF75F5A28A181574AC1B563CD51A78D'.decode('hex')
PACKETDATAOFF = '0142accf232bc4ee10F7B4E74B970D96F3CA2BB5D3CD1C19D0'.decode('hex')

# initialize a socket, think of it as a cable
# SOCK_DGRAM specifies that this is UDP
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, 0)

# connect the socket, think of it as connecting the cable to the address location
s.connect((IPADDR, PORTNUM))

# send the command
s.send(PACKETDATAON)

time.sleep(10)

s.send(PACKETDATAOFF)

# close the socket
s.close()
