//
//  extension-PackageArc.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//let PACKAGE_ARC_CENTER = 1
//let PACKAGE_ARC_RADIUS = 2
//let PACKAGE_ARC_START_ANGLE = 3
//let PACKAGE_ARC_END_ANGLE = 4

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

class RectForERC {
  let p1 : NSPoint
  let p2 : NSPoint
  let width : CGFloat

  //····················································································································

  init (_ inP1 : NSPoint, _ inP2 : NSPoint, _ inWidth : CGFloat) {
    self.p1 = inP1
    self.p2 = inP2
    self.width = inWidth
  }

  //····················································································································

  private var mCircumRadius : CGFloat? = nil
  var circumRadius : CGFloat {
    if let r = self.mCircumRadius {
      return r
    }else{
      let d = NSPoint.distance (self.p1, self.p2)
      let r = (d * d + self.width * self.width).squareRoot () / 2.0
      self.mCircumRadius = r
      return r
    }
  }

  //····················································································································

  private var mInnerRadius : CGFloat? = nil
  var innerRadius : CGFloat {
    if let r = self.mInnerRadius {
      return r
    }else{
      let d = NSPoint.distance (self.p1, self.p2)
      let r = min (d, self.width) / 2.0
      self.mInnerRadius = r
      return r
    }
  }

  //····················································································································

  private var mCenterCache : NSPoint? = nil
  var center : NSPoint {
    if let c = self.mCenterCache {
      return c
    }else{
      let c = NSPoint.center (self.p1, self.p2)
      self.mCenterCache = c
      return c
    }
  }

  //····················································································································

  private var mVerticesCache : [NSPoint]? = nil
  var vertices : [NSPoint] {
    if let v = self.mVerticesCache {
      return v
    }else{
      let angle = NSPoint.angleInRadian (self.p1, self.p2)
      let dx = self.width * cos (angle) / 2.0
      let dy = self.width * sin (angle) / 2.0
      var v = [NSPoint] ()
      v.append (NSPoint (x: self.p1.x - dx, y: self.p1.y + dy))
      v.append (NSPoint (x: self.p1.x + dx, y: self.p1.y - dy))
      v.append (NSPoint (x: self.p2.x + dx, y: self.p2.y - dy))
      v.append (NSPoint (x: self.p2.x - dx, y: self.p2.y + dy))
      self.mVerticesCache = v
      return v
    }
  }

  //····················································································································

  var bounds : NSRect {
    return NSRect (points: self.vertices)
  }

  //····················································································································

  func intersects (_ inCircle : CircleForERC) -> Bool {
    let centerDistance = NSPoint.distance (self.center, inCircle.center)
    if centerDistance > (self.circumRadius + inCircle.radius) {
      return false
    }else if centerDistance <= (self.innerRadius + inCircle.radius) {
      return true
    }else{
    //--- Test intersection between circle and rectangle edge
      var intersects = false
      let vertices = self.vertices
      var i = 0
      while !intersects && (i < vertices.count) {
        intersects = inCircle.intersects (segmentFrom: vertices [i], to: vertices [(i+1) % vertices.count])
        i += 1
      }
      return intersects
    }
  }

  //····················································································································

