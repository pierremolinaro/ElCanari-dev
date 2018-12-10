//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos

@objc(CanariDragSourceButton) class CanariDragSourceButton :
          NSButton,
          EBUserClassNameProtocol,
          NSDraggingSource {

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
  private var mDraggedObjectTypeName = "" // Any value if mDragType is null
  private var mScaleProvider : EBViewScaleProvider? = nil

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType,
                 entityName : String,
                 provideImageFromEntity : Bool,
                 scaleProvider : EBViewScaleProvider?) {
    self.mDragType = draggedType
    self.mDraggedObjectTypeName = entityName
    self.mScaleProvider = scaleProvider
    if provideImageFromEntity {
      if let temporaryObject = newInstanceOfEntityNamed (nil, self.mDraggedObjectTypeName) as? EBGraphicManagedObject {
        let displayShape = temporaryObject.objectDisplay!
        let rect = displayShape.boundingBox
        let imagePDFData = buildPDFimage (frame: rect.insetBy (dx: -3.0, dy: -3.0), shape: displayShape)
        let image = NSImage (data: imagePDFData)
        self.image = image
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
      if let temporaryObject = newInstanceOfEntityNamed (nil, self.mDraggedObjectTypeName) as? EBGraphicManagedObject {
        let transform = NSAffineTransform ()
        transform.scale (by: self.mScaleProvider?.actualScale ?? 1.0)
        let displayShape = temporaryObject.objectDisplay!.transformedBy (transform)
        let rect = displayShape.boundingBox
        let imagePDFData = buildPDFimage (frame: rect, shape: displayShape)
        let image = NSImage (data: imagePDFData)
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
  //  Hilite when mouse is within button
  //····················································································································

  fileprivate var mTrackingArea : NSTrackingArea? = nil

  //····················································································································

  override func updateTrackingAreas () { // This is required for receiving mouseEntered and mouseExited events
  //--- Remove tracking area
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
      NSColor.lightGray.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
    super.draw (inDirtyRect)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
