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
    if let (_, metadataDictionary, rootObject) = try? loadEasyBindingFile (self.ebUndoManager, from: inData),
       let version = metadataDictionary [PMPackageVersion] as? Int,
       let packageRoot = rootObject as? PackageRoot {
      let package = PackageInDevice (self.ebUndoManager, file: #file, #line)
      package.mVersion = version
      package.mName = inName
      package.mFileData = inData
      let strokeBezierPathes = NSBezierPath ()
      var masterPads = [PackagePad] ()
      var slavePads = [PackageSlavePad] ()
      var zones = [PackageZone] ()
      packageRoot.accumulate (
        strokeBezierPathes: strokeBezierPathes,
        masterPads: &masterPads,
        zones: &zones,
        slavePads: &slavePads
      )
      package.mStrokeBezierPath = strokeBezierPathes
      package.mPads_property.setProp (masterPads)
      package.mSlavePads_property.setProp (slavePads)
      package.mZones_property.setProp (zones)
      self.rootObject.packages_property.add (package)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
