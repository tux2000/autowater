#!/usr/bin/python
from subprocess import check_output,call
import sys

OUTPUT = 1
ON = 1
OFF = 0

RED = 0
GREEN = 2
YELLOW = 1
BLUE=3

gpio="/usr/local/bin/gpio"

def togle(channel):
  check_output([gpio, "mode", str(channel),"out"])
  status = check_output([gpio, "read", str(channel)])
  if int(status) == 1:
    call(["gpio", "write", str(channel),"0"])
  else:
    call(["gpio", "write", str(channel),"1"])

n = sys.argv[1]

if n == 'green':
  togle(GREEN)
  check_output(["/home/odroid/tinkering/autowater/sqlite.py","10"])
  togle(GREEN)
elif n == 'yellow':
  togle(YELLOW)
  check_output(["/home/odroid/tinkering/autowater/sqlite.py","11"])
  check_output(["/home/odroid/tinkering/autowater/water2.py"])
  togle(YELLOW)
