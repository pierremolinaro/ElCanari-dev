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
                 scaleProvider : EBViewScaleProvider?) {
    self.mDragType = draggedType
    self.mDraggedObjectTypeName = entityName
    self.mScaleProvider = scaleProvider
  }

  //····················································································································

  func buildButtonImageFromDraggedObjectTypeName () {
    if let temporaryObject = newInstanceOfEntityNamed (nil, self.mDraggedObjectTypeName) as? EBGraphicManagedObject {
      let displayShape = temporaryObject.objectDisplay!
      let rect = displayShape.boundingBox
      if !rect.isEmpty {
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
        let scale = self.mScaleProvider?.actualScale ?? 1.0
        let horizontalFlip : CGFloat = (self.mScaleProvider?.horizontalFlip ?? false) ? -1.0 : 1.0
        let verticalFlip   : CGFloat = (self.mScaleProvider?.verticalFlip   ?? false) ? -1.0 : 1.0
        transform.scaleX (by: scale * horizontalFlip, yBy: scale * verticalFlip)
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

  override func updateTrackingAreas () { // This is required for receiving mouseEntered and mouseExited events
  //--- Remove all tracking areas
    for trackingArea in self.trackingAreas {
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

 // fileprivate var mShape = EBShape ()
  
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if self.mMouseWithin {
      NSColor.lightGray.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
    super.draw (inDirtyRect)
  }

  //····················································································································
  //   Color
  //····················································································································

//  fileprivate var mColorController : EBReadOnlyController_NSColor? = nil
//  fileprivate var mColor : NSColor? = nil
//
// //····················································································································
//
//  func bind_color (_ model : EBReadOnlyProperty_NSColor, file : String, line : Int) {
//    self.mColorController = EBReadOnlyController_NSColor (
//      model: model,
//      callBack: { [weak self] in self?.updateColor (from: model) }
//     )
//  }
//
//  //····················································································································
//
//  func unbind_color() {
//    self.mColorController?.unregister ()
//    self.mColorController = nil
//  }
//
//  //····················································································································
//
//  private func updateColor (from model : EBReadOnlyProperty_NSColor) {
//    switch model.prop {
//    case .empty, .multiple :
//      ()
//    case .single (let v) :
//      self.mColor = v
//      self.needsDisplay = true
//    }
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
