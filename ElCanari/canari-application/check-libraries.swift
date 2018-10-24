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

func checkLibrary (_ window : NSWindow,
                   logView : NSTextView?) {
//--- Clear Log
  logView?.clear ()
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
    logView?.appendMessageString ("\n")
    if errorCount == 0 {
      logView?.appendSuccessString ("No error")
    }else if errorCount == 1 {
      logView?.appendErrorString ("1 error")
    }else{
      logView?.appendErrorString (String (errorCount) + " errors")
    }
    logView?.appendMessageString ("; ")
    if warningCount == 0 {
      logView?.appendSuccessString ("No warning")
    }else if (warningCount == 1) {
      logView?.appendWarningString ("1 warning")
    }else{
      logView?.appendWarningString (String (warningCount) + " warnings")
    }
    logView?.appendMessageString (".")
    if (errorCount + warningCount) > 0 {
      let alert = NSAlert ()
      alert.messageText = "There are inconsistencies in the librairies"
      alert.addButton (withTitle: "Ok")
      alert.addButton (withTitle: "Show Log Window")
      alert.informativeText = "Select the 'Show Log Window' button for details."
      alert.beginSheetModal (for: window, completionHandler: {(inReturnCode : NSApplication.ModalResponse) in
        if (NSApplication.ModalResponse.alertSecondButtonReturn == inReturnCode) {
          logView?.window?.makeKeyAndOrderFront (nil)
        }
      })
    }else{
      presentAlertWithLocalizedMessage ("Librairies are consistent.", window:window)
    }
  }catch let error {
    window.presentError (error)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func presentAlertWithLocalizedMessage (_ inLocalizedMessage : String, window:NSWindow) {
  let alert = NSAlert ()
  alert.messageText = inLocalizedMessage
  alert.beginSheetModal (for: window, completionHandler: {(NSModalResponse) in })
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


private func checkDeviceLibraryCheckAtPath (_ deviceFullPath : String,
                                            logView : NSTextView?,
                                            deviceDict:inout [String : PMDeviceDictionaryEntry]) throws {
  let deviceName = ((deviceFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
//--- Get metadata dictionary
  var metadataStatus = StatusInMetadata.metadataStatusUnknown
  let metadataDictionary : NSDictionary = try metadataForFileAtPath (deviceFullPath, status: &metadataStatus)
//--- Version number
  let possibleVersionNumber : Any? = metadataDictionary.object (forKey: PMDeviceVersion)
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (deviceFullPath, code:#line)
  }
//--- Embedded symbol dictionary
  let possibleSymbolDictionary : Any? = metadataDictionary.object (forKey: PMDeviceSymbols)
  var symbolDictionary : [String : Int] = [:]
  if let d = possibleSymbolDictionary as? [String : Int] {
    for (importedSymbolName, symbolDescription) in d {
      symbolDictionary [importedSymbolName] = symbolDescription
    }
  }else{
    throw badFormatErrorForFileAtPath (deviceFullPath, code:#line)
  }
//--- Embedded package dictionary
  let possiblePackageDictionary : Any? = metadataDictionary.object (forKey: PMDevicePackages)
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
    switch metadataStatus {
    case .metadataStatusUnknown :
      partStatus = .pmPartHasUnknownStatus
    case .metadataStatusSuccess :
      partStatus = partNameIsValid (deviceName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .metadataStatusWarning :
      partStatus = .pmPartHasWarning
    case .metadataStatusError   :
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


private func performDeviceLibraryEnumerationAtPath (_ inPackageLibraryPath : String,
                                                    deviceDict: inout [String : PMDeviceDictionaryEntry],
                                                    logView : NSTextView?) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if (path as NSString).pathExtension == "ElCanariDevice" {
        let fullsubpath = (inPackageLibraryPath as NSString).appendingPathComponent (path)
        try checkDeviceLibraryCheckAtPath (fullsubpath, logView:logView, deviceDict:&deviceDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkDeviceLibrary (_ logView : NSTextView?,
                                 symbolDict : [String : PMSymbolDictionaryEntry],
                                 packageDict : [String : PMPackageDictionaryEntry],
                                 deviceToUpdateSet : inout Set <String>,
                                 errorCount : inout Int,
                                 warningCount : inout Int) throws {
  var deviceDict : [String : PMDeviceDictionaryEntry] = [:]
  logView?.appendMessageString ("\nChecking devices library...\n")
  for path in existingLibraryPathArray () {
    let deviceLibraryPath = deviceLibraryPathForPath (path)
    logView?.appendMessageString (String (format:"  Handling path %@...\n", deviceLibraryPath))
    try performDeviceLibraryEnumerationAtPath (deviceLibraryPath, deviceDict:&deviceDict, logView:logView)
  }
//--- Display duplicate device count
  let foundDevices = deviceDict.count
  if foundDevices <= 1 {
    logView?.appendSuccessString (String (format:"  Found %lu part\n", foundDevices))
  }else{
    logView?.appendSuccessString (String (format:"  Found %lu parts\n", foundDevices))
  }
//--- Display duplicate entries and invalid entries
  for (deviceName, entry) in deviceDict {
  //--- Check device status
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = String (format:"  Error; several files for '%@' device:\n", deviceName)
      for path in entry.mPathArray {
        errorString += String (format:"    - %@\n", path)
      }
      logView?.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView?.appendErrorString (String (format:"  Error; '%@' device has unknown status\n", deviceName))
      errorCount += 1
    case .pmPartHasInvalidName :
      logView?.appendErrorString (String (format:"  Error; '%@' device has an invalid name\n", deviceName))
      errorCount += 1
    case .pmPartHasError :
      logView?.appendErrorString (String (format:"  Error; '%@' device contains error(s)\n", deviceName))
      errorCount += 1
    case .pmPartHasWarning :
      logView?.appendErrorString (String (format:"  Error; '%@' device contains warning(s)\n", deviceName))
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
          logView?.appendErrorString (message)
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
          logView?.appendErrorString (message)
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
          logView?.appendErrorString (message)
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
          logView?.appendErrorString (message)
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
                                            logView : NSTextView?,
                                            symbolDict:inout [String : PMSymbolDictionaryEntry]) throws {
  let symbolName = ((symbolFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  var metadataStatus = StatusInMetadata.metadataStatusUnknown
  // print ("symbolFullPath \(symbolFullPath)")
  let metadataDictionary : NSDictionary = try metadataForFileAtPath (symbolFullPath, status: &metadataStatus)
  let possibleVersionNumber : Any? = metadataDictionary.object (forKey: PMSymbolVersion)
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
    var partStatus : PartStatus
    switch metadataStatus {
    case .metadataStatusUnknown :
      partStatus = .pmPartHasUnknownStatus
    case .metadataStatusSuccess :
      partStatus = partNameIsValid (symbolName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .metadataStatusWarning :
      partStatus = .pmPartHasWarning
    case .metadataStatusError   :
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
                                                    logView : NSTextView?) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inSymbolLibraryPath) {
  //  print ("unwSubpaths \(unwSubpaths)")
    for path in unwSubpaths {
      if (path as NSString).pathExtension == "ElCanariSymbol" {
        let fullsubpath = (inSymbolLibraryPath as NSString).appendingPathComponent (path)
        try checkSymbolLibraryCheckAtPath (fullsubpath, logView:logView, symbolDict:&symbolDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkSymbolLibrary (_ logView : NSTextView?,
                                 symbolDict : inout [String : PMSymbolDictionaryEntry],
                                 errorCount : inout Int,
                                 warningCount : inout Int) throws {
  logView?.appendMessageString ("Checking symbols library...\n")
  for path in existingLibraryPathArray () {
    let symbolLibraryPath = symbolLibraryPathForPath (path)
    logView?.appendMessageString (String (format:"  Handling path %@...\n", symbolLibraryPath))
    try performSymbolLibraryEnumerationAtPath (symbolLibraryPath, symbolDict:&symbolDict, logView:logView)
  }
//--- Display duplicate symbol count
  let foundSymbols = symbolDict.count
  if foundSymbols <= 1 {
    logView?.appendSuccessString (String (format:"  Found %lu part\n", foundSymbols))
  }else{
    logView?.appendSuccessString (String (format:"  Found %lu parts\n", foundSymbols))
  }
//--- Display duplicate entries for symbols, invalid entries
  for (symbolName, entry) in symbolDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = String (format:"  Error; several files for '%@' symbol:\n", symbolName)
      for path in entry.mPathArray {
        errorString += String (format:"    - %@\n", path)
      }
      logView?.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView?.appendErrorString (String (format:"  Error; '%@' symbol has unknown status\n", symbolName))
      errorCount += 1
    case .pmPartHasInvalidName :
      logView?.appendErrorString (String (format:"  Error; '%@' symbol has an invalid name\n", symbolName))
      errorCount += 1
    case .pmPartHasError :
      logView?.appendErrorString (String (format:"  Error; '%@' symbol contains error(s)\n", symbolName))
      errorCount += 1
    case .pmPartHasWarning :
      logView?.appendErrorString (String (format:"  Error; '%@' symbol contains warning(s)\n", symbolName))
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
                                             logView : NSTextView?,
                                             packageDict:inout [String : PMPackageDictionaryEntry]) throws {
  let packageName = ((packageFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  var metadataStatus = StatusInMetadata.metadataStatusUnknown
  let metadataDictionary : NSDictionary = try metadataForFileAtPath (packageFullPath, status: &metadataStatus)
  let possibleVersionNumber : Any? = metadataDictionary.object (forKey: PMPackageVersion)
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
    switch metadataStatus {
    case .metadataStatusUnknown :
      partStatus = .pmPartHasUnknownStatus
    case .metadataStatusSuccess :
      partStatus = partNameIsValid (packageName) ? .pmPartIsValid : .pmPartHasInvalidName
    case .metadataStatusWarning :
      partStatus = .pmPartHasWarning
    case .metadataStatusError   :
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
                                                    logView : NSTextView?) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if (path as NSString).pathExtension == "ElCanariPackage" {
        let fullsubpath = (inPackageLibraryPath as NSString).appendingPathComponent (path)
        try checkPackageLibraryCheckAtPath (fullsubpath, logView:logView, packageDict:&packageDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkPackageLibrary (_ logView : NSTextView?,
                                  packageDict : inout [String : PMPackageDictionaryEntry],
                                  errorCount : inout Int,
                                  warningCount : inout Int) throws {
  logView?.appendMessageString ("\nChecking fonts library...\n")
  for path in existingLibraryPathArray () {
    let packageLibraryPath = packageLibraryPathForPath (path)
    logView?.appendMessageString (String (format:"  Handling path %@...\n", packageLibraryPath))
    try performPackageLibraryEnumerationAtPath (packageLibraryPath, packageDict:&packageDict, logView:logView)
  }
//--- Display duplicate package count
  let foundPackages = packageDict.count
  if foundPackages <= 1 {
    logView?.appendSuccessString (String (format:"  Found %lu part\n", foundPackages))
  }else{
    logView?.appendSuccessString (String (format:"  Found %lu parts\n", foundPackages))
  }
//--- Display duplicate entries for symbols, invalid entries
  for (packageName, entry) in packageDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = String (format:"  Error; several files for '%@' package:\n", packageName)
      for path in entry.mPathArray {
        errorString += String (format:"    - %@\n", path)
      }
      logView?.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView?.appendErrorString (String (format:"  Error; '%@' package has unknown status\n", packageName))
      errorCount += 1
    case .pmPartHasInvalidName :
      logView?.appendErrorString (String (format:"  Error; '%@' package has an invalid name\n", packageName))
      errorCount += 1
    case .pmPartHasError :
      logView?.appendErrorString (String (format:"  Error; '%@' package contains error(s)\n", packageName))
      errorCount += 1
    case .pmPartHasWarning :
      logView?.appendErrorString (String (format:"  Error; '%@' package contains warning(s)\n", packageName))
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
        versionStringForDialog:String,
        pathArray: [String]) {
    mPartStatus = status
    mVersion = version
    mVersionStringForDialog = versionStringForDialog
    mPathArray = pathArray
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func checkFontLibraryCheckAtPath (_ fontFullPath : String,
                                          logView : NSTextView?,
                                          fontDict:inout [String : PMFontDictionaryEntry]) throws {
  let fontName = ((fontFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  var unusedMetadataStatus = StatusInMetadata.metadataStatusUnknown
  let metadataDictionary : NSDictionary = try metadataForFileAtPath (fontFullPath, status: &unusedMetadataStatus)
  let possibleVersionNumber : Any? = metadataDictionary.object (forKey: PMFontVersion)
  let version : Int
  if let n = possibleVersionNumber as? NSNumber {
    version = n.intValue
  }else{
    throw badFormatErrorForFileAtPath (fontFullPath, code:#line)
  }
  let possibleEntry : PMFontDictionaryEntry? = fontDict [fontName]
  if let entry = possibleEntry {
    let newEntry = PMFontDictionaryEntry (status:.pmPartIsDuplicated,
                                          version:0,
                                          versionStringForDialog:"—",
                                          pathArray:entry.mPathArray + [fontFullPath])
    fontDict [fontName] = newEntry
  }else{
    let partStatus : PartStatus = partNameIsValid (fontName) ? .pmPartIsValid : .pmPartHasInvalidName
    let newEntry = PMFontDictionaryEntry (status:partStatus,
                                          version:version,
                                          versionStringForDialog:String (version),
                                          pathArray:[fontFullPath])
    fontDict [fontName] = newEntry
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func performFontLibraryEnumerationAtPath (_ inFontLibraryPath : String,
                                                  fontDict: inout [String : PMFontDictionaryEntry],
                                                  logView : NSTextView?) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inFontLibraryPath) {
    for path in unwSubpaths {
      if (path as NSString).pathExtension == "ElCanariFont" {
        let fullsubpath = (inFontLibraryPath as NSString).appendingPathComponent (path)
        try checkFontLibraryCheckAtPath (fullsubpath, logView:logView, fontDict:&fontDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkFontLibrary (_ logView : NSTextView?,
                               errorCount : inout Int,
                               warningCount : inout Int) throws {
  var fontDict : [String : PMFontDictionaryEntry] = [:]
  logView?.appendMessageString ("\nChecking font library...\n")
  for path in existingLibraryPathArray () {
    let fontLibraryPath = fontLibraryPathForPath (path)
    logView?.appendMessageString (String (format:"  Handling path %@...\n", fontLibraryPath))
    try performFontLibraryEnumerationAtPath (fontLibraryPath, fontDict:&fontDict, logView:logView)
  }
//--- Display duplicate font count
  let foundFonts = fontDict.count
  if foundFonts <= 1 {
    logView?.appendSuccessString (String (format:"  Found %lu part\n", foundFonts))
  }else{
    logView?.appendSuccessString (String (format:"  Found %lu parts\n", foundFonts))
  }
//--- Display duplicate entries for symbols, invalid entries
  for (fontName, entry) in fontDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = String (format:"  Error; several files for '%@' font:\n", fontName)
      for path in entry.mPathArray {
        errorString += String (format:"    - %@\n", path)
      }
      logView?.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView?.appendErrorString (String (format:"  Error; '%@' font has unknown status\n", fontName))
      errorCount += 1
    case .pmPartHasInvalidName :
      logView?.appendErrorString (String (format:"  Error; '%@' font has an invalid name\n", fontName))
      errorCount += 1
    case .pmPartHasError :
      logView?.appendErrorString (String (format:"  Error; '%@' font contains error(s)\n", fontName))
      errorCount += 1
    case .pmPartHasWarning :
      logView?.appendErrorString (String (format:"  Error; '%@' font contains warning(s)\n", fontName))
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
                                             logView : NSTextView?,
                                             artworkDict:inout [String : PMArtworkDictionaryEntry]) throws {
  let packageName = ((artworkFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  var unusedMetadataStatus = StatusInMetadata.metadataStatusUnknown
  let metadataDictionary : NSDictionary = try metadataForFileAtPath (artworkFullPath, status: &unusedMetadataStatus)
  // NSLog ("\(metadataDictionary)")
  let possibleVersionNumber : Any? = metadataDictionary.object (forKey: PMArtworkVersion)
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
                                                    logView : NSTextView?) throws {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if (path as NSString).pathExtension == "ElCanariArtwork" {
        let fullsubpath = (inPackageLibraryPath as NSString).appendingPathComponent (path)
        try checkArtworkLibraryCheckAtPath (fullsubpath, logView:logView, artworkDict:&artworkDict)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


private func checkArtworkLibrary (_ logView : NSTextView?,
                                  errorCount : inout Int,
                                  warningCount : inout Int) throws {
  var artworkDict : [String : PMArtworkDictionaryEntry] = [:]
  logView?.appendMessageString ("\nChecking artworks library...\n")
  for path in existingLibraryPathArray () {
    let artworkLibraryPath = artworkLibraryPathForPath (path)
    logView?.appendMessageString (String (format:"  Handling path %@...\n", artworkLibraryPath))
    try performArtworkLibraryEnumerationAtPath (artworkLibraryPath, artworkDict:&artworkDict, logView:logView)
  }
//--- Display duplicate package count
  let foundPackages = artworkDict.count
  if foundPackages <= 1 {
    logView?.appendSuccessString (String (format:"  Found %lu part\n", foundPackages))
  }else{
    logView?.appendSuccessString (String (format:"  Found %lu parts\n", foundPackages))
  }
//--- Display duplicate entries for symbols, invalid entries
  for (artworkName, entry) in artworkDict {
    switch entry.mPartStatus {
    case .pmPartIsDuplicated :
    if entry.mPathArray.count > 1 {
      var errorString = String (format:"  Error; several files for '%@' artwork:\n", artworkName)
      for path in entry.mPathArray {
        errorString += String (format:"    - %@\n", path)
      }
      logView?.appendErrorString (errorString)
      errorCount += 1
    }
    case .pmPartHasUnknownStatus :
      logView?.appendErrorString (String (format:"  Error; '%@' artwork has unknown status\n", artworkName))
      errorCount += 1
    case .pmPartHasInvalidName :
      logView?.appendErrorString (String (format:"  Error; '%@' artwork has an invalid name\n", artworkName))
      errorCount += 1
    case .pmPartHasError :
      logView?.appendErrorString (String (format:"  Error; '%@' artwork contains error(s)\n", artworkName))
      errorCount += 1
    case .pmPartHasWarning :
      logView?.appendErrorString (String (format:"  Error; '%@' artwork contains warning(s)\n", artworkName))
      errorCount += 1
    case .pmPartIsValid :
      break
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

