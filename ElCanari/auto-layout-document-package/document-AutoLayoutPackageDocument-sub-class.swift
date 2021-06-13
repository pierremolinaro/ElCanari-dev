//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

//let PMPackageVersion = "PMPackageVersion"
//let PMPackageComment = "PMPackageComment"

//----------------------------------------------------------------------------------------------------------------------

//let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.package")

//----------------------------------------------------------------------------------------------------------------------

@objc(AutoLayoutPackageDocumentSubClass) final class AutoLayoutPackageDocumentSubClass : AutoLayoutPackageDocument {

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

//  fileprivate var mPackageColorObserver = EBOutletEvent ()
//  fileprivate var mPadColorObserver = EBOutletEvent ()

  //····················································································································

  override func ebBuildUserInterface () {
  //--- Model image points
    self.setupImagePointsAndTheirObservers ()
  //--- Handle pad number event
    self.addPadNumberingObservers ()
  //--- Register document for renumbering pads
// §    self.mPadRenumberingPullDownButton?.register (document: self)
  //--- Register document for slave pad assignment
// §    self.mSlavePadAssignmentPopUpButton?.register (document: self)
  //--- Package color observer
//    self.mPackageColorObserver.mEventCallBack = { [weak self] in self?.updateDragSourceButtons () }
//    preferences_packageColor_property.addEBObserver (self.mPackageColorObserver)
  //--- Pad color observer
//    self.mPadColorObserver.mEventCallBack = { [weak self] in self?.updateDragPadSourceButtons () }
//    preferences_frontSidePadColor_property.addEBObserver (self.mPadColorObserver)
  //--- Set pages segmented control
//    let pages = [self.mModelImagePageView, self.mPackagePageView, self.mProgramPageView, self.mInfosPageView]
//    self.mPageSegmentedControl?.register (masterView: self.mMasterView, pages)
  //--- Set inspector segmented control
//    let inspectors = [
//      self.mSelectedObjectsInspectorView,
//      self.mGridZoomInspectorView,
//      self.mDisplayInspectorView,
//      self.mIssuesInspectorView
//    ]
//    self.mInspectorSegmentedControl?.register (masterView: self.mBaseInspectorView, inspectors)
  //--- Drag source buttons and destination scroll view
//    self.mAddSegmentButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageSegment (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddBezierButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageBezier (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddOvalButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageOval (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddArcButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageArc (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddPadButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackagePad (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddSlavePadButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { [weak self] in return self?.makeSlavePad () },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddGuideButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageGuide (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddGuideButton?.image = self.imageForAddGuideButton ()
//    self.mAddDimensionButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageDimension (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
//    self.mAddZoneButton?.register (
//      draggedType: packagePasteboardType,
//      draggedObjectFactory: { return (PackageZone (nil), NSDictionary ()) },
//      scaleProvider: self.mComposedPackageView?.mGraphicView
//    )
 //--- Register scroll view
//     self.mComposedPackageView?.mScrollView?.register (document: self, draggedTypes: [packagePasteboardType])
//     self.mComposedPackageView?.mGraphicView.register (pasteboardType: packagePasteboardType)
  //--- Register inspector views
// §   self.mPackageObjectsController.register (inspectorReceivingView: self.mSelectedObjectsInspectorView)
//    self.mPackageObjectsController.register (inspectorView: self.mSegmentInspectorView, for: PackageSegment.self)
//    self.mPackageObjectsController.register (inspectorView: self.mBezierInspectorView, for: PackageBezier.self)
//    self.mPackageObjectsController.register (inspectorView: self.mOvalInspectorView, for: PackageOval.self)
//    self.mPackageObjectsController.register (inspectorView: self.mArcInspectorView, for: PackageArc.self)
//    self.mPackageObjectsController.register (inspectorView: self.mPadInspectorView, for: PackagePad.self)
//    self.mPackageObjectsController.register (inspectorView: self.mSlavePadInspectorView, for: PackageSlavePad.self)
//    self.mPackageObjectsController.register (inspectorView: self.mGuideInspectorView, for: PackageGuide.self)
//    self.mPackageObjectsController.register (inspectorView: self.mDimensionInspectorView, for: PackageDimension.self)
//    self.mPackageObjectsController.register (inspectorView: self.mZoneInspectorView, for: PackageZone.self)
  //--- Set issue display view
// §    self.mIssueTableView?.register (issueDisplayView: self.mComposedPackageView?.mGraphicView)
// §    self.mIssueTableView?.register (hideIssueButton: self.mDeselectIssueButton)
// §    self.mIssueTableView?.register (segmentedControl: self.mInspectorSegmentedControl, segment: 3)
  //--- Update display
//    if let view = self.mComposedPackageView?.mGraphicView {
//      DispatchQueue.main.async { view.scrollToVisibleObjectsOrToZero () }
//    }
    super.ebBuildUserInterface () // Should be the last instruction
  }

