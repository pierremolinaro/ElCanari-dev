//
//  check-libraries.swift
//  canari
//
//  Created by Pierre Molinaro on 30/06/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor func checkLibrary (_ window : NSWindow,
                              logView : AutoLayoutStaticTextView) {
//--- Clear Log
  logView.clear ()
  var errorCount = 0
  var warningCount = 0
  do{
  //--- Checking Symbols
    var symbolDict : [String : PMSymbolDictionaryEntry] = [:]
    try checkSymbolLibrary (logView, symbolDict:&symbolDict, errorCount:&errorCount, warningCount:&warningCount)
  //--- Checking Packages
    var packageDict : [String : PMPackageDictionaryEntry] = [:]
    try checkPackageLibrary (logView, packageDict:&packageDict, errorCount:&errorCount, warningCount:&warningCount)
  //--- Checking Devices
    var deviceToUpdateSet = Set <String> ()
    try checkDeviceLibrary (
      logView,
      symbolDict:symbolDict,
      packageDict:packageDict,
      deviceToUpdateSet:&deviceToUpdateSet,
      errorCount:&errorCount,
      warningCount:&warningCount
    )
    let ws = NSWorkspace.shared
    for path in deviceToUpdateSet {
      ws.open (URL (fileURLWithPath: path))
    }
  //--- Checking Font
    try checkFontLibrary (logView, errorCount:&errorCount, warningCount:&warningCount)
  //--- Checking Artworks
    try checkArtworkLibrary (logView, errorCount:&errorCount, warningCount:&warningCount)
  //--- Summary
    logView.appendMessageString ("\n")
    if errorCount == 0 {
      logView.appendSuccessString ("No error")
    }else if errorCount == 1 {
      logView.appendErrorString ("1 error")
    }else{
      logView.appendErrorString (String (errorCount) + " errors")
    }
    logView.appendMessageString ("; ")
    if warningCount == 0 {
      logView.appendSuccessString ("No warning")
    }else if (warningCount == 1) {
      logView.appendWarningString ("1 warning")
    }else{
      logView.appendWarningString (String (warningCount) + " warnings")
    }
    logView.appendMessageString (".")
    if (errorCount + warningCount) > 0 {
      let alert = NSAlert ()
      alert.messageText = "There are inconsistencies in the librairies"
      _ = alert.addButton (withTitle: "Ok")
      _ = alert.addButton (withTitle: "Show Log Window")
      alert.informativeText = "Select the 'Show Log Window' button for details."
      alert.beginSheetModal (for: window) { inReturnCode in
        if inReturnCode == .alertSecondButtonReturn {
          logView.window?.makeKeyAndOrderFront (nil)
        }
      }
    }else{
      presentAlertWithLocalizedMessage ("Librairies are consistent.", window:window)
    }
  }catch let error {
    _ = window.presentError (error)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func presentAlertWithLocalizedMessage (_ inLocalizedMessage : String, window : NSWindow) {
  let alert = NSAlert ()
  alert.messageText = inLocalizedMessage
  alert.beginSheetModal (for: window) { (NSModalResponse) in }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private enum PartStatus {
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

private struct PMDeviceDictionaryEntry {
  let mPartStatus : PartStatus
  let mVersion : Int
  let mVersionStringForDialog : String
  let mPathArray : [String]
  let mSymbolDictionary : [String : Int]
  let mPackageDictionary : [String : Int]
  
  init (status : PartStatus,
        version : Int,
        versionStringForDialog:String,
        pathArray: [String],
        symbolDictionary : [String : Int],
        packageDictionary : [String : Int]) {
    mPartStatus = status
    mVersion = version
    mVersionStringForDialog = versionStringForDialog
    mPathArray = pathArray
    mSymbolDictionary = symbolDictionary
    mPackageDictionary = packageDictionary
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor private func checkDeviceLibraryCheckAtPath (_ deviceFullPath : String,
                                                       logView : AutoLayoutStaticTextView,
                                                       deviceDict:inout [String : PMDeviceDictionaryEntry]) throws {
  let deviceName = ((deviceFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
//--- Get metadata dictionary
  let metadata = try getFileMetadata (atPath: deviceFullPath)
//--- Version number
  let possibleVersionNumber : Any? = metadata.metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (deviceFullPath, code: #line)
  }
//--- Embedded symbol dictionary
  let possibleSymbolDictionary : Any? = metadata.metadataDictionary [DEVICE_SYMBOL_METADATA_DICTIONARY_KEY]
  var symbolDictionary : [String : Int] = [:]
  if let d = possibleSymbolDictionary as? [String : Int] {
    for (importedSymbolName, symbolDescription) in d {
      symbolDictionary [importedSymbolName] = symbolDescription
    }
  }else{
    throw badFormatErrorForFileAtPath (deviceFullPath, code:#line)
  }
//--- Embedded package dictionary
  let possiblePackageDictionary : Any? = metadata.metadataDictionary [DEVICE_PACKAGE_METADATA_DICTIONARY_KEY]
  var packageDictionary : [String : Int] = [:]
  if let d = possiblePackageDictionary as? [String : Int] {
    for (importedPackageName, packageDescription) in d {
      packageDictionary [importedPackageName] = packageDescription
    }
  }else{
    throw badFormatErrorForFileAtPath (deviceFullPath, code:#line)
  }
//---
  let possibleEntry : PMDeviceDictionaryEntry? = deviceDict [deviceName]
  if let entry = possibleEntry {
  
    let newEntry = PMDeviceDictionaryEntry (
      status:.pmPartIsDuplicated,
      version:0,
      versionStringForDialog:"—",
      pathArray:entry.mPathArray + [deviceFullPath],
      symbolDictionary : symbolDictionary,
      packageDictionary : packageDictionary
    )
    deviceDict [deviceName] = newEntry
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
      status:partStatus,
      version:version,
      versionStringForDialog:String (version),
      pathArray:[deviceFullPath],
      symbolDictionary : symbolDictionary,
      packageDictionary : packageDictionary
    )
    deviceDict [deviceName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


@MainActor private func performDeviceLibraryEnumerationAtPath (_ inPackageLibraryPath : String,
                                                               deviceDict: inout [String : PMDeviceDictionaryEntry],
                                                               logView : AutoLayoutStaticTextView) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased() == ElCanariDevice_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        try checkDeviceLibraryCheckAtPath (fullsubpath, logView: logView, deviceDict:&deviceDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


@MainActor private func checkDeviceLibrary (_ logView : AutoLayoutStaticTextView,
                                            symbolDict : [String : PMSymbolDictionaryEntry],
                                            packageDict : [String : PMPackageDictionaryEntry],
                                            deviceToUpdateSet : inout Set <String>,
                                            errorCount : inout Int,
                                            warningCount : inout Int) throws {
  var deviceDict : [String : PMDeviceDictionaryEntry] = [:]
  logView.appendMessageString ("\nChecking devices library...\n")
  for path in existingLibraryPathArray () {
    let deviceLibraryPath = deviceLibraryPathForPath (path)
    logView.appendMessageString ("  Directory \(deviceLibraryPath)...\n")
    try performDeviceLibraryEnumerationAtPath (deviceLibraryPath, deviceDict: &deviceDict, logView: logView)
  }
//--- Display duplicate device count
  let foundDevices = deviceDict.count
  if foundDevices <= 1 {
    logView.appendSuccessString ("  Found \(foundDevices) part\n")
  }else{
    logView.appendSuccessString ("  Found \(foundDevices) parts\n")
  }
//--- Display duplicate entries and invalid entries
  for (deviceName, entry) in deviceDict {
  //--- Check device status
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = "  Error; several files for '\(deviceName)' device:\n"
      for path in entry.mPathArray {
        errorString += "    - \(path)\n"
      }
      logView.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView.appendErrorString ("  Error; '\(deviceName)' device has unknown status\n")
      errorCount += 1
    case .pmPartHasInvalidName :
      logView.appendErrorString ("  Error; '\(deviceName)' device has an invalid name\n")
      errorCount += 1
    case .pmPartHasError :
      logView.appendErrorString ("  Error; '\(deviceName)' device contains error(s)\n")
      errorCount += 1
    case .pmPartHasWarning :
      logView.appendErrorString ("  Error; '\(deviceName)' device contains warning(s)\n")
      errorCount += 1
    case .pmPartIsValid :
    //--- Check imported symbols
      for (importedSymbolName, importedSymbolVersion) in entry.mSymbolDictionary {
        if symbolDict [importedSymbolName] == nil {
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedSymbolName
          message += "' symbol, but this symbol is not defined by the library\n"
          logView.appendErrorString (message)
          errorCount += 1
        }else if symbolDict [importedSymbolName]!.mVersion != importedSymbolVersion {
          deviceToUpdateSet.insert (entry.mPathArray[0])
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedSymbolName
          message += "' symbol with version "
          message += String (importedSymbolVersion)
          message += ", but this symbol has version "
          message += String (symbolDict [importedSymbolName]!.mVersion)
          message += " in library\n"
          logView.appendErrorString (message)
          errorCount += 1
        }
      }
    //--- Check imported package
      for (importedPackageName, importedPackageVersion) in entry.mPackageDictionary {
        if packageDict [importedPackageName] == nil {
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedPackageName
          message += "' package, but this package is not defined by the library\n"
          logView.appendErrorString (message)
          errorCount += 1
        }else if packageDict [importedPackageName]!.mVersion != importedPackageVersion {
          deviceToUpdateSet.insert (entry.mPathArray[0])
          var message = "  Error; '"
          message += deviceName
          message += "' device contains the '"
          message += importedPackageName
          message += "' package with version "
          message += String (importedPackageVersion)
          message += ", but this package has version "
          message += String (packageDict [importedPackageName]!.mVersion)
          message += " in library\n"
          logView.appendErrorString (message)
          errorCount += 1
        }
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   SYMBOL
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private struct PMSymbolDictionaryEntry {
  let mPartStatus : PartStatus
  let mVersion : Int
  let mVersionStringForDialog : String
  let mPathArray : [String]
  
  init (status : PartStatus,
        version : Int,
        versionStringForDialog:String,
        pathArray: [String]) {
    mPartStatus = status
    mVersion = version
    mVersionStringForDialog = versionStringForDialog
    mPathArray = pathArray
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkSymbolLibraryCheckAtPath (_ symbolFullPath : String,
                                            logView : AutoLayoutStaticTextView,
                                            symbolDict:inout [String : PMSymbolDictionaryEntry]) throws {
  let symbolName = ((symbolFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  // print ("symbolFullPath \(symbolFullPath)")
  let metadata = try getFileMetadata (atPath: symbolFullPath)
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMSymbolVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (symbolFullPath, code:#line)
  }
  let possibleEntry : PMSymbolDictionaryEntry? = symbolDict [symbolName]
  if let entry = possibleEntry {
  
    let newEntry = PMSymbolDictionaryEntry (status:.pmPartIsDuplicated,
                                            version:0,
                                            versionStringForDialog:"—",
                                            pathArray:entry.mPathArray + [symbolFullPath])
    symbolDict [symbolName] = newEntry
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
    let newEntry = PMSymbolDictionaryEntry (status:partStatus,
                                            version:version,
                                            versionStringForDialog:String (version),
                                            pathArray:[symbolFullPath])
    symbolDict [symbolName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func performSymbolLibraryEnumerationAtPath (_ inSymbolLibraryPath : String,
                                                    symbolDict: inout [String : PMSymbolDictionaryEntry],
                                                    logView : AutoLayoutStaticTextView) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inSymbolLibraryPath) {
  //  print ("unwSubpaths \(unwSubpaths)")
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariSymbol_EXTENSION {
        let fullsubpath = inSymbolLibraryPath.appendingPathComponent (path)
        try checkSymbolLibraryCheckAtPath (fullsubpath, logView: logView, symbolDict: &symbolDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor private func checkSymbolLibrary (_ logView : AutoLayoutStaticTextView,
                                            symbolDict : inout [String : PMSymbolDictionaryEntry],
                                            errorCount : inout Int,
                                            warningCount : inout Int) throws {
  logView.appendMessageString ("Checking symbols library...\n")
  for path in existingLibraryPathArray () {
    let symbolLibraryPath = symbolLibraryPathForPath (path)
    logView.appendMessageString ("  Directory \(symbolLibraryPath)...\n")
    try performSymbolLibraryEnumerationAtPath (symbolLibraryPath, symbolDict: &symbolDict, logView: logView)
  }
//--- Display duplicate symbol count
  let foundSymbols = symbolDict.count
  if foundSymbols <= 1 {
    logView.appendSuccessString ("  Found \(foundSymbols) part\n")
  }else{
    logView.appendSuccessString ("  Found \(foundSymbols) parts\n")
  }
//--- Display duplicate entries for symbols, invalid entries
  for (symbolName, entry) in symbolDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = "  Error; several files for '\(symbolName)' symbol:\n"
      for path in entry.mPathArray {
        errorString += "    - \(path)\n"
      }
      logView.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView.appendErrorString ("  Error; '\(symbolName)' symbol has unknown status\n")
      errorCount += 1
    case .pmPartHasInvalidName :
      logView.appendErrorString ("  Error; '\(symbolName)' symbol has an invalid name\n")
      errorCount += 1
    case .pmPartHasError :
      logView.appendErrorString ("  Error; '\(symbolName)' symbol contains error(s)\n")
      errorCount += 1
    case .pmPartHasWarning :
      logView.appendErrorString ("  Error; '\(symbolName)' symbol contains warning(s)\n")
      errorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   PACKAGE
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private struct PMPackageDictionaryEntry {
  let mPartStatus : PartStatus
  let mVersion : Int
  let mVersionStringForDialog : String
  let mPathArray : [String]
  
  init (status : PartStatus,
        version : Int,
        versionStringForDialog:String,
        pathArray: [String]) {
    mPartStatus = status
    mVersion = version
    mVersionStringForDialog = versionStringForDialog
    mPathArray = pathArray
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkPackageLibraryCheckAtPath (_ packageFullPath : String,
                                             logView : AutoLayoutStaticTextView,
                                             packageDict: inout [String : PMPackageDictionaryEntry]) throws {
  let packageName = ((packageFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  let metadata = try getFileMetadata (atPath: packageFullPath)
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMPackageVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (packageFullPath, code:#line)
  }
  let possibleEntry : PMPackageDictionaryEntry? = packageDict [packageName]
  if let entry = possibleEntry {
  
    let newEntry = PMPackageDictionaryEntry (status:.pmPartIsDuplicated,
                                            version:0,
                                            versionStringForDialog:"—",
                                            pathArray:entry.mPathArray + [packageFullPath])
    packageDict [packageName] = newEntry
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
    let newEntry = PMPackageDictionaryEntry (status:partStatus,
                                            version:version,
                                            versionStringForDialog:String (version),
                                            pathArray:[packageFullPath])
    packageDict [packageName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func performPackageLibraryEnumerationAtPath (_ inPackageLibraryPath : String,
                                                    packageDict: inout [String : PMPackageDictionaryEntry],
                                                    logView : AutoLayoutStaticTextView) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased() == ElCanariPackage_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        try checkPackageLibraryCheckAtPath (fullsubpath, logView: logView, packageDict: &packageDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor private func checkPackageLibrary (_ logView : AutoLayoutStaticTextView,
                                             packageDict : inout [String : PMPackageDictionaryEntry],
                                             errorCount : inout Int,
                                             warningCount : inout Int) throws {
  logView.appendMessageString ("\nChecking packages library...\n")
  for path in existingLibraryPathArray () {
    let packageLibraryPath = packageLibraryPathForPath (path)
    logView.appendMessageString ("  Directory \(packageLibraryPath)...\n")
    try performPackageLibraryEnumerationAtPath (packageLibraryPath, packageDict: &packageDict, logView: logView)
  }
//--- Display duplicate package count
  let foundPackages = packageDict.count
  if foundPackages <= 1 {
    logView.appendSuccessString ("  Found \(foundPackages) part\n")
  }else{
    logView.appendSuccessString ("  Found \(foundPackages) parts\n")
  }
//--- Display duplicate entries for symbols, invalid entries
  for (packageName, entry) in packageDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = "  Error; several files for '\(packageName)' package:\n"
      for path in entry.mPathArray {
        errorString += "    - \(path)\n"
      }
      logView.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView.appendErrorString ("  Error; '\(packageName)' package has unknown status\n")
      errorCount += 1
    case .pmPartHasInvalidName :
      logView.appendErrorString ("  Error; '\(packageName)' package has an invalid name\n")
      errorCount += 1
    case .pmPartHasError :
      logView.appendErrorString ("  Error; '\(packageName)' package contains error(s)\n")
      errorCount += 1
    case .pmPartHasWarning :
      logView.appendErrorString ("  Error; '\(packageName)' package contains warning(s)\n")
      errorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   FONT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private struct PMFontDictionaryEntry {
  let mPartStatus : PartStatus
  let mVersion : Int
  let mVersionStringForDialog : String
  let mPathArray : [String]
  
  init (status : PartStatus,
        version : Int,
        versionStringForDialog : String,
        pathArray : [String]) {
    mPartStatus = status
    mVersion = version
    mVersionStringForDialog = versionStringForDialog
    mPathArray = pathArray
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func checkFontLibraryCheckAtPath (_ fontFullPath : String,
                                          logView : AutoLayoutStaticTextView,
                                          fontDict:inout [String : PMFontDictionaryEntry]) throws {
  let fontName = ((fontFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  let metadata = try getFileMetadata (atPath: fontFullPath)
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMFontVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (fontFullPath, code:#line)
  }
  let possibleEntry : PMFontDictionaryEntry? = fontDict [fontName]
  if let entry = possibleEntry {
    let newEntry = PMFontDictionaryEntry (
      status: .pmPartIsDuplicated,
      version: 0,
      versionStringForDialog: "—",
      pathArray: entry.mPathArray + [fontFullPath]
    )
    fontDict [fontName] = newEntry
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
      status: partStatus,
      version: version,
      versionStringForDialog: "\(version)",
      pathArray: [fontFullPath]
    )
    fontDict [fontName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performFontLibraryEnumerationAtPath (_ inFontLibraryPath : String,
                                                  fontDict: inout [String : PMFontDictionaryEntry],
                                                  logView : AutoLayoutStaticTextView) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inFontLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariFont_EXTENSION {
        let fullsubpath = inFontLibraryPath.appendingPathComponent (path)
        try checkFontLibraryCheckAtPath (fullsubpath, logView: logView, fontDict: &fontDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor private func checkFontLibrary (_ logView : AutoLayoutStaticTextView,
                                          errorCount : inout Int,
                                          warningCount : inout Int) throws {
  var fontDict : [String : PMFontDictionaryEntry] = [:]
  logView.appendMessageString ("\nChecking font library...\n")
  for path in existingLibraryPathArray () {
    let fontLibraryPath = fontLibraryPathForPath (path)
    logView.appendMessageString ("  Directory \(fontLibraryPath)...\n")
    try performFontLibraryEnumerationAtPath (fontLibraryPath, fontDict: &fontDict, logView: logView)
  }
//--- Display duplicate font count
  let foundFonts = fontDict.count
  if foundFonts <= 1 {
    logView.appendSuccessString ("  Found \(foundFonts) part\n")
  }else{
    logView.appendSuccessString ("  Found \(foundFonts) parts\n")
  }
//--- Display duplicate entries for font, invalid entries
  for (fontName, entry) in fontDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = "  Error; several files for '\(fontName)' font:\n"
      for path in entry.mPathArray {
        errorString += "    - \(path)\n"
      }
      logView.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView.appendErrorString ("  Error; '\(fontName)' font has unknown status\n")
      errorCount += 1
    case .pmPartHasInvalidName :
      logView.appendErrorString ("  Error; '\(fontName)' font has an invalid name\n")
      errorCount += 1
    case .pmPartHasError :
      logView.appendErrorString ("  Error; '\(fontName)' font contains error(s)\n")
      errorCount += 1
    case .pmPartHasWarning :
      logView.appendErrorString ("  Error; '\(fontName)' font contains warning(s)\n")
      errorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   ARTWORK
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private struct PMArtworkDictionaryEntry {
  let mPartStatus : PartStatus
  let mVersion : Int
  let mVersionStringForDialog : String
  let mPathArray : [String]
  
  init (status : PartStatus,
        version : Int,
        versionStringForDialog:String,
        pathArray: [String]) {
    mPartStatus = status
    mVersion = version
    mVersionStringForDialog = versionStringForDialog
    mPathArray = pathArray
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func checkArtworkLibraryCheckAtPath (_ artworkFullPath : String,
                                             logView : AutoLayoutStaticTextView,
                                             artworkDict: inout [String : PMArtworkDictionaryEntry]) throws {
  let packageName = ((artworkFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  let metadata = try getFileMetadata (atPath: artworkFullPath)
  // NSLog ("\(metadataDictionary)")
  let possibleVersionNumber : Any? = metadata.metadataDictionary [PMArtworkVersion]
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (artworkFullPath, code:#line)
  }
  let possibleEntry : PMArtworkDictionaryEntry? = artworkDict [packageName]
  if let entry = possibleEntry {
  
    let newEntry = PMArtworkDictionaryEntry (status:.pmPartIsDuplicated,
                                             version:0,
                                             versionStringForDialog:"—",
                                             pathArray:entry.mPathArray + [artworkFullPath])
    artworkDict [packageName] = newEntry
  }else{
    let partStatus : PartStatus = partNameIsValid (packageName) ? .pmPartIsValid : .pmPartHasInvalidName
    let newEntry = PMArtworkDictionaryEntry (status:partStatus,
                                             version:version,
                                             versionStringForDialog:String (version),
                                             pathArray:[artworkFullPath])
    artworkDict [packageName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func performArtworkLibraryEnumerationAtPath (_ inPackageLibraryPath : String,
                                                     artworkDict: inout [String : PMArtworkDictionaryEntry],
                                                     logView : AutoLayoutStaticTextView) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariArtwork_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        try checkArtworkLibraryCheckAtPath (fullsubpath, logView: logView, artworkDict: &artworkDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor private func checkArtworkLibrary (_ logView : AutoLayoutStaticTextView,
                                             errorCount : inout Int,
                                             warningCount : inout Int) throws {
  var artworkDict : [String : PMArtworkDictionaryEntry] = [:]
  logView.appendMessageString ("\nChecking artworks library...\n")
  for path in existingLibraryPathArray () {
    let artworkLibraryPath = artworkLibraryPathForPath (path)
    logView.appendMessageString ("  Directory \(artworkLibraryPath)...\n")
    try performArtworkLibraryEnumerationAtPath (artworkLibraryPath, artworkDict: &artworkDict, logView: logView)
  }
//--- Display duplicate package count
  let foundPackages = artworkDict.count
  if foundPackages <= 1 {
    logView.appendSuccessString ("  Found \(foundPackages) part\n")
  }else{
    logView.appendSuccessString ("  Found \(foundPackages) parts\n")
  }
//--- Display duplicate entries for symbols, invalid entries
  for (artworkName, entry) in artworkDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = "  Error; several files for '\(artworkName)' artwork:\n"
      for path in entry.mPathArray {
        errorString += "    - \(path)\n"
      }
      logView.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView.appendErrorString ("  Error; '\(artworkName)' artwork has unknown status\n")
      errorCount += 1
    case .pmPartHasInvalidName :
      logView.appendErrorString ("  Error; '\(artworkName)' artwork has an invalid name\n")
      errorCount += 1
    case .pmPartHasError :
      logView.appendErrorString ("  Error; '\(artworkName)' artwork contains error(s)\n")
      errorCount += 1
    case .pmPartHasWarning :
      logView.appendErrorString ("  Error; '\(artworkName)' artwork contains warning(s)\n")
      errorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

