//
//  ElCanari
//
//  Created by Pierre Molinaro on 06/04/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

extension DeviceDocument {

  //····················································································································

  internal func symbolTypeFromLoadSymbolDialog (_ inData : Data, _ inName : String) {
    if let documentData = try? loadEasyBindingFile (fromData: inData, undoManager: nil),
       let version = documentData.documentMetadataDictionary [PMSymbolVersion] as? Int,
       let symbolRoot = documentData.documentRootObject as? SymbolRoot {
      let strokeBezierPathes = NSBezierPath ()
      let filledBezierPathes = NSBezierPath ()
      var symbolPinTypes = [SymbolPinTypeInDevice] ()
      symbolRoot.accumulate (
        withUndoManager: self.ebUndoManager,
        strokeBezierPathes: strokeBezierPathes,
        filledBezierPathes: filledBezierPathes,
        symbolPins: &symbolPinTypes
      )
      symbolRoot.removeRecursivelyAllRelationsShips ()

      let symbolType = SymbolTypeInDevice (self.ebUndoManager)
      symbolType.mVersion = version
      symbolType.mTypeName = inName
      symbolType.mFileData = inData
      symbolType.mStrokeBezierPath = strokeBezierPathes
      symbolType.mFilledBezierPath = filledBezierPathes
      symbolType.mPinTypes = symbolPinTypes
      var pinLocations = [CanariPoint] ()
      for pinType in symbolPinTypes {
        pinLocations.append (CanariPoint (x: pinType.mPinX, y: pinType.mPinY))
      }
      let pinsCenter = CanariRect (points: pinLocations).center
      self.rootObject.mSymbolTypes_property.add (symbolType)
      let symbolInstance = SymbolInstanceInDevice (self.ebUndoManager)
      self.rootObject.mSymbolInstances_property.add (symbolInstance)
      symbolInstance.mType = symbolType
      symbolInstance.mX = -pinsCenter.x
      symbolInstance.mY = -pinsCenter.y
    //--- Add pin instances
      for pinType in symbolPinTypes {
        let pinInstance = SymbolPinInstanceInDevice (self.ebUndoManager)
        pinInstance.mType = pinType
        symbolInstance.mPinInstances_property.add (pinInstance)
      }
    }
  }

  //····················································································································

  internal func resetSymbolsVersion () {
    for symbolType in self.rootObject.mSymbolTypes {
      symbolType.mVersion = 0
    }
  }

  //····················································································································