  //····················································································································

//  fileprivate func makeSlavePad () -> (PackageSlavePad, NSDictionary) {
//     let additionalDictionary = NSMutableDictionary ()
//     for object in self.mPackageObjectsController.selectedArray {
//       if let masterPad = object as? PackagePad {
//         additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.ebObjectIndex
//       }
//     }
//     if additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] == nil {
//       for object in self.rootObject.packageObjects {
//         if let masterPad = object as? PackagePad {
//           additionalDictionary [ADDITIONAL_DICTIONARY_MASTER_PAD_ID_KEY] = masterPad.ebObjectIndex
//         }
//       }
//     }
//    return (PackageSlavePad (nil), additionalDictionary)
//  }

  //····················································································································
  //   removeUserInterface
  //····················································································································

  override func removeUserInterface () {
//    preferences_packageColor_property.removeEBObserver (self.mPackageColorObserver)
//    preferences_frontSidePadColor_property.removeEBObserver (self.mPadColorObserver)
    self.removeImagePointsObservers ()
    super.removeUserInterface ()
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
      if pasteboard.availableType (from: [packagePasteboardType]) != nil,
         let dataDictionary = pasteboard.propertyList (forType: packagePasteboardType) as? NSDictionary,
         let dictionaryArray = dataDictionary [OBJECT_DICTIONARY_KEY] as? [NSDictionary],
         let additionalDictionaryArray = dataDictionary [OBJECT_ADDITIONAL_DICTIONARY_KEY] as? [NSDictionary],
         let X = dataDictionary [X_KEY] as? Int,
         let Y = dataDictionary [Y_KEY] as? Int {
        var newObjectArray = [PackageObject] ()
        var userSet = Set <EBObject> ()
        var idx = 0
        var errorMessage = ""
        for dictionary in dictionaryArray {
          if let newObject = makeManagedObjectFromDictionary (self.ebUndoManager, dictionary) as? PackageObject {
            if errorMessage == "" {
              errorMessage = newObject.operationAfterPasting (additionalDictionary: additionalDictionaryArray [idx], objectArray: self.rootObject.packageObjects)
            }
            idx += 1
            if errorMessage == "" {
              newObject.translate (
                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y,
                userSet: &userSet
              )
              newObjectArray.append (newObject)
            }
          }
        }
        if errorMessage == "" {
          for newObject in newObjectArray {
            self.rootObject.packageObjects_property.add (newObject)
          }
          self.mPackageObjectsController.setSelection (newObjectArray)
        }else{
           let alert = NSAlert ()
           alert.messageText = errorMessage
           alert.addButton (withTitle: "Ok")
           alert.beginSheetModal (for: self.windowForSheet!) { (inReturnCode : NSApplication.ModalResponse) in }
        }
        ok = true
      }
    }
    return ok
  }

  //····················································································································

