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
    self.mAddSegmentButton?.register (drawImageCallBack : {(_ rect : NSRect) in
      let r = rect.insetBy (dx: 5.0, dy: 5.0)
      NSColor.brown.setStroke ()
      let bp = NSBezierPath ()
      bp.move (to: r.origin)
      bp.line (to: NSPoint (x: r.maxX, y: r.maxY))
      bp.lineWidth = 2.0
      bp.lineCapStyle = .round
      bp.stroke ()
    })
    self.mAddSegmentButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let s = SYMBOL_GRID_IN_COCOA_UNIT * 8.0 * scale
      let lineWidth = CGFloat (g_Preferences?.symbolDrawingWidthMultipliedByTen ?? 10) * scale / 10.0
      let bp = NSBezierPath ()
      bp.move (to: NSPoint ())
      bp.line (to: NSPoint (x: s, y: s))
      bp.lineWidth = lineWidth
      bp.lineCapStyle = .round
      let shape = EBStrokeBezierPathShape ([bp], g_Preferences?.symbolColor ?? NSColor.black)
      let r = NSRect (x: -lineWidth, y: -lineWidth, width: s + lineWidth * 2.0, height: s + lineWidth * 2.0)
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

    self.mAddBezierButton?.register (draggedType: dragAddBezier)
    self.mAddBezierButton?.register (drawImageCallBack : {(_ rect : NSRect) in
      let r = rect.insetBy (dx: 5.0, dy: 5.0)
      NSColor.brown.setStroke ()
      let bp = NSBezierPath ()
      bp.move (to: r.origin)
      bp.curve (
        to: NSPoint (x: r.minX, y: r.maxY),
        controlPoint1: NSPoint (x: r.maxX, y: r.minY),
        controlPoint2: NSPoint (x: r.maxX, y: r.maxY)
      )
      bp.lineWidth = 2.0
      bp.lineCapStyle = .round
      bp.stroke ()
    })
    self.mAddBezierButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let s = SYMBOL_GRID_IN_COCOA_UNIT * 8.0 * scale
      let lineWidth = CGFloat (g_Preferences?.symbolDrawingWidthMultipliedByTen ?? 10) * scale / 10.0
      let bp = NSBezierPath ()
      bp.move (to: NSPoint ())
      bp.curve (to: NSPoint (x: 0.0, y: s), controlPoint1: NSPoint (x: s, y: 0.0), controlPoint2: NSPoint (x: s, y: s))
      bp.lineWidth = lineWidth
      bp.lineCapStyle = .round
      let shape = EBStrokeBezierPathShape ([bp], g_Preferences?.symbolColor ?? NSColor.black)
      let r = NSRect (x: -lineWidth, y: -lineWidth, width: s + lineWidth * 2.0, height: s + lineWidth * 2.0)
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

    self.mAddSolidOvalButton?.register (draggedType: dragAddSolidOval)
    self.mAddSolidOvalButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        NSColor.brown.setFill ()
        let bp = NSBezierPath (ovalIn: r)
        bp.fill ()
    })
    self.mAddSolidOvalButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let s = SYMBOL_GRID_IN_COCOA_UNIT * 8.0 * scale
      let lineWidth = CGFloat (g_Preferences?.symbolDrawingWidthMultipliedByTen ?? 10) * scale / 10.0
      let bp = NSBezierPath (ovalIn: NSRect (x: 0.0, y: 0.0, width: s, height: s))
      let shape = EBFilledBezierPathShape ([bp], g_Preferences?.symbolColor ?? NSColor.black)
      let r = NSRect (x: -lineWidth, y: -lineWidth, width: s + lineWidth * 2.0, height: s + lineWidth * 2.0)
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

    self.mAddOvalButton?.register (draggedType: dragAddFramedOval)
    self.mAddOvalButton?.register (drawImageCallBack : {(_ rect : NSRect) in
      let r = rect.insetBy (dx: 5.0, dy: 5.0)
      NSColor.brown.setStroke ()
      let bp = NSBezierPath (ovalIn: r)
      bp.lineWidth = 2.0
      bp.stroke ()
    })
    self.mAddOvalButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let s = SYMBOL_GRID_IN_COCOA_UNIT * 8.0 * scale
      let lineWidth = CGFloat (g_Preferences?.symbolDrawingWidthMultipliedByTen ?? 10) * scale / 10.0
      let bp = NSBezierPath (ovalIn: NSRect (x: 0.0, y: 0.0, width: s, height: s))
      bp.lineWidth = lineWidth
      bp.lineCapStyle = .round
      let shape = EBStrokeBezierPathShape ([bp], g_Preferences?.symbolColor ?? NSColor.black)
      let r = NSRect (x: -lineWidth, y: -lineWidth, width: s + lineWidth * 2.0, height: s + lineWidth * 2.0)
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

    self.mAddSolidRectButton?.register (draggedType: dragAddSolidRect)
    self.mAddSolidRectButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        NSColor.brown.setFill ()
        let bp = NSBezierPath (rect: r)
        bp.fill ()
    })
    self.mAddSolidRectButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let s = SYMBOL_GRID_IN_COCOA_UNIT * 8.0 * scale
      let lineWidth = CGFloat (g_Preferences?.symbolDrawingWidthMultipliedByTen ?? 10) * scale / 10.0
      let bp = NSBezierPath (rect: NSRect (x: 0.0, y: 0.0, width: s, height: s))
      let shape = EBFilledBezierPathShape ([bp], g_Preferences?.symbolColor ?? NSColor.black)
      let r = NSRect (x: -lineWidth, y: -lineWidth, width: s + lineWidth * 2.0, height: s + lineWidth * 2.0)
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

    self.mAddTextButton?.register (draggedType: dragAddText)
    self.mAddTextButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        let textAttributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : NSFont (name: "Cambria", size: 26.0)!,
          NSAttributedString.Key.foregroundColor : NSColor.brown
        ]
        let size = "T".size (withAttributes: textAttributes)
        "T".draw (at: NSPoint (x: r.midX - size.width / 2.0, y: r.midY - size.height / 2.0 + 3.0), withAttributes: textAttributes)
    })
    self.mAddTextButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let lineWidth = CGFloat (g_Preferences?.symbolDrawingWidthMultipliedByTen ?? 10) * scale / 10.0
      let font = (g_Preferences?.pinNameFont)!
      let fontForDraggedImage = NSFont (name: font.fontName, size: font.pointSize * scale)!
      let textAttributes : [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : fontForDraggedImage,
        NSAttributedString.Key.foregroundColor : g_Preferences?.symbolColor ?? NSColor.black
      ]
      let text = "text"
      let shape = EBTextShape (text, NSPoint (), textAttributes, .center, .center)
      let textSize = text.size (withAttributes: textAttributes)
      let r = NSRect (
        x: -lineWidth - textSize.width / 2.0,
        y: -lineWidth - textSize.height / 2.0,
        width: textSize.width + lineWidth * 2.0,
        height: textSize.height + lineWidth * 2.0
      )
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

    self.mAddPinButton?.register (draggedType: dragAddPin)
    self.mAddPinButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        NSColor.brown.setFill ()
        let circleDiameter : CGFloat = 10.0
        let circle = NSRect (
          x: r.maxX - circleDiameter,
          y: r.midY - circleDiameter / 2.0,
          width: circleDiameter,
          height: circleDiameter
        )
        let bp = NSBezierPath (ovalIn: circle)
        bp.fill ()
        let textAttributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : NSFont.userFixedPitchFont (ofSize: 18.0)!,
          NSAttributedString.Key.foregroundColor : g_Preferences?.symbolColor ?? NSColor.black
        ]
        let size = "#".size (withAttributes: textAttributes)
        "#".draw (at: NSPoint (x: r.minX, y: r.midY - size.height / 2.0), withAttributes: textAttributes)
    })
    self.mAddPinButton?.register (draggedImageCallBack : { [weak self] () -> (NSImage?, NSRect) in
      let scale = self?.mComposedSymbolView?.actualScale () ?? 1.0
      let gridSize = SYMBOL_GRID_IN_COCOA_UNIT * scale
      let shape = EBShape ()
      let color = g_Preferences?.symbolColor ?? NSColor.black
    //--- Pin
      let pinRect = NSRect (
        x: -gridSize,
        y: -gridSize,
        width: gridSize * 2.0,
        height: gridSize * 2.0
      )
      let filledBP = NSBezierPath (ovalIn: pinRect)
      shape.append (shape: EBFilledBezierPathShape ([filledBP], color))
    //--- Name
      let font = (g_Preferences?.pinNameFont)!
      let fontForDraggedImage = NSFont (name: font.fontName, size: font.pointSize * scale)!
      let nameTextAttributes : [NSAttributedString.Key : Any] = [
        NSAttributedString.Key.font : fontForDraggedImage,
        NSAttributedString.Key.foregroundColor : NSColor.black
      ]
      let label = "?"
      let labelSize = label.size (withAttributes: nameTextAttributes)
      let labelOrigin = NSPoint (x: 0.0, y: gridSize * 4.0)
      shape.append (shape: EBTextShape (label, labelOrigin, nameTextAttributes, .center, .center))
    //--- Number
      let number = "##"
      let numberSize = number.size (withAttributes: nameTextAttributes)
      let numberOrigin = NSPoint (x: 0.0, y: -gridSize * 4.0)
      shape.append (shape: EBTextShape (number, numberOrigin, nameTextAttributes, .center, .center))
    //--- Build image
      let r = NSRect (
        x: -gridSize,
        y: -gridSize - gridSize * 4.0 - numberSize.height / 2.0,
        width: gridSize * 2.0,
        height: gridSize * 2.0 + (gridSize * 4.0 + labelSize.height / 2.0) + (gridSize * 4.0 + numberSize.height / 2.0)
      )
      let imageData = buildPDFimage (frame: r, shapes: shape)
      let possibleImage = NSImage (data: imageData)
      return (possibleImage, r)
    })

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
  //    Drag and drop destination
  //····················································································································

  override func draggingEntered (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    return .copy
  }

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
