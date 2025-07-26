#! /usr/bin/env python3
# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------

import sys, os, subprocess, plistlib, shutil

#-------------------------------------------------------------------------------
#   FOR PRINTING IN COLOR
#-------------------------------------------------------------------------------

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

#-------------------------------------------------------------------------------
#   RUN COMMAND
#-------------------------------------------------------------------------------

def runCommand (command) :
  s = MAGENTA + BOLD + "+"
  for c in command :
    if " " in c :
      s += " '" + c + "'"
    else :
      s += " " + c
  s += ENDC
  print (s)
  childProcess = subprocess.Popen (command)
  childProcess.wait ()
  if childProcess.returncode != 0 :
    sys.exit (childProcess.returncode)

#-------------------------------------------------------------------------------
#   RUN COMMAND With envrionment variables
#-------------------------------------------------------------------------------

def runCommandWithEnvironment (command, environment) :
  s = MAGENTA + BOLD + "+"
  for c in command :
    if " " in c :
      s += " '" + c + "'"
    else :
      s += " " + c
  s += ENDC
  print (s)
  childProcess = subprocess.Popen (command, env=environment)
  childProcess.wait ()
  if childProcess.returncode != 0 :
    sys.exit (childProcess.returncode)

#-------------------------------------------------------------------------------
#   runHiddenCommand
#-------------------------------------------------------------------------------

def runHiddenCommand (cmd, logUtilityTool=False) :
  s = MAGENTA + BOLD + "+"
  for c in cmd :
    if " " in c :
      s += " '" + c + "'"
    else :
      s += " " + c
  s += ENDC
  print (s)
  result = ""
  childProcess = subprocess.Popen (cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, universal_newlines=True)
  while True:
    line = childProcess.stdout.readline ()
    if line != "":
      result += line
    else:
      childProcess.wait ()
      if childProcess.returncode != 0 :
        sys.exit (childProcess.returncode)
      return result

#-------------------------------------------------------------------------------
#   myDeleteDir
#-------------------------------------------------------------------------------
# http://unix.stackexchange.com/questions/77127/rm-rf-all-files-and-all-hidden-files-without-error
# http://unix.stackexchange.com/questions/233576/recursively-delete-subdirectories-not-containing-pattern-on-osx

def myDeleteDir (directory):
  while os.path.exists (directory):
    print (MAGENTA + BLUE + "+ Remove '" + directory + "' directory" + ENDC)
    shutil.rmtree (directory, True) # Ignore errors

#-------------------------------------------------------------------------------
#   buildProductForArchitureAndJDK
#-------------------------------------------------------------------------------

