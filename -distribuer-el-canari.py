#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*

import shutil, os, sys, subprocess, datetime, plistlib, urllib, time, json
import xml.etree.ElementTree as ET
from xml.dom import minidom

#-------------------- Version ElCanari
VERSION_CANARI = "0.6.1"
BUILD_KIND =  "Release" # "Debug" #

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
plistFileFullPath = DISTRIBUTION_DIR + "/ElCanari-dev-master/ElCanari/application/Info-" + BUILD_KIND + ".plist"
plistDictionary = plistlib.readPlist (plistFileFullPath)
buildString = plistDictionary ['PMBuildString']
# print "Build String '" + buildString + "'"
#--- Mettre à jour les numéros de version dans la plist
plistDictionary ['CFBundleVersion'] = VERSION_CANARI + ", build " + buildString
plistDictionary ['CFBundleShortVersionString'] = VERSION_CANARI
plistlib.writePlist (plistDictionary, plistFileFullPath)
#-------------------- Compiler le projet Xcode
#let debutCompilation = Date ()
runCommand (["rm", "-fr", "build"])
runCommand (["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
             "-target", "ElCanari-" + BUILD_KIND,
             "-configuration", BUILD_KIND
            ])
#let finCompilation = Date ()
if BUILD_KIND == "Debug" :
  PRODUCT_NAME = "ElCanari-" + BUILD_KIND
#   runCommand (["cp", "-r", "build/" + BUILD_KIND + "/ElCanari-" + BUILD_KIND + ".app", "build/" + BUILD_KIND + "/ElCanari.app"])
else:
  PRODUCT_NAME = "ElCanari"
#-------------------- Créer l'archive BZ2 de Canari
# runCommand (["cp", "-r", "build/" + BUILD_KIND + "/ElCanari.app", "."])
# runCommand (["tar", "-cf", "ElCanari.app.tar", "ElCanari.app"])
# runCommand (["bzip2", "-9", "ElCanari.app.tar"])
# BZ2file = DISTRIBUTION_DIR + "/ElCanari.app." + VERSION_CANARI + ".tar.bz2"
# runCommand (["mv", "ElCanari.app.tar.bz2", BZ2file])
#-------------------- Construction package
packageFile = PRODUCT_NAME + "-" + VERSION_CANARI + ".pkg"
runCommand (["productbuild", "--component", "build/" + BUILD_KIND + "/" + PRODUCT_NAME + ".app", "/Applications", packageFile])
runCommand (["cp", packageFile, DISTRIBUTION_DIR])
#-------------------- Créer l'archive de Cocoa canari
nomArchive = PRODUCT_NAME + "-" + VERSION_CANARI
runCommand (["mkdir", nomArchive])
runCommand (["cp", packageFile, nomArchive])
runCommand (["hdiutil", "create", "-srcfolder", nomArchive, nomArchive + ".dmg", "-fs", "HFS+"])
runCommand (["mv", nomArchive + ".dmg", "../" + nomArchive + ".dmg"])
#-------------------- Supprimer le fichier .pkg
runCommand (["rm", DISTRIBUTION_DIR + "/" + packageFile])
#-------------------- Calculer la clé de la somme de contrôle de l'archive DMG pour Sparkle
cleArchive = runHiddenCommand (["./distribution-el-canari/sign_update", "../" + nomArchive + ".dmg"])
cleArchive = cleArchive [0:-2] # Remove training 'end-of-line', and training '"'
#-------------------- Ajouter les meta infos
dict = dictionaryFromJsonFile (DISTRIBUTION_DIR + "/ElCanari-dev-master/change.json")
x = cleArchive.rpartition('" length="')
length = x [2]
y = x[0].rpartition('sparkle:edSignature="')
sommeControle = y [2]
print ("cleArchive: " + cleArchive)
print ("sommeControle: " + sommeControle)
print ("length: " + length)
dict ["archive-sum"] = sommeControle
dict ["archive-length"] = str (length)
dict ["build"] = buildString
f = open (DISTRIBUTION_DIR + "/" + PRODUCT_NAME + "-" + VERSION_CANARI + ".json", "w")
f.write (json.dumps (dict, indent=2))
f.close ()
#--- Supprimer les répertoires intermédiaires
os.chdir (DISTRIBUTION_DIR)
while os.path.isdir (DISTRIBUTION_DIR + "/ElCanari-dev-master"):
  shutil.rmtree (DISTRIBUTION_DIR + "/ElCanari-dev-master")
#---
#print ("Durée de compilation : \(finCompilation - debutCompilation)")

#——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————*
