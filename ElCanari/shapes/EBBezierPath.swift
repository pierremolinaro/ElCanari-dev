//
//  EBBezierPath.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/06/2019.
//

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    EBTextShape alignments
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum EBTextHorizontalAlignment {
  case onTheRight
  case center
  case onTheLeft
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

enum EBTextVerticalAlignment {
  case above
  case center
  case below
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// EBBezierPath
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct EBBezierPath : Hashable {

  //····················································································································

  private var mPath : OCBezierPath

  //····················································································································

  var nsBezierPath : NSBezierPath { // § TEMP
    return self.mPath.copy () as! OCBezierPath
  }

  //····················································································································

  init () {
    mPath = OCBezierPath ()
  }

  //····················································································································

  init (rect inRect : NSRect) {
    self.mPath = OCBezierPath ()
    self.mPath.appendRect (inRect)
  }

  //····················································································································

  init (ovalIn inRect : NSRect) {
    self.mPath = OCBezierPath ()
    self.mPath.appendOval (in: inRect)
  }

  //····················································································································

  init (roundedRect rect : NSRect, xRadius : CGFloat, yRadius : CGFloat) {
    self.mPath = OCBezierPath ()
    self.mPath.appendRoundedRect (rect, xRadius: xRadius, yRadius: yRadius)
  }

  //····················································································································

  init (_ inBezierPath : NSBezierPath) { // § TEMP
    mPath = OCBezierPath ()
    self.mPath.append (inBezierPath)
    self.mPath.lineWidth = inBezierPath.lineWidth
    self.mPath.lineCapStyle = inBezierPath.lineCapStyle
    self.mPath.lineJoinStyle = inBezierPath.lineJoinStyle
  }

  //····················································································································

  init (with inString : String,
        at inOrigin : NSPoint,
        _ inHorizontalAlignment : EBTextHorizontalAlignment,
        _ inVerticalAlignment : EBTextVerticalAlignment,
        withAttributes inTextAttributes : [NSAttributedString.Key : Any]) {
    self.mPath = OCBezierPath ()
    if inString != "" {
    //--- Font
      let font : NSFont
      if let f = inTextAttributes [NSAttributedString.Key.font] as? NSFont {
        font = f
      }else{
        font = NSFont ()
      }
    //--- Build text infrastructure
      let textStore = NSTextStorage (string: inString, attributes: inTextAttributes)
      let textContainer = NSTextContainer ()
      let myLayout = NSLayoutManager ()
      myLayout.addTextContainer (textContainer)
      textStore.addLayoutManager (myLayout)
    //--- Get CCGlyph array
      let glyphRange : NSRange = myLayout.glyphRange (for: textContainer)
      var cgGlyphArray = [CGGlyph] (repeating: CGGlyph (), count:glyphRange.length)
      _ = myLayout.getGlyphs (in: glyphRange, glyphs: &cgGlyphArray, properties: nil, characterIndexes: nil, bidiLevels: nil)
    //--- Transform in NSGlyph array
      var nsGlyphArray = [NSGlyph] ()
      for cgGlyph in cgGlyphArray {
        nsGlyphArray.append (NSGlyph (cgGlyph))
      }
    //--- Enter in Bezier path
      self.mPath.move (to: NSPoint (x: inOrigin.x, y: inOrigin.y - 2.0 * font.descender))
      self.mPath.appendGlyphs (&nsGlyphArray, count: glyphRange.length, in: font)
    //--- Alignment
      let width = self.mPath.bounds.width
      let height = self.mPath.bounds.height
      var deltaX : CGFloat = inOrigin.x - self.mPath.bounds.origin.x
      switch inHorizontalAlignment {
      case .onTheRight :
        ()
      case .center :
        deltaX -= width / 2.0
      case .onTheLeft :
        deltaX -= width
      }
      var deltaY : CGFloat = inOrigin.y - self.mPath.bounds.origin.y
      switch inVerticalAlignment {
      case .above :
        ()
      case .center :
        deltaY -= height / 2.0
      case .below :
        deltaY -= height
      }
      var af = AffineTransform ()
      af.translate (x: deltaX, y: deltaY)
      self.mPath.transform (using: af)
    }
  }

  //····················································································································

  var lineWidth : CGFloat {
    get {
      return self.mPath.lineWidth
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! OCBezierPath
      }
      self.mPath.lineWidth = newValue
    }
  }


  //····················································································································

  var lineCapStyle : NSBezierPath.LineCapStyle {
    get {
      return self.mPath.lineCapStyle
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! OCBezierPath
      }
      self.mPath.lineCapStyle = newValue
    }
  }

  //····················································································································

  var lineJoinStyle : NSBezierPath.LineJoinStyle {
    get {
      return self.mPath.lineJoinStyle
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! OCBezierPath
      }
      self.mPath.lineJoinStyle = newValue
    }
  }

  //····················································································································

  var windingRule : NSBezierPath.WindingRule {
    get {
      return self.mPath.windingRule
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! OCBezierPath
      }
      self.mPath.windingRule = newValue
    }
  }

  //····················································································································

  mutating func appendRect (_ inRect : NSRect) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.appendRect (inRect)
  }

  //····················································································································

  mutating func appendOval (in inRect : NSRect) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.appendOval (in: inRect)
  }

  //····················································································································

  mutating func move (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.move (to: inPoint)
  }

  //····················································································································

  mutating func relativeMove (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.relativeMove (to: inPoint)
  }

  //····················································································································

  mutating func line (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.line (to: inPoint)
  }

  //····················································································································

  mutating func curve (to inPoint : NSPoint, controlPoint1 inCP1 : NSPoint, controlPoint2 inCP2 : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.curve (to: inPoint, controlPoint1: inCP1, controlPoint2: inCP2)
  }

  //····················································································································

  mutating func close () {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.close ()
  }

  //····················································································································

  mutating func relativeLine (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.relativeLine (to: inPoint)
  }

  //····················································································································

  mutating func transform (using transform: AffineTransform) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.transform (using: transform)
  }

  //····················································································································

  func transformed (by transform: AffineTransform) -> EBBezierPath {
    var result = self
    result.transform (using: transform)
    return result
  }

  //····················································································································

  func stroke () {
    self.mPath.stroke ()
  }

  //····················································································································

  func fill () {
    self.mPath.fill ()
  }

  //····················································································································

  func addClip () {
    self.mPath.addClip ()
  }

  //····················································································································

  func contains (_ point: NSPoint) -> Bool {
    return self.mPath.contains (point)
  }

  //····················································································································

  var bounds : NSRect {
    if self.mPath.isEmpty {
      return .null
    }else{
      return self.mPath.bounds
    }
  }

  //····················································································································

  var isEmpty : Bool {
    return self.mPath.isEmpty
  }

  //····················································································································

  mutating func append (_ inBezierPath : NSBezierPath) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.append (inBezierPath)
  }

  //····················································································································

  mutating func append (_ inBezierPath : EBBezierPath) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! OCBezierPath
    }
    self.mPath.append (inBezierPath.nsBezierPath)
  }

  //····················································································································

  func intersects (rect inRect : NSRect) -> Bool {
    var intersect = self.bounds.intersects (inRect)
    if intersect {
      intersect = self.mPath.contains (inRect.origin) // Bottom left
      if !intersect {
        intersect = self.mPath.contains (NSPoint (x: inRect.minX, y: inRect.maxY)) // Top left
      }
      if !intersect {
        intersect = self.mPath.contains (NSPoint (x: inRect.maxX, y: inRect.maxY)) // Top right
      }
      if !intersect {
        intersect = self.mPath.contains (NSPoint (x: inRect.maxX, y: inRect.minY)) // Bottom right
      }
      if !intersect {
        var points = [NSPoint] (repeating: .zero, count: 3)
        var currentPoint = NSPoint ()
        let flattenedPath = self.mPath.flattened
        var idx = 0
        while (idx < flattenedPath.elementCount) && !intersect {
          let type = flattenedPath.element (at: idx, associatedPoints: &points)
          idx += 1
          switch type {
          case .moveTo:
            currentPoint = points [0]
          case .lineTo:
            let p = points [0]
            let possibleResultSegment = inRect.clippedSegment (p1: currentPoint, p2: p)
            intersect = possibleResultSegment != nil
            currentPoint = p
          case .curveTo, .closePath: // Flattened path has no element of theses types
            ()
          @unknown default:
            ()
          }
        }
      }
    }
    return intersect
  }

  //····················································································································

  public var pathByStroking : EBBezierPath {
    let lineCap : CGLineCap
    switch self.lineCapStyle {
    case .butt : lineCap = .butt
    case .round : lineCap = .round
    case .square : lineCap = .square
    @unknown default:
      lineCap = .round
    }
    let lineJoin : CGLineJoin
    switch self.lineJoinStyle {
    case .bevel : lineJoin = .bevel
    case .miter : lineJoin = .miter
    case .round : lineJoin = .round
    @unknown default:
      lineJoin = .round
    }
    let cgPath = self.mPath.cgPath.copy (
      strokingWithWidth: self.lineWidth,
      lineCap: lineCap,
      lineJoin: lineJoin,
      miterLimit: self.mPath.miterLimit
    )
    var path = EBBezierPath ()
    cgPath.apply (info: &path.mPath, function: CGPathCallback)
    return path
  }

  //····················································································································

  init (octogonInRect inRect : NSRect) {
    self.init ()
    let s2 : CGFloat = sqrt (2.0)
    let w = inRect.size.width
    let h = inRect.size.height
    let x = inRect.origin.x // center x
    let y = inRect.origin.y // center y
    let lg = min (w, h) / (1.0 + s2)
    self.mPath.move (to: NSPoint (x: x + lg / s2,     y: y + h))
    self.mPath.line (to: NSPoint (x: x + w - lg / s2, y: y + h))
    self.mPath.line (to: NSPoint (x: x + w,           y: y + h - lg / s2))
    self.mPath.line (to: NSPoint (x: x + w,           y: y + lg / s2))
    self.mPath.line (to: NSPoint (x: x + w - lg / s2, y: y))
    self.mPath.line (to: NSPoint (x: x + lg / s2,     y: y))
    self.mPath.line (to: NSPoint (x: x,               y: y + lg / s2))
    self.mPath.line (to: NSPoint (x: x,               y: y + h - lg / s2))
    self.mPath.close ()
  }

  //····················································································································

  init (arcWithTangentFromCenter inCenter : NSPoint,
        radius inRadius : CGFloat,
        startAngleInDegrees inStartAngleInDegrees : CGFloat,
        arcAngleInDegrees inArcAngleInDegrees : CGFloat,
        startTangentLength inStartTangentLength : CGFloat,
        endTangentLength inEndTangentLength : CGFloat,
        pathIsClosed inPathIsClosed : Bool) {
    self.init ()
    var endAngle = inStartAngleInDegrees + inArcAngleInDegrees
    if endAngle >= 360.0 {
      endAngle -= 360.0
    }else if endAngle < 0.0 {
      endAngle += 360.0
    }
    self.mPath.appendArc (
      withCenter: inCenter,
      radius: inRadius,
      startAngle: inStartAngleInDegrees,
      endAngle: endAngle
    )
  //--- First point
    var t = NSAffineTransform ()
    t.translateX (by: inCenter.x, yBy: inCenter.y)
    t.rotate (byDegrees: inStartAngleInDegrees)
    var firstPoint = t.transform (NSPoint (x: inRadius, y: 0.0))
    if inStartTangentLength > 0.0 {
      self.move (to: firstPoint)
      t = NSAffineTransform ()
      t.rotate (byDegrees: inStartAngleInDegrees - 90.0)
      let p = t.transform (NSPoint (x: inStartTangentLength, y: 0.0))
      self.relativeLine (to: p)
      firstPoint.x += p.x
      firstPoint.y += p.y
    }
  //--- Last Point
    t = NSAffineTransform ()
    t.translateX (by: inCenter.x, yBy: inCenter.y)
    t.rotate (byDegrees: inStartAngleInDegrees + inArcAngleInDegrees)
    var lastPoint = t.transform (NSPoint (x: inRadius, y: 0.0))
    if inEndTangentLength > 0.0 {
      self.move (to: lastPoint)
      t = NSAffineTransform ()
      t.rotate (byDegrees: inStartAngleInDegrees + inArcAngleInDegrees + 90.0)
      let p = t.transform (NSPoint (x: inEndTangentLength, y: 0.0))
      self.relativeLine (to: p)
      lastPoint.x += p.x
      lastPoint.y += p.y
    }
  //--- Closed ?
    if inPathIsClosed {
      self.move (to: firstPoint)
      self.line (to: lastPoint)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// OCBezierPath
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OCBezierPath : NSBezierPath, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init () {
    super.init ()
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // https://stackoverflow.com/questions/1815568/how-can-i-convert-nsbezierpath-to-cgpath

  public var cgPath : CGPath {
    let path = CGMutablePath ()
    var points = [CGPoint] (repeating: .zero, count: 3)
    for idx in 0 ..< self.elementCount {
      let type = self.element (at: idx, associatedPoints: &points)
      switch type {
      case .moveTo:
        path.move (to: points[0])
      case .lineTo:
        path.addLine (to: points[0])
      case .curveTo:
        path.addCurve (to: points[2], control1: points[0], control2: points[1])
      case .closePath:
        path.closeSubpath ()
      @unknown default:
         ()
      }
    }
    return path
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func CGPathCallback (_ info : UnsafeMutableRawPointer?, _ element : UnsafePointer<CGPathElement>) {
  if let bezierPath : NSBezierPath = info?.load (as: NSBezierPath.self) {
    let points = element.pointee.points
    switch element.pointee.type {
    case .moveToPoint:
      bezierPath.move (to: points [0])
    case .addLineToPoint:
      bezierPath.line (to: points [0])
    case .addQuadCurveToPoint:
        let qp0 = bezierPath.currentPoint
        let qp1 = points [0]
        let qp2 = points [1]
      //  NSPoint qp0 = bezierPath.currentPoint, qp1 = points[0], qp2 = points[1], cp1, cp2;
        let m : CGFloat = 2.0 / 3.0
        let cp1 = NSPoint (x: qp0.x + ((qp1.x - qp0.x) * m), y: qp0.y + ((qp1.y - qp0.y) * m))
//        cp1.x = (qp0.x + ((qp1.x - qp0.x) * m));
//        cp1.y = (qp0.y + ((qp1.y - qp0.y) * m));
        let cp2 = NSPoint (x: qp2.x + ((qp1.x - qp2.x) * m), y: qp2.y + ((qp1.y - qp2.y) * m))
//        cp2.x = (qp2.x + ((qp1.x - qp2.x) * m));
//        cp2.y = (qp2.y + ((qp1.y - qp2.y) * m));
        bezierPath.curve (to: qp2, controlPoint1: cp1, controlPoint2: cp2)
    case .addCurveToPoint:
      bezierPath.curve (to:points[2], controlPoint1: points[0], controlPoint2: points[1])
    case .closeSubpath:
      bezierPath.close ()
    @unknown default:
      ()
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
