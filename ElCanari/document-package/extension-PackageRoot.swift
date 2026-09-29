//
//  extension-PackageRoot.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 02/03/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension PackageRoot {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func accumulate (withUndoManager inUndoManager : UndoManager?,
                   strokeBezierPathes : inout BezierPath,
                   masterPads : inout EBReferenceArray <MasterPadInDevice>) {
    var masterPadDictionary = EBReferenceDictionary <PackagePad, MasterPadInDevice> ()
    for object in self.packageObjects_property.propval.values {
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
        masterPad.mCenterX = packageMasterPad.xCenter.cuValue
        masterPad.mCenterY = packageMasterPad.yCenter.cuValue
        masterPad.mWidth = packageMasterPad.width.cuValue
        masterPad.mHeight = packageMasterPad.height.cuValue
        masterPad.mHoleWidth = packageMasterPad.holeWidth.cuValue
        masterPad.mHoleHeight = packageMasterPad.holeHeight.cuValue
        masterPad.mShape = packageMasterPad.padShape
        masterPad.mStyle = packageMasterPad.padStyle
        masterPad.mName = packageMasterPad.padNameWithZoneName!
        masterPads.append (masterPad)
        masterPadDictionary [packageMasterPad] = masterPad
      }
    }
  //--- Handle slave pads
    for object in self.packageObjects.values {
      if let packageSlavePad = object as? PackageSlavePad {
        let slavePad = SlavePadInDevice (inUndoManager)
        slavePad.mCenterX = packageSlavePad.xCenter.cuValue
        slavePad.mCenterY = packageSlavePad.yCenter.cuValue
        slavePad.mWidth = packageSlavePad.width.cuValue
        slavePad.mHeight = packageSlavePad.height.cuValue
        slavePad.mHoleWidth = packageSlavePad.holeWidth.cuValue
        slavePad.mHoleHeight = packageSlavePad.holeHeight.cuValue
        slavePad.mShape = packageSlavePad.padShape
        slavePad.mStyle = packageSlavePad.padStyle
        let masterPad = masterPadDictionary [packageSlavePad.master_property.propval!]!
        slavePad.mMasterPad_property.setProp (masterPad)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
}

//--------------------------------------------------------------------------------------------------
