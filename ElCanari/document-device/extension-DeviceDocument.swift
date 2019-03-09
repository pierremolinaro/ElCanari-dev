//
//  DeviceDocument-extension-add-package.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension DeviceDocument {

  //····················································································································

  internal func symbolTypeFromLoadSymbolDialog (_ inData : Data, _ inName : String) {
    if let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: inData),
       let version = metadataDictionary [PMSymbolVersion] as? Int,
       let symbolRoot = rootObject as? SymbolRoot {
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
      symbolType.mPinTypes_property.setProp (symbolPinTypes)
      self.rootObject.mSymbolTypes_property.add (symbolType)
      let symbolInstance = SymbolInstanceInDevice (self.ebUndoManager)
      self.rootObject.mSymbolInstances_property.add (symbolInstance)
      symbolInstance.mType_property.setProp (symbolType)
    //--- Add pin instances
      for pinType in symbolPinTypes {
        let pinInstance = SymbolPinInstanceInDevice (self.ebUndoManager)
        pinInstance.mType_property.setProp (pinType)
        symbolInstance.mPinInstances_property.add (pinInstance)
      }
    }
  }

  //····················································································································

  internal func performSymbolsUpdate (_ inSymbol : [SymbolTypeInDevice], _ ioMessages : inout [String]) {
    let fm = FileManager ()
    for symbolType in inSymbol {
      let pathes = symbolFilePathInLibraries (symbolType.mTypeName)
      if pathes.count == 0 {
        ioMessages.append ("No file in Library for \(symbolType.mTypeName) symbol")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]),
           let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: data),
           let symbolRoot = rootObject as? SymbolRoot,
           let version = metadataDictionary [PMSymbolVersion] as? Int {
          if version <= symbolType.mVersion {
            ioMessages.append ("Symbol \(symbolType.mTypeName) is up-to-date.")
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
            symbolRoot.removeRecursivelyAllRelationsShips ()
          //--- Check if symbol pin name set is the same
            var currentPinNameSet = Set <String> ()
            for pinType in symbolType.mPinTypes_property.propval {
              currentPinNameSet.insert (pinType.mName)
            }
            var newPinNameDictionary = [String : SymbolPinTypeInDevice] ()
            for pinType in newSymbolPinTypes {
              newPinNameDictionary [pinType.mName] = pinType
            }
            if currentPinNameSet != Set (newPinNameDictionary.keys) {
              ioMessages.append ("Cannot update \(symbolType.mTypeName) symbol: pin name set has changed.")
            }else{ // Ok, make update
            //-- Set properties
              symbolType.mVersion = version
              symbolType.mFileData = data
              symbolType.mStrokeBezierPath = strokeBezierPathes
              symbolType.mFilledBezierPath = filledBezierPathes
            //--- Update pin types
              for pinType in symbolType.mPinTypes_property.propval {
                let newPinType = newPinNameDictionary [pinType.mName]!
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
              ioMessages.append ("Symbol \(symbolType.mTypeName) has been updated to version \(version).")
            }
          }
        }else{
          ioMessages.append ("Invalid file at path \(pathes [0])")
        }
      }else{ // pathes.count > 1
        ioMessages.append ("Cannot update, several files in Library for \(symbolType.mTypeName) symbol:")
        for path in pathes {
          ioMessages.append ("  - \(path)")
        }
      }
    }
  }

  //····················································································································

  internal func packageFromLoadPackageDialog (_ inData : Data, _ inName : String) {
    if let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: inData),
       let version = metadataDictionary [PMPackageVersion] as? Int,
       let packageRoot = rootObject as? PackageRoot {
      let strokeBezierPathes = NSBezierPath ()
      var masterPads = [MasterPadInDevice] ()
      var slavePads = [SlavePadInDevice] ()
      packageRoot.accumulate (
        withUndoManager: self.ebUndoManager,
        strokeBezierPathes: strokeBezierPathes,
        masterPads: &masterPads,
        slavePads: &slavePads
      )
      packageRoot.removeRecursivelyAllRelationsShips ()

      let package = PackageInDevice (self.ebUndoManager)
      package.mVersion = version
      package.mName = inName
      package.mFileData = inData
      package.mStrokeBezierPath = strokeBezierPathes
      package.mMasterPads_property.setProp (masterPads)
      package.mSlavePads_property.setProp (slavePads)
      self.rootObject.mPackages_property.add (package)
      self.updatePadProxies ()
    }
  }

  //····················································································································

  internal func performPackagesUpdate (_ inPackages : [PackageInDevice], _ ioMessages : inout [String]) {
//--- START OF USER ZONE 2
    let fm = FileManager ()
    for package in inPackages {
      let pathes = packageFilePathInLibraries (package.mName)
      if pathes.count == 0 {
        ioMessages.append ("No file in Library for package \(package.mName)")
      }else if pathes.count == 1 {
        if let data = fm.contents (atPath: pathes [0]),
           let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (nil, from: data),
           let packageRoot = rootObject as? PackageRoot,
           let version = metadataDictionary [PMPackageVersion] as? Int {
          if version <= package.mVersion {
            ioMessages.append ("Package \(package.mName) is up-to-date.")
          }else{
            let strokeBezierPathes = NSBezierPath ()
            var masterPads = [MasterPadInDevice] ()
            var slavePads = [SlavePadInDevice] ()
            packageRoot.accumulate (
              withUndoManager: self.ebUndoManager,
              strokeBezierPathes: strokeBezierPathes,
              masterPads: &masterPads,
              slavePads: &slavePads
            )
            packageRoot.removeRecursivelyAllRelationsShips ()
          //-- Set properties
            package.mVersion = version
            package.mFileData = data
            package.mStrokeBezierPath = strokeBezierPathes
          //--- Set relationship
            package.mMasterPads_property.setProp (masterPads)
            package.mSlavePads_property.setProp (slavePads)
          //---
            ioMessages.append ("Package \(package.mName) has been updated to version \(version).")
          }
        }else{
          ioMessages.append ("Invalid file at path \(pathes [0])")
        }
      }else{ // pathes.count > 1
        ioMessages.append ("Cannot update, several files in Library for package \(package.mName):")
        for path in pathes {
          ioMessages.append ("  - \(path)")
        }
      }
    }
    self.updatePadProxies ()
  }

  //····················································································································

  func updatePadProxies () {
  //--- Inventory of current pad names
    var currentPackagePadNameSet = Set <String> ()
    for package in self.rootObject.mPackages_property.propval {
      for masterPad in package.mMasterPads_property.propval {
        currentPackagePadNameSet.insert (masterPad.padName)
      }
    }
  //--- Inventory of current pad proxies
    var currentProxyPadNameSet = Set <String> ()
    var padProxyDictionary = [String : PadProxyInDevice] ()
    for padProxy in self.rootObject.mPadProxies_property.propval {
      padProxyDictionary [padProxy.mQualifiedPadName] = padProxy
      currentProxyPadNameSet.insert (padProxy.mQualifiedPadName)
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
      newPadProxy.mQualifiedPadName = padName
      self.rootObject.mPadProxies_property.add (newPadProxy)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
