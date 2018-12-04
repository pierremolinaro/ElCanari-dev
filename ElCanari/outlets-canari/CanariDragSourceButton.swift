//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos

@objc(CanariDragSourceButton) class CanariDragSourceButton :
          NSButton,
          EBUserClassNameProtocol,
          NSPasteboardItemDataProvider,
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

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType, entityName : String) {
    self.mDragType = draggedType
    self.mDraggedObjectTypeName = entityName
  }

  //····················································································································
  //  NSDraggingSource protocol implementation
  //····················································································································

  func draggingSession (_ session: NSDraggingSession,
                        sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
    return .generic
  }

  //····················································································································
  //  NSPasteboardItemDataProvider protocol implementation
  //····················································································································

  func pasteboard (_ pasteboard: NSPasteboard?,
                   item: NSPasteboardItem,
                   provideDataForType type: NSPasteboard.PasteboardType) {
    NSLog ("pasteboard")
  }

  //····················································································································

  override func mouseDown (with inEvent : NSEvent) {
    if let dragType = self.mDragType, self.isEnabled {
      let pasteboardItem = NSPasteboardItem ()
      pasteboardItem.setDataProvider (self, forTypes: [dragType])
      let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
    //--- Get dragged image
      do{
        let temporaryObject = try newInstanceOfEntityNamed (nil, self.mDraggedObjectTypeName) as! EBGraphicManagedObject
        let displayShape = temporaryObject.objectDisplay!
        let rect = displayShape.boundingBox
        let imagePDFData = buildPDFimage (frame: rect, shape: displayShape)
        let image = NSImage (data: imagePDFData)!
      //--- Move image rect origin to mouse click location
        let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
        var r = rect
        r.origin.x += mouseDownLocation.x
        r.origin.y += mouseDownLocation.y
      //--- Associated data
        let d = NSMutableDictionary ()
        temporaryObject.saveIntoDictionary (d)
        pasteboardItem.setPropertyList (d, forType: dragType)
      //--- Set dragged image
        draggingItem.setDraggingFrame (r, contents: image)
      //--- Begin
        self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
      }catch let error {
        let alert = NSAlert (error: error)
        alert.beginSheetModal (for: self.window!, completionHandler: nil)
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
  //   Draw function call back
  //····················································································································

  private var mDrawFunctionCallBack : Optional <(_ rect : NSRect) -> Void > = nil

  //····················································································································

  func register (drawImageCallBack : @escaping (_ rect : NSRect) -> Void) {
    self.mDrawFunctionCallBack = drawImageCallBack
  }

  //····················································································································
  //   DRAW
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if self.mMouseWithin {
      NSColor.lightGray.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
    if let drawFunctionCallBack = self.mDrawFunctionCallBack {
      drawFunctionCallBack (self.bounds)
    }else{
      super.draw (inDirtyRect)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
