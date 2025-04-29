//--------------------------------------------------------------------------------------------------
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
    let optionalPreviousSelectedTab = self.mLibraryConsistencyLogTabView?.indexOfSelectedItem
    var optionalTabWithErrorIndex : Int? = nil
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
    let symbolTabContents = MessageStackView ().set (margins: .large)
    var symbolDict : [String : SymbolDictionaryEntry] = [:]
    self.checkSymbolLibrary (symbolTabContents, symbolDict: &symbolDict)
    let symbolErrorCount = symbolTabContents.errorCount
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
    if symbolErrorCount > 0 {
      optionalTabWithErrorIndex = 0
    }
  //---------- Checking Packages
    let packageTabContents = MessageStackView ().set (margins: .large)
    var packageDict : [String : PackageDictionaryEntry] = [:]
    checkPackageLibrary (packageTabContents, packageDict: &packageDict)
    let packageErrorCount = packageTabContents.errorCount
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
    if packageErrorCount > 0, optionalTabWithErrorIndex == nil {
      optionalTabWithErrorIndex = 1
    }
  //---------- Checking Devices
    let deviceTabContents = MessageStackView ().set (margins: .large)
    let (deviceCount, deviceCategorySet) = self.checkDeviceLibrary (
      deviceTabContents,
      symbolDict: symbolDict,
      packageDict: packageDict
    )
    self.setDeviceCategorySet (deviceCategorySet)
    let deviceErrorCount = deviceTabContents.errorCount
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
    if deviceErrorCount > 0, optionalTabWithErrorIndex == nil {
      optionalTabWithErrorIndex = 2
    }
  //--------- Checking Fonts
    let fontTabContents = MessageStackView ().set (margins: .large)
    let fontCount = checkFontLibrary (fontTabContents)
    let fontErrorCount = fontTabContents.errorCount
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
    }else if fontErrorCount > 1 {
      title += " (\(fontErrorCount) errors)"
    }
    _ = tabView.addTab (
      title: title,
      image : (fontErrorCount == 0) ? NSImage.statusSuccess : NSImage.statusError,
      tooltip: "",
      contentView: fontTabContents.appendFlexibleSpace ()
    )
    if fontErrorCount > 0, optionalTabWithErrorIndex == nil {
      optionalTabWithErrorIndex = 3
    }
  //--------- Checking Artworks
    let artworkTabContents = MessageStackView ().set (margins: .large)
    let arworkCount = checkArtworkLibrary (artworkTabContents)
    let artworkErrorCount = artworkTabContents.errorCount
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
    if artworkErrorCount > 0, optionalTabWithErrorIndex == nil {
      optionalTabWithErrorIndex = 4
    }
  //---------
    if let previousSelectedTabIndex = optionalPreviousSelectedTab {
      tabView.selectTab (atIndex: previousSelectedTabIndex)
    }else if let tabWithErrorIndex = optionalTabWithErrorIndex {
      tabView.selectTab (atIndex: tabWithErrorIndex)
    }else{
      tabView.selectTab (atIndex: 0)
    }
    preferences_fileSystemLibraryIsOk_property.setProp (errorCount == 0)
    gOpenDeviceInLibrary.populateCategoryPopUpButton (withCategoryNameSet: deviceCategorySet)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate let MAX_DISPLAYED_ERRORS = 10

//--------------------------------------------------------------------------------------------------

