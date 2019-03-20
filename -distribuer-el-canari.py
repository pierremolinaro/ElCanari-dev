#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

import shutil, os, sys, subprocess, datetime, plistlib, urllib, time, json
import xml.etree.ElementTree as ET
from xml.dom import minidom

#-------------------- Version ElCanari
VERSION_CANARI = "0.6.0"

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
DISTRIBUTION_DIR = scriptDir + "/../DISTRIBUTION_EL_CANARI_" + VERSION_CANARI
os.chdir (scriptDir + "/..")
while os.path.isdir (DISTRIBUTION_DIR):
  shutil.rmtree (DISTRIBUTION_DIR)
#-------------------- Creer le repertoire contenant la distribution
os.mkdir (DISTRIBUTION_DIR)
os.chdir (DISTRIBUTION_DIR)
#-------------------- Importer canari
runCommand (["rm", "-f", "archive.zip"])
runCommand (["rm", "-fr", "ElCanari-dev-master"])
runCommand (["curl", "-L", "https://github.com/pierremolinaro/ElCanari-dev/archive/master.zip", "-o", "archive.zip"])
runCommand (["unzip", "archive.zip"])
runCommand (["rm", "archive.zip"])
os.chdir (DISTRIBUTION_DIR + "/ElCanari-dev-master")
#-------------------- Obtenir l'année
ANNEE = str (datetime.datetime.now().year)
print "ANNÉE : '" + ANNEE + "'"
#-------------------- Obtenir le numéro de build
plistFileFullPath = DISTRIBUTION_DIR + "/ElCanari-dev-master/ElCanari/application/Info-Release.plist"
plistDictionary = plistlib.readPlist (plistFileFullPath)
buildString = plistDictionary ['PMBuildString']
# print "Build String '" + buildString + "'"
#--- Mettre à jour les numéros de version dans la plist
plistDictionary ['CFBundleVersion'] = VERSION_CANARI + ", build " + buildString
plistDictionary ['CFBundleShortVersionString'] = VERSION_CANARI
plistlib.writePlist (plistDictionary, plistFileFullPath)
#-------------------- Compiler le projet Xcode
runCommand (["rm", "-fr", "build"])
runCommand (["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
             "-target", "ElCanari-Release",
             "-configuration", "Release"
            ])
#-------------------- Construction package
packageFile = "ElCanari-" + VERSION_CANARI + ".pkg"
runCommand (["productbuild", "--component", "build/Release/ElCanari.app", "/Applications", packageFile])
runCommand (["cp", packageFile, DISTRIBUTION_DIR])
#-------------------- Calculer la clé de la somme de contrôle de l'archive pour Sparkle
sommeControle = runHiddenCommand (["distribution-el-canari/sign_update",
                                   packageFile,
                                   "distribution-el-canari/dsa_priv.pem"])
sommeControle = sommeControle [0:- 1] # Remove training 'end-of-line'
#-------------------- Ajouter les meta infos
dict = dictionaryFromJsonFile (DISTRIBUTION_DIR + "/ElCanari-dev-master/change.json")
dict ["archive-sum"] = sommeControle
dict ["build"] = buildString
f = open (DISTRIBUTION_DIR + "/ElCanari.app." + VERSION_CANARI + ".json", "w")
f.write (json.dumps (dict, indent=2))
f.close ()
#-------------------- Créer l'archive de Cocoa canari
nomArchive = "ElCanari-" + VERSION_CANARI
runCommand (["mkdir", nomArchive])
runCommand (["cp", packageFile, nomArchive])
runCommand (["hdiutil", "create", "-srcfolder", nomArchive, nomArchive + ".dmg", "-fs", "HFS+"])
runCommand (["mv", nomArchive + ".dmg", "../" + nomArchive + ".dmg"])
#--- Supprimer les répertoires intermédiaires
os.chdir (DISTRIBUTION_DIR)
while os.path.isdir (DISTRIBUTION_DIR + "/ElCanari-dev-master"):
  shutil.rmtree (DISTRIBUTION_DIR + "/ElCanari-dev-master")

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
