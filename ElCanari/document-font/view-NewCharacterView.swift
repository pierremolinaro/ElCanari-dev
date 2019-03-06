//
//  view-NewCharacterView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/09/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Placement
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let ADDRESS_COLUMN_WIDTH : CGFloat = 40.0
private let PLACEMENT_GRID : CGFloat = 20.0

private let LINE_COUNT = 0x100 - 2

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariCharacterView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class NewCharacterView : NSView, EBUserClassNameProtocol {

  //····················································································································

  override init(frame frameRect: NSRect) {
    super.init (frame: frameRect)
    noteObjectAllocation (self)
    let width = ADDRESS_COLUMN_WIDTH + 16.0 * PLACEMENT_GRID
    let height = PLACEMENT_GRID * CGFloat (LINE_COUNT)
    let newRect = CGRect (x:0.0, y:0.0, width: width, height: height)
    self.frame.size = newRect.size
    self.bounds = newRect
  }

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    let width = ADDRESS_COLUMN_WIDTH + 16.0 * PLACEMENT_GRID
    let height = PLACEMENT_GRID * CGFloat (LINE_COUNT)
    let newRect = CGRect (x:0.0, y:0.0, width: width, height: height)
    self.frame.size = newRect.size
    self.bounds = newRect
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    awakeFromNib
  //····················································································································

  override func awakeFromNib () { // Scroll view to display the first row
    self.scroll (CGPoint (x:0.0, y:self.bounds.maxY))
  }

  //····················································································································
  //    Implemented character set
  //····················································································································

  private var mImplementedCharacterSet = Set <Int> ()

  //····················································································································

  func setImplementedCharacterSet (_ inSet : Set <Int>) {
    mImplementedCharacterSet = inSet
    self.setNeedsDisplay (self.visibleRect)
 //   self.needsDisplay = true
    mSelectedCharacter = nil
  }

  //····················································································································

  fileprivate func rectForCharacter (_ inCode : Int) -> CGRect {
    return CGRect (
      x: ADDRESS_COLUMN_WIDTH + PLACEMENT_GRID * CGFloat (inCode % 16),
      y: PLACEMENT_GRID * CGFloat (LINE_COUNT - 1 - inCode / 16 - 2),
      width: PLACEMENT_GRID,
      height: PLACEMENT_GRID
    )
  }

  //····················································································································

  fileprivate var mSelectedCharacter : Int? = nil {
    didSet {
      if let c = oldValue {
        self.setNeedsDisplay (rectForCharacter (c))
      }
      if let c = mSelectedCharacter {
        self.setNeedsDisplay (rectForCharacter (c))
      }
      self.needsDisplay = true
    }
  }

  //····················································································································

  var selectedCharacter : Int? { return self.mSelectedCharacter }

  //····················································································································
  //  isOpaque
  //····················································································································

  override var isOpaque : Bool { return true }

  //····················································································································
  //  Draw rect
  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
  //--- Draw background
    NSColor.white.setFill ()
    NSBezierPath.fill (inDirtyRect)
  //--- Draw lines
    var line = Int ((PLACEMENT_GRID * CGFloat (LINE_COUNT) - inDirtyRect.maxY) / PLACEMENT_GRID)
    var y = PLACEMENT_GRID * CGFloat (LINE_COUNT - line)
    while (line < LINE_COUNT) && (y > inDirtyRect.minY) {
      y -= PLACEMENT_GRID
      let dict : [NSAttributedString.Key : Any]
      if let font = NSFont (name: "Menlo", size: 12.0) {
        dict = [NSAttributedString.Key.font : font]
      }else{
        dict = [:]
      }
      let title = String (format: "%04X", (line + 2) * 16)
      let titleAttributedString = NSAttributedString (string: title, attributes: dict)
      titleAttributedString.draw (at: CGPoint (x:5.0, y: y + 3.0))
      var x = ADDRESS_COLUMN_WIDTH
      for idx in 0 ..< 16 {
        let code = (line + 2) * 16 + idx
        let rChar = CGRect (x:x, y:y, width: PLACEMENT_GRID, height: PLACEMENT_GRID)
        if let selectedCharacter = mSelectedCharacter, selectedCharacter == code {
          NSColor.lightGray.setFill ()
          NSBezierPath.fill (rChar)
        }else if mImplementedCharacterSet.contains (code) {
          NSColor.yellow.setFill ()
          NSBezierPath.fill (rChar)
        }
        let title = String (format: "%C", code)
        let dict = [NSAttributedString.Key.foregroundColor : mImplementedCharacterSet.contains (code) ? NSColor.lightGray : NSColor.blue]
        let attributedString = NSAttributedString (string: title, attributes: dict)
        let size = attributedString.size ()
        attributedString.draw (at: CGPoint (x:x + (PLACEMENT_GRID - size.width) / 2.0, y: y + 3.0))
        x += PLACEMENT_GRID
      }
      line += 1
    }
  }

  //····················································································································
  //  mouseDown
  //····················································································································

  override func mouseDown (with inEvent: NSEvent) {
    let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
    let line = Int ((PLACEMENT_GRID * CGFloat (LINE_COUNT) - mouseDownLocation.y) / PLACEMENT_GRID)
    let column = Int ((mouseDownLocation.x - ADDRESS_COLUMN_WIDTH) / PLACEMENT_GRID)
    // Swift.print ("line \(line), column \(column)")
    let code = (line + 2) * 16 + column
    if !mImplementedCharacterSet.contains (code) {
      self.mSelectedCharacter = (line + 2) * 16 + column
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
