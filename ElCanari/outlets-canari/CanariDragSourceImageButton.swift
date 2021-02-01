//
//  CanariDragSourceImageButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 29/06/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

fileprivate let PULL_DOWN_ARROW_SIZE : CGFloat = 8.0
fileprivate let PULL_DOWN_ARROW_TOP_MARGIN : CGFloat = 4.0

//----------------------------------------------------------------------------------------------------------------------
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos
//----------------------------------------------------------------------------------------------------------------------

class CanariDragSourceImageButton : NSButton, EBUserClassNameProtocol, NSDraggingSource {

  //····················································································································

  @IBOutlet var mRightContextualMenu : CanariChoiceMenu? = nil
  @IBOutlet var mLeftContextualMenu : CanariChoiceMenu? = nil

  //····················································································································

  override var isFlipped : Bool { return false }

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································
  //  Drag type and object type name
  //····················································································································

  private var mDragType : NSPasteboard.PasteboardType? = nil
  private var mDraggedObjectImageShape : Optional < () -> EBShape? > = nil
  private var mScaleProvider : EBGraphicViewScaleProvider? = nil

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType,
                 shapeFactory inShapeFactory : @escaping () -> EBShape?,
                 scaleProvider : EBGraphicViewScaleProvider?) {
    self.mDragType = draggedType
    self.mDraggedObjectImageShape = inShapeFactory
    self.mScaleProvider = scaleProvider
  }

  //····················································································································

  func buildButtonImageFromDraggedObjectTypeName () {
    if let displayShape = self.mDraggedObjectImageShape? () {
      let rect = displayShape.boundingBox
      if !rect.isEmpty {
        self.image = buildPDFimage (frame: rect.insetBy (dx: -3.0, dy: -3.0), shape: displayShape)
      }
    }
  }

  //····················································································································
  //  NSDraggingSource protocol implementation
  //····················································································································

  func draggingSession (_ session: NSDraggingSession,
                        sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
    return .generic
  }

  //····················································································································

  override func mouseDown (with inEvent : NSEvent) {
    let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
    if let menu = self.mRightContextualMenu, self.pullDownRightMenuRect ().contains (mouseDownLocation) {
      NSMenu.popUpContextMenu (menu, with: inEvent, for: self)
    }else if let menu = self.mLeftContextualMenu, self.pullDownLeftMenuRect ().contains (mouseDownLocation) {
      NSMenu.popUpContextMenu (menu, with: inEvent, for: self)
    }else if let dragType = self.mDragType,
       self.isEnabled,
       let temporaryObjectShape = self.mDraggedObjectImageShape? () {
      let pasteboardItem = NSPasteboardItem ()
      let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
    //--- Get dragged image
      var transform = AffineTransform ()
      let scale = self.mScaleProvider?.actualScale ?? 1.0
      let horizontalFlip : CGFloat = (self.mScaleProvider?.horizontalFlip ?? false) ? -1.0 : 1.0
      let verticalFlip   : CGFloat = (self.mScaleProvider?.verticalFlip   ?? false) ? -1.0 : 1.0
      transform.scale (x: scale * horizontalFlip, y: scale * verticalFlip)
      let displayShape = temporaryObjectShape.transformed (by: transform)
      let rect = displayShape.boundingBox
      let image = buildPDFimage (frame: rect, shape: displayShape)
    //--- Move image rect origin to mouse click location
      var r = rect
      r.origin.x += mouseDownLocation.x
      r.origin.y += mouseDownLocation.y
    //--- Associated data (any value, just for setting drag type)
      pasteboardItem.setString ("", forType: dragType)
    //--- Set dragged image
      draggingItem.setDraggingFrame (r, contents: image)
    //--- Begin
      self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
    }
  }

  //····················································································································
  //  Hilite when mouse is within button
  //····················································································································

  private var mTrackingArea : NSTrackingArea? = nil

  //····················································································································

  override func updateTrackingAreas () { // This is required for receiving mouseEntered and mouseExited events
  //--- Remove current tracking area
    if let trackingArea = self.mTrackingArea {
      self.removeTrackingArea (trackingArea)
    }
  //--- Add Updated tracking area
    let trackingArea = NSTrackingArea (
      rect: self.bounds,
      options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea (trackingArea)
    self.mTrackingArea = trackingArea
  //---
    super.updateTrackingAreas ()
  }

  //····················································································································

  private enum MouseZone {
    case outside
    case insideRightPullDown
    case insideLeftPullDown
    case insideDrag
  }

  //····················································································································

  private var mMouseZone = MouseZone.outside {
    didSet {
      if self.mMouseZone != oldValue {
        self.needsDisplay = true
      }
    }
  }

  //····················································································································

  override func mouseEntered (with inEvent : NSEvent) {
    if self.isEnabled {
      let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
      if self.mRightContextualMenu != nil, self.pullDownRightMenuRect ().contains (mouseDownLocation) {
        self.mMouseZone = .insideRightPullDown
      }else if self.mLeftContextualMenu != nil, self.pullDownLeftMenuRect ().contains (mouseDownLocation) {
        self.mMouseZone = .insideLeftPullDown
      }else{
        self.mMouseZone = .insideDrag
      }
    }
    super.mouseEntered (with: inEvent)
  }

  //····················································································································

  override func mouseMoved (with inEvent : NSEvent) {
    if self.isEnabled {
      let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
      if self.mRightContextualMenu != nil, self.pullDownRightMenuRect ().contains (mouseDownLocation) {
        self.mMouseZone = .insideRightPullDown
      }else if self.mLeftContextualMenu != nil, self.pullDownLeftMenuRect ().contains (mouseDownLocation) {
        self.mMouseZone = .insideLeftPullDown
      }else{
        self.mMouseZone = .insideDrag
      }
    }
    super.mouseMoved (with: inEvent)
  }

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.mMouseZone = .outside
    super.mouseExited (with: inEvent)
  }

  //····················································································································
  //   DRAW
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    let x : CGFloat = 0.75
    let myGray = NSColor (red: x, green: x, blue: x, alpha: 1.0)
    myGray.setFill ()
    switch self.mMouseZone {
    case .outside :
      ()
    case .insideRightPullDown :
      NSBezierPath.fill (self.pullDownRightMenuRect ())
    case .insideLeftPullDown :
      NSBezierPath.fill (self.pullDownLeftMenuRect ())
    case .insideDrag :
      let bp = NSBezierPath ()
      let b = self.bounds
      bp.move (to: NSPoint (x: b.minX, y: b.maxY))
      let v = PULL_DOWN_ARROW_TOP_MARGIN + PULL_DOWN_ARROW_SIZE / 2.0
      if self.mLeftContextualMenu != nil, self.mRightContextualMenu != nil {
        bp.line (to: NSPoint (x: b.minX, y: b.minY + v))
        bp.line (to: NSPoint (x: b.maxX, y: b.minY + v))
      }else if self.mLeftContextualMenu != nil { // Only left contextual menu
        bp.line (to: NSPoint (x: b.minX, y: b.minY + v))
        bp.line (to: NSPoint (x: b.midX, y: b.minY + v))
        bp.line (to: NSPoint (x: b.midX, y: b.minY))
        bp.line (to: NSPoint (x: b.maxX, y: b.minY))
      }else if self.mRightContextualMenu != nil { // Only right contextual menu
        bp.line (to: NSPoint (x: b.minX, y: b.minY))
        bp.line (to: NSPoint (x: b.midX, y: b.minY))
        bp.line (to: NSPoint (x: b.midX, y: b.minY + v))
        bp.line (to: NSPoint (x: b.maxX, y: b.minY + v))
      }else{ // No contextual menu
        bp.line (to: NSPoint (x: b.minX, y: b.minY))
        bp.line (to: NSPoint (x: b.maxX, y: b.minY))
      }
      bp.line (to: NSPoint (x: b.maxX, y: b.maxY))
      bp.close ()
      bp.fill ()
    }
    if self.mRightContextualMenu != nil {
      var path = EBBezierPath ()
      path.move (to: NSPoint (x: self.bounds.maxX - PULL_DOWN_ARROW_SIZE, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
      path.line (to: NSPoint (x: self.bounds.maxX, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
      path.line (to: NSPoint (x: self.bounds.maxX - PULL_DOWN_ARROW_SIZE / 2.0, y: self.bounds.minY))
      path.close ()
      NSColor.black.setFill ()
      path.fill ()
    }
    if self.mLeftContextualMenu != nil {
      var path = EBBezierPath ()
      path.move (to: NSPoint (x: 0.0, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
      path.line (to: NSPoint (x: PULL_DOWN_ARROW_SIZE, y: self.bounds.minY + PULL_DOWN_ARROW_SIZE / 2.0))
      path.line (to: NSPoint (x: PULL_DOWN_ARROW_SIZE / 2.0, y: self.bounds.minY))
      path.close ()
      NSColor.black.setFill ()
      path.fill ()
    }
    super.draw (inDirtyRect)
  }

  //····················································································································
  //   PULL DOWN MENU DETECTION RECTANGLE
  //····················································································································

  fileprivate func pullDownRightMenuRect () -> NSRect {
    let r : NSRect
    if self.mRightContextualMenu != nil {
      r = NSRect (
        x: self.bounds.midX,
        y: self.bounds.minY,
        width: self.bounds.size.width / 2.0,
        height: PULL_DOWN_ARROW_TOP_MARGIN + PULL_DOWN_ARROW_SIZE / 2.0
      )
    }else{
      r = NSRect ()
    }
    return r
  }

  //····················································································································

  fileprivate func pullDownLeftMenuRect () -> NSRect {
    let r : NSRect
    if self.mLeftContextualMenu != nil {
      r = NSRect (
        x: 0.0,
        y: 0.0,
        width: self.bounds.size.width / 2.0,
        height: PULL_DOWN_ARROW_TOP_MARGIN + PULL_DOWN_ARROW_SIZE / 2.0
      )
    }else{
      r = NSRect ()
    }
    return r
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
