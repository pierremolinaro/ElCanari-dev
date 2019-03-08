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
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
