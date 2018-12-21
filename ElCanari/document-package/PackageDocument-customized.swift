//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let PMPackageVersion = "PMPackageVersion"
let PMPackageComment = "PMPackageComment"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pierre.pasteboard.package")

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
  internal var mPadNumberingObserver = EBModelEvent ()

  //····················································································································

  override func windowControllerDidLoadNib (_ aController: NSWindowController) {
    super.windowControllerDidLoadNib (aController)
  //--- Handle pad number event
    self.addPadNumbringObservers ()
  //--- Register document for renumbering pull down button
    self.mPadRenumberingPullDownButton?.register (document: self)
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
    self.mAddArcButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageArc",
      scaleProvider: self.mComposedPackageView
    )
    self.mAddPadButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackagePad",
      scaleProvider: self.mComposedPackageView
    )
    self.mAddGuideButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageGuide",
      scaleProvider: self.mComposedPackageView
    )
    self.mAddGuideButton?.image = self.imageForAddGuideButton ()
    self.mAddDimensionButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageDimension",
      scaleProvider: self.mComposedPackageView
    )
    self.mAddZoneButton?.register (
      draggedType: packagePasteboardType,
      entityName: "PackageZone",
      scaleProvider: self.mComposedPackageView
    )
 //--- Register scroll view
    self.mComposedPackageScrollView?.register (document: self, draggedTypes: [packagePasteboardType])
    self.mComposedPackageView?.register (pasteboardType: packagePasteboardType)
    let r = NSRect (x: 0.0, y: 0.0, width: milsToCocoaUnit (10_000.0), height: milsToCocoaUnit (10_000.0))
    self.mComposedPackageView?.set (minimumRectangle: r)
    self.mComposedPackageView?.scrollToVisible (NSRect ())
  //--- Register inspector views
    self.mPackageObjectsController.register (inspectorView: self.mSelectedObjectsInspectorView)
    self.mPackageObjectsController.register (inspectorView: self.mSegmentInspectorView, forClass: "PackageSegment")
    self.mPackageObjectsController.register (inspectorView: self.mBezierInspectorView, forClass: "PackageBezierCurve")
    self.mPackageObjectsController.register (inspectorView: self.mOvalInspectorView, forClass: "PackageOval")
    self.mPackageObjectsController.register (inspectorView: self.mArcInspectorView, forClass: "PackageArc")
    self.mPackageObjectsController.register (inspectorView: self.mPadInspectorView, forClass: "PackagePad")
    self.mPackageObjectsController.register (inspectorView: self.mGuideInspectorView, forClass: "PackageGuide")
    self.mPackageObjectsController.register (inspectorView: self.mDimensionInspectorView, forClass: "PackageDimension")
    self.mPackageObjectsController.register (inspectorView: self.mZoneInspectorView, forClass: "PackageZone")
  //--- Set issue display view
    self.mIssueTableView?.register (issueDisplayView: self.mComposedPackageView)
    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 4)
  }

  //····················································································································
  //   removeWindowController
  //····················································································································

  override func removeUserInterface () {
    super.removeUserInterface ()
    g_Preferences?.packageColor_property.removeEBObserver (self.mPackageColorObserver)
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
          for dictionary in dictionaryArray {
            if let newObject = makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as? PackageObject {
              newObject.operationAfterPasting ()
              newObject.translate (
                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y
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
    let shape = EBShape ()
    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    let bp1 = NSBezierPath ()
    bp1.move (to: NSPoint (x: 5.0, y: 5.0))
    bp1.line (to: NSPoint (x: 35.0, y: 35.0))
    bp1.lineWidth = 3.0
    bp1.lineCapStyle = .round
    shape.append (EBStrokeBezierPathShape ([bp1], NSColor.lightGray))
    let bp2 = NSBezierPath ()
    bp2.move (to: NSPoint (x: 5.0, y: 5.0))
    bp2.line (to: NSPoint (x: 55.0, y: 55.0))
    bp2.lineWidth = 1.5
    bp2.lineCapStyle = .round
    shape.append (EBStrokeBezierPathShape ([bp2], NSColor.yellow))
    let imagePDFData = buildPDFimage (frame: r, shape: shape)
    return NSImage (data: imagePDFData)
  }

  //····················································································································

  private func updateDragSourceButtons () {
    self.mAddBezierButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddSegmentButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddArcButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddPadButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddZoneButton?.buildButtonImageFromDraggedObjectTypeName ()
    self.mAddDimensionButton?.buildButtonImageFromDraggedObjectTypeName ()
  }

   //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
