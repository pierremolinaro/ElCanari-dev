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

fileprivate let symbolPasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pierre.pasteboard.symbol")

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
    self.mAddSegmentButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolSegment")
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

    self.mAddBezierButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolBezierCurve")
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

    self.mAddSolidOvalButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolSolidOval")
    self.mAddSolidOvalButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        NSColor.brown.setFill ()
        let bp = NSBezierPath (ovalIn: r)
        bp.fill ()
    })

    self.mAddOvalButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolOval")
    self.mAddOvalButton?.register (drawImageCallBack : {(_ rect : NSRect) in
      let r = rect.insetBy (dx: 5.0, dy: 5.0)
      NSColor.brown.setStroke ()
      let bp = NSBezierPath (ovalIn: r)
      bp.lineWidth = 2.0
      bp.stroke ()
    })

    self.mAddSolidRectButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolSolidRect")
    self.mAddSolidRectButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        NSColor.brown.setFill ()
        let bp = NSBezierPath (rect: r)
        bp.fill ()
    })

    self.mAddTextButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolText")
    self.mAddTextButton?.register (drawImageCallBack : {(_ rect : NSRect) in
        let r = rect.insetBy (dx: 3.0, dy: 3.0)
        let textAttributes : [NSAttributedString.Key : Any] = [
          NSAttributedString.Key.font : NSFont (name: "Cambria", size: 26.0)!,
          NSAttributedString.Key.foregroundColor : NSColor.brown
        ]
        let size = "T".size (withAttributes: textAttributes)
        "T".draw (at: NSPoint (x: r.midX - size.width / 2.0, y: r.midY - size.height / 2.0 + 3.0), withAttributes: textAttributes)
    })

    self.mAddPinButton?.register (draggedType: symbolPasteboardType, entityName: "SymbolPin")
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

    self.mComposedSymbolScrollView?.register (document: self, draggedTypes: [symbolPasteboardType])
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
      if pasteboard.availableType (from: [symbolPasteboardType]) != nil {
        if let dictionary = pasteboard.propertyList (forType: symbolPasteboardType) as? NSDictionary {
          do{
            let newObject = try makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as! SymbolObject
            self.ebUndoManager.disableUndoRegistration ()
            newObject.translate (xBy: pointInDestinationView.x, yBy: pointInDestinationView.y)
            self.ebUndoManager.enableUndoRegistration ()
            self.rootObject.symbolObjects_property.add (newObject)
            self.mSymbolObjectsController.select (object: newObject)
            ok = true
          }catch let error {
            let alert = NSAlert (error: error)
            alert.beginSheetModal (for: self.windowForSheet!, completionHandler: nil)
          }
        }
      }
    }
    return ok
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