fileprivate class MessageStackView : AutoLayoutVerticalStackViewWithScrollBar {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mErrorCount = 0
  var errorCount : Int { self.mErrorCount }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendInfo (_ inString : String) {
    _ = self.appendView (AutoLayoutStaticLabel (title: inString, bold: false, size: .regular, alignment: .left).setTextColor (.systemBlue).expandableWidth())
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendError (_ inTitle : String,
                    _ inErrorArray : [String],
                    documentPathes inDocumentPathes : [String]) {
    if !inErrorArray.isEmpty {
      if self.mErrorCount < MAX_DISPLAYED_ERRORS {
        var first = true
        for errorString in inErrorArray {
          let hStack = AutoLayoutHorizontalStackView ()
          if first {
            first = false
            let label = AutoLayoutStaticLabel (title: inTitle, bold: false, size: .regular, alignment: .left)
              .setHorizontalStretchingResistance (.high)
              .setHorizontalCompressionResistance (.higher)
            _ = hStack.appendView (label)
          }else{
            _ = hStack.appendFlexibleSpace ()
          }
         _ = hStack.appendGutter ()
                   .appendView (AutoLayoutStaticLabel (title: errorString, bold: true, size: .regular, alignment: .left).setRedTextColor ().expandableWidth())
          _ = self.appendView (hStack)
        }
        for path in inDocumentPathes {
          let button = AutoLayoutButton (title: path, size: .regular).expandableWidth ()
          let fm = FileManager ()
          if fm.fileExists (atPath: path) {
            button.setClosureAction {
              let ws = NSWorkspace.shared
              ws.open (URL (fileURLWithPath: path))
            }
          }else{
            button.isEnabled = false
          }
          let hStack = AutoLayoutHorizontalStackView ()
            .appendFlexibleSpace ()
            .appendGutter ()
            .appendView (button)
          _ = self.appendView (hStack)
        }
      }
      self.mErrorCount += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendOpenLibraryDirectoryButton (_ inTitle : String, _ inDocumentPath : String) {
    let button = AutoLayoutButton (title: inDocumentPath, size: .regular)
    let fm = FileManager ()
    if fm.fileExists (atPath: inDocumentPath) {
      button.setClosureAction {
        let ws = NSWorkspace.shared
        ws.open (URL (fileURLWithPath: inDocumentPath))
      }
    }else{
      button.isEnabled = false
    }
    let hStack = AutoLayoutHorizontalStackView ()
      .appendView (AutoLayoutStaticLabel (title: inTitle, bold: true, size: .regular, alignment: .center).notExpandableWidth())
      .appendView (button.expandableWidth ().setUseBoldFont (true))
    _ = self.appendSeparator ().appendView (hStack)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendMoreErrorsMessage () {
    if self.mErrorCount > MAX_DISPLAYED_ERRORS {
      let moreErrors = self.mErrorCount - MAX_DISPLAYED_ERRORS
      let message = (moreErrors == 1)
        ? "... and 1 more error"
        : "... and \(moreErrors) more errors"
      _ = self.appendView (AutoLayoutStaticLabel (title: message, bold: true, size: .regular, alignment: .left).expandableWidth ())
    }
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
//MARK:   DEVICE
//--------------------------------------------------------------------------------------------------

fileprivate struct DeviceDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
  let symbolDictionary : [String : Int]
  let packageDictionary : [String : Int]
  let category : String
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkDeviceLibrary (_ inStackView : MessageStackView,
                                       atPath inDeviceFullPath : String,
                                       deviceDict ioDeviceDict : inout [String : DeviceDictionaryEntry],
                                       categories ioCategories : inout Set <String>) {
    let deviceName = ((inDeviceFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  //--- Get metadata dictionary
    if let metadata = try? getFileMetadata (atPath: inDeviceFullPath) {
    //--- Category
      let category : String = (metadata.metadataDictionary [DEVICE_CATEGORY_KEY] as? String) ?? ""
      if category == "" {
        inStackView.appendError (
          deviceName,
          ["Device '\(deviceName)' has an empty category string"],
          documentPathes: [inDeviceFullPath]
        )
      }else{
        ioCategories.insert (category)
      }
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
          inStackView.appendError (
            deviceName,
            ["Device '\(deviceName)' has no valid symbol dictionary"],
            documentPathes: [inDeviceFullPath]
          )
        }
      //--- Embedded package dictionary
        let possiblePackageDictionary : Any? = metadata.metadataDictionary [DEVICE_PACKAGE_METADATA_DICTIONARY_KEY]
        var packageDictionary : [String : Int] = [:]
        if let d = possiblePackageDictionary as? [String : Int] {
          for (importedPackageName, packageDescription) in d {
            packageDictionary [importedPackageName] = packageDescription
          }
        }else{
          inStackView.appendError (
            deviceName,
            ["Device '\(deviceName)' has no valid package dictionary"],
            documentPathes: [inDeviceFullPath]
          )
        }
      //---
        let possibleEntry : DeviceDictionaryEntry? = ioDeviceDict [deviceName]
        if let entry = possibleEntry {
          let newEntry = DeviceDictionaryEntry (
            partStatus: .partIsDuplicated,
            version: 0,
            versionStringForDialog: "—",
            pathArray: entry.pathArray + [inDeviceFullPath],
            symbolDictionary : symbolDictionary,
            packageDictionary : packageDictionary,
            category: (metadata.metadataDictionary [DEVICE_CATEGORY_KEY] as? String) ?? ""
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
          let newEntry = DeviceDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: String (version),
            pathArray: [inDeviceFullPath],
            symbolDictionary: symbolDictionary,
            packageDictionary: packageDictionary,
            category: (metadata.metadataDictionary [DEVICE_CATEGORY_KEY] as? String) ?? ""
          )
          ioDeviceDict [deviceName] = newEntry
        }
      }else{
        inStackView.appendError (
          deviceName,
          ["File '\(deviceName)' has an invalid format"],
          documentPathes: [inDeviceFullPath]
        )
      }
    }else{
      inStackView.appendError (
        deviceName,
        ["File '\(deviceName)' has an invalid format"],
        documentPathes: [inDeviceFullPath]
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performDeviceLibraryEnumeration (_ inStackView : MessageStackView,
                                  atPath inPackageLibraryPath : String,
                                  deviceDict ioDeviceDict : inout [String : DeviceDictionaryEntry],
                                  categories ioCategories : inout Set <String>) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased() == ElCanariDevice_EXTENSION {
          let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
          self.checkDeviceLibrary (inStackView, atPath: fullsubpath, deviceDict: &ioDeviceDict, categories: &ioCategories)
        }
      }
    }else{
      inStackView.appendInfo ("Directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkDeviceLibrary (_ inStackView : MessageStackView,
                                       symbolDict inSymbolDict : [String : SymbolDictionaryEntry],
                                       packageDict inPackageDict : [String : PackageDictionaryEntry]) -> (Int, Set <String>) {
    var categories = Set <String> ()
    var deviceDict : [String : DeviceDictionaryEntry] = [:]
    for path in existingLibraryPathArray () {
      let deviceLibraryPath = deviceLibraryPathForPath (path)
      inStackView.appendOpenLibraryDirectoryButton ("Device Library", deviceLibraryPath)
      performDeviceLibraryEnumeration (inStackView, atPath: deviceLibraryPath, deviceDict: &deviceDict, categories: &categories)
    }
  //--- Display duplicate entries and invalid entries
    for (deviceName, entry) in deviceDict {
      var errorMessageArray : [String] = []
      var shouldBeUpdated = false
      switch entry.partStatus {
      case .partIsDuplicated :
        errorMessageArray.append ("Several files for '\(deviceName)' device")
      case .partHasUnknownStatus :
        errorMessageArray.append ("Device has unknown status")
      case .partHasInvalidName :
        errorMessageArray.append ("Device has invalid name")
      case .partHasError :
        errorMessageArray.append ("Device has error(s)")
      case .partHasWarning :
        errorMessageArray.append ("Device has warning(s)")
      case .partIsValid :
      //--- Check imported symbols
        for (importedSymbolName, importedSymbolVersion) in entry.symbolDictionary {
          if inSymbolDict [importedSymbolName] == nil {
            var message = "Device contains the '"
            message += importedSymbolName
            message += "' symbol, but this symbol is not defined by the library\n"
            errorMessageArray.append (message)
          }else if inSymbolDict [importedSymbolName]!.version != importedSymbolVersion {
            shouldBeUpdated = true
          }
        }
      //--- Check imported package
        for (importedPackageName, importedPackageVersion) in entry.packageDictionary {
          if inPackageDict [importedPackageName] == nil {
            var message = "Device contains the '"
            message += importedPackageName
            message += "' package, but this package is not defined by the library\n"
            errorMessageArray.append (message)
          }else if inPackageDict [importedPackageName]!.version != importedPackageVersion {
            shouldBeUpdated = true
          }
        }
        if shouldBeUpdated {
          errorMessageArray.append ("This device should be updated")
        }
        inStackView.appendError (
          deviceName,
          errorMessageArray,
          documentPathes: entry.pathArray
        )
      }
    }
  //---
    inStackView.appendMoreErrorsMessage ()
    return (deviceDict.count, categories)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//MARK:   SYMBOL
//--------------------------------------------------------------------------------------------------

fileprivate struct SymbolDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkSymbolLibrary (_ inStackView : MessageStackView,
                                       atPath inSymbolFullPath : String,
                                       symbolDict ioSymbolDict : inout [String : SymbolDictionaryEntry]) {
    let symbolName = ((inSymbolFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
    if let metadata = try? getFileMetadata (atPath: inSymbolFullPath) {
      let possibleVersionNumber : Any? = metadata.metadataDictionary [PMSymbolVersion]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
        let possibleEntry : SymbolDictionaryEntry? = ioSymbolDict [symbolName]
        if let entry = possibleEntry {
          let newEntry = SymbolDictionaryEntry (
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
          let newEntry = SymbolDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: String (version),
            pathArray: [inSymbolFullPath]
          )
          ioSymbolDict [symbolName] = newEntry
        }
      }else{
        inStackView.appendError (
          symbolName,
          ["File '\(symbolName)' has an invalid format"],
          documentPathes: [inSymbolFullPath]
        )
      }
    }else{
      inStackView.appendError (
        symbolName,
        ["File '\(symbolName)' has an invalid format"],
        documentPathes: [inSymbolFullPath]
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor fileprivate func performSymbolLibraryEnumeration (_ inStackView : MessageStackView,
                                                    atPath inSymbolLibraryPath : String,
                                                    symbolDict ioSymbolDict : inout [String : SymbolDictionaryEntry]) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inSymbolLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased () == ElCanariSymbol_EXTENSION {
          let fullsubpath = inSymbolLibraryPath.appendingPathComponent (path)
          self.checkSymbolLibrary (inStackView, atPath: fullsubpath, symbolDict: &ioSymbolDict)
        }
      }
    }else{
      inStackView.appendInfo ("Directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkSymbolLibrary (_ inStackView : MessageStackView,
                                       symbolDict ioSymbolDict : inout [String : SymbolDictionaryEntry]) {
    for path in existingLibraryPathArray () {
      let symbolLibraryPath = symbolLibraryPathForPath (path)
      inStackView.appendOpenLibraryDirectoryButton ("Symbol Library", symbolLibraryPath)
      performSymbolLibraryEnumeration (inStackView, atPath: symbolLibraryPath, symbolDict: &ioSymbolDict)
    }
  //--- Display duplicate entries for symbols, invalid entries
    for (symbolName, entry) in ioSymbolDict {
      var errorMessageArray : [String] = []
      switch entry.partStatus {
      case .partIsDuplicated :
        errorMessageArray.append ("Several files for '\(symbolName)' symbol")
      case .partHasUnknownStatus :
        errorMessageArray.append ("Symbol has unknown status")
      case .partHasInvalidName :
        errorMessageArray.append ("Symbol has an invalid name")
      case .partHasError :
        errorMessageArray.append ("Symbol has error(s)")
      case .partHasWarning :
        errorMessageArray.append ("Symbol has warning(s)")
      case .partIsValid :
        ()
      }
      inStackView.appendError (symbolName, errorMessageArray, documentPathes: entry.pathArray)
    }
    inStackView.appendMoreErrorsMessage ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//MARK:   PACKAGE
//--------------------------------------------------------------------------------------------------

fileprivate struct PackageDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func checkPackageLibrary (_ inStackView : MessageStackView,
                                           atPath inPackageFullPath : String,
                                           packageDict ioPackageDict : inout [String : PackageDictionaryEntry]) {
  let packageName = ((inPackageFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
  if let metadata = try? getFileMetadata (atPath: inPackageFullPath) {
    let possibleVersionNumber : Any? = metadata.metadataDictionary [PMPackageVersion]
    let version : Int
    if let n = possibleVersionNumber as? NSNumber {
      version = n.intValue
      let possibleEntry : PackageDictionaryEntry? = ioPackageDict [packageName]
      if let entry = possibleEntry {
        let newEntry = PackageDictionaryEntry (
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
        let newEntry = PackageDictionaryEntry (
          partStatus: partStatus,
          version: version,
          versionStringForDialog: String (version),
          pathArray: [inPackageFullPath]
        )
        ioPackageDict [packageName] = newEntry
      }
    }else{
      inStackView.appendError (
        packageName,
        ["File '\(packageName)' has an invalid format"],
        documentPathes: [inPackageFullPath]
      )
    }
  }else{
    inStackView.appendError (
      packageName,
      ["File '\(packageName)' has an invalid format"],
      documentPathes: [inPackageFullPath]
    )
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func performPackageLibraryEnumeration (_ inStackView : MessageStackView,
                                                   atPath inPackageLibraryPath : String,
                                                   packageDict ioPackageDict : inout [String : PackageDictionaryEntry]) {
  let fm = FileManager ()
  if let unwSubpaths = fm.subpaths (atPath: inPackageLibraryPath) {
    for path in unwSubpaths {
      if path.pathExtension.lowercased () == ElCanariPackage_EXTENSION {
        let fullsubpath = inPackageLibraryPath.appendingPathComponent (path)
        checkPackageLibrary (inStackView, atPath: fullsubpath, packageDict: &ioPackageDict)
      }
    }
  }else{
    inStackView.appendInfo ("Directory does not exist")
  }
}

//--------------------------------------------------------------------------------------------------

@MainActor fileprivate func checkPackageLibrary (_ inStackView : MessageStackView,
                                                 packageDict ioPackageDict : inout [String : PackageDictionaryEntry]) {
  for path in existingLibraryPathArray () {
    let packageLibraryPath = packageLibraryPathForPath (path)
    inStackView.appendOpenLibraryDirectoryButton ("Package Library", packageLibraryPath)
    performPackageLibraryEnumeration (inStackView, atPath: packageLibraryPath, packageDict: &ioPackageDict)
  }
//--- Display duplicate entries for symbols, invalid entries
  for (packageName, entry) in ioPackageDict {
    var errorMessageArray = [String] ()
    switch entry.partStatus {
    case .partIsDuplicated :
      errorMessageArray.append ("Several files for '\(packageName)' package")
    case .partHasUnknownStatus :
      errorMessageArray.append ("Package has unknown status")
    case .partHasInvalidName :
      errorMessageArray.append ("Package has an invalid name")
    case .partHasError :
      errorMessageArray.append ("Package has error(s)")
    case .partHasWarning :
      errorMessageArray.append ("Package has warning(s)")
    case .partIsValid :
      ()
    }
    inStackView.appendError (packageName, errorMessageArray, documentPathes: entry.pathArray)
  }
  inStackView.appendMoreErrorsMessage ()
}

//--------------------------------------------------------------------------------------------------
//MARK:   FONT
//--------------------------------------------------------------------------------------------------

fileprivate struct FontDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkFontLibrary (_ inStackView : MessageStackView,
                                     atPath inFontFullPath : String,
                                     fontDict ioFontDict : inout [String : FontDictionaryEntry]) {
    let fontName = ((inFontFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
    if let metadata = try? getFileMetadata (atPath: inFontFullPath) {
      let possibleVersionNumber : Any? = metadata.metadataDictionary [PMFontVersion]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
        let possibleEntry : FontDictionaryEntry? = ioFontDict [fontName]
        if let entry = possibleEntry {
          let newEntry = FontDictionaryEntry (
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
          let newEntry = FontDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: "\(version)",
            pathArray: [inFontFullPath]
          )
          ioFontDict [fontName] = newEntry
        }
      }else{
        inStackView.appendError (
          fontName,
          ["File '\(fontName)' has an invalid format"],
          documentPathes: [inFontFullPath]
        )
      }
    }else{
      inStackView.appendError (
        fontName,
        ["File '\(fontName)' has an invalid format"],
        documentPathes: [inFontFullPath]
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performFontLibraryEnumeration (_ inStackView : MessageStackView,
                                                atPath inFontLibraryPath : String,
                                                fontDict ioFontDict : inout [String : FontDictionaryEntry]) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inFontLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased () == ElCanariFont_EXTENSION {
          let fullsubpath = inFontLibraryPath.appendingPathComponent (path)
          checkFontLibrary (inStackView, atPath: fullsubpath, fontDict: &ioFontDict)
        }
      }
    }else{
      inStackView.appendInfo ("Directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkFontLibrary (_ inStackView : MessageStackView) -> Int {
    var fontDict : [String : FontDictionaryEntry] = [:]
    for path in existingLibraryPathArray () {
      let fontLibraryPath = fontLibraryPathForPath (path)
      inStackView.appendOpenLibraryDirectoryButton ("Font Library", fontLibraryPath)
      performFontLibraryEnumeration (inStackView, atPath: fontLibraryPath, fontDict: &fontDict)
    }
  //--- Display duplicate entries for font, invalid entries
    for (fontName, entry) in fontDict {
      var errorMessageArray : [String] = []
      switch entry.partStatus {
      case .partIsDuplicated :
        errorMessageArray.append ("Several files for '\(fontName)' font")
      case .partHasUnknownStatus :
        errorMessageArray.append ("Font has unknown status")
      case .partHasInvalidName :
        errorMessageArray.append ("Font has an invalid name")
      case .partHasError :
        errorMessageArray.append ("Font has error(s)")
      case .partHasWarning :
        errorMessageArray.append ("Font has warning(s)")
      case .partIsValid :
        ()
      }
      inStackView.appendError (fontName, errorMessageArray, documentPathes: entry.pathArray)
    }
    inStackView.appendMoreErrorsMessage ()
    return fontDict.count
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//MARK:   ARTWORK
//--------------------------------------------------------------------------------------------------

fileprivate struct ArtworkDictionaryEntry {
  let partStatus : PartStatus
  let version : Int
  let versionStringForDialog : String
  let pathArray : [String]
}

//--------------------------------------------------------------------------------------------------

extension Preferences {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkArtworkLibrary (_ inStackView : MessageStackView,
                                        atPath inArtworkFullPath : String,
                                        artworkDict ioArtworkDict : inout [String : ArtworkDictionaryEntry]) {
    let artworkName = ((inArtworkFullPath as NSString).lastPathComponent as NSString).deletingPathExtension
    if let metadata = try? getFileMetadata (atPath: inArtworkFullPath) {
      let possibleVersionNumber : Any? = metadata.metadataDictionary [PMArtworkVersion]
      let version : Int
      if let n = possibleVersionNumber as? NSNumber {
        version = n.intValue
        let possibleEntry : ArtworkDictionaryEntry? = ioArtworkDict [artworkName]
        if let entry = possibleEntry {
          let newEntry = ArtworkDictionaryEntry (
            partStatus: .partIsDuplicated,
            version:0,
            versionStringForDialog: "—",
            pathArray: entry.pathArray + [inArtworkFullPath]
          )
          ioArtworkDict [artworkName] = newEntry
        }else{
          let partStatus : PartStatus = partNameIsValid (artworkName) ? .partIsValid : .partHasInvalidName
          let newEntry = ArtworkDictionaryEntry (
            partStatus: partStatus,
            version: version,
            versionStringForDialog: String (version),
            pathArray: [inArtworkFullPath]
          )
          ioArtworkDict [artworkName] = newEntry
        }
      }else{
        inStackView.appendError (
          artworkName,
          ["File '\(artworkName)' has an invalid format"],
          documentPathes: [inArtworkFullPath]
        )
      }
    }else{
      inStackView.appendError (
        artworkName,
        ["File '\(artworkName)' has an invalid format"],
        documentPathes: [inArtworkFullPath]
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func performArtworkLibraryEnumeration (_ inStackView : MessageStackView,
                                                   atPath inArtworkLibraryPath : String,
                                                   artworkDict ioArtworkDict : inout [String : ArtworkDictionaryEntry]) {
    let fm = FileManager ()
    if let unwSubpaths = fm.subpaths (atPath: inArtworkLibraryPath) {
      for path in unwSubpaths {
        if path.pathExtension.lowercased () == ElCanariArtwork_EXTENSION {
          let fullsubpath = inArtworkLibraryPath.appendingPathComponent (path)
          checkArtworkLibrary (inStackView, atPath: fullsubpath, artworkDict: &ioArtworkDict)
        }
      }
    }else{
      inStackView.appendInfo ("Directory does not exist")
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkArtworkLibrary (_ inStackView : MessageStackView) -> Int {
    var artworkDict : [String : ArtworkDictionaryEntry] = [:]
    for path in existingLibraryPathArray () {
      let artworkLibraryPath = artworkLibraryPathForPath (path)
      inStackView.appendOpenLibraryDirectoryButton ("Arwork Library", artworkLibraryPath)
      performArtworkLibraryEnumeration (inStackView, atPath: artworkLibraryPath, artworkDict: &artworkDict)
    }
  //--- Display duplicate entries for symbols, invalid entries
    for (artworkName, entry) in artworkDict {
      var errorMessageArray = [String] ()
      switch entry.partStatus {
      case .partIsDuplicated :
        errorMessageArray.append ("Several files for '\(artworkName)' artwork")
      case .partHasUnknownStatus :
        errorMessageArray.append ("Artwork has unknown status")
      case .partHasInvalidName :
        errorMessageArray.append ("Artwork has an invalid name")
      case .partHasError :
        errorMessageArray.append ("Artwork has error(s)")
      case .partHasWarning :
        errorMessageArray.append ("Artwork has warning(s)")
      case .partIsValid :
        ()
      }
      inStackView.appendError (artworkName, errorMessageArray, documentPathes: entry.pathArray)
    }
    inStackView.appendMoreErrorsMessage ()
    return artworkDict.count
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
