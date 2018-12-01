//
//  ArtworkDocument+extension.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMSymbolVersion = "PMSymbolVersion"
let PMSymbolComment = "PMSymbolComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let dragAddSegment    = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.segment")
fileprivate let dragAddBezier     = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.bezier")
fileprivate let dragAddFramedOval = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.framed.oval")
fileprivate let dragAddSolidOval  = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.solid.oval")
fileprivate let dragAddSolidRect  = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.solid.rect")
fileprivate let dragAddText       = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.text")
fileprivate let dragAddPin        = NSPasteboard.PasteboardType (rawValue: "drag.and.drop.add.pin")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedSymbolDocument) class CustomizedSymbolDocument : SymbolDocument {

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
     metadataDictionary.setObject (NSNumber (value:version), forKey: PMSymbolVersion as NSCopying)
     metadataDictionary.setObject (rootObject.comments, forKey: PMSymbolComment as NSCopying)
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (metadataDictionary : NSDictionary) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary.object (forKey: PMSymbolVersion) as? NSNumber {
      result = versionNumber.intValue
    }
    return result
  }

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Set pages segmented control
    let pages = [self.mSymbolPageView, self.mInfosPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
    let inspectors = [self.mSymbolBaseInspectorView, self.mSymbolZoomFlipInspectorView, self.mSymbolIssueInspectorView]
    self.mInspectorSegmentedControl?.register (masterView: self.mSymbolRootInspectorView, inspectors)
  //--- Drag source buttons and destination scroll view
    self.mAddSegmentButton?.register (draggedType: dragAddSegment)
    self.mAddBezierButton?.register (draggedType: dragAddBezier)
    self.mAddSolidOvalButton?.register (draggedType: dragAddSolidOval)
    self.mAddOvalButton?.register (draggedType: dragAddFramedOval)
    self.mAddSolidRectButton?.register (draggedType: dragAddSolidRect)
    self.mAddTextButton?.register (draggedType: dragAddText)
    self.mAddPinButton?.register (draggedType: dragAddPin)
    let allTypes = [dragAddSegment, dragAddBezier, dragAddSolidOval, dragAddFramedOval, dragAddSolidRect, dragAddText, dragAddPin]
    self.mComposedSymbolScrollView?.register (document: self, draggedTypes: allTypes)
  //--- Register inspector views
    self.mSymbolObjectsController.register (inspectorView: self.mSymbolBaseInspectorView)
    self.mSymbolObjectsController.register (inspectorView: self.mPinInspectorView, forClass: "SymbolPin")
    self.mSymbolObjectsController.register (inspectorView: self.mTextInspectorView, forClass: "SymbolText")
  //--- Set issue display view
    self.mIssueTableView?.register (issueDisplayView: self.mComposedSymbolView)
    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 2)
  }

  //····················································································································
  //  Called for CanariDragSourceButton for providing a  drag image
  //····················································································································

//  override func ebProvideDraggingFrame (_ ioRect : inout NSRect, _ image : inout NSImage, _ inDragType : NSPasteboard.PasteboardType) {
//    if inDragType == dragAddBezier {
//      let newObject = SymbolSegment (managedObjectContext: self.managedObjectContext, file: #file, #line)
//      let shape = newObject.objectDisplay!
//      ioRect = shape.boundingBox
//      let imageData = buildPDFimage (frame: ioRect, shapes: shape)
//      image = NSImage (data: imageData)!
//      self.managedObjectContext.removeManagedObject (newObject)
//    }
//  }

  //····················································································································
  //    Drag and drop destination
  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
//    let pboard = sender.draggingPasteboard
//    let pboardItem = pboard.pasteboardItems!.first!
//      let newObject = SymbolSegment (managedObjectContext: self.managedObjectContext, file: #file, #line)
//      let shape = newObject.objectDisplay!
////      ioRect = shape.boundingBox
//      let imageData = buildPDFimage (frame: shape.boundingBox, shapes: shape)
//  //    let image = NSImage (data: imageData)!
//      self.managedObjectContext.removeManagedObject (newObject)
//      pboardItem.setData (imageData, forType: .tiff)
  //      draggingItem.setDraggingFrame (shape.boundingBo, contents: image)


