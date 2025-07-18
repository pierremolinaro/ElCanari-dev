//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    extension NSBezierPath : EBStoredPropertyProtocol
//--------------------------------------------------------------------------------------------------

extension NSBezierPath : EBStoredPropertyProtocol, @unchecked @retroactive Sendable {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func ebHashValue () -> UInt32 {
    let s = self.archiveToString ()
    return s.ebHashValue ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func convertToNSObject () -> NSObject {
    let s = self.archiveToString ()
    return s as NSString
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func convertFromNSObject (object : NSObject) -> Self {
    let string = object as! String
    return Self.unarchiveFromString (string: string) as! Self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func archiveToString () -> String {
    var result = ""
    var idx = 0
    var points = [NSPoint] (repeating: .zero, count: 3)
    while idx < self.elementCount {
      let type = unsafe self.element (at: idx, associatedPoints: &points)
      idx += 1
      switch type {
      case .moveTo:
        result += ":\(points[0].x) \(points[0].y)"
      case .lineTo:
        result += ";\(points[0].x) \(points[0].y)"
      case .curveTo:
        result += "@\(points[0].x) \(points[0].y) \(points[1].x) \(points[1].y) \(points[2].x) \(points[2].y)"
      case .closePath:
        result += "#"
      case .cubicCurveTo:
        ()
      case .quadraticCurveTo:
        ()
      @unknown default :
        ()
      }
    }
    result += "*\(self.windingRule.rawValue) \(self.lineCapStyle.rawValue) \(self.lineJoinStyle.rawValue)"
    result += " \(self.lineWidth) \(self.flatness) \(self.miterLimit)"
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func unarchiveFromString (string : String) -> NSObject? {
    let bp = NSBezierPath ()
    let scanner = Scanner (string: string)
    var ok = true
    var loop = true
    while ok && loop {
      if scanner.scanString (":") != nil {
        if let x = scanner.scanDouble (), let y = scanner.scanDouble () {
          bp.move (to: NSPoint (x: CGFloat (x), y: CGFloat (y)))
        }else{
          ok = false
        }
      }else if scanner.scanString (";") != nil {
        if let x = scanner.scanDouble (), let y = scanner.scanDouble () {
          bp.line (to: NSPoint (x: CGFloat (x), y: CGFloat (y)))
        }else{
          ok = false
        }
      }else if scanner.scanString ("@") != nil {
        if let x0 = scanner.scanDouble (),
           let y0 = scanner.scanDouble (),
           let x1 = scanner.scanDouble (),
           let y1 = scanner.scanDouble (),
           let x2 = scanner.scanDouble (),
           let y2 = scanner.scanDouble () {
          bp.curve (
            to: NSPoint (x: CGFloat (x2), y: CGFloat (y2)),
            controlPoint1: NSPoint (x: CGFloat (x0), y: CGFloat (y0)),
            controlPoint2: NSPoint (x: CGFloat (x1), y: CGFloat (y1))
          )
        }else{
          ok = false
        }
      }else if scanner.scanString ("#") != nil {
        bp.close ()
      }else if scanner.scanString ("*") != nil {
        loop = false
      }
    }
    if ok {
      var windingRuleRawValue = 0
      ok = unsafe scanner.scanInt (&windingRuleRawValue)
      if ok, let windingRule = NSBezierPath.WindingRule (rawValue: UInt (windingRuleRawValue)) {
        bp.windingRule = windingRule
      }else{
        ok = false
      }
    }
    if ok {
      var lineCapStyleRawValue = 0
      ok = unsafe scanner.scanInt (&lineCapStyleRawValue)
      if ok, let lineCapStyle = NSBezierPath.LineCapStyle (rawValue: UInt (lineCapStyleRawValue)) {
        bp.lineCapStyle = lineCapStyle
      }else{
        ok = false
      }
    }
    if ok {
      var lineJoinStyleRawValue = 0
      ok = unsafe scanner.scanInt (&lineJoinStyleRawValue)
      if ok, let lineJoinStyle = NSBezierPath.LineJoinStyle (rawValue: UInt (lineJoinStyleRawValue)) {
        bp.lineJoinStyle = lineJoinStyle
      }else{
        ok = false
      }
    }
    if ok {
      if let lineWidth = scanner.scanDouble () {
        bp.lineWidth = CGFloat (lineWidth)
      }else{
        ok = false
      }
    }
    if ok {
      if let flatness = scanner.scanDouble () {
        bp.flatness = CGFloat (flatness)
      }else{
        ok = false
      }
    }
    if ok {
      if let miterLimit = scanner.scanDouble () {
        bp.miterLimit = CGFloat (miterLimit)
      }else{
        ok = false
      }
    }
    return bp
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func appendPropertyValueTo (_ ioData : inout Data) {
    ioData.append (self.archiveToString ().data (using: .utf8)!)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  static func unarchiveFromDataRange (_ inData : Data, _ inRange : NSRange) -> Self? {
    let dataSlice = inData [inRange.location ..< inRange.location + inRange.length]
    if let s = String (data: dataSlice, encoding: .utf8) {
      return NSBezierPath.unarchiveFromString (string: s) as? Self
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