def buildProductForArchitureAndJDK (ARCHIVE_ARCH, ARCHITECTURE, JDK_VERSION) :
  APP_VERSION = "1.9.0"
  FREE_ROUTING_NAME = "Freerouting-" + ARCHITECTURE + "-1-9-0"
  #----------------------------1- Constants
  JDK_MAIN_VERSION = JDK_VERSION.split (".") [0]
  JDK_MAIN_VERSION_AS_INT = int (JDK_MAIN_VERSION)
  SCRIPT_DIR = os.path.dirname (os.path.abspath (sys.argv [0]))
  ARCHIVE_DIRECTORY = SCRIPT_DIR + "/z-archives"
  PRODUCT_DIRECTORY = SCRIPT_DIR + "/z-products-built-with-jdk" + JDK_VERSION
  #----------------------------2- Java JDK
  JAVA_JDK_ARCHIVE = ARCHIVE_DIRECTORY + "/jdk-" + JDK_VERSION + "_macos-" + ARCHIVE_ARCH + "_bin.tar.gz"
  TEMPORARY_ARCHIVE = ARCHIVE_DIRECTORY + "/downloading-temporary"
  JAVA_JDK_DISTRIBUTION_URL = "https://download.oracle.com/java/" + JDK_MAIN_VERSION + "/archive/jdk-" + JDK_VERSION + "_macos-" + ARCHIVE_ARCH + "_bin.tar.gz"
  JAVA_JDK_EXTRACTION_DIR = ARCHIVE_DIRECTORY + "/jdk-" + JDK_VERSION + ".jdk"
  JAVA_ALL_JDK_DIR = SCRIPT_DIR + "/z-all-jdk"
  if not os.path.exists (JAVA_ALL_JDK_DIR) :
    runCommand (["mkdir", "-p", JAVA_ALL_JDK_DIR])
  JAVA_JDK_DIR = JAVA_ALL_JDK_DIR + "/jdk-" + JDK_VERSION + "-" + ARCHIVE_ARCH + ".jdk"
  FREEROUTING_SOURCE_DIR = "freerouting-sources"
  myDeleteDir (FREEROUTING_SOURCE_DIR + "/build")
  if not os.path.exists (PRODUCT_DIRECTORY + "/" + FREE_ROUTING_NAME + ".app") :
    runCommand (["rm", "-f", PRODUCT_DIRECTORY + "/" + FREE_ROUTING_NAME + ".app.tar.xz"])
    runCommand (["mkdir", "-p", PRODUCT_DIRECTORY])
    os.chdir (SCRIPT_DIR)
    #----------------------------3- Get Developer ID
    response = runHiddenCommand (["security", "find-identity", "-v", "-p", "codesigning"])
    print (response)
    responseComponents = response.split ('"')
    developerIDString = ""
    if len (responseComponents) < 3 :
      print (BOLD + RED + "Error, no valid Apple Developer ID" + ENDC)
      sys.exit (1)
    elif len (responseComponents) == 3 :
      developerIDString = responseComponents [1]
      if developerIDString.startswith ("Apple Development: ") :
        print (BOLD + "Success: found Developer ID: '" + developerIDString + "'")
      else:
        print (BOLD + RED + "Error: Developer ID: '" + developerIDString + "' does not start with 'Apple Development: '")
    #----------------------------4- Download JAVA JDK
    if os.path.exists (JAVA_JDK_ARCHIVE) :
      print (BLUE + BOLD + "JDK already download" + ENDC)
    else:
      print (BLUE + BOLD + "Download JDK " + JDK_VERSION + " for " + ARCHITECTURE + ENDC)
      runCommand (["mkdir", "-p", ARCHIVE_DIRECTORY])
      runCommand (["rm", "-f", TEMPORARY_ARCHIVE])
      runCommand (["curl", "-L", "--fail", JAVA_JDK_DISTRIBUTION_URL, "-o", TEMPORARY_ARCHIVE])
      runCommand (["mv", TEMPORARY_ARCHIVE, JAVA_JDK_ARCHIVE])
    #----------------------------5- Install JAVA JDK
    JAVA_JDK_HOME = JAVA_JDK_DIR + "/Contents/Home"
    if os.path.exists (JAVA_JDK_HOME) :
      print (BLUE + BOLD + "JDK already installed" + ENDC)
    else:
      os.chdir (ARCHIVE_DIRECTORY)
      print (BLUE + BOLD + "Unpack JDK" + ENDC)
      runCommand (["tar", "xvzf", JAVA_JDK_ARCHIVE])
      runCommand (["mv", JAVA_JDK_EXTRACTION_DIR, JAVA_JDK_DIR])
      print (BLUE + BOLD + "DONE" + ENDC)
      os.chdir (SCRIPT_DIR)
    #----------------------------6- Install Run time
    JAVA_RUNTIME_DIR = JAVA_JDK_HOME + "/runtime"
    if os.path.exists (JAVA_RUNTIME_DIR) :
      print (BLUE + BOLD + "Java runtime already installed" + ENDC)
    else:
      COMPRESS_ARG = "zip-9" if JDK_MAIN_VERSION_AS_INT >= 21 else "2"
      runCommand ([
        JAVA_JDK_HOME + "/bin/jlink",
        "--module-path", JAVA_JDK_HOME + "/jmods",
        "--add-modules", "java.desktop",
        "--strip-debug",
        "--no-header-files",
        "--no-man-pages",
        "--strip-debug",
        "--strip-native-commands",
        "--vm=server",
        "--compress", COMPRESS_ARG,
        "--output", JAVA_RUNTIME_DIR
      ])
    #----------------------------7- Compile for distribution
    print (BLUE + BOLD + "Compile with gradle" + ENDC)
    os.chdir (SCRIPT_DIR + "/" + FREEROUTING_SOURCE_DIR)
    runCommand (["./gradlew", "--version"])
    runCommand (["./gradlew", "--stop"])
    runCommand (["./gradlew", "--status"])
    myDeleteDir (SCRIPT_DIR + "/" + FREEROUTING_SOURCE_DIR + "/build")
    runCommand ([JAVA_JDK_HOME + "/bin/java", "-version"])
