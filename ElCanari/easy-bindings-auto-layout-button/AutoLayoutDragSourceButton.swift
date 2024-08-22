//
//  AutoLayoutDragSourceButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 08/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos
//--------------------------------------------------------------------------------------------------

final class AutoLayoutDragSourceButton : ALB_NSButton, NSDraggingSource {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  public struct DraggedObjectFactoryDescriptor {
    let graphicObject : EBGraphicManagedObject
    let optionDictionary : [String : Any]
    let retainedObjectArray : [EBManagedObject]

    init (_ inGraphicObject : EBGraphicManagedObject,
          optionDictionary inOptionDictionary : [String : Any] = [:],
          retainedObjectArray inRetainedObjectArray : [EBManagedObject] = []) {
      self.graphicObject = inGraphicObject
      self.optionDictionary = inOptionDictionary
      self.retainedObjectArray = inRetainedObjectArray
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (tooltip inToolTip : String) {
    super.init (title: "", size: .regular)

    self.toolTip = inToolTip
    self.bezelStyle = .regularSquare
    self.isBordered = false
    self.imagePosition = .imageOnly
    self.image = NSImage (named: NSImage.cautionName) // Default image
    self.imageScaling = .scaleProportionallyUpOrDown
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var isFlipped : Bool { return false } // REQUIRED for dragged image vertical position !!!

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (title inTitle : String, font inOptionalFont : NSFont?) {
    self.title = inTitle
    self.image = nil
    if let font = inOptionalFont {
      self.font = font
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func set (image inImage : NSImage?) {
    self.image = inImage
    self.imageScaling = .scaleProportionallyUpOrDown
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var fittingSize : NSSize {
    return NSSize (width: 23.0, height: 23.0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 23.0, height: 23.0)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Drag type and object type name
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mDragType : NSPasteboard.PasteboardType? = nil
  private var mDraggedObjectFactory : Optional < () -> DraggedObjectFactoryDescriptor? > = nil
  private var mDraggedObjectImage : Optional < () -> EBShape? > = nil
  private weak var mScaleProvider : EBGraphicViewControllerProtocol? = nil // Should de WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func register (draggedType : NSPasteboard.PasteboardType,
                 draggedObjectFactory : Optional < () -> DraggedObjectFactoryDescriptor? >,
                 scaleProvider : EBGraphicViewControllerProtocol) {
    self.mDragType = draggedType
    self.mDraggedObjectFactory = draggedObjectFactory
    self.mScaleProvider = scaleProvider
    scaleProvider.addPasteBoardType (draggedType)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func register (draggedType : NSPasteboard.PasteboardType,
                 draggedObjectImage : Optional < () -> EBShape? >,
                 scaleProvider : EBGraphicViewControllerProtocol) {
    self.mDragType = draggedType
    self.mDraggedObjectImage = draggedObjectImage
    self.mScaleProvider = scaleProvider
    scaleProvider.addPasteBoardType (draggedType)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  image binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func updateValue (from inObject : EBObservableProperty <NSImage>) {
    switch inObject.selection {
    case .empty :
      self.image = nil
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      self.image = nil
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .single (let v) :
      self.image = v
      self.enable (fromValueBinding: true, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate var mImageController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_image (_ inObject : EBObservableProperty <NSImage>) -> Self {
    self.mImageController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateValue (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  NSDraggingSource protocol implementation
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func draggingSession (_ session: NSDraggingSession,
                        sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
    return .generic
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseDown (with inEvent : NSEvent) {
    if let dragType = self.mDragType, self.isEnabled {
      let pasteboardItem = NSPasteboardItem ()
      let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
    //--- Get dragged object
      if let draggedObject = self.mDraggedObjectFactory? () {
        var transform = AffineTransform ()
        if let scaleProvider = self.mScaleProvider, scaleProvider.boundViews().count == 1 {
          let view = scaleProvider.boundViews() [0]
          let scale = view.actualScale
          let horizontalFlip : CGFloat = view.horizontalFlip ? -1.0 : 1.0
          let verticalFlip   : CGFloat = view.verticalFlip   ? -1.0 : 1.0
          transform.scale (x: scale * horizontalFlip, y: scale * verticalFlip)
        }
        let displayShape = draggedObject.graphicObject.objectDisplay!.transformed (by: transform)
        let rect : NSRect = displayShape.boundingBox
        if rect.isEmpty {
          let alert = NSAlert ()
          alert.messageText = "Internal error"
          alert.informativeText = "Empty image (\(#line))"
          _ = alert.runModal ()
        }else{
          let image = buildPDFimage (frame: rect, shape: displayShape)
        //--- Move image rect origin to mouse click location
          let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
          var r = rect
          r.origin.x += mouseDownLocation.x
          r.origin.y += mouseDownLocation.y
        //--- Associated data
          var dict = [String : Any] ()
          draggedObject.graphicObject.savePropertiesAndRelationshipsIntoDictionary (&dict)
          let dataDictionary : [String : Any] = [
            OBJECT_DICTIONARY_KEY : [dict],
            OBJECT_ADDITIONAL_DICTIONARY_KEY : [draggedObject.optionDictionary],
            X_KEY : 0,
            Y_KEY : 0
          ]
          pasteboardItem.setPropertyList (dataDictionary, forType: dragType)
        //--- Set dragged image
          draggingItem.setDraggingFrame (r, contents: image)
        //--- Begin
          _ = self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
        }
    //--- Get dragged image
      }else if let shape = self.mDraggedObjectImage? () {
        var transform = AffineTransform ()
        if let scaleProvider = self.mScaleProvider, scaleProvider.boundViews().count == 1 {
          let view = scaleProvider.boundViews() [0]
          let scale = view.actualScale
          let horizontalFlip : CGFloat = view.horizontalFlip ? -1.0 : 1.0
          let verticalFlip   : CGFloat = view.verticalFlip   ? -1.0 : 1.0
          transform.scale (x: scale * horizontalFlip, y: scale * verticalFlip)
        }
        let displayShape = shape.transformed (by: transform)
        let rect : NSRect = displayShape.boundingBox
        if rect.isEmpty {
          let alert = NSAlert ()
          alert.messageText = "Internal error"
          alert.informativeText = "Empty image (\(#line))"
          _ = alert.runModal ()
        }else{
          let image = buildPDFimage (frame: rect, shape: displayShape)
        //--- Move image rect origin to mouse click location
          let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
          var r = rect
          r.origin.x += mouseDownLocation.x
          r.origin.y += mouseDownLocation.y
        //--- Associated data
          let dataDictionary : [String : Any] = [
            OBJECT_DICTIONARY_KEY : [[String : Any]] (),
            OBJECT_ADDITIONAL_DICTIONARY_KEY : [[String : Any]] (),
            X_KEY : 0,
            Y_KEY : 0
          ]
          pasteboardItem.setPropertyList (dataDictionary, forType: dragType)
        //--- Set dragged image
          draggingItem.setDraggingFrame (r, contents: image)
        //--- Begin
          _ = self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseUp (with inEvent : NSEvent) {
    self.mMouseIsInside = false
    super.mouseUp (with: inEvent)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Hilite when mouse is within button
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTrackingArea : NSTrackingArea? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mMouseIsInside = false {
    didSet {
      if self.mMouseIsInside != oldValue {
        self.needsDisplay = true
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseEntered (with inEvent : NSEvent) {
    if self.isEnabled {
      self.mMouseIsInside = true
    }
    super.mouseEntered (with: inEvent)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  override func mouseMoved (with inEvent : NSEvent) {
//    if self.isEnabled {
//      let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
//      self.mMouseIsInside = self.bounds.contains (mouseDownLocation)
//    }
//    super.mouseMoved (with: inEvent)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func mouseExited (with inEvent : NSEvent) {
    self.mMouseIsInside = false
    super.mouseExited (with: inEvent)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   DRAW
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draw (_ inDirtyRect : NSRect) {
    if self.mMouseIsInside {
//      let x : CGFloat = 0.75
//      let myGray = NSColor (red: x, green: x, blue: x, alpha: 0.5)
//      myGray.setFill ()
      NSColor.selectedTextBackgroundColor.setFill  ()
      NSBezierPath.fill (self.bounds)
    }
    super.draw (inDirtyRect)
//    if debugAutoLayout () {
//      let bp = NSBezierPath (rect: self.bounds)
//      bp.lineWidth = 1.0
//      bp.lineJoinStyle = .round
//      DEBUG_STROKE_COLOR.setStroke ()
//      bp.stroke ()
//    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
