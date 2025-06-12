#! /usr/bin/env python3
# -*- coding: UTF-8 -*-
#-------------------------------------------------------------------------------
# https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/Procedures/Procedures.html
#-------------------------------------------------------------------------------
#  Exemple d'exécution
# /Volumes/dev-git/freerouting-pm/jdk-17.0.6.jdk/Contents/Home/bin/java -jar /Volumes/dev-git/freerouting-pm/freerouting/build/dist/freerouting-executable.jar -trace 2 -de /Users/pierremolinaro/Desktop/design.dsn
#-------------------------------------------------------------------------------

import sys, os, subprocess

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
#   MAIN
#-------------------------------------------------------------------------------

def removeTranslationInDir (inDirectory) :
  print ("  " + inDirectory)
  allTranslationFiles = os.listdir (inDirectory)
  for filename in allTranslationFiles:
    if filename.endswith ("_en.properties") :
      print (GREEN + "    " + filename + ENDC)
    elif os.path.isfile (inDirectory + "/" + filename) :
      print (RED + "    " + filename + ENDC)
      os.remove (inDirectory + "/" + filename)
    else :
      print ("    " + filename + " (directory)")

#-------------------------------------------------------------------------------
#   MAIN
#-------------------------------------------------------------------------------

#----------------------------1- First argument is the version number
SCRIPT_DIR = os.path.dirname (os.path.abspath (sys.argv [0]))
#----------------------------2- SELECT VERSION

#--------
APP_VERSION = "1.4.5"
# https://jdk.java.net/17/
# https://www.oracle.com/java/technologies/downloads/#java17
JAVA_SDK_ARCHIVE = "jdk-17.0.15_macos-aarch64_bin.tar.gz"
# JAVA_SDK_DISTRIBUTION_URL = "https://download.oracle.com/otn/java/jdk/17.0.15%2B9/4f092786cec841d58ae21840b10204d7/" + JAVA_SDK_ARCHIVE

JAVA_SDK_DIR = SCRIPT_DIR + "/jdk-17.0.15.jdk"
FREEROUTING_DIR = "freerouting-jdk17"

#----------------------------3- Goto script dir
os.chdir (SCRIPT_DIR)
#----------------------------4- Get Developer ID
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
#----------------------------5- Download JAVA SDK
# if os.path.exists (JAVA_SDK_ARCHIVE) :
#   print (BLUE + BOLD + "JDK already download" + ENDC)
# else:
#   print (BLUE + BOLD + "Download JDK" + ENDC)
#   runCommand (["curl", "-o", JAVA_SDK_ARCHIVE, JAVA_SDK_DISTRIBUTION_URL])
#----------------------------6- Install JAVA SDK
JAVA_SDK_HOME = JAVA_SDK_DIR + "/Contents/Home"
if os.path.exists (JAVA_SDK_HOME) :
  print (BLUE + BOLD + "JDK already installed" + ENDC)
else:
  print (BLUE + BOLD + "Unpack JDK" + ENDC)
  runCommand (["tar", "xvzf", JAVA_SDK_ARCHIVE])
  print (BLUE + BOLD + "DONE" + ENDC)
#----------------------------7- Install Run time
JAVA_RUNTIME_DIR = JAVA_SDK_HOME + "/runtime"
if os.path.exists (JAVA_RUNTIME_DIR) :
  print (BLUE + BOLD + "Java runtime already installed" + ENDC)
else:
  runCommand ([
    JAVA_SDK_HOME + "/bin/jlink",
    "--module-path", JAVA_SDK_HOME + "/jmods",
    "--add-modules", "java.desktop",
    "--strip-debug",
    "--no-header-files",
    "--no-man-pages",
    "--strip-debug",
    "--strip-native-commands",
    "--vm=server",
    "--compress=2",
    "--output", JAVA_RUNTIME_DIR # "runtime"
  ])
