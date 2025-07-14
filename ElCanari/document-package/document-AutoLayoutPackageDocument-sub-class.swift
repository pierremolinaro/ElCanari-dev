//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

let PMPackageVersion = "PMPackageVersion"
let PMPackageComment = "PMPackageComment"

//--------------------------------------------------------------------------------------------------

let packagePasteboardType = NSPasteboard.PasteboardType (rawValue: "name.pcmolinaro.pasteboard.package")

//--------------------------------------------------------------------------------------------------

@objc(AutoLayoutPackageDocumentSubClass) final class AutoLayoutPackageDocumentSubClass : AutoLayoutPackageDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func metadataStatusForSaving () -> UInt8 {
    return UInt8 (self.metadataStatus!.rawValue)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func saveMetadataDictionary (version : Int, metadataDictionary : inout [String : Any]) {
    metadataDictionary [PMPackageVersion] = version
    metadataDictionary [PMPackageComment] = self.rootObject.comments
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func readVersionFromMetadataDictionary (_ metadataDictionary : [String : Any]) -> Int {
    var result = 0
    if let versionNumber = metadataDictionary [PMPackageVersion] as? Int {
      result = versionNumber
    }
    return result
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func windowDefaultSize () -> NSSize {
    return NSSize (width: 800, height: 600)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final func defaultDraftName () -> String {
    return "untitled"
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    buildUserInterface: customization of interface
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func ebBuildUserInterface () {
  //--- Model image points
    self.setupImagePointsAndTheirObservers ()
  //--- Handle pad number event
    self.addPadNumberingObservers ()
  //---
    super.ebBuildUserInterface () // Should be the last instruction
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Drag and drop destination
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func draggingEntered (_ _ : any NSDraggingInfo, _ _ : NSScrollView) -> NSDragOperation {
    return .copy
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func prepareForDragOperation (_ sender: any NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func performDragOperation (_ sender: any NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    var ok = false
    if let documentView = destinationScrollView.documentView {
      let pointInWindow = sender.draggingLocation
      let pointInDestinationView = documentView.convert (pointInWindow, from:nil).aligned (onGrid: SYMBOL_GRID_IN_COCOA_UNIT)
      let pasteboard = sender.draggingPasteboard
      if pasteboard.availableType (from: [packagePasteboardType]) != nil,
         let dataDictionary = pasteboard.propertyList (forType: packagePasteboardType) as? [String : Any],
         let dictionaryArray = dataDictionary [OBJECT_DICTIONARY_KEY] as? [[String : Any]],
         let additionalDictionaryArray = dataDictionary [OBJECT_ADDITIONAL_DICTIONARY_KEY] as? [[String : Any]],
         let X = dataDictionary [X_KEY] as? Int,
         let Y = dataDictionary [Y_KEY] as? Int {
        var newObjectArray = [PackageObject] ()
        var userSet = EBReferenceSet <EBManagedObject> ()
        var idx = 0
        var errorMessage = ""
        for dictionary in dictionaryArray {
          if let newObject = makeManagedObjectFromDictionary (self.undoManager, dictionary) as? PackageObject {
            if errorMessage.isEmpty {
              errorMessage = newObject.operationAfterPasting (additionalDictionary: additionalDictionaryArray [idx],
                                                              optionalDocument: self,
                                                              objectArray: self.rootObject.packageObjects.values)
            }
            idx += 1
            if errorMessage.isEmpty {
              newObject.translate (
                xBy: cocoaToCanariUnit (pointInDestinationView.x) - X,
                yBy: cocoaToCanariUnit (pointInDestinationView.y) - Y,
                userSet: &userSet
              )
              newObjectArray.append (newObject)
              if let grid = self.mPackageGraphicView?.grid {
                newObject.snapToGrid (grid)
              }
            }
          }
        }
        if errorMessage.isEmpty {
          for newObject in newObjectArray {
            self.rootObject.packageObjects_property.add (newObject)
          }
          self.mPackageObjectsController.setSelection (newObjectArray)
        }else{
           let alert = NSAlert ()
           alert.messageText = errorMessage
           _ = alert.addButton (withTitle: "Ok")
           alert.beginSheetModal (for: self.windowForSheet!) { (inReturnCode : NSApplication.ModalResponse) in }
        }
        ok = true
      }
    }
    return ok
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   MODEL IMAGE POINTS OBSERVERS
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mModelImageFirstPointLastX = 0
  private var mModelImageFirstPointXObserver : EBOutletEvent? = nil

  private var mModelImageFirstPointLastY = 0
  private var mModelImageFirstPointYObserver : EBOutletEvent? = nil

  private var mModelImagePointsLastDx = 0
  private var mModelImagePointsDxObserver : EBOutletEvent? = nil

  private var mModelImagePointsLastDy = 0
  private var mModelImagePointsDyObserver : EBOutletEvent? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func buildModelPoints () {
    super.buildModelPoints ()
    self.mModelImageFirstPointLastX = self.rootObject.mModelImageFirstPointX!
    self.mModelImageFirstPointLastY = self.rootObject.mModelImageFirstPointY!
    self.mModelImagePointsLastDx = self.rootObject.mModelImageSecondPointDx!
    self.mModelImagePointsLastDy = self.rootObject.mModelImageSecondPointDy!
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func setupImagePointsAndTheirObservers () {
  //--- Add model observers
    do{
      let observer = EBOutletEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImageFirstPointXDidChange () }
      self.rootObject.mModelImageFirstPointX_property.startsBeingObserved (by: observer)
      self.mModelImageFirstPointXObserver = observer
    }
    do{
      let observer = EBOutletEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImageFirstPointYDidChange () }
      self.rootObject.mModelImageFirstPointY_property.startsBeingObserved (by: observer)
      self.mModelImageFirstPointYObserver = observer
    }
    do{
      let observer = EBOutletEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImagePointsDxDidChange () }
      self.rootObject.mModelImageSecondPointDx_property.startsBeingObserved (by: observer)
      self.mModelImagePointsDxObserver = observer
    }
    do{
      let observer = EBOutletEvent ()
      observer.mEventCallBack = { [weak self] in self?.modelImagePointsDyDidChange () }
      self.rootObject.mModelImageSecondPointDy_property.startsBeingObserved (by: observer)
      self.mModelImagePointsDyObserver = observer
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
      self.mModelImageObjectsController.setBackgroundImageAffineTransform (af)
      self.mPackageObjectsController.setForegroundImageAffineTransform (af)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate var mPadNumberingObserver = EBOutletEvent ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addPadNumberingObservers () {
    self.mPadNumberingObserver.mEventCallBack = { [weak self] in self?.handlePadNumbering () }
    self.rootObject.packagePads_property.toMany_xCenter_StartsBeingObserved (by: self.mPadNumberingObserver)
    self.rootObject.packagePads_property.toMany_yCenter_StartsBeingObserved (by: self.mPadNumberingObserver)
    self.rootObject.padNumbering_property.startsBeingObserved (by: self.mPadNumberingObserver)
    self.rootObject.packageZones_property.toMany_rect_StartsBeingObserved (by: self.mPadNumberingObserver)
    self.rootObject.packageZones_property.toMany_zoneNumbering_StartsBeingObserved (by: self.mPadNumberingObserver)
    self.rootObject.packageZones_property.startsBeingObserved (by: self.mPadNumberingObserver)
    self.rootObject.counterClockNumberingStartAngle_property.startsBeingObserved (by: self.mPadNumberingObserver)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func handlePadNumbering () {
    var allPads = self.rootObject.packagePads_property.propval
    let aPad = allPads.first
    var zoneDictionary = EBReferenceDictionary <PackageZone, [PackagePad]> ()
    for zone in self.rootObject.packageZones.values {
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
    for (zone, padArray) in zoneDictionary.values {
      var forbiddenPadNumberSet = Set <Int> ()
      for f in zone.forbiddenPadNumbers.values {
        forbiddenPadNumberSet.insert (f.padNumber)
      }
      self.performPadNumbering (padArray, zone.zoneNumbering, forbiddenPadNumberSet)
    }
  //--- Handle pads outside zones
    for pad in allPads.values {
      pad.zone_property.setProp (nil)
    }
    self.performPadNumbering (allPads.values, self.rootObject.padNumbering, [])
  //--- Link slave pads to any pad
    let allSlavePads = self.rootObject.packageSlavePads_property.propval
    for slavePad in allSlavePads.values {
      if slavePad.master == nil {
        slavePad.master = aPad
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
      allPads.sort { $0.padNumber < $1.padNumber }
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
        allPads.sort { $0.angleInRadian (from: center, from: startAngle) < $1.angleInRadian (from: center, from: startAngle) }
      }
    case .upRight :
      allPads.sort { ($0.yCenter > $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter > $1.xCenter)) }
    case .upLeft :
      allPads.sort { ($0.yCenter > $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter < $1.xCenter)) }
    case .downRight :
      allPads.sort { ($0.yCenter < $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter > $1.xCenter)) }
    case .downLeft :
      allPads.sort { ($0.yCenter < $1.yCenter) || (($0.yCenter == $1.yCenter) && ($0.xCenter < $1.xCenter)) }
    case .rightUp :
      allPads.sort { ($0.xCenter > $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter < $1.yCenter)) }
    case .rightDown :
      allPads.sort { ($0.xCenter > $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter > $1.yCenter)) }
    case .leftUp :
      allPads.sort { ($0.xCenter < $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter < $1.yCenter)) }
    case .leftDown :
      allPads.sort { ($0.xCenter < $1.xCenter) || (($0.xCenter == $1.xCenter) && ($0.yCenter > $1.yCenter)) }
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
