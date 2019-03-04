import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let CHARACTER_WIDTH  : CGFloat = 20.0
private let CHARACTER_HEIGHT : CGFloat = 20.0
private let LEFT_MARGIN      : CGFloat = 40.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariFontCharacterSelectView : NSView, EBUserClassNameProtocol {
  private var mSelectedCharacterCode : Int = 0
  private var mMouseDownCharacterCode : Int = 0

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (String (describing: type(of: self)))
  }

  //····················································································································
  
  func selectedCharacterCode () -> Int {
    return self.mSelectedCharacterCode
  }

  //····················································································································
  
  func setMouseDownSelectedCharacterCode (_ inCharacterCode : Int) {
    self.mMouseDownCharacterCode = inCharacterCode
  }

  //····················································································································
  
  class func requiredSize () -> NSSize {
    return NSSize (width:16.0 * CHARACTER_WIDTH + 2.0 + LEFT_MARGIN, height:15.0 * CHARACTER_HEIGHT + 2.0)
  }

  //····················································································································

  func mouseDraggedAtScreenPoint (_ inEventLocationInScreenCoordinates : NSRect) {
    if let unwWindow = self.window {
      let eventLocationInWindowCoordinates = unwWindow.convertFromScreen (inEventLocationInScreenCoordinates).origin ;
      let eventLocationInLocalCoordinates = self.convert (eventLocationInWindowCoordinates, from:nil)
    //--- Find character under mouse
      var found = false
      var selectedCharCode : Int = 0
      var c : Int = 0x20
      while (c < 0x100) && !found {
        if (NSPointInRect (eventLocationInLocalCoordinates, rectangleForCharacter (c))) {
          found = true
          selectedCharCode = c
        }
        c += 1
      }
    //---
      if (self.mSelectedCharacterCode != selectedCharCode) {
        self.setNeedsDisplay (rectangleForCharacter (mSelectedCharacterCode))
        self.setNeedsDisplay (rectangleForCharacter (selectedCharCode))
        self.mSelectedCharacterCode = selectedCharCode
      }
    }
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
//    NSColor.black.setStroke ()
//    NSBezierPath.setDefaultLineWidth (2.0)
//    NSBezierPath.stroke (NSInsetRect (self.bounds, 1.0, 1.0))
  //--- "MacRoman" title
    do{
      let titleAttributes : [NSAttributedString.Key:AnyObject] = [
        NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
      ]
      "UTF".draw (at: NSPoint (x:5.0, y: 1.0 + 14.0 * CHARACTER_HEIGHT), withAttributes:titleAttributes)
    }
  //---
    let titleAttributes : [NSAttributedString.Key:AnyObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize),
      NSAttributedString.Key.foregroundColor : NSColor.blue
    ]
  //--- Title
    for c : UInt in 0 ... 15 {
      let r = rectangleForColumnTitle (c)
      let pointCode = (c < 10) ? (c + 0x30) : (c + 0x37)
      let s = String (format:"%C", arguments: [pointCode])
      let size = s.size (withAttributes: titleAttributes)
      let p = NSPoint (x:r.origin.x + (CHARACTER_WIDTH - size.width) / 2.0, y:r.origin.y)
      s.draw (at: p, withAttributes: titleAttributes)
    }
  //--- Row title
    var line : UInt = 2
    for c : UInt in Array (2 ... 7) + Array (10 ... 15) {
      let p = originForUpperRowsTitle (line)
      line += 1
      let s = String (format:"%04hX:", arguments: [c * 16])
      s.draw (at: p, withAttributes: titleAttributes)
    }
  //---
    let attributes : [NSAttributedString.Key:AnyObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    for c : Int in Array (0x20 ... 0x7F) + Array (0xA0 ... 0xFF) {
      drawCharacter (c, attributes:attributes)
    }
  }

  //····················································································································

  func drawCharacter (_ inCharacter : Int, attributes:[NSAttributedString.Key:AnyObject]) {
    let r = rectangleForCharacter (inCharacter)
    if self.mSelectedCharacterCode == inCharacter {
      NSColor.lightGray.setFill ()
      NSBezierPath.fill (r)
    }
    if self.mMouseDownCharacterCode == inCharacter {
      NSColor.blue.setStroke ()
      NSBezierPath.stroke (NSInsetRect (r, 0.5, 0.5))
    }
    let s = String (Unicode.Scalar (inCharacter)!)
    let size = s.size (withAttributes: attributes)
    let p = NSPoint (x:r.origin.x + (CHARACTER_WIDTH - size.width) / 2.0, y:r.origin.y)
    s.draw (at: p, withAttributes: attributes)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func originForUpperRowsTitle (_ inRow : UInt) -> NSPoint {
  let p = NSPoint (x:5.0, y:1.0 + CGFloat (15 - inRow) * CHARACTER_HEIGHT)
  return p
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func originForLowerRowsTitle (_ inRow : UInt) -> NSPoint {
  let p = NSPoint (x:5.0, y:1.0 + CGFloat (17 - inRow) * CHARACTER_HEIGHT)
  return p
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func rectangleForColumnTitle (_ inCharacter : UInt) -> NSRect {
  let r = NSRect (
    x: 1.0 + LEFT_MARGIN + CGFloat (inCharacter) * CHARACTER_WIDTH,
    y: 1.0 + 14.0 * CHARACTER_HEIGHT,
    width: CHARACTER_WIDTH,
    height : CHARACTER_HEIGHT
  )
  return r
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func rectangleForCharacter (_ inCharacter : Int) -> NSRect {
  var line = inCharacter / 16
  if inCharacter >= 0x80 {
    line -= 2
  }
  let r = NSRect (
    x: 1.0 + LEFT_MARGIN + CGFloat (inCharacter % 16) * CHARACTER_WIDTH,
    y: 1.0 + CGFloat (15 - line) * CHARACTER_HEIGHT,
    width: CHARACTER_WIDTH,
    height: CHARACTER_HEIGHT
  )
  return r ;
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
