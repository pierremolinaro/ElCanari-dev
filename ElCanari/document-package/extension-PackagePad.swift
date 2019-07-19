//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let VERY_LARGE_PAD_NUMBER = 1_000_000

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION PackagePad
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension PackagePad {

  //····················································································································

  override func acceptToTranslate (xBy inDx: Int, yBy inDy: Int) -> Bool {
    return true
  }

  //····················································································································

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : OCObjectSet) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int) -> OCCanariPoint {
    return OCCanariPoint (x: inDx, y: inDy)
 }

  //····················································································································

  override func move (knob inKnobIndex : Int, xBy inDx: Int, yBy inDy: Int, newX inNewX : Int, newY inNewY : Int) {
  }

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································

  override func operationAfterPasting () {
    self.padNumber += VERY_LARGE_PAD_NUMBER // So it will be numbered by model observer CustomizedPackageDocument:handlePadNumbering
  }

  //····················································································································
  //  SNAP TO GRID
  //····················································································································

  override func canSnapToGrid (_ inGrid : Int) -> Bool {
    var result = (self.xCenter % inGrid) != 0
    if !result {
      result = (self.yCenter % inGrid) != 0
    }
    return result
  }

  //····················································································································

  override func snapToGrid (_ inGrid : Int) {
    self.xCenter = ((self.xCenter + inGrid / 2) / inGrid) * inGrid
    self.yCenter = ((self.yCenter + inGrid / 2) / inGrid) * inGrid
  }

  //····················································································································

  override func alignmentPoints () -> OCCanariPointSet {
    let result = OCCanariPointSet ()
    result.points.insert (CanariPoint (x: self.xCenter, y: self.yCenter))
    return result
  }

  //····················································································································
  //
  //····················································································································

  func angle (from inCanariPoint : CanariPoint) -> CGFloat {
    return CanariPoint.angleInRadian (CanariPoint (x: self.xCenter, y: self.yCenter), inCanariPoint)
  }

  //····················································································································
  //  Can be deleted
  //····················································································································

  override func canBeDeleted () -> Bool {
    return self.slaves_property.propval.count == 0
  }

  //····················································································································

  override func program () -> String {
    var s = "pad "
    s += stringFrom (valueInCanariUnit: self.xCenter, displayUnit : self.xCenterUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.yCenter, displayUnit : self.yCenterUnit)
    s += " size "
    s += stringFrom (valueInCanariUnit: self.width, displayUnit : self.widthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.height, displayUnit : self.heightUnit)
    s += " shape "
    s += self.padShape.descriptionForExplorer ()
    s += " style "
    s += self.padStyle.descriptionForExplorer ()
    s += " hole "
    s += stringFrom (valueInCanariUnit: self.holeWidth, displayUnit : self.holeWidthUnit)
    s += " : "
    s += stringFrom (valueInCanariUnit: self.holeHeight, displayUnit : self.holeHeightUnit)
    s += " number "
    s += "\(self.padNumber)"
    if self.slaves.count > 0 {
      s += " id "
      s += "\(self.ebObjectIndex)"
    }
    s += ";\n"
    return s
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBBezierPath {

  //····················································································································

  static func pad (centerX inCenterX : Int,
                   centerY inCenterY : Int,
                   width inWidth : Int,
                   height inHeight : Int,
                   shape inShape : PadShape) -> EBBezierPath {
    let center = CanariPoint (x: inCenterX, y: inCenterY).cocoaPoint
    let size = CanariSize (width: inWidth, height: inHeight).cocoaSize
    let r = NSRect (center: center, size: size)
    switch inShape {
    case .rect :
      return EBBezierPath (rect: r)
    case .round :
      return EBBezierPath (oblongInRect: r)
    case .octo :
      return EBBezierPath (octogonInRect: r)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class PadGeometryForERC {
  let circles : [GeometricCircle]
  let rectangles : [GeometricRect]

//····················································································································

  init (centerX inCenterX : Int,
        centerY inCenterY : Int,
        width inWidth : Int,
        height inHeight : Int,
        shape inShape : PadShape) {
    let center = CanariPoint (x: inCenterX, y: inCenterY).cocoaPoint
    let size = CanariSize (width: inWidth, height: inHeight).cocoaSize
    var c = [GeometricCircle] ()
    var rects = [GeometricRect] ()
    switch inShape {
    case .rect :
      let p1 = NSPoint (x: center.x, y: center.y + size.height / 2.0)
      let p2 = NSPoint (x: center.x, y: center.y - size.height / 2.0)
      rects.append (GeometricRect (p1, p2, size.width))
    case .round :
      if size.width > size.height {
        let v = (size.width - size.height) / 2.0
        let p1 = NSPoint (x: center.x + v, y: center.y)
        let p2 = NSPoint (x: center.x - v, y: center.y)
        rects.append (GeometricRect (p1, p2, size.height))
        c.append (GeometricCircle (p1, size.height / 2.0))
        c.append (GeometricCircle (p2, size.height / 2.0))
      }else if size.width < size.height {
        let h = (size.height - size.width) / 2.0
        let p1 = NSPoint (x: center.x, y: center.y + h)
        let p2 = NSPoint (x: center.x, y: center.y - h)
        rects.append (GeometricRect (p1, p2, size.width))
        c.append (GeometricCircle (p1, size.width / 2.0))
        c.append (GeometricCircle (p2, size.width / 2.0))
      }else{
        c.append (GeometricCircle (center, size.width / 2.0))
      }
    case .octo :
      let s2 : CGFloat = sqrt (2.0)
      let lg = min (size.width, size.height) / (1.0 + s2)
      let pLeft  = NSPoint (x: center.x - size.width / 2.0, y: center.y)
      let pRight = NSPoint (x: center.x + size.width / 2.0, y: center.y)
      rects.append (GeometricRect (pLeft, pRight, size.height - lg * s2))
      let pTop    = NSPoint (x: center.x, y: center.y - size.height / 2.0)
      let pBottom = NSPoint (x: center.x, y: center.y + size.height / 2.0)
      rects.append (GeometricRect (pTop, pBottom, size.width - lg * s2))
    //--- Top right corner
      do{
        let p1 = NSPoint (x: center.x - size.width / 2.0 + lg / (2.0 * s2), y: center.y + size.height / 2.0 - lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x + lg / s2, y: p1.y - lg / s2)
        rects.append (GeometricRect (p1, p2, lg))
      }
    //--- Top left corner
      do{
        let p1 = NSPoint (x: center.x + size.width / 2.0 - lg / (2.0 * s2), y: center.y + size.height / 2.0 - lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x - lg / s2, y: p1.y - lg / s2)
        rects.append (GeometricRect (p1, p2, lg))
      }
    //--- Bottom left corner
      do{
        let p1 = NSPoint (x: center.x + size.width / 2.0 - lg / (2.0 * s2), y: center.y - size.height / 2.0 + lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x - lg / s2, y: p1.y + lg / s2)
        rects.append (GeometricRect (p1, p2, lg))
      }
    //--- Bottom right corner
      do{
        let p1 = NSPoint (x: center.x - size.width / 2.0 + lg / (2.0 * s2), y: center.y - size.height / 2.0 + lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x + lg / s2, y: p1.y + lg / s2)
        rects.append (GeometricRect (p1, p2, lg))
      }
    }
    self.circles = c
    self.rectangles = rects
  }

  //····················································································································

  private init (_ inCircles : [GeometricCircle], _ inRectangles : [GeometricRect]) {
    self.circles = inCircles
    self.rectangles = inRectangles
  }

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> PadGeometryForERC {
    var c = [GeometricCircle] ()
    var rects = [GeometricRect] ()
    for circle in self.circles {
      c.append (GeometricCircle (inAffineTransform.transform (circle.center), circle.radius))
    }
    for r in self.rectangles {
      rects.append (GeometricRect (inAffineTransform.transform (r.p1), inAffineTransform.transform (r.p2), r.width))
    }
    return PadGeometryForERC (c, rects)
  }

  //····················································································································

  private var mCachedBounds : NSRect? = nil
  var bounds : NSRect {
    if let b = self.mCachedBounds {
      return b
    }else{
      var b = NSRect.null
      for c in self.circles {
        b = b.union (c.bounds)
      }
      for r in self.rectangles {
        b = b.union (r.bounds)
      }
      self.mCachedBounds = b
      return b
    }
  }

  //····················································································································

  func intersects (_ inOther : PadGeometryForERC) -> Bool {
    if !self.bounds.intersects (inOther.bounds) {
      return false
    }else{
    //--- Check circle - circle insulation
      for c1 in self.circles {
        for c2 in inOther.circles {
          if NSPoint.distance (c1.center, c2.center) < (c1.radius + c2.radius) {
            return true
          }
        }
      }
    //--- Check rectangle - rectangle insulation
      for r1 in self.rectangles {
        for r2 in inOther.rectangles {
          if r1.intersects (rect: r2) {
            return true
          }
        }
      }
    //--- Check rectangle - circle insulation
      for r1 in self.rectangles {
        for c2 in inOther.circles {
          if r1.intersects (circle: c2) {
            return true
          }
        }
      }
    //--- Check circle - rectangle insulation
      for c1 in self.circles {
        for r2 in inOther.rectangles {
          if r2.intersects (circle: c1) {
            return true
          }
        }
      }
    //---
      return false
    }
  }

  //····················································································································

  var bezierPathes : [EBBezierPath] {
    var result = [EBBezierPath] ()
    for circle in self.circles {
      let s = circle.radius * 2.0
      let r = NSRect (center: circle.center, size: NSSize (width: s, height: s))
      let bp = EBBezierPath (ovalIn: r)
      result.append (bp)
//      result.appendOval (in: r)
    }
    for r in self.rectangles {
      var bp = EBBezierPath ()
      bp.move (to: r.p1)
      bp.line (to: r.p2)
      bp.lineWidth = r.width
      bp.lineCapStyle = .butt
      let filledBp = bp.pathByStroking
      result.append (filledBp)
    }
    return result
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == PadGeometryForERC {

  //····················································································································

  func bezierPathes () -> [EBBezierPath] {
    var result = [EBBezierPath] ()
    for entry in self {
      result += entry.bezierPathes
    }
    return result
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
