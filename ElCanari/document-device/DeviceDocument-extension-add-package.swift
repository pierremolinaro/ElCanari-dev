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
      let package = PackageInDevice (self.ebUndoManager, file: #file, #line)
      package.mVersion = version
      package.mName = inName
      package.mFileData = inData
      let strokeBezierPathes = NSBezierPath ()
      var pads = [PackagePad] ()
      var slavePads = [PackageSlavePad] ()
      packageRoot.accumulate (
        strokeBezierPathes: strokeBezierPathes,
        pads: &pads,
        slavePads: &slavePads
      )
      package.mStrokeBezierPath = strokeBezierPathes
      package.mPads_property.setProp (pads)
      package.mSlavePads_property.setProp (slavePads)
      self.rootObject.packages_property.add (package)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
