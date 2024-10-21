//
//  check-libraries.swift
//  canari
//
//  Created by Pierre Molinaro on 30/06/2015.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func checkFileSystemLibrary () {
    let window : CanariWindow
    if let w = self.mLibraryConsistencyLogWindow {
      window = w
    }else{
      window = CanariWindow (
        contentRect: NSRect (x: 0, y: 0, width: 500, height: 400),
        styleMask: [.closable, .resizable, .titled],
        backing: .buffered,
        defer: false
      )
      _ = window.setFrameAutosaveName ("LibraryConsistencyLogWindowSettings")
      window.title = "Library Consistency"
      window.isReleasedWhenClosed = false
      self.mLibraryConsistencyLogWindow = window
    }
    var errorCount = 0
  //---------- Previous Tab View selection
    let previousSelectedTab = self.mLibraryConsistencyLogTabView?.indexOfSelectedItem ?? 0
  //---------- Comment
    let comment = AutoLayoutStaticLabel (
      title: "ElCanari observes file system, this window is automatically updated on changes",
      bold: false,
      size: .regular,
      alignment: .center
    )
  //---------- Tab View
    let tabView = AutoLayoutTabView (size: .regular)
      .expandableWidth ()
      .expandableHeight ()
    self.mLibraryConsistencyLogTabView = tabView
    window.setContentView (AutoLayoutVerticalStackView ().set (margins: .large).appendView (comment).appendView (tabView))
  //---------- Checking Symbols
    let symbolTabContents = AutoLayoutVerticalStackViewWithScrollBar ().set (margins: .large)
    var symbolDict : [String : PMSymbolDictionaryEntry] = [:]
    let symbolErrorCount = self.checkSymbolLibrary (symbolTabContents, symbolDict: &symbolDict)
    errorCount += symbolErrorCount
    var title : String
    if symbolDict.count == 0 {
      title = "No symbol"
    }else if symbolDict.count == 1 {
      title = "1 symbol"
    }else{
      title = "\(symbolDict.count) symbols"
    }
    if symbolErrorCount == 1 {
      title += " (1 error)"
    }else if symbolErrorCount > 1 {
      title += " (\(symbolErrorCount) errors)"
    }
    _ = tabView.addTab (
      title: title,
      image : (symbolErrorCount == 0) ? NSImage.statusSuccess : NSImage.statusError,
      tooltip: "",
      contentView: symbolTabContents.appendFlexibleSpace ()
    )
  //---------- Checking Packages
    let packageTabContents = AutoLayoutVerticalStackViewWithScrollBar ().set (margins: .large)
    var packageDict : [String : PMPackageDictionaryEntry] = [:]
    let packageErrorCount = checkPackageLibrary (packageTabContents, packageDict: &packageDict)
    errorCount += packageErrorCount
    if packageDict.count == 0 {
      title = "No package"
    }else if packageDict.count == 1 {
      title = "1 package"
    }else{
      title = "\(packageDict.count) packages"
    }
    if packageErrorCount == 1 {
      title += " (1 error)"
    }else if packageErrorCount > 1 {
      title += " (\(packageErrorCount) errors)"
    }
    _ = tabView.addTab (
      title: title,
      image : (packageErrorCount == 0) ? NSImage.statusSuccess : NSImage.statusError,
      tooltip: "",
      contentView: packageTabContents.appendFlexibleSpace ()
    )
  //---------- Checking Devices
    let deviceTabContents = AutoLayoutVerticalStackViewWithScrollBar ().set (margins: .large)
    let (deviceCount, deviceErrorCount) = self.checkDeviceLibrary (
      deviceTabContents,
      symbolDict: symbolDict,
      packageDict: packageDict
    )
    errorCount += deviceErrorCount
    if deviceCount == 0 {
      title = "No device"
    }else if deviceCount == 1 {
      title = "1 device"
    }else{
      title = "\(deviceCount) devices"
    }
    if deviceErrorCount == 1 {
      title += " (1 error)"
    }else if deviceErrorCount > 1 {
      title += " (\(deviceErrorCount) errors)"
    }
    _ = tabView.addTab (
      title: title,
      image : (deviceErrorCount == 0) ? NSImage.statusSuccess : NSImage.statusError,
      tooltip: "",
      contentView: deviceTabContents.appendFlexibleSpace ()
    )
  //--------- Checking Fonts
    let fontTabContents = AutoLayoutVerticalStackViewWithScrollBar ().set (margins: .large)
    let (fontCount, fontErrorCount) = checkFontLibrary (fontTabContents)
    errorCount += fontErrorCount
    if fontCount == 0 {
      title = "No font"
    }else if fontCount == 1 {
      title = "1 font"
    }else{
      title = "\(fontCount) fonts"
    }
    if fontErrorCount == 1 {
      title += " (1 error)"
    }else if deviceErrorCount > 1 {
      title += " (\(fontErrorCount) errors)"
    }
    _ = tabView.addTab (
      title: title,
      image : (fontErrorCount == 0) ? NSImage.statusSuccess : NSImage.statusError,
      tooltip: "",
      contentView: fontTabContents.appendFlexibleSpace ()
    )
  //--------- Checking Artworks
    let artworkTabContents = AutoLayoutVerticalStackViewWithScrollBar ().set (margins: .large)
    let (arworkCount, artworkErrorCount) = checkArtworkLibrary (artworkTabContents)
    errorCount += artworkErrorCount
    if arworkCount == 0 {
      title = "No artwork"
    }else if arworkCount == 1 {
      title = "1 artwork"
    }else{
      title = "\(arworkCount) artworks"
    }
    if artworkErrorCount == 1 {
      title += " (1 error)"
    }else if artworkErrorCount > 1 {
      title += " (\(artworkErrorCount) errors)"
    }
    _ = tabView.addTab (
      title: title,
      image : (artworkErrorCount == 0) ? NSImage.statusSuccess : NSImage.statusError,
      tooltip: "",
      contentView: artworkTabContents.appendFlexibleSpace ()
    )
  //---------
    tabView.selectTab (atIndex: previousSelectedTab)
    preferences_fileSystemLibraryIsOk_property.setProp (errorCount == 0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate extension AutoLayoutVerticalStackViewWithScrollBar {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendText (_ inString : String, bold inBold : Bool) {
    _ = self.appendView (AutoLayoutStaticLabel (title: inString, bold: inBold, size: .regular, alignment: .left).expandableWidth ())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendError (_ inString : String) {
    _ = self.appendView (AutoLayoutStaticLabel (title: inString, bold: true, size: .regular, alignment: .left).setRedTextColor ().expandableWidth())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInfo (_ inString : String) {
    _ = self.appendView (AutoLayoutStaticLabel (title: inString, bold: false, size: .regular, alignment: .left).setTextColor (.systemBlue).expandableWidth())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendOpenDocumentButton (_ inDocumentPath : String) {
    let button = AutoLayoutButton (title: inDocumentPath, size: .regular).expandableWidth ()
    let fm = FileManager ()
    if fm.fileExists (atPath: inDocumentPath) {
      button.setClosureAction {
        let ws = NSWorkspace.shared
        ws.open (URL (fileURLWithPath: inDocumentPath))
      }
    }else{
      button.isEnabled = false
    }
    _ = self.appendView (button)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate enum PartStatus {
  case partHasUnknownStatus
  case partIsDuplicated
  case partHasInvalidName
  case partHasError
  case partHasWarning
  case partIsValid
}

//--------------------------------------------------------------------------------------------------
//   DEVICE
//--------------------------------------------------------------------------------------------------

fileprivate struct PMDeviceDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
  let symbolDictionary : [String : Int]
  let packageDictionary : [String : Int]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkDeviceLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                       atPath inDeviceFullPath : String,
                                       deviceDict ioDeviceDict : inout [String : PMDeviceDictionaryEntry],
                                       errorCount ioErrorCount : inout Int) {
    let deviceName = ((inDeviceFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  //--- Get metadata dictionary
    if let metadata = try? getFileMetadata (atPath: inDeviceFullPath) {
    //--- Version number
      let possibleVersionNumber : Any? = metadata.metadataDictionary [DEVICE_VERSION_METADATA_DICTIONARY_KEY]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
      //--- Embedded symbol dictionary
        let possibleSymbolDictionary : Any? = metadata.metadataDictionary [DEVICE_SYMBOL_METADATA_DICTIONARY_KEY]
        var symbolDictionary : [String : Int] = [:]
        if let d = possibleSymbolDictionary as? [String : Int] {
          for (importedSymbolName, symbolDescription) in d {
            symbolDictionary [importedSymbolName] = symbolDescription
          }
        }else{
          inStackView.appendError ("Device '\(deviceName)' has no valid symbol dictionary")
          inStackView.appendOpenDocumentButton (inDeviceFullPath)
          ioErrorCount += 1
        }
      //--- Embedded package dictionary
        let possiblePackageDictionary : Any? = metadata.metadataDictionary [DEVICE_PACKAGE_METADATA_DICTIONARY_KEY]
        var packageDictionary : [String : Int] = [:]
        if let d = possiblePackageDictionary as? [String : Int] {
          for (importedPackageName, packageDescription) in d {
            packageDictionary [importedPackageName] = packageDescription
          }
        }else{
          inStackView.appendError ("Device '\(deviceName)' has no valid package dictionary")
          inStackView.appendOpenDocumentButton (inDeviceFullPath)
          ioErrorCount += 1
        }
      //---
        let possibleEntry : PMDeviceDictionaryEntry? = ioDeviceDict [deviceName]
        if let entry = possibleEntry {
          let newEntry = PMDeviceDictionaryEntry (
            partStatus: .partIsDuplicated,
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
            partStatus = .partHasUnknownStatus
          case .ok :
            partStatus = partNameIsValid (deviceName) ? .partIsValid : .partHasInvalidName
          case .warning :
            partStatus = .partHasWarning
          case .error :
            partStatus = .partHasError
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
      }else{
        inStackView.appendError ("File '\(deviceName)' has an invalid format")
        inStackView.appendOpenDocumentButton ((inDeviceFullPath as NSString).deletingLastPathComponent)
        ioErrorCount += 1
      }
    }else{
      inStackView.appendError ("File '\(deviceName)' has an invalid format")
      inStackView.appendOpenDocumentButton ((inDeviceFullPath as NSString).deletingLastPathComponent)
      ioErrorCount += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performDeviceLibraryEnumeration (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                  atPath inPackageLibraryPath : String,
                                  deviceDict ioDeviceDict : inout [String : PMDeviceDictionaryEntry],
                                  errorCount ioErrorCount : inout Int) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased() == ElCanariDevice_EXTENSION {
          let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
          self.checkDeviceLibrary (inStackView, atPath: fullsubpath, deviceDict: &ioDeviceDict, errorCount: &ioErrorCount)
        }
      }
    }else{
      inStackView.appendInfo ("\(inPackageLibraryPath) directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkDeviceLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                       symbolDict inSymbolDict : [String : PMSymbolDictionaryEntry],
                                       packageDict inPackageDict : [String : PMPackageDictionaryEntry]) -> (Int, Int) {
    var deviceDict : [String : PMDeviceDictionaryEntry] = [:]
    inStackView.appendText ("Device Library Pathes", bold: true)
    let MAX_DISPLAYED_ERRORS = 10
    var errorCount = 0
    for path in existingLibraryPathArray () {
      let deviceLibraryPath = deviceLibraryPathForPath (path)
      inStackView.appendOpenDocumentButton (deviceLibraryPath)
      performDeviceLibraryEnumeration (inStackView, atPath: deviceLibraryPath, deviceDict: &deviceDict, errorCount: &errorCount)
    }
  //--- Display duplicate entries and invalid entries
    var deviceToUpdateSet = Set <String> ()
    var moreErrorCount = 0
    for (deviceName, entry) in deviceDict {
      if errorCount >= MAX_DISPLAYED_ERRORS {
        switch entry.partStatus {
        case .partIsDuplicated, .partHasUnknownStatus, .partHasInvalidName, .partHasError, .partHasWarning :
          moreErrorCount += 1
          errorCount += 1
        case .partIsValid :
        //--- Check imported symbols
          for (importedSymbolName, _) in entry.symbolDictionary {
            if inSymbolDict [importedSymbolName] == nil {
              moreErrorCount += 1
              errorCount += 1
            }
          }
        //--- Check imported package
          for (importedPackageName, _) in entry.packageDictionary {
            if inPackageDict [importedPackageName] == nil {
              moreErrorCount += 1
              errorCount += 1
            }
          }
        }
      }else{
        if entry.partStatus != .partIsValid {
          _ = inStackView.appendSeparator ()
        }
        switch entry.partStatus {
        case .partIsDuplicated :
          inStackView.appendError ("  Error; several files for '\(deviceName)' device")
          for path in entry.pathArray {
            inStackView.appendOpenDocumentButton (path)
          }
          errorCount += 1
        case .partHasUnknownStatus :
          inStackView.appendError ("  Error; '\(deviceName)' device has unknown status")
          errorCount += 1
        case .partHasInvalidName :
          inStackView.appendError ("  Error; '\(deviceName)' device has an invalid name")
          errorCount += 1
        case .partHasError :
          inStackView.appendError ("  Error; '\(deviceName)' device contains error(s)")
          errorCount += 1
        case .partHasWarning :
          inStackView.appendError ("  Error; '\(deviceName)' device contains warning(s)")
          errorCount += 1
        case .partIsValid :
        //--- Check imported symbols
          var deviceHasError = false
          for (importedSymbolName, importedSymbolVersion) in entry.symbolDictionary {
            if inSymbolDict [importedSymbolName] == nil {
              if !deviceHasError {
                deviceHasError = true
                _ = inStackView.appendSeparator ()
              }
              var message = "  Error; '"
              message += deviceName
              message += "' device contains the '"
              message += importedSymbolName
              message += "' symbol, but this symbol is not defined by the library\n"
              inStackView.appendError (message)
              errorCount += 1
            }else if inSymbolDict [importedSymbolName]!.version != importedSymbolVersion {
              deviceToUpdateSet.insert (entry.pathArray[0])
            }
          }
        //--- Check imported package
          for (importedPackageName, importedPackageVersion) in entry.packageDictionary {
            if inPackageDict [importedPackageName] == nil {
              if !deviceHasError {
                deviceHasError = true
                _ = inStackView.appendSeparator ()
              }
              var message = "  Error; '"
              message += deviceName
              message += "' device contains the '"
              message += importedPackageName
              message += "' package, but this package is not defined by the library\n"
              inStackView.appendError (message)
              errorCount += 1
            }else if inPackageDict [importedPackageName]!.version != importedPackageVersion {
              deviceToUpdateSet.insert (entry.pathArray[0])
            }
          }
          if deviceHasError || (entry.partStatus != .partIsValid) {
            for path in entry.pathArray {
              inStackView.appendOpenDocumentButton (path)
            }
          }
        }
      }
    }
//  //--- Count duplicate entries and invalid entries
//    var moreErrorCount = 0
//    for (_, entry) in deviceDict {
//      switch entry.partStatus {
//      case .partIsDuplicated, .partHasUnknownStatus, .partHasInvalidName, .partHasError, .partHasWarning :
//        moreErrorCount += 1
//      case .partIsValid :
//      //--- Check imported symbols
//        for (importedSymbolName, _) in entry.symbolDictionary {
//          if inSymbolDict [importedSymbolName] == nil {
//            moreErrorCount += 1
//          }
//        }
//      //--- Check imported package
//        for (importedPackageName, _) in entry.packageDictionary {
//          if inPackageDict [importedPackageName] == nil {
//            moreErrorCount += 1
//          }
//        }
//      }
//    }
    if moreErrorCount == 1 {
      inStackView.appendSeparator ().appendError ("  …and 1 more error")
    }else if moreErrorCount > 1 {
      inStackView.appendSeparator ().appendError ("  …and \(moreErrorCount) more errors")
    }
  //---
    if errorCount < MAX_DISPLAYED_ERRORS {
      if !deviceToUpdateSet.isEmpty {
        inStackView.appendSeparator ().appendSeparator ()
          .appendText ("Theses devices should be updated", bold: true)
        for path in deviceToUpdateSet {
          inStackView.appendSeparator ().appendOpenDocumentButton (path)
          errorCount += 1
        }
      }
    }else{
      if deviceToUpdateSet.count == 1 {
        inStackView.appendError ("  …and 1 more updatable device")
      }else if deviceToUpdateSet.count > 1 {
        inStackView.appendError ("  …and \(deviceToUpdateSet.count) more updatable devices")
      }
    }
  //---
    return (deviceDict.count, errorCount)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   SYMBOL
//--------------------------------------------------------------------------------------------------

fileprivate struct PMSymbolDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkSymbolLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                       atPath inSymbolFullPath : String,
                                       symbolDict ioSymbolDict : inout [String : PMSymbolDictionaryEntry],
                                       errorCount ioErrorCount : inout Int) {
    let symbolName = ((inSymbolFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
    if let metadata = try? getFileMetadata (atPath: inSymbolFullPath) {
      let possibleVersionNumber : Any? = metadata.metadataDictionary [PMSymbolVersion]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
        let possibleEntry : PMSymbolDictionaryEntry? = ioSymbolDict [symbolName]
        if let entry = possibleEntry {
          let newEntry = PMSymbolDictionaryEntry (
            partStatus: .partIsDuplicated,
            version: 0,
            versionStringForDialog: "—",
            pathArray: entry.pathArray + [inSymbolFullPath]
          )
          ioSymbolDict [symbolName] = newEntry
        }else{
          let partStatus : PartStatus
          switch metadata.metadataStatus {
          case .unknown :
            partStatus = .partHasUnknownStatus
          case .ok :
            partStatus = partNameIsValid (symbolName) ? .partIsValid : .partHasInvalidName
          case .warning :
            partStatus = .partHasWarning
          case .error :
            partStatus = .partHasError
          }
          let newEntry = PMSymbolDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: String (version),
            pathArray: [inSymbolFullPath]
          )
          ioSymbolDict [symbolName] = newEntry
        }
      }else{
        inStackView.appendError ("File '\(symbolName)' has an invalid format")
        inStackView.appendOpenDocumentButton ((inSymbolFullPath as NSString).deletingLastPathComponent)
        ioErrorCount += 1
      }
    }else{
      inStackView.appendError ("File '\(symbolName)' has an invalid format")
      inStackView.appendOpenDocumentButton ((inSymbolFullPath as NSString).deletingLastPathComponent)
      ioErrorCount += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor fileprivate func performSymbolLibraryEnumeration (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                                    atPath inSymbolLibraryPath : String,
                                                    errorCount ioErrorCount : inout Int,
                                                    symbolDict ioSymbolDict : inout [String : PMSymbolDictionaryEntry]) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inSymbolLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased () == ElCanariSymbol_EXTENSION {
          let fullsubpath = inSymbolLibraryPath.appendingPathComponent (path)
          self.checkSymbolLibrary (inStackView, atPath: fullsubpath, symbolDict: &ioSymbolDict, errorCount: &ioErrorCount)
        }
      }
    }else{
      inStackView.appendInfo ("\(inSymbolLibraryPath) directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkSymbolLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                       symbolDict ioSymbolDict : inout [String : PMSymbolDictionaryEntry]) -> Int {
    inStackView.appendText ("Symbol Library Pathes", bold: true)
    let MAX_DISPLAYED_ERRORS = 10
    var errorCount = 0
    for path in existingLibraryPathArray () {
      let symbolLibraryPath = symbolLibraryPathForPath (path)
      inStackView.appendOpenDocumentButton (symbolLibraryPath)
      performSymbolLibraryEnumeration (inStackView, atPath: symbolLibraryPath, errorCount: &errorCount, symbolDict: &ioSymbolDict)
    }
  //--- Display duplicate entries for symbols, invalid entries
    var moreErrorCount = 0
    for (symbolName, entry) in ioSymbolDict {
      if errorCount >= MAX_DISPLAYED_ERRORS {
        if entry.partStatus != .partIsValid {
          moreErrorCount += 1
          errorCount += 1
        }
      }else{
        if entry.partStatus != .partIsValid {
          _ = inStackView.appendSeparator ()
        }
        switch entry.partStatus {
        case .partIsDuplicated :
          inStackView.appendError ("  Error; several files for '\(symbolName)' symbol")
          errorCount += 1
        case .partHasUnknownStatus :
          inStackView.appendError ("  Error; '\(symbolName)' symbol has unknown status")
          errorCount += 1
        case .partHasInvalidName :
          inStackView.appendError ("  Error; '\(symbolName)' symbol has an invalid name")
          errorCount += 1
        case .partHasError :
          inStackView.appendError ("  Error; '\(symbolName)' symbol contains error(s)")
          errorCount += 1
        case .partHasWarning :
          inStackView.appendError ("  Error; '\(symbolName)' symbol contains warning(s)")
          errorCount += 1
        case .partIsValid :
          break
        }
        if entry.partStatus != .partIsValid {
          for path in entry.pathArray {
            inStackView.appendOpenDocumentButton (path)
          }
        }
      }
    }
    if moreErrorCount == 1 {
      inStackView.appendSeparator ().appendError ("  …and 1 more error")
    }else if moreErrorCount > 1 {
      inStackView.appendSeparator ().appendError ("  …and \(moreErrorCount) more errors")
    }
    return errorCount
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   PACKAGE
//--------------------------------------------------------------------------------------------------

fileprivate struct PMPackageDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func checkPackageLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                           atPath inPackageFullPath : String,
                                           packageDict ioPackageDict : inout [String : PMPackageDictionaryEntry],
                                           errorCount ioErrorCount : inout Int) {
  let packageName = ((inPackageFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  if let metadata = try? getFileMetadata (atPath: inPackageFullPath) {
    let possibleVersionNumber : Any? = metadata.metadataDictionary [PMPackageVersion]
    let version : Int
    if let n = possibleVersionNumber as? NSNumber {
      version = n.intValue
      let possibleEntry : PMPackageDictionaryEntry? = ioPackageDict [packageName]
      if let entry = possibleEntry {
        let newEntry = PMPackageDictionaryEntry (
          partStatus: .partIsDuplicated,
          version: 0,
          versionStringForDialog: "—",
          pathArray: entry.pathArray + [inPackageFullPath]
        )
        ioPackageDict [packageName] = newEntry
      }else{
        var partStatus : PartStatus
        switch metadata.metadataStatus {
        case .unknown :
          partStatus = .partHasUnknownStatus
        case .ok :
          partStatus = partNameIsValid (packageName) ? .partIsValid : .partHasInvalidName
        case .warning :
          partStatus = .partHasWarning
        case .error :
          partStatus = .partHasError
        }
        let newEntry = PMPackageDictionaryEntry (
          partStatus: partStatus,
          version: version,
          versionStringForDialog: String (version),
          pathArray: [inPackageFullPath]
        )
        ioPackageDict [packageName] = newEntry
      }
    }else{
      inStackView.appendError ("File '\(packageName)' has an invalid format")
      inStackView.appendOpenDocumentButton ((inPackageFullPath as NSString).deletingLastPathComponent)
      ioErrorCount += 1
    }
  }else{
    inStackView.appendError ("File '\(packageName)' has an invalid format")
    inStackView.appendOpenDocumentButton ((inPackageFullPath as NSString).deletingLastPathComponent)
    ioErrorCount += 1
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func performPackageLibraryEnumeration (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                                   atPath inPackageLibraryPath : String,
                                                   packageDict ioPackageDict : inout [String : PMPackageDictionaryEntry],
                                                   errorCount ioErrorCount : inout Int) {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariPackage_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        checkPackageLibrary (inStackView, atPath: fullsubpath, packageDict: &ioPackageDict, errorCount: &ioErrorCount)
      }
    }
  }else{
    inStackView.appendInfo ("\(inPackageLibraryPath) directory does not exist")
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func checkPackageLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                                 packageDict ioPackageDict : inout [String : PMPackageDictionaryEntry]) -> Int {
  inStackView.appendText ("Package Library Pathes", bold: true)
  let MAX_DISPLAYED_ERRORS = 10
  var errorCount = 0
  for path in existingLibraryPathArray () {
    let packageLibraryPath = packageLibraryPathForPath (path)
    inStackView.appendOpenDocumentButton (packageLibraryPath)
    performPackageLibraryEnumeration (inStackView, atPath: packageLibraryPath, packageDict: &ioPackageDict, errorCount: &errorCount)
  }
//--- Display duplicate entries for symbols, invalid entries
  var moreErrorCount = 0
  for (packageName, entry) in ioPackageDict {
    if errorCount >= MAX_DISPLAYED_ERRORS {
      if entry.partStatus != .partIsValid {
        errorCount += 1
        moreErrorCount += 1
      }
    }else{
      if entry.partStatus != .partIsValid {
        _ = inStackView.appendSeparator ()
      }
      switch entry.partStatus {
      case .partIsDuplicated :
        inStackView.appendError ("  Error; several files for '\(packageName)' package")
        errorCount += 1
      case .partHasUnknownStatus :
        inStackView.appendError ("  Error; '\(packageName)' package has unknown status")
        errorCount += 1
      case .partHasInvalidName :
        inStackView.appendError ("  Error; '\(packageName)' package has an invalid name")
        errorCount += 1
      case .partHasError :
        inStackView.appendError ("  Error; '\(packageName)' package contains error(s)")
        errorCount += 1
      case .partHasWarning :
        inStackView.appendError ("  Error; '\(packageName)' package contains warning(s)")
        errorCount += 1
      case .partIsValid :
        break
      }
      if entry.partStatus != .partIsValid {
        for path in entry.pathArray {
          inStackView.appendOpenDocumentButton (path)
        }
      }
    }
  }
  if moreErrorCount == 1 {
    inStackView.appendSeparator ().appendError ("  …and 1 more error")
  }else if moreErrorCount > 1 {
    inStackView.appendSeparator ().appendError ("  …and \(moreErrorCount) more errors")
  }
  return errorCount
}

//--------------------------------------------------------------------------------------------------
//   FONT
//--------------------------------------------------------------------------------------------------

fileprivate struct PMFontDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkFontLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                     atPath inFontFullPath : String,
                                     fontDict ioFontDict : inout [String : PMFontDictionaryEntry],
                                     errorCount ioErrorCount : inout Int) {
    let fontName = ((inFontFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
    if let metadata = try? getFileMetadata (atPath: inFontFullPath) {
      let possibleVersionNumber : Any? = metadata.metadataDictionary [PMFontVersion]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
        let possibleEntry : PMFontDictionaryEntry? = ioFontDict [fontName]
        if let entry = possibleEntry {
          let newEntry = PMFontDictionaryEntry (
            partStatus: .partIsDuplicated,
            version: 0,
            versionStringForDialog: "—",
            pathArray: entry.pathArray + [inFontFullPath]
          )
          ioFontDict [fontName] = newEntry
        }else{
          let partStatus : PartStatus
          switch metadata.metadataStatus {
          case .unknown :
            partStatus = .partHasUnknownStatus
          case .ok :
            partStatus = partNameIsValid (fontName) ? .partIsValid : .partHasInvalidName
          case .warning :
            partStatus = .partHasWarning
          case .error :
            partStatus = .partHasError
          }
          let newEntry = PMFontDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: "\(version)",
            pathArray: [inFontFullPath]
          )
          ioFontDict [fontName] = newEntry
        }
      }else{
        inStackView.appendError ("File '\(fontName)' has an invalid format")
        inStackView.appendOpenDocumentButton ((inFontFullPath as NSString).deletingLastPathComponent)
        ioErrorCount += 1
      }
    }else{
      inStackView.appendError ("File '\(fontName)' has an invalid format")
      inStackView.appendOpenDocumentButton ((inFontFullPath as NSString).deletingLastPathComponent)
      ioErrorCount += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performFontLibraryEnumeration (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                                atPath inFontLibraryPath : String,
                                                fontDict ioFontDict : inout [String : PMFontDictionaryEntry],
                                                errorCount ioErrorCount : inout Int) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inFontLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased () == ElCanariFont_EXTENSION {
          let fullsubpath = inFontLibraryPath.appendingPathComponent (path)
          checkFontLibrary (inStackView, atPath: fullsubpath, fontDict: &ioFontDict, errorCount: &ioErrorCount)
        }
      }
    }else{
      inStackView.appendInfo ("\(inFontLibraryPath) directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkFontLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar) -> (Int, Int) {
    var fontDict : [String : PMFontDictionaryEntry] = [:]
    inStackView.appendText ("Font Library Pathes", bold: true)
    var errorCount = 0
    for path in existingLibraryPathArray () {
      let fontLibraryPath = fontLibraryPathForPath (path)
      inStackView.appendOpenDocumentButton (fontLibraryPath)
      performFontLibraryEnumeration (inStackView, atPath: fontLibraryPath, fontDict: &fontDict, errorCount: &errorCount)
    }
  //--- Display duplicate entries for font, invalid entries
    for (fontName, entry) in fontDict {
      if entry.partStatus != .partIsValid {
        _ = inStackView.appendSeparator ()
      }
      switch entry.partStatus {
      case .partIsDuplicated :
        inStackView.appendError ("  Error; several files for '\(fontName)' font")
        errorCount += 1
      case .partHasUnknownStatus :
        inStackView.appendError ("  Error; '\(fontName)' font has unknown status")
        errorCount += 1
      case .partHasInvalidName :
        inStackView.appendError ("  Error; '\(fontName)' font has an invalid name")
        errorCount += 1
      case .partHasError :
        inStackView.appendError ("  Error; '\(fontName)' font contains error(s)")
        errorCount += 1
      case .partHasWarning :
        inStackView.appendError ("  Error; '\(fontName)' font contains warning(s)")
        errorCount += 1
      case .partIsValid :
        break
      }
      if entry.partStatus != .partIsValid {
        for path in entry.pathArray {
          inStackView.appendOpenDocumentButton (path)
        }
      }
    }
    return (fontDict.count, errorCount)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//--------------------------------------------------------------------------------------------------
//   ARTWORK
//--------------------------------------------------------------------------------------------------

fileprivate struct PMArtworkDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkArtworkLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                        atPath inArtworkFullPath : String,
                                        artworkDict ioArtworkDict : inout [String : PMArtworkDictionaryEntry],
                                        errorCount ioErrorCount : inout Int) {
    let artworkName = ((inArtworkFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
    if let metadata = try? getFileMetadata (atPath: inArtworkFullPath) {
      // NSLog ("\(metadataDictionary)")
      let possibleVersionNumber : Any? = metadata.metadataDictionary [PMArtworkVersion]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
        let possibleEntry : PMArtworkDictionaryEntry? = ioArtworkDict [artworkName]
        if let entry = possibleEntry {
          let newEntry = PMArtworkDictionaryEntry (
            partStatus: .partIsDuplicated,
            version:0,
            versionStringForDialog: "—",
            pathArray: entry.pathArray + [inArtworkFullPath]
          )
          ioArtworkDict [artworkName] = newEntry
        }else{
          let partStatus : PartStatus = partNameIsValid (artworkName) ? .partIsValid : .partHasInvalidName
          let newEntry = PMArtworkDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: String (version),
            pathArray: [inArtworkFullPath]
          )
          ioArtworkDict [artworkName] = newEntry
        }
      }else{
        inStackView.appendError ("File '\(artworkName)' has an invalid format")
        inStackView.appendOpenDocumentButton ((inArtworkFullPath as NSString).deletingLastPathComponent)
        ioErrorCount += 1
      }
    }else{
      inStackView.appendError ("File '\(artworkName)' has an invalid format")
      inStackView.appendOpenDocumentButton ((inArtworkFullPath as NSString).deletingLastPathComponent)
      ioErrorCount += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performArtworkLibraryEnumeration (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar,
                                                   atPath inArtworkLibraryPath : String,
                                                   artworkDict ioArtworkDict : inout [String : PMArtworkDictionaryEntry],
                                                   errorCount ioErrorCount : inout Int) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inArtworkLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased () == ElCanariArtwork_EXTENSION {
          let fullsubpath = inArtworkLibraryPath.appendingPathComponent (path)
          checkArtworkLibrary (inStackView, atPath: fullsubpath, artworkDict: &ioArtworkDict, errorCount: &ioErrorCount)
        }
      }
    }else{
      inStackView.appendInfo ("\(inArtworkLibraryPath) directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkArtworkLibrary (_ inStackView : AutoLayoutVerticalStackViewWithScrollBar) -> (Int, Int) {
    var artworkDict : [String : PMArtworkDictionaryEntry] = [:]
    inStackView.appendText ("Arwork Library Pathes", bold: true)
    var errorCount = 0
    for path in existingLibraryPathArray () {
      let artworkLibraryPath = artworkLibraryPathForPath (path)
      inStackView.appendOpenDocumentButton (artworkLibraryPath)
      performArtworkLibraryEnumeration (inStackView, atPath: artworkLibraryPath, artworkDict: &artworkDict, errorCount: &errorCount)
    }
  //--- Display duplicate entries for symbols, invalid entries
    for (artworkName, entry) in artworkDict {
      if entry.partStatus != .partIsValid {
        _ = inStackView.appendSeparator ()
      }
      switch entry.partStatus {
      case .partIsDuplicated :
        inStackView.appendError ("  Error; several files for '\(artworkName)' artwork")
        errorCount += 1
      case .partHasUnknownStatus :
        inStackView.appendError ("  Error; '\(artworkName)' artwork has unknown status")
        errorCount += 1
      case .partHasInvalidName :
        inStackView.appendError ("  Error; '\(artworkName)' artwork has an invalid name")
        errorCount += 1
      case .partHasError :
        inStackView.appendError ("  Error; '\(artworkName)' artwork contains error(s)")
        errorCount += 1
      case .partHasWarning :
        inStackView.appendError ("  Error; '\(artworkName)' artwork contains warning(s)")
        errorCount += 1
      case .partIsValid :
        break
      }
      if entry.partStatus != .partIsValid {
        for path in entry.pathArray {
          inStackView.appendOpenDocumentButton (path)
        }
      }
    }
    return (artworkDict.count, errorCount)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
