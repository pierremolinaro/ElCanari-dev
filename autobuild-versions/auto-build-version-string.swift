#! /usr/bin/swift

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of Data
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func sha1 (_ inData : Data) -> String {
  let transform = SecDigestTransformCreate (kSecDigestSHA1, 0, nil)
  SecTransformSetAttribute (transform, kSecTransformInputAttributeName, inData as CFTypeRef, nil)
  let shaValue = SecTransformExecute (transform, nil) as! Data
  var s = ""
  for byte in shaValue {
    s += "\(String (byte, radix:16, uppercase: false))"
  }
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func store (buildString : String, intoElCanariPLIST inPath : String) {
  let plistFileURL = URL (fileURLWithPath: inPath)
  let data = try! Data (contentsOf: plistFileURL)
  var dict = try! PropertyListSerialization.propertyList (from: data, options: [], format: nil) as! [String : Any]
  dict ["PMBuildString"] = buildString
  let newData = try! PropertyListSerialization.data (fromPropertyList: dict, format: .binary, options: 0)
  try! newData.write (to: plistFileURL)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "J", "K", "L", "M", "N", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// http://stackoverflow.com/questions/6286937/how-to-auto-increment-bundle-version-in-xcode-4
// https://developer.apple.com/library/mac/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/1-Build_Setting_Reference/build_setting_ref.html
// http://stackoverflow.com/questions/6045184/specify-a-filelist-to-run-script-build-phase-in-xcode/9307058#9307058
// http://indiestack.com/2014/12/speeding-up-custom-script-phases/
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    MAIN
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let fm = FileManager ()
//-------------------- Get script absolute path
let scriptDir = URL (fileURLWithPath: CommandLine.arguments [0]).deletingLastPathComponent ().path
//print ("scriptDir \(scriptDir)")
//--- Get file SHA plist
let plistFileURL = URL (fileURLWithPath: scriptDir + "/files-sha.plist")
//print ("plistFileURL: '\(plistFileURL)'")
let currentFileDictionary : [String : Any]
if let data = try? Data (contentsOf: plistFileURL) {
  let d = try! PropertyListSerialization.propertyList (from: data, options: [], format: nil)
  let dd = d as! [String : Any]
  currentFileDictionary = dd
}else{
  currentFileDictionary = [String : Any] ()
}
//--- Detect changes in sources
let sourceDir = scriptDir + "/../ElCanari"
let allFilePathes = try! fm.subpathsOfDirectory (atPath: sourceDir)
var newFileDictionary = [String : Any] ()
var changed = false
for filePath in allFilePathes {
  let fileURL = URL (fileURLWithPath: sourceDir + "/" + filePath)
  let pathExtension = fileURL.pathExtension
  var isDir : ObjCBool = true
  if pathExtension != "plist", filePath != ".DS_Store", fm.fileExists (atPath: sourceDir + "/" + filePath, isDirectory: &isDir), !isDir.boolValue {
    // print ("fileURL '\(fileURL)'")
    let data = try! Data (contentsOf: fileURL)
    let sha = sha1 (data)
    newFileDictionary [filePath] = sha
    let fileChanged : Bool
    if let oldSHA = currentFileDictionary [filePath] as? String {
      fileChanged = oldSHA != sha
    }else{
      fileChanged = true
    }
    if fileChanged {
      changed = true
      print ("SHA did change for file '\(filePath)'")
    }
  }
}
//--- Checks keys are the same
let oldKeys = Set (currentFileDictionary.keys)
var newKeys = Set (newFileDictionary.keys)
newKeys.insert ("-")
if oldKeys != newKeys {
  changed = true
}
for newFilePath in newKeys.subtracting (oldKeys) {
  print ("ADDED PATH '\(newFilePath)'")
}
for removedFilePath in oldKeys.subtracting (newKeys) {
  print ("REMOVED PATH '\(removedFilePath)'")
}
//--- If change, update plist file and write new build number into ElCanari plist files
if changed {
  //--- Get previous build number
    var buildNumber : Int
    if let n = currentFileDictionary ["-"] as? Int {
      buildNumber = n
    }else{
      buildNumber = 0
    }
    buildNumber += 1
    let minor = buildNumber % 100
    let letter = letters [(buildNumber / 100) % letters.count]
    let major = 1 + buildNumber / 100 / letters.count
    let buildString = "\(major)\(letter)\(minor)"
    newFileDictionary ["-"] = buildNumber
    print ("Updated build number: \(buildNumber) \(buildString)")
  //--- Store in ElCanari plist files
    store (buildString: buildString, intoElCanariPLIST: sourceDir + "/application/Info-Debug.plist")
    store (buildString: buildString, intoElCanariPLIST: sourceDir + "/application/Info-Release.plist")
  //--- Store new plist file
    let data = try! PropertyListSerialization.data (fromPropertyList: newFileDictionary, format: .binary, options: 0)
    try! data.write (to: plistFileURL)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