  func intersects (_ inOther : RectForERC) -> Bool {
    let centerDistance = NSPoint.distance (self.center, inOther.center)
    if centerDistance > (self.circumRadius + inOther.circumRadius) {
      return false
    }else if centerDistance <= (self.innerRadius + inOther.innerRadius) {
      return true
    }else{
    //--- Method of separating axes (https://www.youtube.com/watch?v=WBy6AveIRRs)
      var intersects = true
      let vertices1 = self.vertices
      let vertices2 = inOther.vertices
      do{
        var i = 0
        while intersects && (i < vertices1.count) {
          let ref = CGPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices1 [(i+2) % vertices1.count])
          var outside = true
          var j = 0
          while outside && (j < vertices2.count) {
            let test = CGPoint.product (vertices1 [i], vertices1 [(i+1) % vertices1.count], vertices2 [j])
            outside = (ref * test) < 0.0
            j += 1
          }
          intersects = !outside
          i += 1
        }
      }
    //---
      if intersects {
        var i = 0
        while intersects && (i < vertices2.count) {
          let ref = CGPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices2 [(i+2) % vertices2.count])
          var outside = true
          var j = 0
          while outside && (j < vertices1.count) {
            let test = CGPoint.product (vertices2 [i], vertices2 [(i+1) % vertices2.count], vertices1 [j])
            outside = (ref * test) < 0.0
            j += 1
          }
          intersects = !outside
          i += 1
        }
      }
    //---
      return intersects
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CircleForERC {
  let center : NSPoint
  let radius : CGFloat

  //····················································································································

  func intersects (segmentFrom p1 : NSPoint, to p2 : NSPoint) -> Bool {
    var intersects = NSPoint.distance (p1, self.center) <= self.radius
    if !intersects {
      intersects = NSPoint.distance (p2, self.center) <= self.radius
    }
    if !intersects {
      let segmentAngle = NSPoint.angleInRadian (p1, p2)
      let segmentCenter = NSPoint (x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
      let tr = CGAffineTransform (rotationAngle: -segmentAngle).translatedBy (x:-segmentCenter.x, y:-segmentCenter.y)
      let point = self.center.applying (tr)
      intersects = abs (point.y) <= self.radius
      if intersects {
        let segmentLength = NSPoint.distance (p1, p2)
        intersects = abs (point.x) <= (segmentLength * 0.5)
      }
    }
    return intersects
  }

  //····················································································································

  var bounds : NSRect {
    let s = NSSize (width: self.radius * 2.0, height: self.radius * 2.0)
    return NSRect (center: self.center, size: s)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class PadGeometryForERC {
  let circles : [CircleForERC]
  let rectangles : [RectForERC]

//····················································································································

  init (centerX inCenterX : Int,
        centerY inCenterY : Int,
        width inWidth : Int,
        height inHeight : Int,
        shape inShape : PadShape) {
    let center = CanariPoint (x: inCenterX, y: inCenterY).cocoaPoint
    let size = CanariSize (width: inWidth, height: inHeight).cocoaSize
    var c = [CircleForERC] ()
    var rects = [RectForERC] ()
    switch inShape {
    case .rect :
      let p1 = NSPoint (x: center.x, y: center.y + size.height / 2.0)
      let p2 = NSPoint (x: center.x, y: center.y - size.height / 2.0)
      rects.append (RectForERC (p1, p2, size.width))
    case .round :
      if size.width > size.height {
        let v = (size.width - size.height) / 2.0
        let p1 = NSPoint (x: center.x + v, y: center.y)
        let p2 = NSPoint (x: center.x - v, y: center.y)
        rects.append (RectForERC (p1, p2, size.height))
        c.append (CircleForERC (center: p1, radius: size.height / 2.0))
        c.append (CircleForERC (center: p2, radius: size.height / 2.0))
      }else if size.width < size.height {
        let h = (size.height - size.width) / 2.0
        let p1 = NSPoint (x: center.x, y: center.y + h)
        let p2 = NSPoint (x: center.x, y: center.y - h)
        rects.append (RectForERC (p1, p2, size.width))
        c.append (CircleForERC (center: p1, radius: size.width / 2.0))
        c.append (CircleForERC (center: p2, radius: size.width / 2.0))
      }else{
        c.append (CircleForERC (center: center, radius: size.width / 2.0))
      }
    case .octo :
      let s2 : CGFloat = sqrt (2.0)
      let lg = min (size.width, size.height) / (1.0 + s2)
      let pLeft  = NSPoint (x: center.x - size.width / 2.0, y: center.y)
      let pRight = NSPoint (x: center.x + size.width / 2.0, y: center.y)
      rects.append (RectForERC (pLeft, pRight, size.height - lg * s2))
      let pTop    = NSPoint (x: center.x, y: center.y - size.height / 2.0)
      let pBottom = NSPoint (x: center.x, y: center.y + size.height / 2.0)
      rects.append (RectForERC (pTop, pBottom, size.width - lg * s2))
    //--- Top right corner
      do{
        let p1 = NSPoint (x: center.x - size.width / 2.0 + lg / (2.0 * s2), y: center.y + size.height / 2.0 - lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x + lg / s2, y: p1.y - lg / s2)
        rects.append (RectForERC (p1, p2, lg))
      }
    //--- Top left corner
      do{
        let p1 = NSPoint (x: center.x + size.width / 2.0 - lg / (2.0 * s2), y: center.y + size.height / 2.0 - lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x - lg / s2, y: p1.y - lg / s2)
        rects.append (RectForERC (p1, p2, lg))
      }
    //--- Bottom left corner
      do{
        let p1 = NSPoint (x: center.x + size.width / 2.0 - lg / (2.0 * s2), y: center.y - size.height / 2.0 + lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x - lg / s2, y: p1.y + lg / s2)
        rects.append (RectForERC (p1, p2, lg))
      }
    //--- Bottom right corner
      do{
        let p1 = NSPoint (x: center.x - size.width / 2.0 + lg / (2.0 * s2), y: center.y - size.height / 2.0 + lg / (2.0 * s2))
        let p2 = NSPoint (x: p1.x + lg / s2, y: p1.y + lg / s2)
        rects.append (RectForERC (p1, p2, lg))
      }
    }
    self.circles = c
    self.rectangles = rects
  }

  //····················································································································

  private init (_ inCircles : [CircleForERC], _ inRectangles : [RectForERC]) {
    self.circles = inCircles
    self.rectangles = inRectangles
  }

  //····················································································································

  func transformed (by inAffineTransform : AffineTransform) -> PadGeometryForERC {
    var c = [CircleForERC] ()
    var rects = [RectForERC] ()
    for circle in self.circles {
      c.append (CircleForERC (center: inAffineTransform.transform (circle.center), radius: circle.radius))
    }
    for r in self.rectangles {
      rects.append (RectForERC (inAffineTransform.transform (r.p1), inAffineTransform.transform (r.p2), r.width))
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
          if r1.intersects (r2) {
            return true
          }
        }
      }
    //--- Check rectangle - circle insulation
      for r1 in self.rectangles {
        for c2 in inOther.circles {
          if r1.intersects (c2) {
            return true
          }
        }
      }
    //--- Check circle - rectangle insulation
      for c1 in self.circles {
        for r2 in inOther.rectangles {
          if r2.intersects (c1) {
            return true
          }
        }
      }
    //---
      return false
    }
  }

  //····················································································································

  var bezierPath : EBBezierPath {
    var result = EBBezierPath ()
    for circle in self.circles {
      let s = circle.radius * 2.0
      let r = NSRect (center: circle.center, size: NSSize (width: s, height: s))
      result.appendOval (in: r)
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
    result.windingRule = .nonZero
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
      result.append (entry.bezierPath)
    }
    return result
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
