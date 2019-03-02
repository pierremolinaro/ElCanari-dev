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

  func accumulate (strokeBezierPathes : NSBezierPath,
                   topSidePadFilledBezierPathes : NSBezierPath,
                   backSidePadFilledBezierPathes : NSBezierPath) {
    for object in self.packageObjects_property.propval {
      if let segment = object as? PackageSegment, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageBezier, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageOval, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let segment = object as? PackageArc, let bp = segment.strokeBezierPath {
        strokeBezierPathes.append (bp)
      }else if let pad = object as? PackagePad, let bpTop = pad.topSideFilledBezierPath, let bpBack = pad.backSideFilledBezierPath {
        topSidePadFilledBezierPathes.append (bpTop)
        backSidePadFilledBezierPathes.append (bpBack)
      }else if let pad = object as? PackageSlavePad, let bpTop = pad.topSideFilledBezierPath, let bpBack = pad.backSideFilledBezierPath {
        topSidePadFilledBezierPathes.append (bpTop)
        backSidePadFilledBezierPathes.append (bpBack)
      }

    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