//  fileprivate func imageForAddGuideButton () ->  NSImage? {
//    var shape = EBShape ()
//    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
//    var bp1 = EBBezierPath ()
//    bp1.move (to: NSPoint (x: 5.0, y: 5.0))
//    bp1.line (to: NSPoint (x: 35.0, y: 35.0))
//    bp1.lineWidth = 3.0
//    bp1.lineCapStyle = .round
//    shape.add (stroke: [bp1], NSColor.lightGray)
//    var bp2 = EBBezierPath ()
//    bp2.move (to: NSPoint (x: 5.0, y: 5.0))
//    bp2.line (to: NSPoint (x: 55.0, y: 55.0))
//    bp2.lineWidth = 1.5
//    bp2.lineCapStyle = .round
//    shape.add (stroke: [bp2], NSColor.yellow)
//    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
//    return NSImage (data: imagePDFData)
//  }

  //····················································································································

//  private func updateDragSourceButtons () {
//    self.mAddBezierButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddSegmentButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddOvalButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddArcButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddZoneButton?.buildButtonImageFromDraggedObjectTypeName ()
//    self.mAddDimensionButton?.buildButtonImageFromDraggedObjectTypeName ()
//  }

  //····················································································································

//  private func updateDragPadSourceButtons () {
//    self.mAddPadButton?.image = self.imageForAddMasterPadButton ()
//    self.mAddSlavePadButton?.image = self.imageForAddSlavePadButton ()
//  }

  //····················································································································

//  fileprivate func imageForAddMasterPadButton () ->  NSImage? {
//    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
//    var bp = EBBezierPath (rect: r.insetBy (dx: 12.0, dy: 8.0))
//    bp.appendOval (in: r.insetBy (dx: 17.0, dy: 17.0))
//    bp.windingRule = .evenOdd
//    let shape = EBShape (filled: [bp], preferences_frontSidePadColor)
//    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
//    return NSImage (data: imagePDFData)
//  }

  //····················································································································

