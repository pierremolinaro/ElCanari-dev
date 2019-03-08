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
                   masterPads : inout [MasterPadInDevice],
                   slavePads : inout [SlavePadInDevice]) {
    for object in self.packageObjects_property.propval {
      if let segment = object as? PackageSegment, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageBezier, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageOval, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageArc, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let packagePad = object as? PackagePad {
        let pad = MasterPadInDevice (inUndoManager)
        pad.xCenter = packagePad.xCenter
        pad.yCenter = packagePad.yCenter
        pad.width = packagePad.width
        pad.height = packagePad.height
        pad.holeDiameter = packagePad.holeDiameter
        pad.padShape = packagePad.padShape
        pad.padStyle = packagePad.padStyle
        pad.padName = packagePad.padName!
        masterPads.append (pad)
      }else if let packagePad = object as? PackageSlavePad {
        let pad = SlavePadInDevice (inUndoManager)
        pad.xCenter = packagePad.xCenter
        pad.yCenter = packagePad.yCenter
        pad.width = packagePad.width
        pad.height = packagePad.height
        pad.holeDiameter = packagePad.holeDiameter
        pad.padShape = packagePad.padShape
        pad.padStyle = packagePad.padStyle
        pad.padName = packagePad.padName!
        slavePads.append (pad)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
