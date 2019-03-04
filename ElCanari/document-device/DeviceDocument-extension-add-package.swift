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

      let package = PackageInDevice (self.ebUndoManager, file: #file, #line)
      package.mVersion = version
      package.mName = inName
      package.mFileData = inData
      package.mStrokeBezierPath = strokeBezierPathes
      package.mMasterPads_property.setProp (masterPads)
      package.mSlavePads_property.setProp (slavePads)
      self.rootObject.packages_property.add (package)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
