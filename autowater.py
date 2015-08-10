#!/usr/bin/python
from subprocess import check_output,call
import sys
import re
import sqlite3

def water():
  check_output(["/home/odroid/tinkering/autowater/sqlite.py","2"])
  check_output(["/home/odroid/tinkering/autowater/water.py"])
  pass

def blocked(hours):
  conn = sqlite3.connect('/home/odroid/tinkering/historic.db')
  c = conn.cursor()
  c.execute("SELECT count(*) FROM messwerte WHERE date > datetime('now', '-"+str(hours)+" hours') AND water == 0")
  blocks = c.fetchone()[0]
  conn.close()  
  return blocks

if(blocked(3) == 0):
  status = check_output(["/usr/bin/Rscript", "/home/odroid/tinkering/autowater/rscript.R"]) 
  dec_search = re.search('decicion:\s+(\d+\.?\d*)', status,re.MULTILINE)  
  if dec_search:
    dec = float(dec_search.group(1))
  else:
    raise Exception()
  real_search = re.search('real:\s+(\d+)', status, re.IGNORECASE)
  if real_search:
    rea = int(real_search.group(1))
  else:
    raise Exception()
  if round(dec) > rea:
    water()
    print "dec: %f\treal: %d\t => watering" % (dec,rea)
  else:
    print "dec: %d\treal: %d\t => not watering" % (dec,rea)
