//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMPackageVersion = "PMPackageVersion"
let PMPackageComment = "PMPackageComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pierre.pasteboard.packzage")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedPackageDocument) class CustomizedPackageDocument : PackageDocument {

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout NSMutableDictionary) {
     metadataDictionary.setObject (NSNumber (value:version), forKey: PMPackageVersion as NSCopying)
     metadataDictionary.setObject (rootObject.comments, forKey: PMPackageComment as NSCopying)
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (metadataDictionary : NSDictionary) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary.object (forKey: PMPackageVersion) as? NSNumber {
      result = versionNumber.intValue
    }
    return result
  }

  //····················································································································
  //    windowControllerDidLoadNib: customization of interface
  //····················································································································

  fileprivate var mPackageColorObserver = EBOutletEvent ()

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Package color observer
    self.mPackageColorObserver.eventCallBack = { [weak self] in self?.updateDragSourceButtons () }
    g_Preferences?.packageColor_property.addEBObserver (self.mPackageColorObserver)
  //--- Set pages segmented control
    let pages = [self.mPackagePageView, self.mProgramPageView, self.mPadPageView, self.mInfosPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
    let inspectors = [
      self.mSelectedObjectsInspectorView,
      self.mGridZoomInspectorView,
      self.mDisplayInspectorView,
      self.mAutoNumberingInspectorView,
      self.mIssuesInspectorView
    ]
    self.mInspectorSegmentedControl?.register (masterView: self.mBaseInspectorView, inspectors)
  //--- Drag source buttons and destination scroll view
    self.mAddSegmentButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageSegment",
      scaleProvider: self.mComposedPackageView
    )
    self.mAddBezierButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageBezierCurve",
      scaleProvider: self.mComposedPackageView
    )
    self.mAddOvalButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageOval",
      scaleProvider: self.mComposedPackageView
    )
//
//    self.mAddOvalButton?.register (
//      draggedType: packagePasteboardType,
//      entityName: "SymbolOval",
//      scaleProvider: self.mComposedPackageView
//    )
//
//    self.mAddSolidRectButton?.register (
//      draggedType: packagePasteboardType,
//      entityName: "SymbolSolidRect",
//      scaleProvider: self.mComposedPackageView
//    )
//
//    self.mAddTextButton?.register (
//      draggedType: packagePasteboardType,
//      entityName: "SymbolText",
//      scaleProvider: self.mComposedPackageView
//    )
//
//    self.mAddPinButton?.register (
//      draggedType: packagePasteboardType,
//      entityName: "SymbolPin",
//      scaleProvider: self.mComposedPackageView
//    )
//
    self.mComposedPackageScrollView?.register (document: self, draggedTypes: [packagePasteboardType])
    self.mComposedPackageView?.register (pasteboardType: packagePasteboardType)
    let r = NSRect (x: 0.0, y: 0.0, width: milsToCocoaUnit (10_000.0), height: milsToCocoaUnit (10_000.0))
    self.mComposedPackageView?.set (minimumRectangle: r)
//    self.mComposedPackageView?.set (mouseGridInCanariUnit: SYMBOL_GRID_IN_CANARI_UNIT)
  //--- Register inspector views
    self.mPackageObjectsController.register (inspectorView: self.mSelectedObjectsInspectorView)
    self.mPackageObjectsController.register (inspectorView: self.mSegmentInspectorView, forClass: "PackageSegment")
    self.mPackageObjectsController.register (inspectorView: self.mBezierInspectorView, forClass: "PackageBezierCurve")
    self.mPackageObjectsController.register (inspectorView: self.mOvalInspectorView, forClass: "PackageOval")
//  //--- Set issue display view
//    self.mIssueTableView?.register (issueDisplayView: self.mComposedPackageView)
//    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
//    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 2)
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
      if pasteboard.availableType (from: [packagePasteboardType]) != nil {
        if let dataDictionary = pasteboard.propertyList (forType: packagePasteboardType) as? NSDictionary,
           let dictionaryArray = dataDictionary ["OBJECTS"] as? [NSDictionary],
           let X = dataDictionary ["X"] as? Int,
           let Y = dataDictionary ["Y"] as? Int {
          for dictionary in dictionaryArray {
            if let newObject = makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as? PackageObject {
              newObject.translate (
                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y
              )
              self.rootObject.packageObjects_property.add (newObject)
              self.mPackageObjectsController.select (object: newObject)
            }
          }
          ok = true
        }
      }
    }
    return ok
  }

  //····················································································································

//  fileprivate func imageForAddTextButton () ->  NSImage? {
//    let r = NSRect (x: 0.0, y: 0.0, width: 20.0, height: 20.0)
//    let textAttributes : [NSAttributedString.Key : Any] = [
//      NSAttributedString.Key.font : NSFont (name: "Cambria", size: 20.0)!,
//      NSAttributedString.Key.foregroundColor : g_Preferences?.symbolColor ?? NSColor.black
//    ]
//    let shape = EBTextShape ("T", CGPoint (x: r.midX, y: r.midY - 1.0), textAttributes, .center, .center)
//    let imagePDFData = buildPDFimage (frame: r, shape: shape)
//    return NSImage (data: imagePDFData)
//  }

  //····················································································································

//  fileprivate func imageForAddPinButton () ->  NSImage? {
//    let r = NSRect (x: 0.0, y: 0.0, width: 20.0, height: 20.0)
//    let circleDiameter : CGFloat = 8.0
//    let circle = NSRect (
//      x: r.maxX - circleDiameter - 2.0,
//      y: r.midY - circleDiameter / 2.0,
//      width: circleDiameter,
//      height: circleDiameter
//    )
//    let shape = EBShape ()
//    shape.append (EBFilledBezierPathShape ([NSBezierPath (ovalIn: circle)], g_Preferences?.symbolColor ?? NSColor.black))
//    let textAttributes : [NSAttributedString.Key : Any] = [
//      NSAttributedString.Key.font : NSFont.userFixedPitchFont (ofSize: 12.0)!,
//      NSAttributedString.Key.foregroundColor : g_Preferences?.symbolColor ?? NSColor.black
//    ]
//    shape.append (EBTextShape ("#", CGPoint (x: r.minX + 2.0, y: r.midY), textAttributes, .left, .center))
//    let imagePDFData = buildPDFimage (frame: r, shape: shape)
//    return NSImage (data: imagePDFData)
//  }

  //····················································································································

  private func updateDragSourceButtons () {
//    self.mAddPinButton?.image = self.imageForAddPinButton ()
//    self.mAddTextButton?.image = self.imageForAddTextButton ()
//    self.mAddOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddBezierButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddSegmentButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddSolidOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddSolidRectButton?.buildButtonImageFromDraggedObjectTypeName ()
  }

  //····················································································································
  //   removeWindowController
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
    g_Preferences?.packageColor_property.removeEBObserver (self.mPackageColorObserver)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