//  fileprivate func imageForAddSlavePadButton () ->  NSImage? {
//    var shape = EBShape ()
//  //---
//    let r = NSRect (x: 0.0, y: 0.0, width: 40.0, height: 40.0)
//    var bp = EBBezierPath (rect: r.insetBy (dx: 12.0, dy: 8.0))
//    bp.appendOval (in: r.insetBy (dx: 17.0, dy: 17.0))
//    bp.windingRule = .evenOdd
//    shape.add (filled: [bp], preferences_frontSidePadColor)
// //---
//    let textAttributes : [NSAttributedString.Key : Any] = [
//      NSAttributedString.Key.font : NSFont.systemFont (ofSize: 28.0),
//      NSAttributedString.Key.foregroundColor : preferences_frontSidePadColor
//    ]
//    shape.add (text: "(", NSPoint (x:  2.0, y: 17.0), textAttributes, .onTheRight, .center)
//    shape.add (text: ")", NSPoint (x: 38.0, y: 17.0), textAttributes, .onTheLeft, .center)
// //---
//    let imagePDFData = buildPDFimageData (frame: r, shape: shape)
//    return NSImage (data: imagePDFData)
//  }

  //····················································································································
  //   MODEL IMAGE POINTS OBSERVERS
  //····················································································································

  private var mModelImageFirstPointLastX = 0
  private var mModelImageFirstPointXObserver : EBModelEvent? = nil

  private var mModelImageFirstPointLastY = 0
  private var mModelImageFirstPointYObserver : EBModelEvent? = nil

  private var mModelImagePointsLastDx = 0
  private var mModelImagePointsDxObserver : EBModelEvent? = nil

  private var mModelImagePointsLastDy = 0
  private var mModelImagePointsDyObserver : EBModelEvent? = nil

  //····················································································································

  override func buildModelPoints () {
    super.buildModelPoints ()
    self.mModelImageFirstPointLastX = self.rootObject.mModelImageFirstPointX!
    self.mModelImageFirstPointLastY = self.rootObject.mModelImageFirstPointY!
    self.mModelImagePointsLastDx = self.rootObject.mModelImageSecondPointDx!
    self.mModelImagePointsLastDy = self.rootObject.mModelImageSecondPointDy!
  }

  //····················································································································

  fileprivate func setupImagePointsAndTheirObservers () {
  //--- Model image points
  //  self.buildModelPoints ()
  //--- Add model observers
    do{
      let observer = EBModelEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImageFirstPointXDidChange () }
      self.rootObject.mModelImageFirstPointX_property.addEBObserver (observer)
      self.mModelImageFirstPointXObserver = observer
    }
    do{
      let observer = EBModelEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImageFirstPointYDidChange () }
      self.rootObject.mModelImageFirstPointY_property.addEBObserver (observer)
      self.mModelImageFirstPointYObserver = observer
    }
    do{
      let observer = EBModelEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImagePointsDxDidChange () }
      self.rootObject.mModelImageSecondPointDx_property.addEBObserver (observer)
      self.mModelImagePointsDxObserver = observer
    }
    do{
      let observer = EBModelEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImagePointsDyDidChange () }
      self.rootObject.mModelImageSecondPointDy_property.addEBObserver (observer)
      self.mModelImagePointsDyObserver = observer
    }
  }

  //····················································································································

  fileprivate func removeImagePointsObservers () {
    if let observer = self.mModelImageFirstPointXObserver {
      self.rootObject.mModelImageFirstPointX_property.removeEBObserver (observer)
      self.mModelImageFirstPointXObserver = nil
    }
    if let observer = self.mModelImageFirstPointYObserver {
      self.rootObject.mModelImageFirstPointY_property.removeEBObserver (observer)
      self.mModelImageFirstPointYObserver = nil
    }
    if let observer = self.mModelImagePointsDxObserver {
      self.rootObject.mModelImageSecondPointDx_property.removeEBObserver (observer)
      self.mModelImagePointsDxObserver = nil
    }
    if let observer = self.mModelImagePointsDyObserver {
      self.rootObject.mModelImageSecondPointDy_property.removeEBObserver (observer)
      self.mModelImagePointsDyObserver = nil
    }
  }

  //····················································································································

  fileprivate func modelImageFirstPointXDidChange () {
    if let newX = self.rootObject.mModelImageFirstPointX {
      if newX != self.mModelImageFirstPointLastX {
        self.mModelImageFirstPointLastX = newX
        if !self.rootObject.mPointsAreLocked {
          self.rootObject.mModelImageFirstPointXOnLock = newX
        }
        self.applyAffineTransformToModelImage ()
      }
    }
  }

  //····················································································································

  fileprivate func modelImageFirstPointYDidChange () {
    if let newY = self.rootObject.mModelImageFirstPointY {
      if newY != self.mModelImageFirstPointLastY {
        self.mModelImageFirstPointLastY = newY
        if !self.rootObject.mPointsAreLocked {
          self.rootObject.mModelImageFirstPointYOnLock = newY
        }
        self.applyAffineTransformToModelImage ()
      }
    }
  }

  //····················································································································

  fileprivate func modelImagePointsDxDidChange () {
    if let newX = self.rootObject.mModelImageSecondPointDx {
      if newX != self.mModelImagePointsLastDx {
        self.mModelImagePointsLastDx = newX
        if !self.rootObject.mPointsAreLocked {
          self.rootObject.mModelImagePointsDxOnLock = newX
        }
        self.modelImageSecondPointDidChange ()
      }
    }
  }

  //····················································································································

  fileprivate func modelImagePointsDyDidChange () {
    if let newY = self.rootObject.mModelImageSecondPointDy {
      if newY != self.mModelImagePointsLastDy {
        self.mModelImagePointsLastDy = newY
        if !self.rootObject.mPointsAreLocked {
          self.rootObject.mModelImagePointsDyOnLock = newY
        }
        self.modelImageSecondPointDidChange ()
      }
    }
  }

  //····················································································································

  fileprivate func modelImageSecondPointDidChange () {
    if self.rootObject.mPointsAreLocked {
      let lockDx = CGFloat (self.rootObject.mModelImagePointsDxOnLock)
      let lockDy = CGFloat (self.rootObject.mModelImagePointsDyOnLock)
      let distanceReference = sqrt (lockDx * lockDx + lockDy * lockDy)
      let angleReference = atan2 (lockDy, lockDx) // Result in radian
      let dx = CGFloat (self.rootObject.mModelImageSecondPointDx!)
      let dy = CGFloat (self.rootObject.mModelImageSecondPointDy!)
      let newDistance = sqrt (dx * dx + dy * dy)
      self.rootObject.mModelImageScale = Double (newDistance / distanceReference)
      let angle = atan2 (dy, dx) - angleReference // Result in radian
      self.rootObject.mModelImageRotationInRadians = Double (angle)
      self.applyAffineTransformToModelImage ()
    }
  }

  //····················································································································

  fileprivate func applyAffineTransformToModelImage () {
    if self.rootObject.mPointsAreLocked {
      let af = NSAffineTransform ()
      let scale = CGFloat (self.rootObject.mModelImageScale)
      af.translateX (
        by: canariUnitToCocoa (self.rootObject.mModelImageFirstPointX!),
        yBy: canariUnitToCocoa (self.rootObject.mModelImageFirstPointY!)
      )
      af.rotate (byRadians: CGFloat (self.rootObject.mModelImageRotationInRadians))
      af.scaleX (by: scale, yBy: scale)
      af.translateX (
        by: canariUnitToCocoa (-self.rootObject.mModelImageFirstPointXOnLock),
        yBy: canariUnitToCocoa (-self.rootObject.mModelImageFirstPointYOnLock)
      )
//      self.mModelImageView?.mBackgroundImageAffineTransform = af
//      self.mComposedPackageView?.mForegroundImageAffineTransform = af
      self.mModelImageObjectsController.setBackgroundImageAffineTransform (af)
      self.mPackageObjectsController.setBackgroundImageAffineTransform (af)
    }
  }

  //····················································································································

  fileprivate var mPadNumberingObserver = EBModelEvent ()

  //····················································································································

  internal func addPadNumberingObservers () {
    self.mPadNumberingObserver.mEventCallBack = { [weak self] in self?.handlePadNumbering () }
    self.rootObject.packagePads_property.addEBObserverOf_xCenter (self.mPadNumberingObserver)
    self.rootObject.packagePads_property.addEBObserverOf_yCenter (self.mPadNumberingObserver)
    self.rootObject.padNumbering_property.addEBObserver (self.mPadNumberingObserver)
    self.rootObject.packageZones_property.addEBObserverOf_rect (self.mPadNumberingObserver)
    self.rootObject.packageZones_property.addEBObserverOf_zoneNumbering (self.mPadNumberingObserver)
    self.rootObject.packageZones_property.addEBObserver (self.mPadNumberingObserver)
    self.rootObject.counterClockNumberingStartAngle_property.addEBObserver (self.mPadNumberingObserver)
  }

  //····················································································································

  private func handlePadNumbering () {
    var allPads = self.rootObject.packagePads_property.propval
    let aPad = allPads.first
    var zoneDictionary = [PackageZone : [PackagePad]] ()
    for zone in self.rootObject.packageZones_property.propval {
      let zoneRect = zone.rect!
      var idx = 0
      while idx < allPads.count {
        let pad = allPads [idx]
        idx += 1
        if zoneRect.contains (x: pad.xCenter, y: pad.yCenter) {
          let a = zoneDictionary [zone] ?? []
          zoneDictionary [zone] = a + [pad]
          pad.zone_property.setProp (zone)
          idx -= 1
          allPads.remove(at: idx)
        }
      }
    }
  //---
    for (zone, padArray) in zoneDictionary {
      var forbiddenPadNumberSet = Set <Int> ()
      for f in zone.forbiddenPadNumbers {
        forbiddenPadNumberSet.insert (f.padNumber)
      }
      self.performPadNumbering (padArray, zone.zoneNumbering, forbiddenPadNumberSet)
    }
  //--- Handle pads outside zones
    for pad in allPads {
      pad.zone_property.setProp (nil)
    }
    self.performPadNumbering (allPads, self.rootObject.padNumbering, [])
  //--- Link slave pads to any pad
    let allSlavePads = self.rootObject.packageSlavePads_property.propval
    for slavePad in allSlavePads {
      if slavePad.master == nil {
        slavePad.master = aPad
      }
    }
  }

  //····················································································································

  private func performPadNumbering (_ inPadArray : [PackagePad],
                                    _ inNumberingPolicy : PadNumbering,
                                    _ inForbiddenPadNumberSet : Set <Int>) {
    // Swift.print ("handlePadNumbering")
  //--- Get all pads
    var allPads = inPadArray
  //--- Apply pad numbering
    switch inNumberingPolicy {
    case .noNumbering :
    //--- Find max pad number
      var maxPadNumber = 0
      for pad in allPads {
        if maxPadNumber < pad.padNumber {
          maxPadNumber = pad.padNumber
        }
      }
    //--- Set a number to pad with number equal to 0
      for pad in allPads {
        if pad.padNumber == 0 {
          maxPadNumber += 1
          pad.padNumber = maxPadNumber
        }
      }
    //--- Sort pads by pad number
      allPads.sort (by: { $0.padNumber < $1.padNumber } )
    case .counterClock :
      if allPads.count > 0 {
        var xMin = Int.max
        var yMin = Int.max
        var xMax = Int.min
        var yMax = Int.min
        for pad in allPads {
          if xMin > pad.xCenter {
            xMin = pad.xCenter
          }
          if yMin > pad.yCenter {
            yMin = pad.yCenter
          }
          if xMax < pad.xCenter {
            xMax = pad.xCenter
          }
          if yMax < pad.yCenter {
            yMax = pad.yCenter
          }
        }
        let center = CanariPoint (x: (xMin + xMax) / 2, y: (yMin + yMax) / 2)
        let startAngle = CGFloat (self.rootObject.counterClockNumberingStartAngle) * .pi / 180.0
        allPads.sort (by: { $0.angleInRadian (from: center, from: startAngle) < $1.angleInRadian (from: center, from: startAngle) } )
      }
    case .upRight :
      allPads.sort (by: { ($0.yCenter > $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter > $1.xCenter)) } )
    case .upLeft :
      allPads.sort (by: { ($0.yCenter > $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter < $1.xCenter)) } )
    case .downRight :
      allPads.sort (by: { ($0.yCenter < $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter > $1.xCenter)) } )
    case .downLeft :
      allPads.sort (by: { ($0.yCenter < $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter < $1.xCenter)) } )
    case .rightUp :
      allPads.sort (by: { ($0.xCenter > $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter < $1.yCenter)) } )
    case .rightDown :
      allPads.sort (by: { ($0.xCenter > $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter > $1.yCenter)) } )
    case .leftUp :
      allPads.sort (by: { ($0.xCenter < $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter < $1.yCenter)) } )
    case .leftDown :
      allPads.sort (by: { ($0.xCenter < $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter > $1.yCenter)) } )
    }
  //--- Set pad numbers from 1
    var idx = 1
    for pad in allPads {
      while inForbiddenPadNumberSet.contains (idx) {
        idx += 1
      }
      pad.padNumber = idx
      idx += 1
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
