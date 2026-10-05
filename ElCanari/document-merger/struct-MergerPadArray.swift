//
//  MergerPad.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/06/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------
//   MergerPad
//--------------------------------------------------------------------------------------------------

struct MergerPad : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let x : CanariLength
  let y : CanariLength
  let width : CanariLength
  let height : CanariLength
  let shape : PadShape
  let rotation : CanariAngle

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   MergerPadArray
//--------------------------------------------------------------------------------------------------

struct MergerPadArray : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let padArray : [MergerPad]

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func buildBezierPaths () -> BezierPathArray {
    var result = BezierPathArray ()
    for pad in self.padArray {
      let width = pad.width
      let height = pad.height
      let r = CanariRect (left: -width / 2.0, bottom: -height / 2.0, width:width, height:height)
      var bp : BezierPath
      switch pad.shape {
      case .rect :
        bp = BezierPath (rect:r)
      case .round :
        if pad.width < pad.height {
          bp = BezierPath (roundedRect: r, xRadius:width / 2.0, yRadius:width / 2.0)
        }else if pad.width > pad.height {
          bp = BezierPath (roundedRect: r, xRadius:height / 2.0, yRadius:height / 2.0)
        }else{
          bp = BezierPath (ovalIn:r)
        }
      case .octo :
        bp = BezierPath (octogonInRect: r)
      }
      let transform = CanariAffinity.translating (x: pad.x, y: pad.y).rotating (by: pad.rotation)
      bp.transform (using: transform)
      result.append (bp)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addPads (toFilledBezierPaths ioBezierPaths : inout [BezierPath],
                dx inDx : CanariLength,
                dy inDy: CanariLength,
                horizontalMirror inHorizontalMirror : Bool,
                boardWidth inBoardWidth : CanariLength,
                modelWidth inModelWidth : CanariLength,
                modelHeight inModelHeight : CanariLength,
                instanceRotation inInstanceRotation : QuadrantRotation) {
   //  Swift.print ("PDF : \(self.padArray.count)")
    for pad in self.padArray {
      var x = inDx
      var y = inDy
      switch inInstanceRotation {
      case .rotation0 :
        x += pad.x
        y += pad.y
      case .rotation90 :
        x += inModelHeight - pad.y
        y += pad.x
      case .rotation180 :
        x += inModelWidth  - pad.x
        y += inModelHeight - pad.y
      case .rotation270 :
        x += pad.y
        y += inModelWidth - pad.x
      }
      let xf = (inHorizontalMirror ? (inBoardWidth - x) : x)
      let yf = y
      let width = pad.width
      let height = pad.height
      let r = CanariRect (left: -width / 2.0, bottom: -height / 2.0, width:width, height:height)
      var transform = CanariAffinity.translating (x: xf, y:yf)
      if inHorizontalMirror {
        transform.scale (x: -1.0, y: 1.0)
      }
      transform.rotate (by: pad.rotation + .degree (Double (inInstanceRotation.rawValue) * 90.0))
      var bp : BezierPath
      switch pad.shape {
      case .rect :
        bp = BezierPath (rect: r)
      case .round :
        if pad.width < pad.height {
          bp = BezierPath (roundedRect:r, xRadius:width / 2.0, yRadius:width / 2.0)
        }else if pad.width > pad.height {
          bp = BezierPath (roundedRect:r, xRadius:height / 2.0, yRadius:height / 2.0)
        }else{
          bp = BezierPath (ovalIn: r)
        }
      case .octo :
        bp = BezierPath (octogonInRect: r)
      }
      ioBezierPaths.append (bp.transformed (by: transform))
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
