//
//  ElCanari
//
//  Created by Pierre Molinaro on 06/04/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutDeviceDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func symbolTypeFromLoadSymbolDialog (_ inData : Data, _ inName : String) -> Bool {
    var ok = false
    let documentReadData = loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: nil)
    switch documentReadData {
    case .ok (let documentData) :
      if let version = documentData.documentMetadataDictionary [PMSymbolVersion] as? Int,
         let symbolRoot = documentData.documentRootObject as? SymbolRoot {
        ok = true
        let strokeBezierPathes = NSBezierPath ()
        let filledBezierPathes = NSBezierPath ()
        var symbolPinTypes = EBReferenceArray <SymbolPinTypeInDevice> ()
        symbolRoot.accumulate (
          withUndoManager: self.undoManager,
          strokeBezierPathes: strokeBezierPathes,
          filledBezierPathes: filledBezierPathes,
          symbolPins: &symbolPinTypes
        )
        let symbolType = SymbolTypeInDevice (self.undoManager)
        symbolType.mVersion = version
        symbolType.mTypeName = inName
        symbolType.mFileData = inData
        symbolType.mStrokeBezierPath = strokeBezierPathes
        symbolType.mFilledBezierPath = filledBezierPathes
        symbolType.mPinTypes = symbolPinTypes
        var pinLocations = [CanariPoint] ()
        for pinType in symbolPinTypes.values {
          pinLocations.append (CanariPoint (x: pinType.mPinX, y: pinType.mPinY))
        }
        let pinsCenter = CanariRect (points: pinLocations).center
        self.rootObject.mSymbolTypes_property.add (symbolType)
        let symbolInstance = SymbolInstanceInDevice (self.undoManager)
        self.rootObject.mSymbolInstances_property.add (symbolInstance)
        symbolInstance.mType = symbolType
        symbolInstance.mX = -pinsCenter.x
        symbolInstance.mY = -pinsCenter.y
      //--- Add pin instances
        for pinType in symbolPinTypes.values {
          let pinInstance = SymbolPinInstanceInDevice (self.undoManager)
          pinInstance.mType = pinType
          symbolInstance.mPinInstances_property.add (pinInstance)
        }
      }
    case .readError (_) :
      ()
    }
    return ok
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func resetSymbolsVersion () {
//    for symbolType in self.rootObject.mSymbolTypes.values {
//      symbolType.mVersion = 0
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func performSymbolsUpdate (_ ioOkMessages : inout [String],
                                   _ ioErrorMessages : inout [String]) {
    let fm = FileManager ()
    for symbolType in self.rootObject.mSymbolTypes.values {
      let pathes = symbolFilePathInLibraries (symbolType.mTypeName)
      if pathes.count == 0 {
        ioErrorMessages.append ("No file in Library for \(symbolType.mTypeName) symbol")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let symbolRoot = documentData.documentRootObject as? SymbolRoot,
               let version = documentData.documentMetadataDictionary [PMSymbolVersion] as? Int {
              if version <= symbolType.mVersion {
                ioOkMessages.append ("Symbol \(symbolType.mTypeName) is up-to-date.")
              }else{
                let strokeBezierPathes = NSBezierPath ()
                let filledBezierPathes = NSBezierPath ()
                var newSymbolPinTypes = EBReferenceArray <SymbolPinTypeInDevice> ()
                symbolRoot.accumulate (
                  withUndoManager: self.undoManager,
                  strokeBezierPathes: strokeBezierPathes,
                  filledBezierPathes: filledBezierPathes,
                  symbolPins: &newSymbolPinTypes
                )
              //--- Check if symbol pin name set is the same
                var currentPinNameSet = Set <String> ()
                for pinType in symbolType.mPinTypes.values {
                  currentPinNameSet.insert (pinType.mName)
                }
                var newPinNameDictionary = [String : SymbolPinTypeInDevice] ()
                for pinType in newSymbolPinTypes.values {
                  newPinNameDictionary [pinType.mName] = pinType
                }
                if currentPinNameSet != Set (newPinNameDictionary.keys) {
                  ioErrorMessages.append ("Cannot update \(symbolType.mTypeName) symbol: pin name set has changed.")
                }else{ // Ok, make update
                //-- Set properties
                  symbolType.mVersion = version
                  symbolType.mFileData = data
                  // Swift.print ("BP \(strokeBezierPathes.elementCount) \(filledBezierPathes.elementCount)")
                  symbolType.mStrokeBezierPath = strokeBezierPathes
                  symbolType.mFilledBezierPath = filledBezierPathes
                //--- Update pin types
                  for pinType : SymbolPinTypeInDevice in symbolType.mPinTypes.values {
                    let newPinType = newPinNameDictionary [pinType.mName]!
                    pinType.mPinX = newPinType.mPinX
                    pinType.mPinY = newPinType.mPinY
                    pinType.mXName = newPinType.mXName
                    pinType.mYName = newPinType.mYName
                    pinType.mName = newPinType.mName
                    pinType.mNameHorizontalAlignment = newPinType.mNameHorizontalAlignment
                    pinType.mPinNameIsDisplayedInSchematics = newPinType.mPinNameIsDisplayedInSchematics
                    pinType.mXNumber = newPinType.mXNumber
                    pinType.mYNumber = newPinType.mYNumber
                    pinType.mNumberHorizontalAlignment = newPinType.mNumberHorizontalAlignment
                 }
                //---
                  ioOkMessages.append ("Symbol \(symbolType.mTypeName) has been updated to version \(version).")
                }
              }
            }else{
              ioErrorMessages.append ("Invalid file at path \(pathes [0])")
            }
          case .readError (_) :
            ioErrorMessages.append ("Invalid file at path \(pathes [0])")
          }
        }else{
          ioErrorMessages.append ("Invalid file at path \(pathes [0])")
        }
      }else{ // pathes.count > 1
        ioErrorMessages.append ("Cannot update, several files in Library for \(symbolType.mTypeName) symbol:")
        for path in pathes {
          ioErrorMessages.append ("  - \(path)")
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func packageFromLoadPackageDialog (_ inData : Data, _ inName : String) -> Bool {
    var ok = false
    let documentReadData = loadEasyBindingFile (fromData: inData, documentName: inName, undoManager: nil)
    switch documentReadData {
    case .ok (let documentData) :
      if let version = documentData.documentMetadataDictionary [PMPackageVersion] as? Int,
         let packageRoot = documentData.documentRootObject as? PackageRoot {
        ok = true
        var strokeBezierPathes = EBBezierPath ()
        var masterPads = EBReferenceArray <MasterPadInDevice> ()
        packageRoot.accumulate (
          withUndoManager: self.undoManager,
          strokeBezierPathes: &strokeBezierPathes,
          masterPads: &masterPads
        )

        var masterPadsLocations = [CanariPoint] ()
        for masterPad in masterPads.values {
          masterPadsLocations.append (CanariPoint (x: masterPad.mCenterX, y: masterPad.mCenterY))
        }
        let masterPadsCenter = CanariRect (points: masterPadsLocations).center

        let package = PackageInDevice (self.undoManager)
        package.mX = -masterPadsCenter.x
        package.mY = -masterPadsCenter.y
        package.mVersion = version
        package.mName = inName
        package.mFileData = inData
        package.mStrokeBezierPath = strokeBezierPathes.nsBezierPath
        package.mMasterPads = masterPads
        self.rootObject.mPackages_property.add (package)
        self.rootObject.updatePadProxies ()
      }
    case .readError (_) :
      ()
    }
    return ok
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func resetPackagesVersion () {
//    for package in self.rootObject.mPackages.values {
//      package.mVersion = 0
//    }
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func performPackagesUpdate (_ inPackages : EBReferenceArray <PackageInDevice>,
                                    _ ioOkMessages : inout [String],
                                    _ ioErrorMessages : inout [String]) {
//--- START OF USER ZONE 2
    let fm = FileManager ()
    for package in inPackages.values {
      let pathes = packageFilePathInLibraries (package.mName)
      if pathes.count == 0 {
        ioErrorMessages.append ("No file in Library for package \(package.mName)")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]) {
          let documentReadData = loadEasyBindingFile (fromData: data, documentName: pathes [0].lastPathComponent, undoManager: nil)
          switch documentReadData {
          case .ok (let documentData) :
            if let packageRoot = documentData.documentRootObject as? PackageRoot,
              let version = documentData.documentMetadataDictionary [PMPackageVersion] as? Int {
              if version <= package.mVersion {
                ioOkMessages.append ("Package \(package.mName) is up-to-date.")
              }else{
                var strokeBezierPathes = EBBezierPath ()
                var masterPads = EBReferenceArray <MasterPadInDevice> ()
                packageRoot.accumulate (
                  withUndoManager: self.undoManager,
                  strokeBezierPathes: &strokeBezierPathes,
                  masterPads: &masterPads
                )
              //-- Set properties
                package.mVersion = version
                package.mFileData = data
                package.mStrokeBezierPath = strokeBezierPathes.nsBezierPath
                package.mMasterPads_property.setProp (masterPads)
              //---
                ioOkMessages.append ("Package \(package.mName) has been updated to version \(version).")
              }
            }else{
              ioErrorMessages.append ("Invalid file at path \(pathes [0])")
            }
          case .readError (_) :
            ioErrorMessages.append ("Invalid file at path \(pathes [0])")
          }
        }else{
          ioErrorMessages.append ("Invalid file at path \(pathes [0])")
        }
      }else{ // pathes.count > 1
        ioErrorMessages.append ("Cannot update, several files in Library for package \(package.mName):")
        for path in pathes {
          ioErrorMessages.append ("  - \(path)")
        }
      }
    }
    self.rootObject.updatePadProxies ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
