#! /usr/bin/python3
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
  totalLineCount = 0
  for root, dirnames, filenames in os.walk (repertoire):
    total = 0
    for filename in fnmatch.filter (filenames, '*.' + extension):
      total += compterLignesFichier (os.path.join (root, filename))
    totalLineCount += total
    if total > 0 :
      print ("Sources, " + root + ": " + str (total) + " lines")
  return totalLineCount

#----------------------------------------------------------------- Get script absolute path
scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
os.chdir (scriptDir)
#----------------------------------------------------------------- Get goal as first argument
totalLineCount = compterLignes (scriptDir + "/ElCanari", "swift")
print ("Swift Sources, total: " + str (totalLineCount) + " lines")
print ("Easy-bindings Sources: " + str (compterLignes (scriptDir, "eb")) + " lines")

#----------------------------------------------------------------------------------------------------------------------*
