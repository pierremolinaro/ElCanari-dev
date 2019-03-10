//
//  extension-PackageRoot.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/03/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackageRoot {

  //····················································································································

  func accumulate (withUndoManager inUndoManager : EBUndoManager,
                   strokeBezierPathes : NSBezierPath,
                   masterPads : inout [MasterPadInDevice]) {
    var masterPadDictionary = [PackagePad : MasterPadInDevice] ()
    for object in self.packageObjects_property.propval {
      if let segment = object as? PackageSegment, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageBezier, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageOval, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageArc, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let packageMasterPad = object as? PackagePad {
        let masterPad = MasterPadInDevice (inUndoManager)
        masterPad.xCenter = packageMasterPad.xCenter
        masterPad.yCenter = packageMasterPad.yCenter
        masterPad.width = packageMasterPad.width
        masterPad.height = packageMasterPad.height
        masterPad.holeDiameter = packageMasterPad.holeDiameter
        masterPad.padShape = packageMasterPad.padShape
        masterPad.padStyle = packageMasterPad.padStyle
        masterPad.padName = packageMasterPad.padName!
        masterPads.append (masterPad)
        masterPadDictionary [packageMasterPad] = masterPad
      }
    }
  //--- Handle slave pads
    for object in self.packageObjects_property.propval {
      if let packageSlavePad = object as? PackageSlavePad {
        let slavePad = SlavePadInDevice (inUndoManager)
        slavePad.xCenter = packageSlavePad.xCenter
        slavePad.yCenter = packageSlavePad.yCenter
        slavePad.width = packageSlavePad.width
        slavePad.height = packageSlavePad.height
        slavePad.holeDiameter = packageSlavePad.holeDiameter
        slavePad.padShape = packageSlavePad.padShape
        slavePad.padStyle = packageSlavePad.padStyle
        let masterPad = masterPadDictionary [packageSlavePad.master_property.propval!]!
        slavePad.mMasterPad_property.setProp (masterPad)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