//    NSLog ("draggingEntered")
    return .copy
  }

  //····················································································································

//  func draggingUpdated (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
//    // NSLog ("draggingUpdated")
//    return .copy
//  }

  //····················································································································

//  override func draggingExited (_ sender: NSDraggingInfo?, _ destinationScrollView : NSScrollView) {
//    NSLog ("draggingExited")
//  }

  //····················································································································

  override func prepareForDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    return true
  }

  //····················································································································

  override func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    var ok = false
    if let documentView = destinationScrollView.documentView {
      let pointInWindow = sender.draggingLocation
      let pointInDestinationView = documentView.convert (pointInWindow, from:nil).aligned (onGrid: SYMBOL_GRID_IN_COCOA_UNIT)
      let pasteboard = sender.draggingPasteboard
      if pasteboard.availableType (from: [dragAddSegment]) != nil {
        self.addSegment (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddBezier]) != nil {
        self.addBezier (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddFramedOval]) != nil {
        self.addOval (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddSolidOval]) != nil {
        self.addSolidOval (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddSolidRect]) != nil {
        self.addSolidRect (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddText]) != nil {
        self.addText (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddText]) != nil {
        self.addText (at: pointInDestinationView)
        ok = true
      }else if pasteboard.availableType (from: [dragAddPin]) != nil {
        self.addPin (at: pointInDestinationView)
        ok = true
      }
    }
    return ok
  }

  //····················································································································

  private func addSegment (at inCocoaPoint : NSPoint) {
    let newObject = SymbolSegment (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.x1 = p.x
    newObject.y1 = p.y
    newObject.x2 = newObject.x1 + SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.y2 = newObject.y1 + SYMBOL_GRID_IN_CANARI_UNIT * 8
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

  //····················································································································

  private func addBezier (at inCocoaPoint : NSPoint) {
    let newObject = SymbolBezierCurve (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.x1 = p.x
    newObject.y1 = p.y
    newObject.x2 = newObject.x1
    newObject.y2 = newObject.y1 + SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.cpx1 = newObject.x1 + SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.cpy1 = newObject.y1
    newObject.cpx2 = newObject.x1 + SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.cpy2 = newObject.y1 + SYMBOL_GRID_IN_CANARI_UNIT * 8
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

  //····················································································································

  private func addOval (at inCocoaPoint : NSPoint) {
    let newObject = SymbolOval (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.x = p.x
    newObject.y = p.y
    newObject.width = SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.height = SYMBOL_GRID_IN_CANARI_UNIT * 8
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

 //····················································································································

  private func addSolidOval (at inCocoaPoint : NSPoint) {
    let newObject = SymbolSolidOval (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.x = p.x
    newObject.y = p.y
    newObject.width = SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.height = SYMBOL_GRID_IN_CANARI_UNIT * 8
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

  //····················································································································

  private func addSolidRect (at inCocoaPoint : NSPoint) {
    let newObject = SymbolSolidRect (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.x = p.x
    newObject.y = p.y
    newObject.width = SYMBOL_GRID_IN_CANARI_UNIT * 8
    newObject.height = SYMBOL_GRID_IN_CANARI_UNIT * 8
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

  //····················································································································

  private func addText (at inCocoaPoint : NSPoint) {
    let newObject = SymbolText (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.x = p.x
    newObject.y = p.y
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

  //····················································································································

  private func addPin (at inCocoaPoint : NSPoint) {
    let newObject = SymbolPin (managedObjectContext: self.managedObjectContext, file: #file, #line)
    let p = inCocoaPoint.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    newObject.xPin = p.x
    newObject.yPin = p.y
    newObject.xName = newObject.xPin
    newObject.yName = newObject.yPin + SYMBOL_GRID_IN_CANARI_UNIT * 4
    newObject.xNumber = newObject.xPin
    newObject.yNumber = newObject.yPin - SYMBOL_GRID_IN_CANARI_UNIT * 4
    self.rootObject.symbolObjects_property.add (newObject)
    self.mSymbolObjectsController.select (object: newObject)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
