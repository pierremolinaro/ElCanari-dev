//
//  BézierPath.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 22/06/2019.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// BézierPath
//--------------------------------------------------------------------------------------------------

struct BézierPath : Hashable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    self.mPath = NSBezierPath ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (rect inRect : NSRect) {
    self.mPath = NSBezierPath (rect: inRect)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (ovalIn inRect : NSRect) {
    self.mPath = NSBezierPath (ovalIn: inRect)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (roundedRect rect : NSRect, xRadius inXRadius : CGFloat, yRadius inYRadius : CGFloat) {
    self.mPath = NSBezierPath (roundedRect: rect, xRadius: inXRadius, yRadius: inYRadius)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (_ inBezierPath : NSBezierPath) {
    self.mPath = inBezierPath.copy () as! NSBezierPath
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (withString inString : String,
        at inOrigin : NSPoint,
        _ inHorizontalAlignment : BézierPath.TextHorizontalAlignment,
        _ inVerticalAlignment : BézierPath.TextVerticalAlignment,
        withAttributes inTextAttributes : [NSAttributedString.Key : Any]) {
    self.mPath = NSBezierPath ()
    if inString != "" {
    //--- Font
      let font : NSFont
      if let f = inTextAttributes [NSAttributedString.Key.font] as? NSFont {
        font = f
      }else{
        font = NSFont ()
      }
    //--- Disable ligatures
      var t = inTextAttributes
      t [NSAttributedString.Key.ligature] = 0
    //--- Build text infrastructure
      let textStore = NSTextStorage (string: inString, attributes: t)
      let textContainer = NSTextContainer ()
      let myLayout = NSLayoutManager ()
      myLayout.addTextContainer (textContainer)
      textStore.addLayoutManager (myLayout)
    //--- Get CCGlyph array
      let glyphRange : NSRange = myLayout.glyphRange (for: textContainer)
      var cgGlyphArray = [CGGlyph] (repeating: CGGlyph (), count:glyphRange.length)
      _ = unsafe myLayout.getGlyphs (in: glyphRange, glyphs: &cgGlyphArray, properties: nil, characterIndexes: nil, bidiLevels: nil)
    //--- Enter in Bezier path
      self.mPath.move (to: NSPoint (x: inOrigin.x, y: inOrigin.y - 2.0 * font.descender))
      unsafe self.mPath.append (withCGGlyphs: &cgGlyphArray, count: glyphRange.length, in: font)
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
      case .baseline :
        deltaY = 2.0 * font.descender
      case .below :
        deltaY -= height
      }
      var af = AffineTransform ()
      af.translate (x: deltaX, y: deltaY)
      self.mPath.transform (using: af)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mPath : NSBezierPath

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var nsBezierPath : NSBezierPath {
    return self.mPath.copy () as! NSBezierPath
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  nonisolated static func == (lhs : BézierPath, rhs : BézierPath) -> Bool {
    return ObjectIdentifier (lhs.mPath) == ObjectIdentifier (rhs.mPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func >= (lhs : BézierPath, rhs : BézierPath) -> Bool {
    return ObjectIdentifier (lhs.mPath) >= ObjectIdentifier (rhs.mPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Hashable Protocol
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  nonisolated func hash (into hasher: inout Hasher) {
    ObjectIdentifier (self.mPath).hash (into: &hasher)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var lineWidth : CGFloat {
    get {
      return self.mPath.lineWidth
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! NSBezierPath
      }
      self.mPath.lineWidth = newValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var lineCapStyle : NSBezierPath.LineCapStyle {
    get {
      return self.mPath.lineCapStyle
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! NSBezierPath
      }
      self.mPath.lineCapStyle = newValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var lineJoinStyle : NSBezierPath.LineJoinStyle {
    get {
      return self.mPath.lineJoinStyle
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! NSBezierPath
      }
      self.mPath.lineJoinStyle = newValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var windingRule : NSBezierPath.WindingRule {
    get {
      return self.mPath.windingRule
    }
    set {
      if !isKnownUniquelyReferenced (&self.mPath) {
        self.mPath = self.mPath.copy () as! NSBezierPath
      }
      self.mPath.windingRule = newValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendRect (_ inRect : NSRect) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.appendRect (inRect)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendOval (in inRect : NSRect) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.appendOval (in: inRect)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func move (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.move (to: inPoint)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func relativeMove (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.relativeMove (to: inPoint)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func line (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.line (to: inPoint)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func relativeLine (to inPoint : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.relativeLine (to: inPoint)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func curve (to inPoint : NSPoint, controlPoint1 inCP1 : NSPoint, controlPoint2 inCP2 : NSPoint) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.curve (to: inPoint, controlPoint1: inCP1, controlPoint2: inCP2)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func close () {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.close ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  mutating func relativeLine (to inPoint : NSPoint) {
//    if !isKnownUniquelyReferenced (&self.mPath) {
//      self.mPath = self.mPath.copy () as! NSBezierPath
//    }
//    self.mPath.relativeLine (to: inPoint)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func transform (using transform: AffineTransform) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.transform (using: transform)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func transformed (by transform: AffineTransform) -> BézierPath {
    var result = self
    result.transform (using: transform)
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func stroke () {
    self.mPath.stroke ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func fill () {
    self.mPath.fill ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func addClip () {
    self.mPath.addClip ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func contains (_ point: NSPoint) -> Bool {
    return self.mPath.contains (point)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var bounds : NSRect {
    if self.mPath.isEmpty {
      return .null
    }else{
      return self.mPath.bounds
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var isEmpty : Bool {
    return self.mPath.isEmpty
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (_ inBezierPath : NSBezierPath) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.append (inBezierPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func append (_ inBezierPath : BézierPath) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    self.mPath.append (inBezierPath.nsBezierPath)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
          let type = unsafe flattenedPath.element (at: idx, associatedPoints: &points)
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
          case .cubicCurveTo:
            ()
          case .quadraticCurveTo:
            ()
          @unknown default:
            ()
          }
        }
      }
    }
    return intersect
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var pathToFillByStroking : BézierPath {
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
    var path = BézierPath ()
    // https://forums.swift.org/t/handling-the-new-forming-unsaferawpointer-warning/65523/4
//    public typealias CGPathApplierFunction = @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CGPathElement>) -> Void
    let callBack : @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CGPathElement>) -> Void = {
      unsafe pathByStrokingCallback ($0, $1)
    }
    unsafe withUnsafeMutablePointer (to: &path.mPath) {
   //   cgPath.apply (info: $0, function: pathByStrokingCallback)
      unsafe cgPath.apply (info: $0, function: callBack)
    }
    return path
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (oblongInRect inRect : NSRect) {
    self.init ()
    let width = inRect.size.width
    let height = inRect.size.height
    if width < height {
      self.mPath.appendRoundedRect (inRect, xRadius: width / 2.0, yRadius: width / 2.0)
    }else if width > height {
      self.mPath.appendRoundedRect (inRect, xRadius: height / 2.0, yRadius: height / 2.0)
    }else{
      self.mPath.appendOval (in: inRect)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  mutating func appendOblong (in inRect : NSRect) {
    if !isKnownUniquelyReferenced (&self.mPath) {
      self.mPath = self.mPath.copy () as! NSBezierPath
    }
    let width = inRect.size.width
    let height = inRect.size.height
    if width < height {
      self.mPath.appendRoundedRect (inRect, xRadius: width / 2.0, yRadius: width / 2.0)
    }else if width > height {
      self.mPath.appendRoundedRect (inRect, xRadius: height / 2.0, yRadius: height / 2.0)
    }else{
      self.mPath.appendOval (in: inRect)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (octogonInRect inRect : NSRect) {
    self.init ()
    let s2 : CGFloat = sqrt (2.0)
    let w = inRect.size.width
    let h = inRect.size.height
    let x = inRect.origin.x
    let y = inRect.origin.y
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var reversed : BézierPath {
    var result = BézierPath ()
    result.mPath = self.mPath.reversed
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func linePathesByFlattening (withFlatness inFlatness : CGFloat) -> [EBLinePath] { // Array of pathes
    let savedDefaultFlatness = NSBezierPath.defaultFlatness
    NSBezierPath.defaultFlatness = inFlatness
    let flattenedBP = self.mPath.flattened
    NSBezierPath.defaultFlatness = savedDefaultFlatness
    var result = [EBLinePath] ()
    var curvePoints = [NSPoint] (repeating: .zero, count: 3)
    var optionalStartPoint : NSPoint? = nil
    var linePoints = [NSPoint] ()
    for idx in 0 ..< flattenedBP.elementCount {
      let type = unsafe flattenedBP.element (at: idx, associatedPoints: &curvePoints)
      switch type {
      case .moveTo:
        if let startPoint = optionalStartPoint, linePoints.count > 0 {
          let path = EBLinePath (origin: startPoint, lines: linePoints, closed: false)
          result.append (path)
        }
        optionalStartPoint = curvePoints[0]
        linePoints.removeAll ()
      case .lineTo:
        linePoints.append (curvePoints[0])
      case .curveTo: // No curve, Bezier path is flattened
        ()
      case .closePath:
        if let startPoint = optionalStartPoint, linePoints.count > 0  {
          let path = EBLinePath (origin: startPoint, lines: linePoints, closed: true)
          result.append (path)
          optionalStartPoint = nil
          linePoints.removeAll ()
        }
      case .cubicCurveTo:
        ()
      case .quadraticCurveTo:
        ()
      @unknown default:
         ()
      }
    }
    if let startPoint = optionalStartPoint, linePoints.count > 0 {
      let path = EBLinePath (origin: startPoint, lines: linePoints, closed: false)
      result.append (path)
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func productSegments (withFlatness inFlatness : CGFloat,
                        transformedBy inAffineTransform : AffineTransform,
                        clippedBy inClipRect : NSRect) -> [ProductSegment] {
    let pathArray = self.linePathesByFlattening (withFlatness: inFlatness)
    var transformedLinePathArray = [EBLinePath] ()
    for linePath in pathArray {
      let transformedLinePath = linePath.transformed (by: inAffineTransform)
      transformedLinePathArray += transformedLinePath.linePathClipped (by: inClipRect)
    }
    var result = [ProductSegment] ()
    for linePath in transformedLinePathArray {
      let firstPoint = ProductPoint (cocoaPoint: linePath.origin)
      var currentPoint = firstPoint
      for p in linePath.lines {
        let pp = ProductPoint (cocoaPoint: p)
        result.append (ProductSegment (p1: currentPoint, p2: pp))
        currentPoint = pp
      }
      if linePath.closed {
        result.append (ProductSegment (p1: currentPoint, p2: firstPoint))
      }
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum TextHorizontalAlignment {
    case onTheRight
    case center
    case onTheLeft
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  enum TextVerticalAlignment {
    case above
    case center
    case baseline
    case below
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
// NSBezierPath
//--------------------------------------------------------------------------------------------------

extension NSBezierPath {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // https://stackoverflow.com/questions/1815568/how-can-i-convert-nsbezierpath-to-cgpath
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var cgPath : CGPath {
    let path = CGMutablePath ()
    var points = [NSPoint] (repeating: .zero, count: 3)
    for idx in 0 ..< self.elementCount {
      let type = unsafe self.element (at: idx, associatedPoints: &points)
      switch type {
      case .moveTo:
        path.move (to: points[0])
      case .lineTo:
        path.addLine (to: points[0])
      case .curveTo:
        path.addCurve (to: points[2], control1: points[0], control2: points[1])
      case .closePath:
        path.closeSubpath ()
      case .cubicCurveTo:
        ()
      case .quadraticCurveTo:
        ()
      @unknown default:
         ()
      }
    }
    return path
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

private func pathByStrokingCallback (_ inInfo : UnsafeMutableRawPointer?, _ inElement : UnsafePointer<CGPathElement>) {
  if let bezierPath : NSBezierPath = unsafe inInfo?.load (as: NSBezierPath.self) {
    let points = unsafe inElement.pointee.points
    switch unsafe inElement.pointee.type {
    case .moveToPoint:
      unsafe bezierPath.move (to: points [0])
    case .addLineToPoint:
      unsafe bezierPath.line (to: points [0])
    case .addQuadCurveToPoint:
      let qp0 = bezierPath.currentPoint
      let qp1 = unsafe points [0]
      let qp2 = unsafe points [1]
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
      unsafe bezierPath.curve (to: points[2], controlPoint1: points[0], controlPoint2: points[1])
    case .closeSubpath:
      bezierPath.close ()
    @unknown default:
      ()
    }
  }
}

//--------------------------------------------------------------------------------------------------

extension Array where Element == BézierPath {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var boundingBox : NSRect {
   var r = NSRect.null
   for path in self {
     if !path.isEmpty {
       r = r.union (path.bounds)
     }
   }
   return r
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
