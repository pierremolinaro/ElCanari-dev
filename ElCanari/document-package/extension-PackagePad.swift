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

  override func translate (xBy inDx: Int, yBy inDy: Int, userSet ioSet : ObjcObjectSet) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  //····················································································································
  //  Knob
  //····················································································································

  override func canMove (knob inKnobIndex : Int,
                         proposedUnalignedAlignedTranslation inProposedUnalignedTranslation : ObjcCanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : ObjcCanariPoint,
                         unalignedMouseDraggedLocation inUnalignedMouseDraggedLocation : ObjcCanariPoint,
                         shift inShift : Bool) -> ObjcCanariPoint {
    return inProposedAlignedTranslation
 }

  //····················································································································

  override func move (knob inKnobIndex: Int,
                      proposedDx inDx: Int,
                      proposedDy inDy: Int,
                      unalignedMouseLocationX inUnlignedMouseLocationX : Int,
                      unalignedMouseLocationY inUnlignedMouseLocationY : Int,
                      alignedMouseLocationX inAlignedMouseLocationX : Int,
                      alignedMouseLocationY inAlignedMouseLocationY : Int,
                      shift inShift : Bool) {
  }

  //····················································································································
  //  Rotate 90°
  //····················································································································

  override func canRotate90 (accumulatedPoints : ObjcCanariPointSet) -> Bool {
    accumulatedPoints.insert (x: self.xCenter, y: self.yCenter)
    return true
  }

  //····················································································································

  override func rotate90Clockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  //····················································································································

  override func rotate90CounterClockwise (from inRotationCenter : ObjcCanariPoint, userSet ioSet : ObjcObjectSet) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  //····················································································································
  //  COPY AND PASTE
  //····················································································································

  override func canCopyAndPaste () -> Bool {
    return true
  }

  //····················································································································

  override func operationAfterPasting (additionalDictionary inDictionary : NSDictionary, objectArray inObjectArray : [EBGraphicManagedObject]) -> String {
    self.padNumber += VERY_LARGE_PAD_NUMBER // So it will be numbered by model observer CustomizedPackageDocument:handlePadNumbering
    return "" // Means ok
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

  override func alignmentPoints () -> ObjcCanariPointSet {
    let result = ObjcCanariPointSet ()
    result.insert (CanariPoint (x: self.xCenter, y: self.yCenter))
    return result
  }

  //····················································································································
  //
  //····················································································································

  func angleInRadian (from inCanariPoint : CanariPoint, from inStartAngleInRadian : CGFloat) -> CGFloat {
    let a = CanariPoint.angleInRadian (inCanariPoint, CanariPoint (x: self.xCenter, y: self.yCenter))
    return (2.0 * CGFloat.pi + a - inStartAngleInRadian).truncatingRemainder (dividingBy: 2.0 * CGFloat.pi)
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

final class PadGeometryForERC {
  let id : Int
  let circles : [GeometricCircle]
  let rectangles : [GeometricRect]
  let bezierPath : EBBezierPath

  //····················································································································

  init (id inID : Int,
        centerX inCenterX : Int,
        centerY inCenterY : Int,
        width inWidth : Int,
        height inHeight : Int,
        clearance inClearance : Int,
        shape inShape : PadShape) {
    self.id = inID
    let center = CanariPoint (x: inCenterX, y: inCenterY).cocoaPoint
    let size = CanariSize (width: inWidth, height: inHeight).cocoaSize
    let clearance = canariUnitToCocoa (inClearance)
    var c = [GeometricCircle] ()
    var rects = [GeometricRect] ()
    switch inShape {
    case .rect :
      let pTop = NSPoint (x: center.x, y: center.y + (clearance + size.height) / 2.0)
      let pBottom = NSPoint (x: center.x, y: center.y - (clearance + size.height) / 2.0)
      rects.append (GeometricRect (pTop, pBottom, size.width))
      let pLeft  = NSPoint (x: center.x - (clearance + size.width) / 2.0, y: center.y)
      let pRight = NSPoint (x: center.x + (clearance + size.width) / 2.0, y: center.y)
      rects.append (GeometricRect (pLeft, pRight, size.height))
      let pTopLeft = NSPoint (x: center.x - size.width / 2.0, y: center.y + size.height / 2.0)
      c.append (GeometricCircle (center: pTopLeft, radius: clearance / 2.0))
      let pTopRight = NSPoint (x: center.x + size.width / 2.0, y: center.y + size.height / 2.0)
      c.append (GeometricCircle (center: pTopRight, radius: clearance / 2.0))
      let pBottomLeft = NSPoint (x: center.x - size.width / 2.0, y: center.y - size.height / 2.0)
      c.append (GeometricCircle (center: pBottomLeft, radius: clearance / 2.0))
      let pBottomRight = NSPoint (x: center.x + size.width / 2.0, y: center.y - size.height / 2.0)
      c.append (GeometricCircle (center: pBottomRight, radius: clearance / 2.0))
    case .round :
      if size.width > size.height {
        let v = (size.width - size.height) / 2.0
        let p1 = NSPoint (x: center.x + v, y: center.y)
        let p2 = NSPoint (x: center.x - v, y: center.y)
        rects.append (GeometricRect (p1, p2, clearance + size.height))
        c.append (GeometricCircle (center: p1, radius: (clearance + size.height) / 2.0))
        c.append (GeometricCircle (center: p2, radius: (clearance + size.height) / 2.0))
      }else if size.width < size.height {
        let h = (size.height - size.width) / 2.0
        let p1 = NSPoint (x: center.x, y: center.y + h)
        let p2 = NSPoint (x: center.x, y: center.y - h)
        rects.append (GeometricRect (p1, p2, clearance + size.width))
        c.append (GeometricCircle (center: p1, radius: (clearance + size.width) / 2.0))
        c.append (GeometricCircle (center: p2, radius: (clearance + size.width) / 2.0))
      }else{
        c.append (GeometricCircle (center: center, radius: (clearance + size.width) / 2.0))
      }
    case .octo :
      let s2 : CGFloat = sqrt (2.0)
      let lg = min (size.width + clearance, size.height + clearance) / (1.0 + s2)
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
    self.bezierPath = EBBezierPath.pad (
      centerX: inCenterX,
      centerY: inCenterY,
      width: inWidth + inClearance,
      height: inHeight + inClearance,
      shape: inShape
    )
  }

  //····················································································································

  private init (_ inID : Int,
                _ inCircles : [GeometricCircle],
                _ inRectangles : [GeometricRect],
                _ inBezierPath : EBBezierPath) {
    self.id = inID
    self.circles = inCircles
    self.rectangles = inRectangles
    self.bezierPath = inBezierPath
  }

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> PadGeometryForERC {
    var c = [GeometricCircle] ()
    var rects = [GeometricRect] ()
    for circle in self.circles {
      c.append (GeometricCircle (center: inAffineTransform.transform (circle.center), radius: circle.radius))
    }
    for r in self.rectangles {
      rects.append (GeometricRect (inAffineTransform.transform (r.p1), inAffineTransform.transform (r.p2), r.width))
    }
    return PadGeometryForERC (self.id, c, rects, self.bezierPath.transformed (by: inAffineTransform))
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

  func intersects (pad inOther : PadGeometryForERC) -> Bool {
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

  func intersects (oblong inOblong : GeometricOblong) -> Bool {
    if !self.bounds.intersects (inOblong.bounds) {
      return false
    }else{
      for circle in self.circles {
        if inOblong.intersects (circle: circle) {
          return true
        }
      }
      for rectangle in self.rectangles {
        if inOblong.intersects (rect: rectangle) {
          return true
        }
      }
      return false
    }
  }

  //····················································································································

  func intersects (rect inRect : GeometricRect) -> Bool {
    if !self.bounds.intersects (inRect.bounds) {
      return false
    }else{
      for circle in self.circles {
        if inRect.intersects (circle: circle) {
          return true
        }
      }
      for rectangle in self.rectangles {
        if inRect.intersects (rect: rectangle) {
          return true
        }
      }
      return false
    }
  }

  //····················································································································

  func intersects (circle inCircle : GeometricCircle) -> Bool {
    if !self.bounds.intersects (inCircle.bounds) {
      return false
    }else{
      for circle in self.circles {
        if circle.intersects (circle: inCircle) {
          return true
        }
      }
      for rectangle in self.rectangles {
        if rectangle.intersects (circle: inCircle) {
          return true
        }
      }
      return false
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Array where Element == PadGeometryForERC {

  //····················································································································

  func bezierPathes () -> [EBBezierPath] {
    var result = [EBBezierPath] ()
    for entry in self {
      result.append (entry.bezierPath)
    }
    return result
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
