//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMPackageVersion = "PMPackageVersion"
let PMPackageComment = "PMPackageComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.package")

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CustomizedPackageDocument) class CustomizedPackageDocument : PackageDocument {

  //····················································································································

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.metadataStatus!.rawValue)
  }

  //····················································································································

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMPackageVersion] = version
    metadataDictionary [PMPackageComment] = self.rootObject.comments
  }

  //····················································································································

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMPackageVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  //····················································································································
  //    buildUserInterface: customization of interface
  //····················································································································

  fileprivate var mPackageColorObserver = EBOutletEvent ()
  fileprivate var mPadColorObserver = EBOutletEvent ()
  internal var mPadNumberingObserver = EBModelEvent () // Used in PackageDocument-pad-numbering.swift

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Handle pad number event
    self.addPadNumberingObservers ()
  //--- Register document for renumbering pads
    self.mPadRenumberingPullDownButton?.register (document: self)
  //--- Register document for slave pad assignment
    self.mSlavePadAssignmentPopUpButton?.register (document: self)
  //--- Package color observer
    self.mPackageColorObserver.mEventCallBack = { [weak self] in self?.updateDragSourceButtons () }
    g_Preferences?.packageColor_property.addEBObserver (self.mPackageColorObserver)
  //--- Pad color observer
    self.mPadColorObserver.mEventCallBack = { [weak self] in self?.updateDragPadSourceButtons () }
    g_Preferences?.frontSidePadColor_property.addEBObserver (self.mPadColorObserver)
  //--- Set pages segmented control
    let pages = [self.mPackagePageView, self.mProgramPageView, self.mInfosPageView]
    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
    let inspectors = [
      self.mSelectedObjectsInspectorView,
      self.mGridZoomInspectorView,
      self.mDisplayInspectorView,
      self.mIssuesInspectorView
    ]
    self.mInspectorSegmentedControl?.register (masterView: self.mBaseInspectorView, inspectors)
  //--- Drag source buttons and destination scroll view
    self.mAddSegmentButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageSegment (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddBezierButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageBezier (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddOvalButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageOval (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddArcButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageArc (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddPadButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackagePad (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddSlavePadButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageSlavePad (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddGuideButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageGuide (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddGuideButton?.image = self.imageForAddGuideButton ()
    self.mAddDimensionButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageDimension (nil) },
      scaleProvider: self.mComposedPackageView
    )
    self.mAddZoneButton?.register (
      draggedType: packagePasteboardType,
      draggedObjectFactory: { return PackageZone (nil) },
      scaleProvider: self.mComposedPackageView
    )
 //--- Register scroll view
    self.mComposedPackageScrollView?.register (document: self, draggedTypes: [packagePasteboardType])
    self.mComposedPackageView?.register (pasteboardType: packagePasteboardType)
    let r = NSRect (x: 0.0, y: 0.0, width: milsToCocoaUnit (10_000.0), height: milsToCocoaUnit (10_000.0))
    self.mComposedPackageView?.set (minimumRectangle: r)
  //--- Register inspector views
    self.mPackageObjectsController.register (inspectorReceivingView: self.mSelectedObjectsInspectorView)
    self.mPackageObjectsController.register (inspectorView: self.mSegmentInspectorView, for: PackageSegment.self)
    self.mPackageObjectsController.register (inspectorView: self.mBezierInspectorView, for: PackageBezier.self)
    self.mPackageObjectsController.register (inspectorView: self.mOvalInspectorView, for: PackageOval.self)
    self.mPackageObjectsController.register (inspectorView: self.mArcInspectorView, for: PackageArc.self)
    self.mPackageObjectsController.register (inspectorView: self.mPadInspectorView, for: PackagePad.self)
    self.mPackageObjectsController.register (inspectorView: self.mSlavePadInspectorView, for: PackageSlavePad.self)
    self.mPackageObjectsController.register (inspectorView: self.mGuideInspectorView, for: PackageGuide.self)
    self.mPackageObjectsController.register (inspectorView: self.mDimensionInspectorView, for: PackageDimension.self)
    self.mPackageObjectsController.register (inspectorView: self.mZoneInspectorView, for: PackageZone.self)
  //--- Set issue display view
    self.mIssueTableView?.register (issueDisplayView: self.mComposedPackageView)
    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 3)
  //--- Update display
    if let view = self.mComposedPackageView {
      DispatchQueue.main.async { _ = view.scrollToVisible (view.objectsAndIssueBoundingBox) }
    }
  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
    g_Preferences?.packageColor_property.removeEBObserver (self.mPackageColorObserver)
    g_Preferences?.frontSidePadColor_property.removeEBObserver (self.mPadColorObserver)
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
          var objetsToSelect = [PackageObject] ()
          let userSet = OCObjectSet ()
          for dictionary in dictionaryArray {
            if let newObject = makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as? PackageObject {
              newObject.operationAfterPasting ()
              newObject.translate (
                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y,
                userSet: userSet
              )
              self.rootObject.packageObjects_property.add (newObject)
              objetsToSelect.append (newObject)
            }
          }
          self.mPackageObjectsController.setSelection (objetsToSelect)
          ok = true
        }
      }
    }
    return ok
  }

  //····················································································································

  fileprivate func imageForAddGuideButton () ->  NSImage? {
    var shape = EBShape ()
    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    var bp1 = EBBezierPath ()
    bp1.move (to: NSPoint (x: 5.0, y: 5.0))
    bp1.line (to: NSPoint (x: 35.0, y: 35.0))
    bp1.lineWidth = 3.0
    bp1.lineCapStyle = .round
    shape.add (stroke: [bp1], NSColor.lightGray)
    var bp2 = EBBezierPath ()
    bp2.move (to: NSPoint (x: 5.0, y: 5.0))
    bp2.line (to: NSPoint (x: 55.0, y: 55.0))
    bp2.lineWidth = 1.5
    bp2.lineCapStyle = .round
    shape.add (stroke: [bp2], NSColor.yellow)
    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
    return NSImage (data: imagePDFData)
  }

  //····················································································································

  private func updateDragSourceButtons () {
    self.mAddBezierButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddSegmentButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddArcButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddZoneButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddDimensionButton?.buildButtonImageFromDraggedObjectTypeName ()
  }

  //····················································································································

  private func updateDragPadSourceButtons () {
    self.mAddPadButton?.image = self.imageForAddMasterPadButton ()
    self.mAddSlavePadButton?.image = self.imageForAddSlavePadButton ()
  }

  //····················································································································

  fileprivate func imageForAddMasterPadButton () ->  NSImage? {
    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    var bp = EBBezierPath (rect: r.insetBy (dx: 12.0, dy: 8.0))
    bp.appendOval (in: r.insetBy (dx: 17.0, dy: 17.0))
    bp.windingRule = .evenOdd
    let shape = EBShape (filled: [bp], g_Preferences!.frontSidePadColor)
    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
    return NSImage (data: imagePDFData)
  }

  //····················································································································

  fileprivate func imageForAddSlavePadButton () ->  NSImage? {
    var shape = EBShape ()
  //---
    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    var bp = EBBezierPath (rect: r.insetBy (dx: 12.0, dy: 8.0))
    bp.appendOval (in: r.insetBy (dx: 17.0, dy: 17.0))
    bp.windingRule = .evenOdd
    shape.add (filled: [bp], g_Preferences!.frontSidePadColor)
 //---
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: 28.0),
      NSAttributedString.Key.foregroundColor : g_Preferences!.frontSidePadColor
    ]
    shape.add (text: "(", NSPoint (x : 2.0, y: 17.0), textAttributes, .onTheRight, .center)
    shape.add (text: ")", NSPoint (x :38.0, y: 17.0), textAttributes, .onTheLeft, .center)
 //---
    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
    return NSImage (data: imagePDFData)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
