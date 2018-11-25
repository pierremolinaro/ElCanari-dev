//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos

@objc(CanariDragSourceButton) class CanariDragSourceButton : NSButton, EBUserClassNameProtocol, NSDraggingSource, NSPasteboardItemDataProvider {

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
  //  Drag type UTI
  //····················································································································

  var mDragTypeUTI : NSPasteboard.PasteboardType? = nil

  //····················································································································

  func set (dragTypeUTI : NSPasteboard.PasteboardType) {
    self.mDragTypeUTI = dragTypeUTI
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
  }

  //····················································································································
  //  Drag source on mouse down
  //····················································································································

  override func mouseDown (with inEvent : NSEvent) {
    if self.isEnabled {
      if let dragTypeUTI = self.mDragTypeUTI {
        let pasteboardItem = NSPasteboardItem ()
        pasteboardItem.setDataProvider (self, forTypes: [dragTypeUTI])

        let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
        draggingItem.setDraggingFrame (self.bounds, contents: self.image)

        self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
      }else{
        __NSBeep ()
      }
    }
  }

  //····················································································································
  //  Hilite when mouse is within button
  //····················································································································

  fileprivate var mTrackingArea :  NSTrackingArea? = nil

  //····················································································································

  override func updateTrackingAreas () { // This is required for reveiving mouseEntered and mouseExited
  //--- Remove tracking area
    if let trackingArea = mTrackingArea {
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

  private var mMouseWithin = false

  //····················································································································

  override func mouseEntered (with inEvent : NSEvent) {
  if self.isEnabled {
    self.mMouseWithin = true
    self.needsDisplay = true
  }
  super.mouseEntered (with: inEvent)
}

  //····················································································································

  override func mouseExited (with inEvent : NSEvent) {
    self.mMouseWithin = false
    self.needsDisplay = true
    super.mouseExited (with: inEvent)
  }

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
