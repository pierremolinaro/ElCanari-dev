#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#----------------------------------------------------------------------------------------------------------------------*

import sys, os, fnmatch

#----------------------------------------------------------------------------------------------------------------------*

def compterLignesFichier (nomFichier) :
  fd = open (nomFichier, 'r')
  n = 0
  while fd.readline ():
    n += 1
  fd.close ()
  return n

#----------------------------------------------------------------------------------------------------------------------*

gTotalLineCount = 0

#----------------------------------------------------------------------------------------------------------------------*

def compterLignes (repertoire, extension) :
  global gTotalLineCount
  for root, dirnames, filenames in os.walk (repertoire):
    for filename in fnmatch.filter (filenames, '*.' + extension):
      gTotalLineCount += compterLignesFichier (os.path.join (root, filename))

#----------------------------------------------------------------- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
os.chdir (scriptDir)
#----------------------------------------------------------------- Get goal as first argument
compterLignes (scriptDir + "/ElCanari", "swift")
print ("Swift Sources: " + str (gTotalLineCount) + " lines")
print ("Easy-bindings Sources: " + str (compterLignes (scriptDir, "eb")) + " lines")

#----------------------------------------------------------------------------------------------------------------------*
