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

//  var bezierPath : NSBezierPath {
//    return self.mPath.copy () as! OCBezierPath
//  }

  //····················································································································

  init (_ inBezierPath : NSBezierPath) {
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// OCBezierPath
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate class OCBezierPath : NSBezierPath, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    self.lineWidth = 1.0
    self.lineCapStyle = .round
    self.lineJoinStyle = .round
  }

  //····················································································································

  override init () {
    super.init ()
    noteObjectAllocation (self)
    self.lineWidth = 1.0
    self.lineCapStyle = .round
    self.lineJoinStyle = .round
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
