import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func partNameIsValid (_ inPartName : String) -> Bool {
  var valid = inPartName.unicodeScalars.count > 0
  for c in inPartName.unicodeScalars {
    if valid {
      valid = (c >= "a") && (c <= "z")
      if !valid {
        valid = (c >= "0") && (c <= "9")
      }
      if !valid {
       valid = (c == "_") || (c == "-") || (c == "+")
      }
    }
  }
  return valid
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func existingLibraryPathArray () -> [String] {
  let fm = FileManager ()
  var result = [String] ()
//--- System library
//  if let prefs = g_Preferences, prefs.usesSystemLibrary.propval {
//    let slp = systemLibraryPath ()
//    if fm.fileExists (atPath: slp) {
//      result.append (slp)
//    }
//  }
//--- User library
  if let prefs = g_Preferences, prefs.usesUserLibrary_property.propval {
    let ulp = userLibraryPath ()
    if fm.fileExists (atPath: ulp) {
      result.append (ulp)
    }
  }
//--- Other libraries
  if let prefs = g_Preferences {
    for libraryEntry in prefs.additionnalLibraryArray_property.propval {
      if libraryEntry.mUses {
        if fm.fileExists (atPath: libraryEntry.mPath) {
          result.append (libraryEntry.mPath)
        }
      }
    }
  }
//---
  return result
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func temporaryDownloadDirectory () -> String {
  return NSTemporaryDirectory () + "/ElCanariTemporaries"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func userLibraryPath () -> String {
  let a = NSSearchPathForDirectoriesInDomains (FileManager.SearchPathDirectory.applicationSupportDirectory,
                                               FileManager.SearchPathDomainMask.userDomainMask,
                                               true) ;
  // NSLog (@"%@", a) ;
  if a.count != 1 {
    presentErrorWindow (file: #file, line:#line, errorMessage:String (a.count) + " entries for NSSearchPathForDirectoriesInDomains")
  }
  return a [0] + "/ElCanariLibrary"
}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func systemLibraryPath () -> String {
  return NSHomeDirectory () + "/Library/Application Support/ElCanariLibrary"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func symbolLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/symbols"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func packageLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/packages"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func deviceLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/devices"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func artworkLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/artworks"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func fontLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/fonts"
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func createLibraryAtPath (_ inPath : String) throws {
  let fm = FileManager ()
//--- Library directory
  if !fm.fileExists (atPath: inPath) {
    try fm.createDirectory (atPath: inPath, withIntermediateDirectories:true, attributes:nil)
  }
//--- Symbol directory
  do{
    let dir = symbolLibraryPathForPath (inPath)
    if !fm.fileExists (atPath: dir) {
      try fm.createDirectory (atPath: dir, withIntermediateDirectories:true, attributes:nil)
    }
  }
//--- Package directory
  do{
    let dir = packageLibraryPathForPath (inPath)
    if !fm.fileExists (atPath: dir) {
      try fm.createDirectory (atPath: dir, withIntermediateDirectories:true, attributes:nil)
    }
  }
//--- Device directory
  do{
    let dir = deviceLibraryPathForPath (inPath)
    if !fm.fileExists (atPath: dir) {
      try fm.createDirectory (atPath: dir, withIntermediateDirectories:true, attributes:nil)
    }
  }
//--- Artwork directory
  do{
    let dir = artworkLibraryPathForPath (inPath)
    if !fm.fileExists (atPath: dir) {
      try fm.createDirectory (atPath: dir, withIntermediateDirectories:true, attributes:nil)
    }
  }
//--- Font directory
  do{
    let dir = fontLibraryPathForPath (inPath)
    if !fm.fileExists (atPath: dir) {
      try fm.createDirectory (atPath: dir, withIntermediateDirectories:true, attributes:nil)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func packageFilePathInLibraries (_ inPackageName : String) -> [String] {
  var pathes = [String] ()
  let fm = FileManager ()
  for libraryDir in existingLibraryPathArray () {
    let packageLibraryDir = packageLibraryPathForPath (libraryDir)
    if let allPackages = try? fm.subpathsOfDirectory(atPath: packageLibraryDir) {
      for candidatePackagePath in allPackages {
        if candidatePackagePath.lastPathComponent.deletingPathExtension == inPackageName {
          pathes.append (packageLibraryDir + "/" + candidatePackagePath)
        }
      }
    }
  }
  return pathes
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func deviceFilePathInLibraries (_ inDeviceName : String) -> [String] {
  var pathes = [String] ()
  let fm = FileManager ()
  for libraryDir in existingLibraryPathArray () {
    let deviceLibraryDir = deviceLibraryPathForPath (libraryDir)
    if let allDevices = try? fm.subpathsOfDirectory(atPath: deviceLibraryDir) {
      for candidateDevicePath in allDevices {
        if candidateDevicePath.lastPathComponent.deletingPathExtension == inDeviceName {
          pathes.append (deviceLibraryDir + "/" + candidateDevicePath)
        }
      }
    }
  }
  return pathes
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
