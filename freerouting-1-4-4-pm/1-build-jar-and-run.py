#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#------------------------------------------------------------------------------

import sys, os, subprocess

#------------------------------------------------------------------------------
#   FOR PRINTING IN COLOR
#------------------------------------------------------------------------------

BLACK = '\033[30m'
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
MAGENTA = '\033[35m'
CYAN = '\033[36m'
WHITE = '\033[37m'
ENDC = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'
BLINK = '\033[5m'

#------------------------------------------------------------------------------

def runCommand (command) :
  s = MAGENTA + BOLD + "+"
  for c in command :
    s += " " + c
  s += ENDC
  print (s)
  childProcess = subprocess.Popen (command)
  childProcess.wait ()
  if childProcess.returncode != 0 :
    sys.exit (childProcess.returncode)


#------------------------------------------------------------------------------
#   MAIN
#------------------------------------------------------------------------------

FREEROUTING_DIR = "/Volumes/dev-git/freerouting"
APP_VERSION = "1.4.4-pm"
#--- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
#--- Goto Freerouting dir
os.chdir (FREEROUTING_DIR)
#--- Compile for jar
runCommand (["bash", "gradlew", "assemble"])
#--- run
runCommand (["java", "-jar", "build/libs/freerouting-executable.jar"])

#------------------------------------------------------------------------------
