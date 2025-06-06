import Foundation

//--------------------------------------------------------------------------------------------------

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

//--------------------------------------------------------------------------------------------------

@MainActor func existingLibraryPathArray () -> [String] {
  let fm = FileManager ()
  var result = [String] ()
//--- User library
  if preferences_usesUserLibrary_property.propval {
    let ulp = userLibraryPath ()
    if fm.fileExists (atPath: ulp) {
      result.append (ulp)
    }
  }
//--- Other libraries
  for libraryEntry in preferences_additionnalLibraryArray_property.propval.values {
    if libraryEntry.mUses {
      if fm.fileExists (atPath: libraryEntry.mPath) {
        result.append (libraryEntry.mPath)
      }
    }
  }
//---
  return result
}

//--------------------------------------------------------------------------------------------------

@MainActor func userLibraryPath () -> String {
  let a = NSSearchPathForDirectoriesInDomains (
    FileManager.SearchPathDirectory.applicationSupportDirectory,
    FileManager.SearchPathDomainMask.userDomainMask,
    true
  ) ;
  if a.count != 1 {
    presentErrorWindow (#file, #line, "\(a.count) entries for NSSearchPathForDirectoriesInDomains")
  }
  return a [0] + "/ElCanariLibrary"
}


//--------------------------------------------------------------------------------------------------

func systemLibraryPath () -> String {
  return NSHomeDirectory () + "/Library/Application Support/ElCanariLibrary"
}

//--------------------------------------------------------------------------------------------------

func symbolLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/symbols"
}

//--------------------------------------------------------------------------------------------------

func packageLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/packages"
}

//--------------------------------------------------------------------------------------------------

func deviceLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/devices"
}

//--------------------------------------------------------------------------------------------------

func artworkLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/artworks"
}

//--------------------------------------------------------------------------------------------------

func fontLibraryPathForPath (_ inLibraryPath : String) -> String {
  return inLibraryPath + "/fonts"
}

//--------------------------------------------------------------------------------------------------

@MainActor func symbolFilePathInLibraries (_ inSymbolNameWithoutExtension : String) -> [String] {
  var pathes = [String] ()
  let fm = FileManager ()
  for libraryDir in existingLibraryPathArray () {
    let symbolLibraryDir = symbolLibraryPathForPath (libraryDir)
    if let allSymbols = try? fm.subpathsOfDirectory(atPath: symbolLibraryDir) {
      for candidateSymbolPath in allSymbols {
        let pathExtension = candidateSymbolPath.lastPathComponent.pathExtension
        let baseName = candidateSymbolPath.lastPathComponent.deletingPathExtension
        if (baseName == inSymbolNameWithoutExtension) && (pathExtension.lowercased() == ElCanariSymbol_EXTENSION) {
          pathes.append (symbolLibraryDir + "/" + candidateSymbolPath)
        }
      }
    }
  }
  return pathes
}

//--------------------------------------------------------------------------------------------------

@MainActor func packageFilePathInLibraries (_ inPackageNameWithoutExtension : String) -> [String] {
  var pathes = [String] ()
  let fm = FileManager ()
  for libraryDir in existingLibraryPathArray () {
    let packageLibraryDir = packageLibraryPathForPath (libraryDir)
    if let allPackages = try? fm.subpathsOfDirectory(atPath: packageLibraryDir) {
      for candidatePackagePath in allPackages {
        let pathExtension = candidatePackagePath.lastPathComponent.pathExtension
        let baseName = candidatePackagePath.lastPathComponent.deletingPathExtension
        if (baseName == inPackageNameWithoutExtension) && (pathExtension.lowercased() == ElCanariPackage_EXTENSION) {
          pathes.append (packageLibraryDir + "/" + candidatePackagePath)
        }
      }
    }
  }
  return pathes
}

//--------------------------------------------------------------------------------------------------

@MainActor func deviceFilePathInLibraries (_ inDeviceNameWithoutExtension : String) -> [String] {
  var pathes = [String] ()
  let fm = FileManager ()
  for libraryDir in existingLibraryPathArray () {
    let deviceLibraryDir = deviceLibraryPathForPath (libraryDir)
    if let allDevices = try? fm.subpathsOfDirectory(atPath: deviceLibraryDir) {
      for candidateDevicePath in allDevices {
        let pathExtension = candidateDevicePath.lastPathComponent.pathExtension
        let baseName = candidateDevicePath.lastPathComponent.deletingPathExtension
        if (baseName == inDeviceNameWithoutExtension) && (pathExtension.lowercased() == ElCanariDevice_EXTENSION) {
          pathes.append (deviceLibraryDir + "/" + candidateDevicePath)
        }
      }
    }
  }
  return pathes
}

//--------------------------------------------------------------------------------------------------

@MainActor func fontFilePathInLibraries (_ inFontNameWithoutExtension : String) -> [String] {
  var pathes = [String] ()
  let fm = FileManager ()
  for libraryDir in existingLibraryPathArray () {
    let fontLibraryDir = fontLibraryPathForPath (libraryDir)
    if let allFonts = try? fm.subpathsOfDirectory (atPath: fontLibraryDir) {
      for candidateFontPath in allFonts {
        let pathExtension = candidateFontPath.lastPathComponent.pathExtension
        let baseName = candidateFontPath.lastPathComponent.deletingPathExtension
        if (baseName == inFontNameWithoutExtension) && (pathExtension.lowercased() == ElCanariFont_EXTENSION) {
          pathes.append (fontLibraryDir + "/" + candidateFontPath)
        }
      }
    }
  }
  return pathes
}

//--------------------------------------------------------------------------------------------------
