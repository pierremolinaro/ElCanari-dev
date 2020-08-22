//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos
//----------------------------------------------------------------------------------------------------------------------

class CanariDragSourceButton : NSButton, EBUserClassNameProtocol, NSDraggingSource {

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

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //  Drag type and object type name
  //····················································································································

  private var mDragType : NSPasteboard.PasteboardType? = nil
  private var mDraggedObjectFactory : Optional < () -> EBGraphicManagedObject? > = nil
  private var mScaleProvider : EBGraphicViewScaleProvider? = nil

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType,
                 draggedObjectFactory : Optional < () -> EBGraphicManagedObject? >,
                 scaleProvider : EBGraphicViewScaleProvider?) {
    self.mDragType = draggedType
    self.mDraggedObjectFactory = draggedObjectFactory
    self.mScaleProvider = scaleProvider
  }

  //····················································································································

  func buildButtonImageFromDraggedObjectTypeName () {
    if let temporaryObject = self.mDraggedObjectFactory? () {
      let displayShape = temporaryObject.objectDisplay!
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
    if let dragType = self.mDragType, self.isEnabled {
      let pasteboardItem = NSPasteboardItem ()
      let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
    //--- Get dragged image
      if let temporaryObject = self.mDraggedObjectFactory? () {
        var transform = AffineTransform ()
        let scale = self.mScaleProvider?.actualScale ?? 1.0
        let horizontalFlip : CGFloat = (self.mScaleProvider?.horizontalFlip ?? false) ? -1.0 : 1.0
        let verticalFlip   : CGFloat = (self.mScaleProvider?.verticalFlip   ?? false) ? -1.0 : 1.0
        transform.scale (x: scale * horizontalFlip, y: scale * verticalFlip)
        let displayShape = temporaryObject.objectDisplay!.transformed (by: transform)
        let rect = displayShape.boundingBox
        let image = buildPDFimage (frame: rect, shape: displayShape)
      //--- Move image rect origin to mouse click location
        let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
        var r = rect
        r.origin.x += mouseDownLocation.x
        r.origin.y += mouseDownLocation.y
      //--- Associated data
        let d = NSMutableDictionary ()
        temporaryObject.saveIntoDictionary (d)
        let dataDictionary : NSDictionary = ["OBJECTS" : [d], "X" : 0, "Y" : 0]
        pasteboardItem.setPropertyList (dataDictionary, forType: dragType)
      //--- Set dragged image
        draggingItem.setDraggingFrame (r, contents: image)
      //--- Begin
        self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
      }
    }
  }

  //····················································································································
  //  Method called when dragging ends
  //····················································································································

  func draggingSession (_ session: NSDraggingSession,
                        endedAt screenPoint: NSPoint,
                        operation: NSDragOperation) {
    if let myWindow = self.window {
      let mouseLocation = self.convert (myWindow.mouseLocationOutsideOfEventStream, from: nil)
      self.mMouseWithin = self.bounds.contains (mouseLocation)
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
      options: [.mouseEnteredAndExited, .activeInKeyWindow],
      owner: self,
      userInfo: nil
    )
    self.addTrackingArea (trackingArea)
    self.mTrackingArea = trackingArea
  //---
    super.updateTrackingAreas ()
  }

  //····················································································································

  private var mMouseWithin = false { didSet { self.needsDisplay = true } }

  //····················································································································

  override func mouseEntered (with inEvent : NSEvent) {
    if self.isEnabled {
      self.mMouseWithin = true
    }
    super.mouseEntered (with: inEvent)
  }

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.mMouseWithin = false
    super.mouseExited (with: inEvent)
  }

  //····················································································································
  //   DRAW
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if self.mMouseWithin {
      let x : CGFloat = 0.75
      let myGray = NSColor (red: x, green: x, blue: x, alpha: 1.0)
      myGray.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
    super.draw (inDirtyRect)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
