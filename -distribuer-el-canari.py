#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

import shutil, os, sys, subprocess, datetime, plistlib, urllib, time, json
import xml.etree.ElementTree as ET
from xml.dom import minidom

#-------------------- Version ElCanari
VERSION_CANARI = "0.3.2"

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   FOR PRINTING IN COLOR                                                                                              *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

MAGENTA = '\033[95m'
BLUE = '\033[94m'
GREEN = '\033[92m'
RED = '\033[91m'
ENDC = '\033[0m'
BOLD = '\033[1m'
UNDERLINE = '\033[4m'
BOLD_MAGENTA = BOLD + MAGENTA
BOLD_BLUE = BOLD + BLUE
BOLD_GREEN = BOLD + GREEN
BOLD_RED = BOLD + RED

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   runCommand                                                                                                         *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def runCommand (cmd) :
  str = "+"
  for s in cmd:
    str += " " + s
  print BOLD_MAGENTA + str + ENDC
  childProcess = subprocess.Popen (cmd)
  childProcess.wait ()
  if childProcess.returncode != 0 :
    sys.exit (childProcess.returncode)

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   runHiddenCommand                                                                                                   *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def runHiddenCommand (cmd) :
  str = "+"
  for s in cmd:
    str += " " + s
  print (BOLD_MAGENTA + str + ENDC)
  result = ""
  compteur = 0
  childProcess = subprocess.Popen (cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  while True:
    line = childProcess.stdout.readline ()
    if line != "":
      compteur = compteur + 1
      result += line
      if compteur == 10:
        compteur = 0
        sys.stdout.write (".") # Print without newline
    else:
      print ""
      childProcess.wait ()
      if childProcess.returncode != 0 :
        # print (BOLD_RED + "*** Error " + str (childProcess.returncode) + " ***" + ENDC)
        sys.exit (childProcess.returncode)
      return result

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
#   dictionaryFromJsonFile                                                                                             *
#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

def dictionaryFromJsonFile (file) :
  result = {}
  if not os.path.exists (os.path.abspath (file)):
    print (BOLD_RED + "The '" + file + "' file does not exist" + ENDC)
    sys.exit (1)
  try:
    f = open (file, "r")
    result = json.loads (f.read ())
    f.close ()
  except:
    print (BOLD_RED + "Syntax error in " + file + ENDC)
    sys.exit (1)
  return result


#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

#--- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
#-------------------- Supprimer une distribution existante
TEMP_DIR = scriptDir + "/../DISTRIBUTION_EL_CANARI_" + VERSION_CANARI
os.chdir (scriptDir + "/..")
while os.path.isdir (TEMP_DIR):
  shutil.rmtree (TEMP_DIR)
#-------------------- Creer le repertoire contenant la distribution
os.mkdir (TEMP_DIR)
os.chdir (TEMP_DIR)
#-------------------- Importer canari
runCommand (["rm", "-f", "archive.zip"])
runCommand (["rm", "-fr", "ElCanari-dev-master"])
runCommand (["curl", "-L", "https://github.com/pierremolinaro/ElCanari-dev/archive/master.zip", "-o", "archive.zip"])
runCommand (["unzip", "archive.zip"])
runCommand (["rm", "archive.zip"])
os.chdir (TEMP_DIR + "/ElCanari-dev-master")
#-------------------- Obtenir l'année
ANNEE = str (datetime.datetime.now().year)
print "ANNÉE : '" + ANNEE + "'"
#-------------------- Obtenir le numéro de build
plistFileFullPath = TEMP_DIR + "/ElCanari-dev-master/ElCanari/canari-application/Info.plist"
plistDictionary = plistlib.readPlist (plistFileFullPath)
buildString = plistDictionary ['PMBuildString']
# print "Build String '" + buildString + "'"
#--- Mettre à jour les numéros de version dans la plist
#plistDictionary ['CFBundleVersion'] = VERSION_CANARI + ", repository " + numeroRevisionSVN + ", build " + buildString
plistDictionary ['CFBundleVersion'] = VERSION_CANARI + ", build " + buildString
plistDictionary ['CFBundleShortVersionString'] = VERSION_CANARI
plistlib.writePlist (plistDictionary, plistFileFullPath)
#-------------------- Copier le fichier change.html
#runCommand (["cp", TEMP_DIR + "/canari/change.html", TEMP_DIR + "/change.html"])
#-------------------- Compiler le projet Xcode
runCommand (["rm", "-fr", "build"])
runCommand (["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
             "-target", "ElCanari",
             "-configuration", "Release"
            ])
#-------------------- Créer l'archive BZ2 de Canari
runCommand (["cp", "-r", "build/Release/ElCanari.app", "."])
runCommand (["tar", "-cf", "ElCanari.app.tar", "ElCanari.app"])
runCommand (["bzip2", "-9", "ElCanari.app.tar"])
BZ2file = TEMP_DIR + "/ElCanari.app." + VERSION_CANARI + ".tar.bz2"
runCommand (["mv", "ElCanari.app.tar.bz2", BZ2file])
#-------------------- Calculer la clé de la somme de contrôle de l'archive pour Sparkle
sommeControle = runHiddenCommand (["distribution-el-canari/sign_update.sh",
                                  BZ2file,
                                  "distribution-el-canari/dsa_priv.pem"])
sommeControle = sommeControle [0:- 1] # Remove training 'end-of-line'
#-------------------- Ajouter les meta infos
dict = dictionaryFromJsonFile (TEMP_DIR + "/ElCanari-dev-master/change.json")
dict ["archive-sum"] = sommeControle
dict ["build"] = buildString
f = open (TEMP_DIR + "/ElCanari.app." + VERSION_CANARI + ".json", "w")
f.write (json.dumps (dict, indent=2))
f.close ()
#-------------------- Vérifier si l'application est signée
# runCommand (["codesign", "-s", "351CAC09BC3DB2515349D8081B30F1836D1A1969", "-f", "ElCanari.app"])
# runCommand (["xattr", "-r", "-d", "com.apple.quarantine", "ElCanari.app"])
# runCommand (["spctl", "-a", "-vv", "ElCanari.app"])
#-------------------- Créer l'archive de Cocoa canari
# nomArchive = "ElCanari-" + VERSION_CANARI
# runCommand (["mkdir", nomArchive])
# runCommand (["mv", "ElCanari.app", nomArchive + "/ElCanari.app"])
# runCommand (["ln", "-s", "/Applications", nomArchive + "/Applications"])
# runCommand (["hdiutil", "create", "-srcfolder", nomArchive, nomArchive + ".dmg"])
# runCommand (["mv", nomArchive + ".dmg", "../" + nomArchive + ".dmg"])
#--- Supprimer les répertoires intermédiaires
# while os.path.isdir (TEMP_DIR + "/COCOA-CANARI"):
#   shutil.rmtree (TEMP_DIR + "/COCOA-CANARI")
while os.path.isdir (TEMP_DIR + "/ElCanari-dev-master"):
  shutil.rmtree (TEMP_DIR + "/ElCanari-dev-master")

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
