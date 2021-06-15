//
//  AutoLayoutDragSourceButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 08/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

fileprivate let PULL_DOWN_ARROW_SIZE : CGFloat = 8.0
fileprivate let PULL_DOWN_ARROW_TOP_MARGIN : CGFloat = 4.0

//----------------------------------------------------------------------------------------------------------------------
// https://www.raywenderlich.com/1016-drag-and-drop-tutorial-for-macos
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutDragSourceButton : NSButton, EBUserClassNameProtocol, NSDraggingSource {

  //····················································································································

  @IBOutlet var mRightContextualMenu : CanariChoiceMenu? = nil
  @IBOutlet var mLeftContextualMenu : CanariChoiceMenu? = nil

  //····················································································································

  init (tooltip inToolTip : String) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.toolTip = inToolTip
    self.bezelStyle = .regularSquare
    self.isBordered = false
    self.imagePosition = .imageOnly
    self.image = NSImage (named: NSImage.cautionName)
    self.imageScaling = .scaleProportionallyUpOrDown
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
  //····················································································································

  override var fittingSize : NSSize {
    return NSSize (width: 23.0, height: 23.0)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: 23.0, height: 23.0)
  }

  //····················································································································

  override func ebCleanUp () {
    self.mImageController?.unregister ()
    self.mImageController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  //  Drag type and object type name
  //····················································································································

  private var mDragType : NSPasteboard.PasteboardType? = nil
  private var mDraggedObjectFactory : Optional < () -> (EBGraphicManagedObject, NSDictionary)? > = nil
  private var mScaleProvider : EBGraphicViewControllerProtocol? = nil

  //····················································································································

  func register (draggedType : NSPasteboard.PasteboardType,
                 draggedObjectFactory : Optional < () -> (EBGraphicManagedObject, NSDictionary)? >,
                 scaleProvider : EBGraphicViewControllerProtocol) {
    self.mDragType = draggedType
    self.mDraggedObjectFactory = draggedObjectFactory
    self.mScaleProvider = scaleProvider
    scaleProvider.addPasteBoardType (draggedType)
  }

  //····················································································································
  //  image binding
  //····················································································································

  fileprivate func updateValue (from inObject : EBReadOnlyProperty_NSImage) {
    switch inObject.selection {
    case .empty :
      self.image = nil
      self.enable (fromValueBinding: false)
    case .multiple :
      self.image = nil
      self.enable (fromValueBinding: false)
    case .single (let v) :
      self.image = v
      self.enable (fromValueBinding: true)
    }
  }

  //····················································································································

  fileprivate var mImageController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_image (_ inObject : EBReadOnlyProperty_NSImage) -> Self {
    self.mImageController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateValue (from: inObject) }
    )
    return self
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
    if let menu = self.mRightContextualMenu, pullDownRightMenuRect ().contains (mouseDownLocation) {
      NSMenu.popUpContextMenu (menu, with: inEvent, for: self)
    }else if let menu = self.mLeftContextualMenu, self.pullDownLeftMenuRect ().contains (mouseDownLocation) {
      NSMenu.popUpContextMenu (menu, with: inEvent, for: self)
    }else if let dragType = self.mDragType, self.isEnabled {
      let pasteboardItem = NSPasteboardItem ()
      let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
    //--- Get dragged image
      if let (temporaryObject, additionalDict) = self.mDraggedObjectFactory? () {
        var transform = AffineTransform ()
        if let scaleProvider = self.mScaleProvider, scaleProvider.boundViews().count == 1 {
          let view = scaleProvider.boundViews() [0]
          let scale = view.actualScale
          let horizontalFlip : CGFloat = view.horizontalFlip ? -1.0 : 1.0
          let verticalFlip   : CGFloat = view.verticalFlip   ? -1.0 : 1.0
          transform.scale (x: scale * horizontalFlip, y: scale * verticalFlip)
       }
        let displayShape = temporaryObject.objectDisplay!.transformed (by: transform)
        let rect = displayShape.boundingBox
        let image = buildPDFimage (frame: rect, shape: displayShape)
      //--- Move image rect origin to mouse click location
        let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
        var r = rect
        r.origin.x += mouseDownLocation.x
        r.origin.y += mouseDownLocation.y
      //--- Associated data
        let dict = NSMutableDictionary ()
        temporaryObject.saveIntoDictionary (dict)
        let dataDictionary : NSDictionary = [
          OBJECT_DICTIONARY_KEY : [dict],
          OBJECT_ADDITIONAL_DICTIONARY_KEY : [additionalDict],
          X_KEY : 0,
          Y_KEY : 0
        ]
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
    if debugAutoLayout () {
      DEBUG_FILL_COLOR.setFill ()
      NSBezierPath.fill (inDirtyRect)
      let bp = NSBezierPath (rect: self.bounds)
      bp.lineWidth = 1.0
      bp.lineJoinStyle = .round
      DEBUG_STROKE_COLOR.setStroke ()
      bp.stroke ()
    }
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
