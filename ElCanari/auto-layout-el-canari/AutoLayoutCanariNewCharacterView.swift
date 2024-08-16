//
//  AutoLayoutCanariCharacterView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/09/2018, autolayout 02/10/2021
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   Placement
//--------------------------------------------------------------------------------------------------

private let ADDRESS_COLUMN_WIDTH : CGFloat = 40.0
private let PLACEMENT_GRID : CGFloat = 20.0

private let LINE_COUNT = 0x100 - 2

//--------------------------------------------------------------------------------------------------
//   AutoLayoutCanariCharacterView
//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariCharacterView : NSScrollView {

  private var mCharacterView : InternalNewCharacterView

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (okButton inOkButton : AutoLayoutSheetDefaultOkButton) {
    self.mCharacterView = InternalNewCharacterView (okButton: inOkButton)
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.drawsBackground = false
    self.documentView = self.mCharacterView
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
    self.automaticallyAdjustsContentInsets = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 380, height: -1)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Implemented character set
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setImplementedCharacterSet (_ inSet : Set <Int>) {
    self.mCharacterView.setImplementedCharacterSet (inSet)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedCharacter : Int? { return self.mCharacterView.selectedCharacter }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

private class InternalNewCharacterView : NSView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mOkButton : AutoLayoutSheetDefaultOkButton? // Should be weak

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (okButton inOkButton : AutoLayoutSheetDefaultOkButton) {
    self.mOkButton = inOkButton
    inOkButton.enable (fromEnableBinding: false, nil)
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    // self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.setContentHuggingPriority (.defaultLow, for: .horizontal)

    let width = ADDRESS_COLUMN_WIDTH + 16.0 * PLACEMENT_GRID
    let height = PLACEMENT_GRID * CGFloat (LINE_COUNT)
    let newRect = NSRect (x: 0.0, y: 0.0, width: width, height: height)
    self.frame.size = newRect.size
    self.bounds = newRect
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Implemented character set
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mImplementedCharacterSet = Set <Int> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setImplementedCharacterSet (_ inSet : Set <Int>) {
    self.mImplementedCharacterSet = inSet
    self.setNeedsDisplay (self.visibleRect)
    self.mSelectedCharacter = nil
    self.scroll (NSPoint (x: 0.0, y: self.bounds.maxY))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func rectForCharacter (_ inCode : Int) -> NSRect {
    return NSRect (
      x: ADDRESS_COLUMN_WIDTH + PLACEMENT_GRID * CGFloat (inCode % 16),
      y: PLACEMENT_GRID * CGFloat (LINE_COUNT - 1 - inCode / 16 - 2),
      width: PLACEMENT_GRID,
      height: PLACEMENT_GRID
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate var mSelectedCharacter : Int? = nil {
    didSet {
      if let c = oldValue {
        self.setNeedsDisplay (rectForCharacter (c).insetBy(dx: -1.0, dy: -1.0))
      }
      if let c = mSelectedCharacter {
        self.setNeedsDisplay (rectForCharacter (c).insetBy(dx: -1.0, dy: -1.0))
      }
      self.needsDisplay = true
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedCharacter : Int? { return self.mSelectedCharacter }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  isOpaque
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var isOpaque : Bool { return true }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Draw rect
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect: NSRect) {
  //--- Draw background
    NSColor.white.setFill ()
    NSBezierPath.fill (self.bounds)
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
      titleAttributedString.draw (at: NSPoint (x:5.0, y: y + 3.0))
      var x = ADDRESS_COLUMN_WIDTH
      for idx in 0 ..< 16 {
        let code = (line + 2) * 16 + idx
        let rChar = NSRect (x:x, y:y, width: PLACEMENT_GRID, height: PLACEMENT_GRID)
        if let selectedCharacter = self.mSelectedCharacter, selectedCharacter == code {
          NSColor.lightGray.setFill ()
          NSBezierPath.fill (rChar)
        }
        let title = String (format: "%C", code)
        let dict = [NSAttributedString.Key.foregroundColor : mImplementedCharacterSet.contains (code) ? NSColor.lightGray : NSColor.blue]
        let attributedString = NSAttributedString (string: title, attributes: dict)
        let size = attributedString.size ()
        attributedString.draw (at: NSPoint (x:x + (PLACEMENT_GRID - size.width) / 2.0, y: y + 3.0))
        x += PLACEMENT_GRID
      }
      line += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  mouseDown
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseDown (with inEvent: NSEvent) {
    let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
    let line = Int ((PLACEMENT_GRID * CGFloat (LINE_COUNT) - mouseDownLocation.y) / PLACEMENT_GRID)
    let column = Int ((mouseDownLocation.x - ADDRESS_COLUMN_WIDTH) / PLACEMENT_GRID)
    // Swift.print ("line \(line), column \(column)")
    let code = (line + 2) * 16 + column
    if mImplementedCharacterSet.contains (code) {
      self.mSelectedCharacter = nil
      self.mOkButton?.enable (fromEnableBinding: false, nil)
    }else{
      self.mSelectedCharacter = code
      self.mOkButton?.enable (fromEnableBinding: true, nil)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