#----------------------------8- Remove language translations, uses only english
# print (BLUE + BOLD + "Remove translations" + ENDC)
# removeTranslationInDir (SCRIPT_DIR + "/" + FREEROUTING_DIR + "/src/main/resources/app/freerouting")
# removeTranslationInDir (SCRIPT_DIR + "/" + FREEROUTING_DIR + "/src/main/resources/app/freerouting/gui")
# removeTranslationInDir (SCRIPT_DIR + "/" + FREEROUTING_DIR + "/src/main/resources/app/freerouting/boardgraphics")
# removeTranslationInDir (SCRIPT_DIR + "/" + FREEROUTING_DIR + "/src/main/resources/app/freerouting/interactive")
#----------------------------9- Compile for distribution
print (BLUE + BOLD + "Compile with gradle" + ENDC)
os.chdir (SCRIPT_DIR + "/" + FREEROUTING_DIR)
runCommand (["./gradlew", "--version"])
runCommand (["./gradlew", "clean"])
runCommandWithEnvironment (["./gradlew", "build"], {"JAVA_HOME": JAVA_SDK_HOME})
runCommandWithEnvironment (["./gradlew", "dist", "--stacktrace"], {"JAVA_HOME": JAVA_SDK_HOME})
os.chdir (SCRIPT_DIR)
#---------------------------10- Build executable
print (BLUE + BOLD + "Build executable" + ENDC)
FREE_ROUTING_NAME = "Freerouting-" + APP_VERSION
runCommand (["rm", "-fr", FREE_ROUTING_NAME + ".app"])
runCommand ([
  JAVA_SDK_HOME + "/bin/jpackage",
  "--input", SCRIPT_DIR + "/" + FREEROUTING_DIR + "/build/dist/",
  "--name", FREE_ROUTING_NAME,
  "--main-jar", "freerouting-executable.jar",
  "--type", "app-image",
  "--runtime-image", JAVA_RUNTIME_DIR,
   "--app-version", APP_VERSION
])
#---------------------------11- Sign executable
runCommand ([
  "/usr/bin/codesign",
  "--force",
  "--sign", "EEADE4830CA01C9224CD316028B65BDACDA62CA9", #developerIDString,
  "--deep",
  FREE_ROUTING_NAME + ".app"
])
#---------------------------12- Display executable signature
runCommand ([
  "/usr/bin/codesign",
  "-dv",
  "--verbose=4",
  FREE_ROUTING_NAME + ".app"
])
#---------------------------13- Verify executable signature
runCommand ([
  "/usr/bin/codesign",
  "--verify",
  "--deep",
  "--strict",
  "--verbose=1",
  FREE_ROUTING_NAME + ".app"
])
#---------------------------14- Distribution directory
DISTRIBUTION_DIR = "Freerouting-" + APP_VERSION
runCommand (["/bin/rm", "-rf", DISTRIBUTION_DIR])
runCommand (["/bin/rm", "-f", FREE_ROUTING_NAME + ".dmg"])
runCommand (["/bin/mkdir", DISTRIBUTION_DIR])
#---------------------------15- Build PKG
# PACKAGE_FILE = FREE_ROUTING_NAME + ".pkg"
# runCommand ([
#   "/usr/bin/productbuild",
#   "--component-compression", "auto",
#   "--component", FREE_ROUTING_NAME + ".app",
#   "/Applications",
#   PACKAGE_FILE
# ])
#---------------------------16- Build DMG
# if DMG_CONTAINS_APP:
#   runCommand (["/bin/cp", "-r", FREE_ROUTING_NAME + ".app", DISTRIBUTION_DIR])
# if DMG_CONTAINS_PKG:
#   runCommand (["/bin/cp", PACKAGE_FILE, DISTRIBUTION_DIR])
# runCommand ([
#   "/usr/bin/hdiutil",
#   "create",
#   "-srcfolder", FREE_ROUTING_NAME,
#   FREE_ROUTING_NAME + ".dmg",
#   "-fs", "HFS+"
# ])
#---------------------------17- Clean
# if DMG_CONTAINS_PKG :
#   runCommand (["/bin/rm", PACKAGE_FILE])
runCommand (["/bin/rm", "-rf", DISTRIBUTION_DIR])
print (BLUE + "Done!" + ENDC)

#-------------------------------------------------------------------------------
