import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let CHARACTER_WIDTH  : CGFloat = 20.0
private let CHARACTER_HEIGHT : CGFloat = 20.0
private let LEFT_MARGIN      : CGFloat = 40.0

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class FontCharacterSelectView : NSView, EBUserClassNameProtocol {
  private var mSelectedCharacterCode : Int = 0
  private var mDefinedCharacterSet = Set <Int> ()
  private var mMouseDownCharacterCode : Int = 0
  private var mDefinedLineArray = [Int] ()

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func setDefinedCharacterSet (_ inSet : Set <Int>) -> Void {
    self.mDefinedCharacterSet = inSet
    var definedLineSet = Set <Int> ()
    for codePoint in self.mDefinedCharacterSet {
      definedLineSet.insert (codePoint / 16) ;
    }
    self.mDefinedLineArray = [Int] (definedLineSet).sorted ()
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
  
  class func requiredSizeForCharacterSet (_ inSet : Set <Int>) -> NSSize {
    var definedLineSet = Set <Int> ()
    for codePoint in inSet {
      definedLineSet.insert (codePoint / 16) ;
    }
    let definedLineArray = [Int] (definedLineSet).sorted ()
    return NSSize (width:16.0 * CHARACTER_WIDTH + 2.0 + LEFT_MARGIN, height: CGFloat (definedLineArray.count + 1) * CHARACTER_HEIGHT + 2.0)
  }

  //····················································································································

  func mouseDraggedAtScreenPoint (_ inEventLocationInScreenCoordinates : NSRect) {
    if let unwWindow = self.window {
      let eventLocationInWindowCoordinates = unwWindow.convertFromScreen (inEventLocationInScreenCoordinates).origin ;
      let eventLocationInLocalCoordinates = self.convert (eventLocationInWindowCoordinates, from:nil)
    //--- find row and column under mouse
      let column = Int ((eventLocationInLocalCoordinates.x - 1.0 - LEFT_MARGIN) / CHARACTER_WIDTH)
      let row = Int (CGFloat (self.mDefinedLineArray.count) - eventLocationInLocalCoordinates.y / CHARACTER_HEIGHT)
    //--- On a character ?
      if (column >= 0) && (column < 16) && (row >= 0) && (row < self.mDefinedLineArray.count) {
        let codePointUnderMouse = self.mDefinedLineArray [row] * 16 + column
        if self.mDefinedCharacterSet.contains (codePointUnderMouse), self.mSelectedCharacterCode != codePointUnderMouse {
        //  self.needsDisplay = true
          if let row = self.mDefinedLineArray.firstIndex (of: self.mSelectedCharacterCode / 16) {
            let r = self.rectangleForCharacter (atLineIndex: row, column: self.mSelectedCharacterCode % 16)
            self.setNeedsDisplay (r)
          }
          let r = self.rectangleForCharacter (atLineIndex: row, column: column)
          self.setNeedsDisplay (r)
          self.mSelectedCharacterCode = codePointUnderMouse
        }
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
      "UTF".draw (at: NSPoint (x:5.0, y: 1.0 + CGFloat (self.mDefinedLineArray.count) * CHARACTER_HEIGHT), withAttributes:titleAttributes)
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
    var lineIndex = 0
    for line in self.mDefinedLineArray {
      let p = originForRowTitle (lineIndex)
      lineIndex += 1
      let s = String (format:"%04hX:", arguments: [line * 16])
      s.draw (at: p, withAttributes: titleAttributes)
    }
  //--- Draw characters
    for lineIndex in 0 ..< self.mDefinedLineArray.count {
      self.drawCharacters (forLineIndex: lineIndex, inDirtyRect)
    }
  }

  //····················································································································

  func drawCharacters (forLineIndex inLineIndex : Int, _ inDirtyRect : NSRect) {
    var charRect = self.rectangleForCharacter (atLineIndex: inLineIndex, column: 0)
    if max (charRect.minY, inDirtyRect.minY) <= min (charRect.maxY, inDirtyRect.maxY) {
      let lineCodePoint = self.mDefinedLineArray [inLineIndex] * 16
      for codePoint in lineCodePoint ..< lineCodePoint + 16 {
        if self.mSelectedCharacterCode == codePoint {
          NSColor.lightGray.setFill ()
          NSBezierPath.fill (charRect)
        }
        if self.mMouseDownCharacterCode == codePoint {
          NSColor.blue.setStroke ()
          NSBezierPath.stroke (NSInsetRect (charRect, 0.5, 0.5))
        }
        if let uniscalar = Unicode.Scalar (codePoint) {
          let attributes : [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize),
            NSAttributedString.Key.foregroundColor : self.mDefinedCharacterSet.contains (codePoint) ? NSColor.black : .lightGray
          ]
          let s = String (uniscalar)
          let size = s.size (withAttributes: attributes)
          let p = NSPoint (x: charRect.origin.x + (CHARACTER_WIDTH - size.width) / 2.0, y: charRect.origin.y)
          s.draw (at: p, withAttributes: attributes)
        }
        charRect.origin.x += CHARACTER_WIDTH
      }
    }
  }

  //····················································································································

  fileprivate func originForRowTitle (_ inRow : Int) -> NSPoint {
    let p = NSPoint (x: 5.0, y: 1.0 + CGFloat (self.mDefinedLineArray.count - 1 - inRow) * CHARACTER_HEIGHT)
    return p
  }

  //····················································································································

  private func rectangleForColumnTitle (_ inCharacter : UInt) -> NSRect {
    let r = NSRect (
      x: 1.0 + LEFT_MARGIN + CGFloat (inCharacter) * CHARACTER_WIDTH,
      y: 1.0 + CGFloat (self.mDefinedLineArray.count) * CHARACTER_HEIGHT,
      width: CHARACTER_WIDTH,
      height : CHARACTER_HEIGHT
    )
    return r
  }

  //····················································································································

  private func rectangleForCharacter (atLineIndex inLineIndex : Int, column inColumn : Int) -> NSRect {
    let r = NSRect (
      x: 1.0 + LEFT_MARGIN + CGFloat (inColumn) * CHARACTER_WIDTH,
      y: 1.0 + CGFloat (self.mDefinedLineArray.count - 1 - inLineIndex) * CHARACTER_HEIGHT,
      width: CHARACTER_WIDTH,
      height: CHARACTER_HEIGHT
    )
    return r
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
