//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//--------------------------------------------------------------------------------------------------

import AppKit
import CanariGeometry

//--------------------------------------------------------------------------------------------------

let VERY_LARGE_PAD_NUMBER = 1_000_000

//--------------------------------------------------------------------------------------------------
//   EXTENSION PackagePad
//--------------------------------------------------------------------------------------------------

extension PackagePad {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Cursor
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func cursorForKnob_PackagePad (knob _ : Int) -> NSCursor? {
    return nil // Uses default cursor
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Translation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptedTranslation_PackagePad  (xBy inDx: CanariLength, yBy inDy: CanariLength) -> CanariPoint {
    return CanariPoint (x: inDx, y: inDy)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func acceptToTranslate_PackagePad (xBy _ : CanariLength, yBy _ : CanariLength) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func translate_PackagePad (xBy inDx: CanariLength,
                             yBy inDy: CanariLength,
                             userSet _ : inout EBReferenceSet <EBManagedObject>) {
    self.xCenter += inDx
    self.yCenter += inDy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  HORIZONTAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipHorizontally_PackagePad () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipHorizontally_PackagePad () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  VERTICAL FLIP
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func flipVertically_PackagePad () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canFlipVertically_PackagePad () -> Bool {
    return false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Knob
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canMove_PackagePad (knob _ : Int,
                         proposedUnalignedAlignedTranslation _ : CanariPoint,
                         proposedAlignedTranslation inProposedAlignedTranslation : CanariPoint,
                         unalignedMouseDraggedLocation _ : CanariPoint,
                         shift _ : Bool) -> CanariPoint {
    return inProposedAlignedTranslation
 }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func move_PackagePad (knob _ : Int,
                        proposedDx _ : CanariLength,
                        proposedDy _ : CanariLength,
                        unalignedMouseLocationX _ : CanariLength,
                        unalignedMouseLocationY _ : CanariLength,
                        alignedMouseLocationX _ : CanariLength,
                        alignedMouseLocationY _ : CanariLength,
                        shift _ : Bool) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Rotate 90°
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canRotate90_PackagePad (accumulatedPoints : inout Set <CanariPoint>) -> Bool {
    accumulatedPoints.insert (x: self.xCenter, y: self.yCenter)
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90Clockwise_PackagePad (from inRotationCenter : CanariPoint,
                                     userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90Clockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func rotate90CounterClockwise_PackagePad (from inRotationCenter : CanariPoint,
                                            userSet _ : inout EBReferenceSet <EBManagedObject>) {
    let newCenter = inRotationCenter.rotated90CounterClockwise (x: self.xCenter, y: self.yCenter)
    self.xCenter = newCenter.x
    self.yCenter = newCenter.y
    (self.width, self.height) = (self.height, self.width)
    (self.holeWidth, self.holeHeight) = (self.holeHeight, self.holeWidth)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationAfterPasting_PackagePad (additionalDictionary _ : [String : Any],
                                         optionalDocument _ : EBAutoLayoutManagedDocument?,
                                         objectArray _ : [EBGraphicManagedObject]) -> String {
    self.padNumber += VERY_LARGE_PAD_NUMBER // So it will be numbered by model observer CustomizedPackageDocument:handlePadNumbering
    return "" // Means ok
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Save into additional dictionary
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func saveIntoAdditionalDictionary_PackagePad (_ _ : inout [String : Any]) {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  SNAP TO GRID
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func canSnapToGrid_PackagePad (_ inGrid : CanariLength) -> Bool {
    var result = self.xCenter.isAligned (on: inGrid)
    if !result {
      result = self.yCenter.isAligned (on: inGrid)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func snapToGrid_PackagePad (_ inGrid : CanariLength) {
    self.xCenter.align (on: inGrid)
    self.yCenter.align (on: inGrid)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func alignmentPoints_PackagePad () -> Set <CanariPoint> {
    var result = Set <CanariPoint> ()
    result.insert (x: self.xCenter, y: self.yCenter)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  operationBeforeRemoving
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func operationBeforeRemoving_PackagePad () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func angleInRadian (from inCanariPoint : CanariPoint, from inStartAngleInRadian : CGFloat) -> CGFloat {
    let a = CanariPoint.angleInRadian (inCanariPoint, CanariPoint (x: self.xCenter, y: self.yCenter))
    return (2.0 * CGFloat.pi + a - inStartAngleInRadian).truncatingRemainder (dividingBy: 2.0 * CGFloat.pi)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func program () -> String {
    var s = "pad "
    s += self.xCenter.string (in: self.xCenterUnit, fractionDigits: 2)
    s += " : "
    s += self.yCenter.string (in: self.yCenterUnit, fractionDigits: 2)
    s += " size "
    s += self.width.string (in: self.widthUnit, fractionDigits: 2)
    s += " : "
    s += self.height.string (in: self.heightUnit, fractionDigits: 2)
    s += " shape "
    s += self.padShape.string
    s += " style "
    s += self.padStyle.string
    s += " hole "
    s += self.holeWidth.string (in: self.holeWidthUnit, fractionDigits: 2)
    s += " : "
    s += self.holeHeight.string (in: self.holeHeightUnit, fractionDigits: 2)
    s += " number "
    s += "\(self.padNumber)"
    if self.slaves.count > 0 {
      s += " id "
      s += "\(self.objectIndex)"
    }
    s += ";\n"
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

extension BezierPath {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func pad (centerX inCenterX : CanariLength,
                   centerY inCenterY : CanariLength,
                   width inWidth : CanariLength,
                   height inHeight : CanariLength,
                   shape inShape : PadShape) -> BezierPath {
    let center = NSPoint (x: inCenterX, y: inCenterY)
    let size = NSSize (width: inWidth, height: inHeight)
    let r = NSRect (center: center, size: size)
    switch inShape {
    case .rect :
      return BezierPath (rect: r)
    case .round :
      return BezierPath (oblongInRect: r)
    case .octo :
      return BezierPath (octogonInRect: r)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

final class PadGeometryForERC {
  let id : Int
  let circles : [GeometricCircle]
  let rectangles : [GeometricRect]
  let bezierPath : BezierPath

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (padId inID : Int,
        centerX inCenterX : CanariLength,
        centerY inCenterY : CanariLength,
        width inWidth : CanariLength,
        height inHeight : CanariLength,
        clearance inClearance : CanariLength,
        shape inShape : PadShape) {
    self.id = inID
    let center = NSPoint (x: inCenterX, y: inCenterY)
    let size = NSSize (width: inWidth, height: inHeight)
    let clearance = inClearance.ptValue
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
    self.bezierPath = BezierPath.pad (
      centerX: inCenterX,
      centerY: inCenterY,
      width: inWidth + inClearance,
      height: inHeight + inClearance,
      shape: inShape
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private init (_ inID : Int,
                _ inCircles : [GeometricCircle],
                _ inRectangles : [GeometricRect],
                _ inBezierPath : BezierPath) {
    self.id = inID
    self.circles = inCircles
    self.rectangles = inRectangles
    self.bezierPath = inBezierPath
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

//extension Array where Element == PadGeometryForERC {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  func bezierPathes () -> [BezierPath] {
//    var result = [BezierPath] ()
//    for entry in self {
//      result.append (entry.bezierPath)
//    }
//    return result
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------
