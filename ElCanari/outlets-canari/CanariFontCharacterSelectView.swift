import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let CANARI_FONT_CHARACTER_COUNT = 224 // From 0x20 to 0xFF, MacRoman encoding

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let CHARACTER_WIDTH  : CGFloat = 20.0
private let CHARACTER_HEIGHT : CGFloat = 20.0
private let LEFT_MARGIN      : CGFloat = 40.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariFontCharacterSelectView) class CanariFontCharacterSelectView : NSView, EBUserClassNameProtocol {
  private var mSelectedCharacterCode : UInt = 0
  private var mMouseDownCharacterCode : UInt = 0

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
    noteObjectDeallocation (self)
  }

  //····················································································································
  
  func selectedCharacterCode () -> UInt {
    return mSelectedCharacterCode
  }

  //····················································································································
  
  func setMouseDownSelectedCharacterCode (_ inCharacterCode : UInt) {
    mMouseDownCharacterCode = inCharacterCode
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
      var selectedCharCode : UInt = 0
      var c : UInt = 0x20
      while (c < 0x100) && !found {
        if (NSPointInRect (eventLocationInLocalCoordinates, rectangleForCharacter (c))) {
          found = true
          selectedCharCode = c
        }
        c += 1
      }
    //---
      if (mSelectedCharacterCode != selectedCharCode) {
        self.setNeedsDisplay (rectangleForCharacter (mSelectedCharacterCode))
        self.setNeedsDisplay (rectangleForCharacter (selectedCharCode))
        mSelectedCharacterCode = selectedCharCode
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
      let titleAttributes : [String:AnyObject] = [
        NSFontAttributeName : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize () / 1.5)
      ]
      "Mac".draw   (at: NSPoint (x:5.0, y: 1.0 + 14.5 * CHARACTER_HEIGHT), withAttributes:titleAttributes)
      "Roman".draw (at: NSPoint (x:5.0, y: 1.0 + 14.0 * CHARACTER_HEIGHT), withAttributes:titleAttributes)
    }
  //---
    let titleAttributes : [String:AnyObject] = [
      NSFontAttributeName : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize ()),
      NSForegroundColorAttributeName : NSColor.blue
    ]
  //--- Title
    for c : UInt in 0 ... 15 {
      let r = rectangleForColumnTitle (c)
      let pointCode = (c < 10) ? (c + 0x30) : (c + 0x37)
      let s = String (format:"%C", arguments: [pointCode])
      let size = s.size (withAttributes: titleAttributes)
      let p = NSPoint (x:r.origin.x + (CHARACTER_WIDTH - size.width) / 2.0, y:r.origin.y)
      s.draw (at: p, withAttributes:titleAttributes)
    }
  //--- Row title
    for c : UInt in 2 ... 15 {
      let p = originForUpperRowsTitle (c)
      let s = String (format:"%04hX:", arguments: [c * 16])
      s.draw (at: p, withAttributes:titleAttributes)
    }
  //---
    let attributes : [String:AnyObject] = [
      NSFontAttributeName : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize ())
    ]
    for c : UInt in 0x20 ... 0xFF {
      drawCharacter (c, attributes:attributes)
    }
  }

  //····················································································································

  func drawCharacter (_ inCharacter : UInt, attributes:[String:AnyObject]) {
    let r = rectangleForCharacter (inCharacter)
    if mSelectedCharacterCode == inCharacter {
      NSColor.lightGray.setFill ()
      NSBezierPath.fill (r)
    }
    if mMouseDownCharacterCode == inCharacter {
      NSColor.blue.setStroke ()
      NSBezierPath.stroke (NSInsetRect (r, 0.5, 0.5))
    }
    let data = Data ([UInt8 (inCharacter)])
    let s = String (data: data, encoding: .macOSRoman)!
    let size = s.size (withAttributes: attributes)
    let p = NSPoint (x:r.origin.x + (CHARACTER_WIDTH - size.width) / 2.0, y:r.origin.y)
    s.draw (at: p, withAttributes:attributes)
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

private func rectangleForCharacter (_ inCharacter : UInt) -> NSRect {
  let r = NSRect (
    x: 1.0 + LEFT_MARGIN + CGFloat (inCharacter % 16) * CHARACTER_WIDTH,
    y: 1.0 + CGFloat (15 - (inCharacter / 16)) * CHARACTER_HEIGHT,
    width: CHARACTER_WIDTH,
    height: CHARACTER_HEIGHT
  )
  return r ;
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
