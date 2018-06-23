#! /usr/bin/env python
# -*- coding: UTF-8 -*-

#----------------------------------------------------------------------------------------------------------------------*
# http://stackoverflow.com/questions/6286937/how-to-auto-increment-bundle-version-in-xcode-4
# https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html
# http://stackoverflow.com/questions/6045184/specify-a-filelist-to-run-script-build-phase-in-xcode/9307058#9307058
# http://indiestack.com/2014/12/speeding-up-custom-script-phases/
#----------------------------------------------------------------------------------------------------------------------*

import plistlib, hashlib, sys, os, json
import source_did_change

#----------------------------------------------------------------------------------------------------------------------*

#--- Detect changes in sources
didChange = source_did_change.sourceDidChange ("Info.plist.json")
if didChange :
  #--- Get plist file path (from environment variables)
  INFOPLIST_FILE = os.environ['INFOPLIST_FILE']
  #print "INFOPLIST_FILE '" + INFOPLIST_FILE + "'"
  #--- Read Info.plist file
  dictionary = plistlib.readPlist (INFOPLIST_FILE)
  if 'PMBuildString' in dictionary:
    buildString = dictionary ['PMBuildString']
    #print "in dict '" + buildString + "'"
  else:
    buildString = "1A0"
  #--- Decompose build string
  major = 0
  while buildString [0].isdigit () :
    major *= 10 ;
    major += int (buildString [0])
    buildString = buildString [1:]
    #print "Major " + str (major) + " " + buildString
  letter = buildString [0]
  minor = int (buildString [1:])
  #print "Major " + str (major) + ", letter " + letter + ", minor " + str (minor)
  #--- increment build version
  minor = minor + 1
  if minor == 100 :
    minor = 0
    letter = chr (ord (letter) + 1)
    if letter == '[' : # '[" is the next char after 'Z'
      letter = 'A'
      major = major + 1
  newBuildString = str(major) + letter + str (minor)
  print "newBuildString '" + newBuildString + "'"
  #--- Update info.plist string
  dictionary ['PMBuildString'] = newBuildString
  plistlib.writePlist (dictionary, INFOPLIST_FILE)

#----------------------------------------------------------------------------------------------------------------------*