#    runCommand (["./gradlew", "clean"])
    runCommandWithEnvironment (["./gradlew", "build"], {"JAVA_HOME": JAVA_JDK_HOME})
    runCommandWithEnvironment (["./gradlew", "dist", "--stacktrace"], {"JAVA_HOME": JAVA_JDK_HOME})
    os.chdir (SCRIPT_DIR)
    #----------------------------8- Build executable
    os.chdir (PRODUCT_DIRECTORY)
    print (BLUE + BOLD + "Build executable" + ENDC)
    runCommand (["rm", "-fr", FREE_ROUTING_NAME + ".app"])
    runCommand ([
      JAVA_JDK_HOME + "/bin/jpackage",
      "--input", SCRIPT_DIR + "/" + FREEROUTING_SOURCE_DIR + "/build/dist/",
      "--name", FREE_ROUTING_NAME,
      "--main-jar", "freerouting-executable.jar",
      "--type", "app-image",
#       "--verbose",
      "--icon", SCRIPT_DIR + "/" + FREEROUTING_SOURCE_DIR + "/freerouting.icns",
      "--runtime-image", JAVA_RUNTIME_DIR,
       "--app-version", APP_VERSION
    ])
    #---------------------------14- Get application Info.plist
    # Strangely, the Info.plist shows the application can request the microphone!
    PLIST_FILE_PATH = PRODUCT_DIRECTORY + "/" + FREE_ROUTING_NAME + ".app/Contents/Info.plist"
    fp = open (PLIST_FILE_PATH, mode='rb') # b is important -> binary
    plistAsDictionary = plistlib.load (fp)
    fp.close ()
    # print (plistAsDictionary)
    writeInfoPlList = False
    if "NSMicrophoneUsageDescription" in plistAsDictionary :
      del plistAsDictionary ["NSMicrophoneUsageDescription"]
      writeInfoPlList = True
    #print (plistAsDictionary)
    minimumVersion = plistAsDictionary ["LSMinimumSystemVersion"] # ridicule, "10.11" est toujours retourné
    plistAsDictionary ["LSMinimumSystemVersion"] = "11.0" if JDK_MAIN_VERSION_AS_INT > 21 else "10.15"
    # print (minimumVersion)
    if writeInfoPlList :
      with open (PLIST_FILE_PATH, 'wb') as fp:
        plistlib.dump (plistAsDictionary, fp)
    #----------------------------9- Sign executable
    runCommand ([
      "/usr/bin/codesign",
      "--force",
      "--sign", "EEADE4830CA01C9224CD316028B65BDACDA62CA9", #developerIDString,
      "--deep",
      FREE_ROUTING_NAME + ".app"
    ])
    #---------------------------10- Display executable signature
    runCommand ([
      "/usr/bin/codesign",
      "-dv",
      "--verbose=4",
      FREE_ROUTING_NAME + ".app"
    ])
    #---------------------------11- Verify executable signature
    runCommand ([
      "/usr/bin/codesign",
      "--verify",
      "--deep",
      "--strict",
      "--verbose=1",
      FREE_ROUTING_NAME + ".app"
    ])
  #---------------------------12- Build tar.xz file
  os.chdir (PRODUCT_DIRECTORY)
  if not os.path.exists (FREE_ROUTING_NAME + ".app.tar.xz") :
    runCommand (["tar", "cfJ", FREE_ROUTING_NAME + ".app.tar.xz", FREE_ROUTING_NAME + ".app"])
  #---------------------------13- Clean
  myDeleteDir (SCRIPT_DIR + "/" + FREEROUTING_SOURCE_DIR + "/build")
  #---------------------------15- Done
  print (BOLD + BLUE + FREE_ROUTING_NAME + ".app with JDK " + JDK_VERSION + " for " + ARCHITECTURE + ": Done!" + ENDC)
  os.chdir (SCRIPT_DIR)

#-------------------------------------------------------------------------------
#   buildProductsForJDK
#-------------------------------------------------------------------------------

def buildProductsForJDK (JDK_VERSION) :
  buildProductForArchitureAndJDK (ARCHIVE_ARCH="x64", ARCHITECTURE="x86_64", JDK_VERSION=JDK_VERSION)
  buildProductForArchitureAndJDK (ARCHIVE_ARCH="aarch64", ARCHITECTURE="arm64", JDK_VERSION=JDK_VERSION)

#-------------------------------------------------------------------------------
#   MAIN
#-------------------------------------------------------------------------------

buildProductsForJDK (JDK_VERSION="21.0.6")
# buildProductsForJDK (JDK_VERSION="22.0.2")
# buildProductsForJDK (JDK_VERSION="23.0.2")
# buildProductsForJDK (JDK_VERSION="24")

#-------------------------------------------------------------------------------
