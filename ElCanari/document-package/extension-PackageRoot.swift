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
        masterPad.mCenterX = packageMasterPad.xCenter
        masterPad.mCenterY = packageMasterPad.yCenter
        masterPad.mWidth = packageMasterPad.width
        masterPad.mHeight = packageMasterPad.height
        masterPad.mHoleDiameter = packageMasterPad.holeDiameter
        masterPad.mShape = packageMasterPad.padShape
        masterPad.mStyle = packageMasterPad.padStyle
        masterPad.mName = packageMasterPad.padName!
        masterPads.append (masterPad)
        masterPadDictionary [packageMasterPad] = masterPad
      }
    }
  //--- Handle slave pads
    for object in self.packageObjects_property.propval {
      if let packageSlavePad = object as? PackageSlavePad {
        let slavePad = SlavePadInDevice (inUndoManager)
        slavePad.mCenterX = packageSlavePad.xCenter
        slavePad.mCenterY = packageSlavePad.yCenter
        slavePad.mWidth = packageSlavePad.width
        slavePad.mHeight = packageSlavePad.height
        slavePad.mHoleDiameter = packageSlavePad.holeDiameter
        slavePad.mShape = packageSlavePad.padShape
        slavePad.mStyle = packageSlavePad.padStyle
        let masterPad = masterPadDictionary [packageSlavePad.master_property.propval!]!
        slavePad.mMasterPad_property.setProp (masterPad)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
