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

def compterLignes (repertoire, extension) :
  n = 0
  for root, dirnames, filenames in os.walk (repertoire):
    for filename in fnmatch.filter (filenames, '*.' + extension):
      n += compterLignesFichier (os.path.join (root, filename))
  return n

#----------------------------------------------------------------- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
os.chdir (scriptDir)
#----------------------------------------------------------------- Get goal as first argument
print ("Swift Sources: " + str (compterLignes (scriptDir + "/ElCanari", "swift")) + " lines")
print ("Easy-bindings Sources: " + str (compterLignes (scriptDir, "eb")) + " lines")

#----------------------------------------------------------------------------------------------------------------------*
