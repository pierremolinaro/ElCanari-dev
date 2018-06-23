#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#----------------------------------------------------------------------------------------------------------------------*
# http://stackoverflow.com/questions/6286937/how-to-auto-increment-bundle-version-in-xcode-4
# https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html
# http://stackoverflow.com/questions/6045184/specify-a-filelist-to-run-script-build-phase-in-xcode/9307058#9307058
# http://indiestack.com/2014/12/speeding-up-custom-script-phases/
#----------------------------------------------------------------------------------------------------------------------*

import plistlib, hashlib, sys, os, json

#----------------------------------------------------------------------------------------------------------------------*

def sourceDidChange (jsonFileName) :
  #--- Build infos (from environment variables)
  CURRENT_ARCH = os.environ['CURRENT_ARCH']
  #print "CURRENT_ARCH '" + CURRENT_ARCH + "'"
  CURRENT_VARIANT = os.environ['CURRENT_VARIANT']
  #print "CURRENT_VARIANT '" + CURRENT_VARIANT + "'"
  OBJECT_FILE_DIR = os.environ['OBJECT_FILE_DIR_' + CURRENT_VARIANT] + "/" + CURRENT_ARCH
  #print "OBJECT_FILE_DIR '" + OBJECT_FILE_DIR + "'"
  #--- Enumerate OBJECT_FILE_DIR directory, retain .d files
  dependanceFileList = []
  for dirname, dirnames, filenames in os.walk (OBJECT_FILE_DIR):
    for file in filenames:
      extension = os.path.splitext(file)[1]
      if extension == ".d" :
        #print "  Dependence file : '" + file + "'"
        dependanceFileList.append (file)
  #--- Analyze dependence files
  sourceFileSet = set ()
  for file in dependanceFileList :
    #print "  Dependence file : '" + file + "'"
    fullPath = OBJECT_FILE_DIR + "/" + file
    f = open (fullPath, 'r')
    f.readline () # Pass first line (it contains 'dependences:'
    for line in f :
      #print "   Line : '" + line + "'"
      components = line.split ()
      if components.count > 0:
        #print "   Component : '" + components[0] + "'"
        sourceFileSet.add (components[0])
    f.close ()
  #--- Get sorted file list
  sourceFileList = sorted (list (sourceFileSet))
  #--- Get script absolute path
  scriptDir = os.path.dirname (os.path.abspath (sys.argv [0]))
  #--- Compute SHA1 sum for all files
  newDictionary = {}
  for file in sourceFileList:
    if os.path.isfile (file) :
      f = open (file, 'r')
      contents = f.read ()
      f.close ()
      sha1 = hashlib.sha1 (contents).hexdigest ()
      #print "file '" + file + "' -> SHA1 : " + sha1
      newDictionary [os.path.basename (file)] = sha1
    else:
      newDictionary [os.path.basename (file)] = "?"
  #--- Check if files did change
  didChange = True
  jsonFileFullPath = scriptDir + "/" + jsonFileName
  if os.path.isfile (jsonFileFullPath) :
    #--- Read json file
    f = open (jsonFileFullPath, "r")
    loadedDictionary = json.loads (f.read ())
    f.close ()
    #--- Change ?
    didChange = newDictionary != loadedDictionary
  #--- If change write new dictionary
  if didChange :
    f = open (jsonFileFullPath, "w")
    f.write (json.dumps (newDictionary))
    f.close ()
  #---
  return didChange

#----------------------------------------------------------------------------------------------------------------------*
