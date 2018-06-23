#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#----------------------------------------------------------------------------------------------------------------------*

import shutil, os, sys, subprocess, datetime, plistlib, urllib, time, json
import xml.etree.ElementTree as ET
from xml.dom import minidom

#-------------------- Version ElCanari
VERSION_CANARI = "0.2.4"

#----------------------------------------------------------------------------------------------------------------------*
#   FOR PRINTING IN COLOR                                                                                              *
#----------------------------------------------------------------------------------------------------------------------*

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

#----------------------------------------------------------------------------------------------------------------------*
#   DOWNLOAD FILE                                                                                                      *
#----------------------------------------------------------------------------------------------------------------------*

def downloadArchive (archiveURL, filePath):
  print BOLD_MAGENTA + "Download " + filePath + ENDC
  runCommand (["rm", "-f", filePath + ".downloading"])
  try:
    urllib.urlretrieve (archiveURL,  filePath + ".downloading")
    runCommand (["mv", filePath + ".downloading", filePath])
  except:
    print BOLD_RED () + "Error: no network connection" + ENDC ()
    sys.exit (1)

#----------------------------------------------------------------------------------------------------------------------*
#   runCommand                                                                                                         *
#----------------------------------------------------------------------------------------------------------------------*

def runCommand (cmd) :
  str = "+"
  for s in cmd:
    str += " " + s
  print BOLD_MAGENTA + str + ENDC
  childProcess = subprocess.Popen (cmd)
  childProcess.wait ()
  if childProcess.returncode != 0 :
    sys.exit (childProcess.returncode)

#----------------------------------------------------------------------------------------------------------------------*
#   runHiddenCommand                                                                                                   *
#----------------------------------------------------------------------------------------------------------------------*

def runHiddenCommand (cmd) :
  str = "+"
  for s in cmd:
    str += " " + s
  print BOLD_MAGENTA + str + ENDC
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
        print BOLD_RED + "*** Error " + str (childProcess.returncode) + " ***" + ENDC
        sys.exit (childProcess.returncode)
      return result

#----------------------------------------------------------------------------------------------------------------------*

#--- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
#-------------------- Supprimer une distribution existante
TEMP_DIR = scriptDir + "/../DISTRIBUTION_EL_CANARI_" + VERSION_CANARI
if os.path.isdir (TEMP_DIR):
  shutil.rmtree (TEMP_DIR)
#-------------------- Creer le repertoire contenant la distribution
os.mkdir (TEMP_DIR)
os.chdir (TEMP_DIR)
#-------------------- Importer canari
texteSurConsole = runHiddenCommand (["svn", "export", "https://canari.rts-software.org/svn/version-2-swift/", TEMP_DIR + "/canari"])
components = texteSurConsole.split ("Exported revision")
#print "'" + components [1] + "'"
components = components [1].split (".")
numeroRevisionSVN = components [0].strip ()
print "Révision SVN : '" + numeroRevisionSVN + "'"
#-------------------- AUTHORS et COPYING
os.mkdir (TEMP_DIR + "/COCOA-CANARI")
runHiddenCommand (["svn",
                   "export",
                   "https://canari.rts-software.org/svn/AUTHORS",
                   TEMP_DIR + "/COCOA-CANARI/AUTHORS"
                 ])
runHiddenCommand (["svn",
                   "export",
                   "https://canari.rts-software.org/svn/COPYING",
                   TEMP_DIR + "/COCOA-CANARI/COPYING"
                 ])
#-------------------- Obtenir l'année
ANNEE = str (datetime.datetime.now().year)
print "ANNÉE : '" + ANNEE + "'"
#-------------------- Obtenir le numéro de build
plistFileFullPath = TEMP_DIR + "/canari/ElCanari/canari-application/Info.plist"
plistDictionary = plistlib.readPlist (plistFileFullPath)
buildString = plistDictionary ['PMBuildString']
print "Build String '" + buildString + "'"
#--- Mettre à jour les numéros de version dans la plist
plistDictionary ['CFBundleVersion'] = VERSION_CANARI + ", repository " + numeroRevisionSVN + ", build " + buildString
plistDictionary ['CFBundleShortVersionString'] = VERSION_CANARI
plistlib.writePlist (plistDictionary, plistFileFullPath)
#-------------------- Copier le fichier change.html
runCommand (["cp", TEMP_DIR + "/canari/change.html", TEMP_DIR + "/change.html"])
#-------------------- Compiler le projet Xcode
os.chdir (TEMP_DIR + "/canari")
runCommand (["rm", "-fr", "build"])
runCommand (["/Applications/Xcode.app/Contents/Developer/usr/bin/xcodebuild",
             "-target", "ElCanari",
             "-configuration", "Release"
            ])
os.chdir (TEMP_DIR)
#-------------------- Créer l'archive BZ2 de Canari
runCommand (["cp", "-r", TEMP_DIR + "/canari/build/Release/ElCanari.app", TEMP_DIR])
runCommand (["tar", "-cf", "ElCanari.app.tar", "ElCanari.app"])
runCommand (["bzip2", "-9", "ElCanari.app.tar"])
BZ2file = TEMP_DIR + "/ElCanari.app." + VERSION_CANARI + ".tar.bz2"
runCommand (["mv", "ElCanari.app.tar.bz2", BZ2file])
#-------------------- Calculer la clé de la somme de contrôle de l'archive pour Sparkle
sommeControle = runHiddenCommand ([scriptDir + "/distribution-el-canari/sign_update.sh",
                                  BZ2file,
                                  scriptDir + "/distribution-el-canari/dsa_priv.pem"])
sommeControle = sommeControle [0:- 1] # Remove training 'end-of-line'
#-------------------- Ajouter les meta infos
dict = {
  "version-svn" : str (numeroRevisionSVN),
  "archive-sum" : sommeControle,
  "build" : buildString
}
f = open (TEMP_DIR + "/infos.json", "w")
f.write (json.dumps (dict, indent=2))
f.close ()
#-------------------- Vérifier si l'application est signée
runCommand (["spctl", "-a", "-t", "exec", "-vv", "ElCanari.app"])
#-------------------- Créer l'archive de Cocoa canari
# cp ${DIR}/canari/AUTHORS ${DIR}/COCOA-CANARI &&
# cp ${DIR}/canari/COPYING ${DIR}/COCOA-CANARI &&
runCommand (["mv", "ElCanari.app", TEMP_DIR + "/COCOA-CANARI"])
runCommand (["ln", "-s", "/Applications", TEMP_DIR + "/COCOA-CANARI/Applications"])
# cp -r ${DIR}/canari/version-1/build/Release/Canari.app ${DIR}/COCOA-CANARI &&
runCommand (["hdiutil",
             "create",
             "-srcfolder",
             TEMP_DIR + "/COCOA-CANARI",
             TEMP_DIR + "/ElCanari." + VERSION_CANARI + ".dmg"
           ])
#--- Supprimer les répertoires intermédiaires
#shutil.rmtree (TEMP_DIR + "/canari")
#shutil.rmtree (TEMP_DIR + "/COCOA-CANARI")

#----------------------------------------------------------------------------------------------------------------------*