  internal func performSymbolsUpdate (_ ioOkMessages : inout [String],
                                      _ ioErrorMessages : inout [String]) {
    let fm = FileManager ()
    for symbolType in self.rootObject.mSymbolTypes {
      let pathes = symbolFilePathInLibraries (symbolType.mTypeName)
      if pathes.count == 0 {
        ioErrorMessages.append ("No file in Library for \(symbolType.mTypeName) symbol")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]),
           let documentData = try? loadEasyBindingFile (fromData: data, undoManager: nil),
           let symbolRoot = documentData.documentRootObject as? SymbolRoot,
           let version = documentData.documentMetadataDictionary [PMSymbolVersion] as? Int {
          if version <= symbolType.mVersion {
            ioOkMessages.append ("Symbol \(symbolType.mTypeName) is up-to-date.")
          }else{
            let strokeBezierPathes = NSBezierPath ()
            let filledBezierPathes = NSBezierPath ()
            var newSymbolPinTypes = [SymbolPinTypeInDevice] ()
            symbolRoot.accumulate (
              withUndoManager: self.ebUndoManager,
              strokeBezierPathes: strokeBezierPathes,
              filledBezierPathes: filledBezierPathes,
              symbolPins: &newSymbolPinTypes
            )
          //--- Check if symbol pin name set is the same
            var currentPinNameSet = Set <String> ()
            for pinType in symbolType.mPinTypes {
              currentPinNameSet.insert (pinType.mName)
            }
            var newPinNameDictionary = [String : SymbolPinTypeInDevice] ()
            for pinType in newSymbolPinTypes {
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
              for pinType : SymbolPinTypeInDevice in symbolType.mPinTypes {
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
          symbolRoot.removeRecursivelyAllRelationsShips ()
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

  //····················································································································

  internal func packageFromLoadPackageDialog (_ inData : Data, _ inName : String) {
    if let documentData = try? loadEasyBindingFile (fromData: inData, undoManager: nil),
       let version = documentData.documentMetadataDictionary [PMPackageVersion] as? Int,
       let packageRoot = documentData.documentRootObject as? PackageRoot {
      var strokeBezierPathes = EBBezierPath ()
      var masterPads = [MasterPadInDevice] ()
      packageRoot.accumulate (
        withUndoManager: self.ebUndoManager,
        strokeBezierPathes: &strokeBezierPathes,
        masterPads: &masterPads
      )
      packageRoot.removeRecursivelyAllRelationsShips ()

      var masterPadsLocations = [CanariPoint] ()
      for masterPad in masterPads {
        masterPadsLocations.append (CanariPoint (x: masterPad.mCenterX, y: masterPad.mCenterY))
      }
      let masterPadsCenter = CanariRect (points: masterPadsLocations).center

      let package = PackageInDevice (self.ebUndoManager)
      package.mX = -masterPadsCenter.x
      package.mY = -masterPadsCenter.y
      package.mVersion = version
      package.mName = inName
      package.mFileData = inData
      package.mStrokeBezierPath = strokeBezierPathes.nsBezierPath
      package.mMasterPads = masterPads
      self.rootObject.mPackages_property.add (package)
      self.updatePadProxies ()
    }
  }

  //····················································································································

  internal func resetPackagesVersion () {
    for package in self.rootObject.mPackages {
      package.mVersion = 0
    }
  }

  //····················································································································

  internal func performPackagesUpdate (_ inPackages : [PackageInDevice],
                                       _ ioOkMessages : inout [String],
                                       _ ioErrorMessages : inout [String]) {
//--- START OF USER ZONE 2
    let fm = FileManager ()
    for package in inPackages {
      let pathes = packageFilePathInLibraries (package.mName)
      if pathes.count == 0 {
        ioErrorMessages.append ("No file in Library for package \(package.mName)")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]),
          let documentData = try? loadEasyBindingFile (fromData: data, undoManager: nil),
           let packageRoot = documentData.documentRootObject as? PackageRoot,
           let version = documentData.documentMetadataDictionary [PMPackageVersion] as? Int {
          if version <= package.mVersion {
            ioOkMessages.append ("Package \(package.mName) is up-to-date.")
          }else{
            var strokeBezierPathes = EBBezierPath ()
            var masterPads = [MasterPadInDevice] ()
            packageRoot.accumulate (
              withUndoManager: self.ebUndoManager,
              strokeBezierPathes: &strokeBezierPathes,
              masterPads: &masterPads
            )
          //-- Set properties
            package.mVersion = version
            package.mFileData = data
            package.mStrokeBezierPath = strokeBezierPathes.nsBezierPath
          //--- Set relationship
            let oldMasterPads = package.mMasterPads_property.propval
            package.mMasterPads_property.setProp (masterPads)
            for oldMasterPad in oldMasterPads {
              oldMasterPad.removeRecursivelyAllRelationsShips ()
            }
          //---
            ioOkMessages.append ("Package \(package.mName) has been updated to version \(version).")
          }
          packageRoot.removeRecursivelyAllRelationsShips ()
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
    self.updatePadProxies ()
  }

  //····················································································································

  func updatePadProxies () {
  //--- Inventory of current pad names
    var currentPackagePadNameSet = Set <String> ()
    for package in self.rootObject.mPackages {
      for masterPad in package.mMasterPads {
        currentPackagePadNameSet.insert (masterPad.mName)
      }
    }
  //--- Inventory of current pad proxies
    var currentProxyPadNameSet = Set <String> ()
    var padProxyDictionary = [String : PadProxyInDevice] ()
    for padProxy in self.rootObject.mPadProxies {
      padProxyDictionary [padProxy.mPadName] = padProxy
      currentProxyPadNameSet.insert (padProxy.mPadName)
    }
  //--- Remove pad proxies without corresponding pad
    for padName in currentProxyPadNameSet.subtracting (currentPackagePadNameSet) {
      let padProxy = padProxyDictionary [padName]!
      padProxy.cleanUpRelationshipsAndRemoveAllObservers ()
      self.rootObject.mPadProxies_property.remove (padProxy)
    }
  //--- Add missing pad proxies
    for padName in currentPackagePadNameSet.subtracting (currentProxyPadNameSet) {
      let newPadProxy = PadProxyInDevice (self.ebUndoManager)
      newPadProxy.mPadName = padName
      self.rootObject.mPadProxies_property.add (newPadProxy)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
