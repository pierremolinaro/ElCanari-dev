#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#------------------------------------------------------------------------------
# https://www.oracle.com/java/technologies/downloads/#jdk17-mac

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

#--- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
#--- Free routing dir
FREEROUTING_DIR = scriptDir + "/freerouting"
APP_VERSION = "1.4.4-pm"
#--- Goto Freerouting dir
os.chdir (FREEROUTING_DIR)
#--- Compile for distribution
runCommand (["bash", "gradlew", "dist"])
print (BLUE + BOLD + "DONE" + ENDC)
#--- Download and install JDK
# https://jdk.java.net/14/
JPACKAGE_JVM="https://download.java.net/java/GA/jdk14/076bab302c7b4508975440c56f6cc26a/36/GPL/openjdk-14_osx-x64_bin.tar.gz"
JPKG_DIR = scriptDir + "/jdk14"
JPKG_HOME = JPKG_DIR + "/jdk-14.jdk/Contents/Home"
JPKG_ARCHIVE = "jdk14.tar.gz"
if os.path.exists (JPKG_HOME) :
  print (BLUE + BOLD + "JDK already installed" + ENDC)
else:
  if not os.path.exists (JPKG_DIR) :
    runCommand (["mkdir", "-p", JPKG_DIR])
  os.chdir (JPKG_DIR)
  #--- Download ?
  if not os.path.exists (JPKG_ARCHIVE) :
    print (BLUE + "Download JDK" + ENDC)
    runCommand (["curl", "-o", JPKG_ARCHIVE, JPACKAGE_JVM])
  #--- Install ?
  if not os.path.exists (JPKG_DIR + "/runtime") :
    print (BLUE + "Unpack JDK" + ENDC)
    runCommand (["tar", "xvzf", JPKG_ARCHIVE])
    print (BLUE + "Create runtime image" + ENDC)
    runCommand ([
      JPKG_HOME + "/bin/jlink",
      "--module-path", JPKG_HOME + "/jmods",
      "--add-modules", "java.desktop",
      "--strip-debug",
      "--no-header-files",
      "--no-man-pages",
      "--strip-native-commands",
      "--vm=server",
      "--compress=2",
      "--output", "runtime"
    ])
#--- Build executable
os.chdir (scriptDir)
FREE_ROUTING_NAME = "Freerouting-" + APP_VERSION
runCommand (["rm", "-fr", FREE_ROUTING_NAME + ".app"])
runCommand ([
  JPKG_HOME + "/bin/jpackage",
  "--input", FREEROUTING_DIR + "/build/dist/",
  "--name", FREE_ROUTING_NAME,
  "--main-jar", "freerouting-executable.jar",
  "--type", "app-image",
  "--runtime-image", "jdk14/runtime",
#  "--mac-sign",
#   "--mac-signing-key-user-name", "pierre@pcmolinaro.name",
  "--app-version", APP_VERSION
])
runCommand ([
  "codesign",
  "--force",
  "--sign", "U399CP39LD",
#  "--sign", "Apple Development: pierre@pcmolinaro.name",
  "--deep",
  FREE_ROUTING_NAME + ".app"
])
runCommand ([
  "/usr/bin/codesign",
  "-dv",
  "--verbose=4",
  FREE_ROUTING_NAME + ".app"
])
# runCommand ([
#   "spctl",
#   "-a",
#   FREE_ROUTING_NAME + ".app"
# ])
# runCommand ([
#   "spctl",
#   "--assess",
#   "--verbose=4",
#   "--type", "execute",
#   FREE_ROUTING_NAME + ".app"
# ])
# runCommand (["rm", "-fr", FREE_ROUTING_NAME + ".dmg"])
# runCommand ([
#   JPKG_HOME + "/bin/jpackage",
#   "--input", FREEROUTING_DIR + "/build/dist/",
#   "--name", "Freerouting",
#   "--main-jar", "freerouting-executable.jar",
#   "--type", "dmg",
#   "--runtime-image", "jdk14/runtime",
#   "--app-version", APP_VERSION,
#   "--license-file", "../LICENSE"
# ])
# runCommand (["rm", "-fr", FREE_ROUTING_NAME + ".pkg"])
# runCommand ([
#   JPKG_HOME + "/bin/jpackage",
#   "--input", FREEROUTING_DIR + "/build/dist/",
#   "--name", "Freerouting",
#   "--main-jar", "freerouting-executable.jar",
#   "--type", "pkg",
#   "--runtime-image", "jdk14/runtime",
#   "--app-version", APP_VERSION,
#   "--license-file", "../LICENSE"
# ])
#--- Copy application in ElCanari resource directory
ELCANARI_FREEROUTING_RESOURCE_DIR = scriptDir + "/../ElCanari/free-router-application"
runCommand (["rm", "-rf", ELCANARI_FREEROUTING_RESOURCE_DIR + "/Freerouting.app"])
runCommand (["cp", "-r", FREE_ROUTING_NAME + ".app", ELCANARI_FREEROUTING_RESOURCE_DIR])
runCommand (["mv", ELCANARI_FREEROUTING_RESOURCE_DIR + "/" + FREE_ROUTING_NAME + ".app", ELCANARI_FREEROUTING_RESOURCE_DIR + "/Freerouting.app"])

#------------------------------------------------------------------------------
