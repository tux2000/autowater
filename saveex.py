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

if n == 'red':
  togle(RED)
  check_output(["/media/odroid/861d42ef-a564-4d51-8df6-7b2d7293c8f7/tinkering/autowater/sqlite.py","0"])
  togle(RED)
elif n == 'blue':
  togle(BLUE)
  check_output(["/media/odroid/861d42ef-a564-4d51-8df6-7b2d7293c8f7/tinkering/autowater/sqlite.py","1"])
  check_output(["/media/odroid/861d42ef-a564-4d51-8df6-7b2d7293c8f7/tinkering/autowater/water.py"])
  togle(BLUE)
