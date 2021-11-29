import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let CHARACTER_WIDTH  : CGFloat = 20.0
private let CHARACTER_HEIGHT : CGFloat = 20.0
private let LEFT_MARGIN      : CGFloat = 40.0
private let SCROLL_TIMER_PERIOD = 0.1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class FontCharacterSelectView : NSView, EBUserClassNameProtocol {
  private var mSelectedCharacterCode : Int = 0
  private var mDefinedCharacterSet = Set <Int> ()
  private var mMouseDownCharacterCode : Int = 0
  private var mDefinedLineArray = [Int] ()
  private var mVerticalShift : CGFloat = 0.0
  private var mScrollTimer : Timer? = nil

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

  override func removeFromSuperview() {
    super.removeFromSuperview ()
    if let timer = self.mScrollTimer {
      timer.invalidate ()
      self.mScrollTimer = nil
    }
  }

  //····················································································································

  override func removeFromSuperviewWithoutNeedingDisplay () {
    super.removeFromSuperviewWithoutNeedingDisplay ()
    if let timer = self.mScrollTimer {
      timer.invalidate ()
      self.mScrollTimer = nil
    }
  }

  //····················································································································

  func setDefinedCharacterSet (_ inSet : Set <Int>) {
    self.mDefinedCharacterSet = inSet
    var definedLineSet = Set <Int> ()
    for codePoint in self.mDefinedCharacterSet {
      definedLineSet.insert (codePoint / 16) ;
    }
    self.mDefinedLineArray = [Int] (definedLineSet).sorted ()
    self.mVerticalShift = self.maximumVerticalShift ()
    if self.mVerticalShift < 0.0 {
      let timer = Timer (
        timeInterval: SCROLL_TIMER_PERIOD,
        target: self,
        selector: #selector (FontCharacterSelectView.timerScrollAction(_:)),
        userInfo: nil,
        repeats: true
      )
      RunLoop.current.add (timer, forMode: .default)
      self.mScrollTimer = timer
    }
  }

  //····················································································································

  private func maximumVerticalShift () -> CGFloat {
    let nominalHeight = CGFloat (self.mDefinedLineArray.count + 1) * CHARACTER_HEIGHT + 2.0
    return self.frame.size.height - nominalHeight
  }

  //····················································································································

  func selectedCharacterCode () -> Int {
    return self.mSelectedCharacterCode
  }

  //····················································································································
  
  func setMouseDownSelectedCharacterCode (_ inCharacterCode : Int) {
    self.mMouseDownCharacterCode = inCharacterCode
    let r = self.rectangleForCharacter (pointCode: inCharacterCode)
    if r.origin.y < 0.0 {
      self.mVerticalShift += -r.origin.y
    }else if r.maxY > self.bounds.maxY {
      self.mVerticalShift += r.maxY - self.bounds.maxY
    }
  }

  //····················································································································
  
  class func requiredSizeForCharacterSet (_ inSet : Set <Int>, _ currentWindow : NSWindow?) -> NSSize {
    var definedLineSet = Set <Int> ()
    for codePoint in inSet {
      definedLineSet.insert (codePoint / 16) ;
    }
    var height = CGFloat (definedLineSet.count + 1) * CHARACTER_HEIGHT + 2.0
    if let visibleFrame = currentWindow?.screen?.visibleFrame, height > visibleFrame.size.height {
      height = visibleFrame.size.height
    }
    return NSSize (width:16.0 * CHARACTER_WIDTH + 2.0 + LEFT_MARGIN, height: height)
  }

  //····················································································································

  func mouseDraggedAtScreenPoint (_ inEventLocationInScreenCoordinates : NSRect) {
    if let unwWindow = self.window {
      let eventLocationInWindowCoordinates = unwWindow.convertFromScreen (inEventLocationInScreenCoordinates).origin ;
      let eventLocationInLocalCoordinates = self.convert (eventLocationInWindowCoordinates, from:nil)
      if (eventLocationInLocalCoordinates.y > 0.0) && (eventLocationInLocalCoordinates.y < self.bounds.maxY) {
    //--- find row and column under mouse
        let column = Int ((eventLocationInLocalCoordinates.x - 1.0 - LEFT_MARGIN) / CHARACTER_WIDTH)
        let row = Int (CGFloat (self.mDefinedLineArray.count) - (eventLocationInLocalCoordinates.y - self.mVerticalShift) / CHARACTER_HEIGHT)
      //--- On a character ?
        if (column >= 0) && (column < 16) && (row >= 0) && (row < self.mDefinedLineArray.count) {
          let codePointUnderMouse = self.mDefinedLineArray [row] * 16 + column
          if self.mDefinedCharacterSet.contains (codePointUnderMouse), self.mSelectedCharacterCode != codePointUnderMouse {
            if let row = self.mDefinedLineArray.firstIndex (of: self.mSelectedCharacterCode / 16) {
              let r = self.rectangleForCharacter (atLineIndex: row, column: self.mSelectedCharacterCode % 16)
              self.setNeedsDisplay (r.insetBy(dx: -1.0, dy: -1.0))
            }
            let r = self.rectangleForCharacter (atLineIndex: row, column: column)
            self.setNeedsDisplay (r.insetBy(dx: -1.0, dy: -1.0))
            self.mSelectedCharacterCode = codePointUnderMouse
          }
        }
      }
    }
  }

  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    let titleAttributes : [NSAttributedString.Key : AnyObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize),
      NSAttributedString.Key.foregroundColor : NSColor.blue
    ]
    do{
    //--- "UTF" title
      let p = NSPoint (x: 5.0, y: 1.0 + CGFloat (self.mDefinedLineArray.count) * CHARACTER_HEIGHT + self.mVerticalShift)
      if p.y < inDirtyRect.maxY {
        let UTFAttributes : [NSAttributedString.Key : AnyObject] = [
          NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
        ]
        "UTF".draw (at: p, withAttributes: UTFAttributes)
      }
    //--- Title
      for c : UInt in 0 ... 15 {
        let r = rectangleForColumnTitle (c)
        let pointCode = (c < 10) ? (c + 0x30) : (c + 0x37)
        let s = String (format:"%C", arguments: [pointCode])
        let size = s.size (withAttributes: titleAttributes)
        let p = NSPoint (x:r.origin.x + (CHARACTER_WIDTH - size.width) / 2.0, y: r.origin.y)
        s.draw (at: p, withAttributes: titleAttributes)
      }
    }
  //--- Row title
    var lineIndex = 0
    for line in self.mDefinedLineArray {
      let p = originForRowTitle (lineIndex)
      lineIndex += 1
      if (p.y >= inDirtyRect.minY) && (p.y <= inDirtyRect.maxY) {
        let s = String (format:"%04hX:", arguments: [line * 16])
        s.draw (at: p, withAttributes: titleAttributes)
      }
    }
  //--- Draw characters
    for lineIndex in 0 ..< self.mDefinedLineArray.count {
      self.drawCharacters (forLineIndex: lineIndex, inDirtyRect)
    }
  }

  //····················································································································

  func drawCharacters (forLineIndex inLineIndex : Int, _ inDirtyRect : NSRect) {
    var charRect = self.rectangleForCharacter (atLineIndex: inLineIndex, column: 0)
    if (charRect.minY >= inDirtyRect.minY) && (max (charRect.minY, inDirtyRect.minY) <= min (charRect.maxY, inDirtyRect.maxY)) {
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
          let foreColor : NSColor
          if self.mDefinedCharacterSet.contains (codePoint) {
            foreColor = .blue
          }else{
            foreColor = .lightGray
          }
          let attributes : [NSAttributedString.Key:AnyObject] = [
            NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize),
            NSAttributedString.Key.foregroundColor : foreColor
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
    let p = NSPoint (x: 5.0, y: 1.0 + CGFloat (self.mDefinedLineArray.count - 1 - inRow) * CHARACTER_HEIGHT + self.mVerticalShift )
    return p
  }

  //····················································································································

  private func rectangleForColumnTitle (_ inCharacter : UInt) -> NSRect {
    let r = NSRect (
      x: 1.0 + LEFT_MARGIN + CGFloat (inCharacter) * CHARACTER_WIDTH,
      y: 1.0 + CGFloat (self.mDefinedLineArray.count) * CHARACTER_HEIGHT + self.mVerticalShift ,
      width: CHARACTER_WIDTH,
      height : CHARACTER_HEIGHT
    )
    return r
  }

  //····················································································································

  private func rectangleForCharacter (atLineIndex inLineIndex : Int, column inColumn : Int) -> NSRect {
    let r = NSRect (
      x: 1.0 + LEFT_MARGIN + CGFloat (inColumn) * CHARACTER_WIDTH,
      y: 1.0 + CGFloat (self.mDefinedLineArray.count - 1 - inLineIndex) * CHARACTER_HEIGHT + self.mVerticalShift ,
      width: CHARACTER_WIDTH,
      height: CHARACTER_HEIGHT
    )
    return r
  }

  //····················································································································

  private func rectangleForCharacter (pointCode inPointCode : Int) -> NSRect {
    let column = inPointCode % 16
    let lineIndex = self.mDefinedLineArray.firstIndex (of: inPointCode / 16) ?? 0
    let r = NSRect (
      x: 1.0 + LEFT_MARGIN + CGFloat (column) * CHARACTER_WIDTH,
      y: 1.0 + CGFloat (self.mDefinedLineArray.count - 1 - lineIndex) * CHARACTER_HEIGHT + self.mVerticalShift ,
      width: CHARACTER_WIDTH,
      height: CHARACTER_HEIGHT
    )
    return r
  }

  //····················································································································

  @objc func timerScrollAction (_ : Timer) {
    if let myWindow = self.window {
      let mouseRect = NSRect (origin: NSEvent.mouseLocation, size: NSSize ())
      let eventLocationInWindowCoordinates = myWindow.convertFromScreen (mouseRect).origin
      let eventLocationInLocalCoordinates = self.convert (eventLocationInWindowCoordinates, from:nil)
      let maxVerticalShift = self.maximumVerticalShift ()
      if (eventLocationInLocalCoordinates.y < 0.0) && (self.mVerticalShift < 0.0) {
        self.mVerticalShift += CHARACTER_HEIGHT
        if self.mVerticalShift > 0.0 {
          self.mVerticalShift = 0.0
        }
        self.needsDisplay = true
      }else if (eventLocationInLocalCoordinates.y > self.bounds.maxY) && (self.mVerticalShift > maxVerticalShift) {
        self.mVerticalShift -= CHARACTER_HEIGHT
        if self.mVerticalShift < maxVerticalShift {
          self.mVerticalShift = maxVerticalShift
        }
        self.needsDisplay = true
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
