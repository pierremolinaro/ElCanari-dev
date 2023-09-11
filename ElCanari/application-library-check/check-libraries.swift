//
//  check-libraries.swift
//  canari
//
//  Created by Pierre Molinaro on 30/06/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func checkLibrary (windowForSheet inWindow : NSWindow,
                              logWindow inLogWindow : NSWindow) {
  let logView = AutoLayoutStaticTextView (drawsBackground: false, horizontalScroller: true, verticalScroller: true)
    .expandableWidth ()
    .expandableHeight ()
  inLogWindow.contentView = logView
//--- Clear Log
  logView.clear ()
  var errorCount = 0
//  var warningCount = 0
  do{
  //--- Checking Symbols
    var symbolDict : [String : PMSymbolDictionaryEntry] = [:]
    try checkSymbolLibrary (logView, symbolDict: &symbolDict, errorCount: &errorCount)
  //--- Checking Packages
    var packageDict : [String : PMPackageDictionaryEntry] = [:]
    try checkPackageLibrary (logView, packageDict: &packageDict, errorCount: &errorCount)
  //--- Checking Devices
    var deviceToUpdateSet = Set <String> ()
    try checkDeviceLibrary (
      logView,
      symbolDict: symbolDict,
      packageDict: packageDict,
      deviceToUpdateSet: &deviceToUpdateSet,
      errorCount: &errorCount
    )
    let ws = NSWorkspace.shared
    for path in deviceToUpdateSet {
      ws.open (URL (fileURLWithPath: path))
    }
  //--- Checking Font
    try checkFontLibrary (logView, errorCount: &errorCount)
  //--- Checking Artworks
    try checkArtworkLibrary (logView, errorCount: &errorCount)
  //--- Summary
    logView.appendMessageString ("\n")
    if errorCount == 0 {
      logView.appendSuccessString ("No error")
    }else if errorCount == 1 {
      logView.appendErrorString ("1 error")
    }else{
      logView.appendErrorString ("\(errorCount) errors")
    }
//    logView.appendMessageString ("; ")
//    if warningCount == 0 {
//      logView.appendSuccessString ("No warning")
//    }else if (warningCount == 1) {
//      logView.appendWarningString ("1 warning")
//    }else{
//      logView.appendWarningString (String (warningCount) + " warnings")
//    }
    logView.appendMessageString (".")
    if errorCount > 0 {
      let alert = NSAlert ()
      alert.messageText = "There are inconsistencies in the librairies"
      _ = alert.addButton (withTitle: "Ok")
      _ = alert.addButton (withTitle: "Show Log Window")
      alert.informativeText = "Select the 'Show Log Window' button for details."
      alert.beginSheetModal (for: inWindow) { inReturnCode in
        if inReturnCode == .alertSecondButtonReturn {
          logView.window?.makeKeyAndOrderFront (nil)
        }
      }
    }else{
      let alert = NSAlert ()
      alert.messageText = "Librairies are consistent."
      alert.beginSheetModal (for: inWindow) { (NSModalResponse) in }
    }
  }catch let error {
    _ = inWindow.presentError (error)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate enum PartStatus {
  case pmPartHasUnknownStatus
  case pmPartIsDuplicated
  case pmPartHasInvalidName
  case pmPartHasError
  case pmPartHasWarning
  case pmPartIsValid
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   DEVICE
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PMDeviceDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
  let symbolDictionary : [String : Int]
  let packageDictionary : [String : Int]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func checkDeviceLibraryCheck (atPath inDeviceFullPath : String,
                                                     deviceDict ioDeviceDict : inout [String : PMDeviceDictionaryEntry]) throws {
  let deviceName = ((inDeviceFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
//--- Get metadata dictionary
  let metadata = try getFileMetadata (atPath: inDeviceFullPath)
//--- Version number
  let possibleVersionNumber : Any? = metadata.metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (inDeviceFullPath, code: #line)
  }
//--- Embedded symbol dictionary
  let possibleSymbolDictionary : Any? = metadata.metadataDictionary [DEVICE_SYMBOL_METADATA_DICTIONARY_KEY]
  var symbolDictionary : [String : Int] = [:]
  if let d = possibleSymbolDictionary as? [String : Int] {
    for (importedSymbolName, symbolDescription) in d {
      symbolDictionary [importedSymbolName] = symbolDescription
    }
  }else{
    throw badFormatErrorForFileAtPath (inDeviceFullPath, code: #line)
  }
//--- Embedded package dictionary
  let possiblePackageDictionary : Any? = metadata.metadataDictionary [DEVICE_PACKAGE_METADATA_DICTIONARY_KEY]
  var packageDictionary : [String : Int] = [:]
  if let d = possiblePackageDictionary as? [String : Int] {
    for (importedPackageName, packageDescription) in d {
      packageDictionary [importedPackageName] = packageDescription
    }
  }else{
    throw badFormatErrorForFileAtPath (inDeviceFullPath, code:#line)
  }
//---
  let possibleEntry : PMDeviceDictionaryEntry? = ioDeviceDict [deviceName]
  if let entry = possibleEntry {
    let newEntry = PMDeviceDictionaryEntry (
      partStatus: .pmPartIsDuplicated,
      version: 0,
      versionStringForDialog: "—",
      pathArray: entry.pathArray + [inDeviceFullPath],
      symbolDictionary : symbolDictionary,
      packageDictionary : packageDictionary
    )
    ioDeviceDict [deviceName] = newEntry
  }else{
    var partStatus : PartStatus
    switch metadata.metadataStatus {
    case .unknown :
      partStatus = .pmPartHasUnknownStatus
    case .ok :
      partStatus = partNameIsValid (deviceName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .warning :
      partStatus = .pmPartHasWarning
    case .error :
      partStatus = .pmPartHasError
    }
    let newEntry = PMDeviceDictionaryEntry (
      partStatus: partStatus,
      version: version,
      versionStringForDialog: String (version),
      pathArray: [inDeviceFullPath],
      symbolDictionary: symbolDictionary,
      packageDictionary: packageDictionary
    )
    ioDeviceDict [deviceName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func performDeviceLibraryEnumeration (atPath inPackageLibraryPath : String,
                                                             deviceDict ioDeviceDict : inout [String : PMDeviceDictionaryEntry]) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased() == ElCanariDevice_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        try checkDeviceLibraryCheck (atPath: fullsubpath, deviceDict: &ioDeviceDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func checkDeviceLibrary (_ inLogView : AutoLayoutStaticTextView,
                                                symbolDict inSymbolDict : [String : PMSymbolDictionaryEntry],
                                                packageDict inPackageDict : [String : PMPackageDictionaryEntry],
                                                deviceToUpdateSet ioDeviceToUpdateSet : inout Set <String>,
                                                errorCount ioErrorCount : inout Int) throws {
  var deviceDict : [String : PMDeviceDictionaryEntry] = [:]
  inLogView.appendMessageString ("\nChecking devices library...\n")
  for path in existingLibraryPathArray () {
    let deviceLibraryPath = deviceLibraryPathForPath (path)
    inLogView.appendMessageString ("  Directory \(deviceLibraryPath)...\n")
    try performDeviceLibraryEnumeration (atPath: deviceLibraryPath, deviceDict: &deviceDict)
  }
//--- Display duplicate device count
  let foundDevices = deviceDict.count
  if foundDevices <= 1 {
    inLogView.appendSuccessString ("  Found \(foundDevices) part\n")
  }else{
    inLogView.appendSuccessString ("  Found \(foundDevices) parts\n")
  }
//--- Display duplicate entries and invalid entries
  for (deviceName, entry) in deviceDict {
  //--- Check device status
    switch entry.partStatus {
    case .pmPartIsDuplicated :
    if entry.pathArray.count > 1 {
      var errorString = "  Error; several files for '\(deviceName)' device:\n"
      for path in entry.pathArray {
        errorString += "    - \(path)\n"
      }
      inLogView.appendErrorString (errorString)
      ioErrorCount += 1
    }
    case .pmPartHasUnknownStatus :
      inLogView.appendErrorString ("  Error; '\(deviceName)' device has unknown status\n")
      ioErrorCount += 1
    case .pmPartHasInvalidName :
      inLogView.appendErrorString ("  Error; '\(deviceName)' device has an invalid name\n")
      ioErrorCount += 1
    case .pmPartHasError :
      inLogView.appendErrorString ("  Error; '\(deviceName)' device contains error(s)\n")
      ioErrorCount += 1
    case .pmPartHasWarning :
      inLogView.appendErrorString ("  Error; '\(deviceName)' device contains warning(s)\n")
      ioErrorCount += 1
    case .pmPartIsValid :
    //--- Check imported symbols
      for (importedSymbolName, importedSymbolVersion) in entry.symbolDictionary {
        if inSymbolDict [importedSymbolName] == nil {
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedSymbolName
          message += "' symbol, but this symbol is not defined by the library\n"
          inLogView.appendErrorString (message)
          ioErrorCount += 1
        }else if inSymbolDict [importedSymbolName]!.version != importedSymbolVersion {
          ioDeviceToUpdateSet.insert (entry.pathArray[0])
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedSymbolName
          message += "' symbol with version "
          message += String (importedSymbolVersion)
          message += ", but this symbol has version "
          message += String (inSymbolDict [importedSymbolName]!.version)
          message += " in library\n"
          inLogView.appendErrorString (message)
          ioErrorCount += 1
        }
      }
    //--- Check imported package
      for (importedPackageName, importedPackageVersion) in entry.packageDictionary {
        if inPackageDict [importedPackageName] == nil {
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedPackageName
          message += "' package, but this package is not defined by the library\n"
          inLogView.appendErrorString (message)
          ioErrorCount += 1
        }else if inPackageDict [importedPackageName]!.version != importedPackageVersion {
          ioDeviceToUpdateSet.insert (entry.pathArray[0])
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedPackageName
          message += "' package with version "
          message += String (importedPackageVersion)
          message += ", but this package has version "
          message += String (inPackageDict [importedPackageName]!.version)
          message += " in library\n"
          inLogView.appendErrorString (message)
          ioErrorCount += 1
        }
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   SYMBOL
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PMSymbolDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func checkSymbolLibraryCheck (atPath inSymbolFullPath : String,
                                          symbolDict ioSymbolDict : inout [String : PMSymbolDictionaryEntry]) throws {
  let symbolName = ((inSymbolFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  // print ("symbolFullPath \(symbolFullPath)")
  let metadata = try getFileMetadata (atPath: inSymbolFullPath)
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMSymbolVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (inSymbolFullPath, code:#line)
  }
  let possibleEntry : PMSymbolDictionaryEntry? = ioSymbolDict [symbolName]
  if let entry = possibleEntry {
  
    let newEntry = PMSymbolDictionaryEntry (
      partStatus: .pmPartIsDuplicated,
      version: 0,
      versionStringForDialog: "—",
      pathArray: entry.pathArray + [inSymbolFullPath]
    )
    ioSymbolDict [symbolName] = newEntry
  }else{
    let partStatus : PartStatus
    switch metadata.metadataStatus {
    case .unknown :
      partStatus = .pmPartHasUnknownStatus
    case .ok :
      partStatus = partNameIsValid (symbolName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .warning :
      partStatus = .pmPartHasWarning
    case .error :
      partStatus = .pmPartHasError
    }
    let newEntry = PMSymbolDictionaryEntry (
      partStatus: partStatus,
      version: version,
      versionStringForDialog: String (version),
      pathArray: [inSymbolFullPath]
    )
    ioSymbolDict [symbolName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func performSymbolLibraryEnumeration (atPath inSymbolLibraryPath : String,
                                                  symbolDict ioSymbolDict : inout [String : PMSymbolDictionaryEntry]) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inSymbolLibraryPath) {
  //  print ("unwSubpaths \(unwSubpaths)")
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariSymbol_EXTENSION {
        let fullsubpath = inSymbolLibraryPath.appendingPathComponent (path)
        try checkSymbolLibraryCheck (atPath: fullsubpath, symbolDict: &ioSymbolDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func checkSymbolLibrary (_ inLogView : AutoLayoutStaticTextView,
                                                symbolDict ioSymbolDict : inout [String : PMSymbolDictionaryEntry],
                                                errorCount ioErrorCount : inout Int) throws {
  inLogView.appendMessageString ("Checking symbols library...\n")
  for path in existingLibraryPathArray () {
    let symbolLibraryPath = symbolLibraryPathForPath (path)
    inLogView.appendMessageString ("  Directory \(symbolLibraryPath)...\n")
    try performSymbolLibraryEnumeration (atPath: symbolLibraryPath, symbolDict: &ioSymbolDict)
  }
//--- Display duplicate symbol count
  let foundSymbols = ioSymbolDict.count
  if foundSymbols <= 1 {
    inLogView.appendSuccessString ("  Found \(foundSymbols) part\n")
  }else{
    inLogView.appendSuccessString ("  Found \(foundSymbols) parts\n")
  }
//--- Display duplicate entries for symbols, invalid entries
  for (symbolName, entry) in ioSymbolDict {
    switch entry.partStatus {
    case .pmPartIsDuplicated :
    if entry.pathArray.count > 1 {
      var errorString = "  Error; several files for '\(symbolName)' symbol:\n"
      for path in entry.pathArray {
        errorString += "    - \(path)\n"
      }
      inLogView.appendErrorString (errorString)
      ioErrorCount += 1
    }
    case .pmPartHasUnknownStatus :
      inLogView.appendErrorString ("  Error; '\(symbolName)' symbol has unknown status\n")
      ioErrorCount += 1
    case .pmPartHasInvalidName :
      inLogView.appendErrorString ("  Error; '\(symbolName)' symbol has an invalid name\n")
      ioErrorCount += 1
    case .pmPartHasError :
      inLogView.appendErrorString ("  Error; '\(symbolName)' symbol contains error(s)\n")
      ioErrorCount += 1
    case .pmPartHasWarning :
      inLogView.appendErrorString ("  Error; '\(symbolName)' symbol contains warning(s)\n")
      ioErrorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   PACKAGE
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PMPackageDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func checkPackageLibraryCheck (atPath inPackageFullPath : String,
                                           packageDict ioPackageDict : inout [String : PMPackageDictionaryEntry]) throws {
  let packageName = ((inPackageFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  let metadata = try getFileMetadata (atPath: inPackageFullPath)
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMPackageVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (inPackageFullPath, code:#line)
  }
  let possibleEntry : PMPackageDictionaryEntry? = ioPackageDict [packageName]
  if let entry = possibleEntry {
  
    let newEntry = PMPackageDictionaryEntry (
      partStatus: .pmPartIsDuplicated,
      version: 0,
      versionStringForDialog: "—",
      pathArray: entry.pathArray + [inPackageFullPath]
    )
    ioPackageDict [packageName] = newEntry
  }else{
    var partStatus : PartStatus
    switch metadata.metadataStatus {
    case .unknown :
      partStatus = .pmPartHasUnknownStatus
    case .ok :
      partStatus = partNameIsValid (packageName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .warning :
      partStatus = .pmPartHasWarning
    case .error :
      partStatus = .pmPartHasError
    }
    let newEntry = PMPackageDictionaryEntry (
      partStatus: partStatus,
      version: version,
      versionStringForDialog: String (version),
      pathArray: [inPackageFullPath]
    )
    ioPackageDict [packageName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func performPackageLibraryEnumeration (atPath inPackageLibraryPath : String,
                                                   packageDict ioPackageDict : inout [String : PMPackageDictionaryEntry]) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased() == ElCanariPackage_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        try checkPackageLibraryCheck (atPath: fullsubpath, packageDict: &ioPackageDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func checkPackageLibrary (_ inLogView : AutoLayoutStaticTextView,
                                                 packageDict ioPackageDict : inout [String : PMPackageDictionaryEntry],
                                                 errorCount ioErrorCount : inout Int) throws {
  inLogView.appendMessageString ("\nChecking packages library...\n")
  for path in existingLibraryPathArray () {
    let packageLibraryPath = packageLibraryPathForPath (path)
    inLogView.appendMessageString ("  Directory \(packageLibraryPath)...\n")
    try performPackageLibraryEnumeration (atPath: packageLibraryPath, packageDict: &ioPackageDict)
  }
//--- Display duplicate package count
  let foundPackages = ioPackageDict.count
  if foundPackages <= 1 {
    inLogView.appendSuccessString ("  Found \(foundPackages) part\n")
  }else{
    inLogView.appendSuccessString ("  Found \(foundPackages) parts\n")
  }
//--- Display duplicate entries for symbols, invalid entries
  for (packageName, entry) in ioPackageDict {
    switch entry.partStatus {
    case .pmPartIsDuplicated :
    if entry.pathArray.count > 1 {
      var errorString = "  Error; several files for '\(packageName)' package:\n"
      for path in entry.pathArray {
        errorString += "    - \(path)\n"
      }
      inLogView.appendErrorString (errorString)
      ioErrorCount += 1
    }
    case .pmPartHasUnknownStatus :
      inLogView.appendErrorString ("  Error; '\(packageName)' package has unknown status\n")
      ioErrorCount += 1
    case .pmPartHasInvalidName :
      inLogView.appendErrorString ("  Error; '\(packageName)' package has an invalid name\n")
      ioErrorCount += 1
    case .pmPartHasError :
      inLogView.appendErrorString ("  Error; '\(packageName)' package contains error(s)\n")
      ioErrorCount += 1
    case .pmPartHasWarning :
      inLogView.appendErrorString ("  Error; '\(packageName)' package contains warning(s)\n")
      ioErrorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   FONT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PMFontDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func checkFontLibraryCheck (atPath inFontFullPath : String,
                                        fontDict ioFontDict : inout [String : PMFontDictionaryEntry]) throws {
  let fontName = ((inFontFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  let metadata = try getFileMetadata (atPath: inFontFullPath)
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMFontVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (inFontFullPath, code: #line)
  }
  let possibleEntry : PMFontDictionaryEntry? = ioFontDict [fontName]
  if let entry = possibleEntry {
    let newEntry = PMFontDictionaryEntry (
      partStatus: .pmPartIsDuplicated,
      version: 0,
      versionStringForDialog: "—",
      pathArray: entry.pathArray + [inFontFullPath]
    )
    ioFontDict [fontName] = newEntry
  }else{
    let partStatus : PartStatus
    switch metadata.metadataStatus {
    case .unknown :
      partStatus = .pmPartHasUnknownStatus
    case .ok :
      partStatus = partNameIsValid (fontName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .warning :
      partStatus = .pmPartHasWarning
    case .error :
      partStatus = .pmPartHasError
    }
    let newEntry = PMFontDictionaryEntry (
      partStatus: partStatus,
      version: version,
      versionStringForDialog: "\(version)",
      pathArray: [inFontFullPath]
    )
    ioFontDict [fontName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func performFontLibraryEnumeration (atPath inFontLibraryPath : String,
                                                fontDict ioFontDict : inout [String : PMFontDictionaryEntry]) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inFontLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariFont_EXTENSION {
        let fullsubpath = inFontLibraryPath.appendingPathComponent (path)
        try checkFontLibraryCheck (atPath: fullsubpath, fontDict: &ioFontDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func checkFontLibrary (_ inLogView : AutoLayoutStaticTextView,
                                              errorCount ioErrorCount : inout Int) throws {
  var fontDict : [String : PMFontDictionaryEntry] = [:]
  inLogView.appendMessageString ("\nChecking font library...\n")
  for path in existingLibraryPathArray () {
    let fontLibraryPath = fontLibraryPathForPath (path)
    inLogView.appendMessageString ("  Directory \(fontLibraryPath)...\n")
    try performFontLibraryEnumeration (atPath: fontLibraryPath, fontDict: &fontDict)
  }
//--- Display duplicate font count
  let foundFonts = fontDict.count
  if foundFonts <= 1 {
    inLogView.appendSuccessString ("  Found \(foundFonts) part\n")
  }else{
    inLogView.appendSuccessString ("  Found \(foundFonts) parts\n")
  }
//--- Display duplicate entries for font, invalid entries
  for (fontName, entry) in fontDict {
    switch entry.partStatus {
    case .pmPartIsDuplicated :
    if entry.pathArray.count > 1 {
      var errorString = "  Error; several files for '\(fontName)' font:\n"
      for path in entry.pathArray {
        errorString += "    - \(path)\n"
      }
      inLogView.appendErrorString (errorString)
      ioErrorCount += 1
    }
    case .pmPartHasUnknownStatus :
      inLogView.appendErrorString ("  Error; '\(fontName)' font has unknown status\n")
      ioErrorCount += 1
    case .pmPartHasInvalidName :
      inLogView.appendErrorString ("  Error; '\(fontName)' font has an invalid name\n")
      ioErrorCount += 1
    case .pmPartHasError :
      inLogView.appendErrorString ("  Error; '\(fontName)' font contains error(s)\n")
      ioErrorCount += 1
    case .pmPartHasWarning :
      inLogView.appendErrorString ("  Error; '\(fontName)' font contains warning(s)\n")
      ioErrorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   ARTWORK
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate struct PMArtworkDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func checkArtworkLibraryCheck (atPath inArtworkFullPath : String,
                                           artworkDict ioArtworkDict : inout [String : PMArtworkDictionaryEntry]) throws {
  let packageName = ((inArtworkFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  let metadata = try getFileMetadata (atPath: inArtworkFullPath)
  // NSLog ("\(metadataDictionary)")
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMArtworkVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (inArtworkFullPath, code:#line)
  }
  let possibleEntry : PMArtworkDictionaryEntry? = ioArtworkDict [packageName]
  if let entry = possibleEntry {
    let newEntry = PMArtworkDictionaryEntry (
      partStatus: .pmPartIsDuplicated,
      version:0,
      versionStringForDialog: "—",
      pathArray: entry.pathArray + [inArtworkFullPath]
    )
    ioArtworkDict [packageName] = newEntry
  }else{
    let partStatus : PartStatus = partNameIsValid (packageName) ? .pmPartIsValid : .pmPartHasInvalidName
    let newEntry = PMArtworkDictionaryEntry (
      partStatus: partStatus,
      version: version,
      versionStringForDialog: String (version),
      pathArray: [inArtworkFullPath]
    )
    ioArtworkDict [packageName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate func performArtworkLibraryEnumeration (atPath inPackageLibraryPath : String,
                                                   artworkDict ioArtworkDict : inout [String : PMArtworkDictionaryEntry]) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariArtwork_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        try checkArtworkLibraryCheck (atPath: fullsubpath, artworkDict: &ioArtworkDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor fileprivate func checkArtworkLibrary (_ inLogView : AutoLayoutStaticTextView,
                                                 errorCount ioErrorCount : inout Int) throws {
  var artworkDict : [String : PMArtworkDictionaryEntry] = [:]
  inLogView.appendMessageString ("\nChecking artworks library...\n")
  for path in existingLibraryPathArray () {
    let artworkLibraryPath = artworkLibraryPathForPath (path)
    inLogView.appendMessageString ("  Directory \(artworkLibraryPath)...\n")
    try performArtworkLibraryEnumeration (atPath: artworkLibraryPath, artworkDict: &artworkDict)
  }
//--- Display duplicate package count
  let foundPackages = artworkDict.count
  if foundPackages <= 1 {
    inLogView.appendSuccessString ("  Found \(foundPackages) part\n")
  }else{
    inLogView.appendSuccessString ("  Found \(foundPackages) parts\n")
  }
//--- Display duplicate entries for symbols, invalid entries
  for (artworkName, entry) in artworkDict {
    switch entry.partStatus {
    case .pmPartIsDuplicated :
    if entry.pathArray.count > 1 {
      var errorString = "  Error; several files for '\(artworkName)' artwork:\n"
      for path in entry.pathArray {
        errorString += "    - \(path)\n"
      }
      inLogView.appendErrorString (errorString)
      ioErrorCount += 1
    }
    case .pmPartHasUnknownStatus :
      inLogView.appendErrorString ("  Error; '\(artworkName)' artwork has unknown status\n")
      ioErrorCount += 1
    case .pmPartHasInvalidName :
      inLogView.appendErrorString ("  Error; '\(artworkName)' artwork has an invalid name\n")
      ioErrorCount += 1
    case .pmPartHasError :
      inLogView.appendErrorString ("  Error; '\(artworkName)' artwork contains error(s)\n")
      ioErrorCount += 1
    case .pmPartHasWarning :
      inLogView.appendErrorString ("  Error; '\(artworkName)' artwork contains warning(s)\n")
      ioErrorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
