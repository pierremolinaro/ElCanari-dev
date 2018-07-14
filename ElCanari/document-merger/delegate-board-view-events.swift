//
//  delegate-board-view-events.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 11/07/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   DelegateForMergerBoardViewEvents
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class DelegateForMergerBoardViewEvents : EBSimpleClass {

  //····················································································································
  //  Outlets
  //····················································································································

  @IBOutlet private weak var mMergerDocument : MergerDocument? = nil
  @IBOutlet private weak var mBoardView : CanariBoardModelView? = nil

  //····················································································································
  // Properties
  //····················································································································

  private var mModel : ToManyRelationship_MergerRoot_boardInstances? = nil
  let selectedArray_property = TransientArrayOf_MergerBoardInstance ()

  //····················································································································

  override func awakeFromNib() {
    super.awakeFromNib ()
    mModel = mMergerDocument?.rootObject.boardInstances_property
    self.selectedArray_property.readModelFunction = { [weak self] in
      if let model = self?.mModel, let selectedSet = self?.mSelectedSet {
        switch model.prop {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var result = [MergerBoardInstance] ()
          for object in v {
            if selectedSet.contains (object) {
              result.append (object)
            }
          }
          return .single (result)
        }
      }else{
        return .empty
      }
    }
  }

  //····················································································································
  // Selected set
  //····················································································································

  private var mSelectedSet = Set <MergerBoardInstance> () {
    didSet {
      if mSelectedSet != oldValue {
        // NSLog ("mSelectedSet \(mSelectedSet)")
      //--- Stop observing selection layers of deselected objects
        let deselectedObjects = oldValue.subtracting (mSelectedSet)
        for object in deselectedObjects {
          object.selectionLayer_property.removeEBObserver (self.mObserverOfSectionLayerOfSelectedObjects)
        }
      //--- Start observing selection layers of new objects
        let newObjects = mSelectedSet.subtracting (oldValue)
        for object in newObjects {
          object.selectionLayer_property.addEBObserver (self.mObserverOfSectionLayerOfSelectedObjects)
        }
      //---
        self.computeSelectionLayer ()
      //--- Update selectedArray property
        self.selectedArray_property.postEvent ()
      }
    }
  }

  //····················································································································

  var objectCount : Int {
    let objects = mModel?.propval ?? []
    return objects.count
  }

  //····················································································································
  // init
  //····················································································································

  override init () {
    super.init ()
    mObserverOfSectionLayerOfSelectedObjects.eventCallBack = {[weak self] in self?.computeSelectionLayer () }
  }

  //····················································································································
  // Observe selection layer of selected objects
  //····················································································································

  private var mObserverOfSectionLayerOfSelectedObjects = EBOutletEvent ()

  //····················································································································
  // Mouse Events
  //····················································································································

  private var mLastMouseDraggedLocation : NSPoint? = nil
  private var mSelectionRectangleOrigin : NSPoint? = nil

  func mouseDown (with inEvent: NSEvent, objectIndex inObjectIndex : Int) {
    mLastMouseDraggedLocation = mBoardView?.convert (inEvent.locationInWindow, from:nil)
    let objects = mModel?.propval ?? []
    let shiftKey = inEvent.modifierFlags.contains (.shift)
    let commandKey = inEvent.modifierFlags.contains (.command)
    if shiftKey { // Shift key extends selection
      if inObjectIndex >= 0 {
        var newSet = mSelectedSet
        newSet.insert (objects [inObjectIndex])
        mSelectedSet = newSet
      }
    }else if commandKey { // Command key toggles selection of object under click
      if inObjectIndex >= 0 {
        let object = objects [inObjectIndex]
        if mSelectedSet.contains (object) {
          var newSet = mSelectedSet
          newSet.remove (object)
          mSelectedSet = newSet
        }else{
          var newSet = mSelectedSet
          newSet.insert (object)
          mSelectedSet = newSet
        }
      }
    }else if inObjectIndex >= 0 {
      // NSLog ("Clicked objectindex \(inObjectIndex)")
      let clickedObject = objects [inObjectIndex]
      if !mSelectedSet.contains (clickedObject) {
        mSelectedSet = [clickedObject]
      }
    }else{ // Click outside an object : clear selection
      mSelectedSet = Set ()
      mSelectionRectangleOrigin = mLastMouseDraggedLocation
    }
  }

  //····················································································································

  func mouseDragged (with inEvent : NSEvent) {
    if let boardView = mBoardView {
      let mouseDraggedLocation = boardView.convert (inEvent.locationInWindow, from:nil)
      if let selectionRectangleOrigin = mSelectionRectangleOrigin {
        // NSLog ("Dragged")
        let xMin = min (selectionRectangleOrigin.x, mouseDraggedLocation.x)
        let yMin = min (selectionRectangleOrigin.y, mouseDraggedLocation.y)
        let xMax = max (selectionRectangleOrigin.x, mouseDraggedLocation.x)
        let yMax = max (selectionRectangleOrigin.y, mouseDraggedLocation.y)
        let layer = CAShapeLayer ()
        let r = CGRect (x:xMin, y:yMin, width:xMax-xMin, height:yMax-yMin)
        layer.path = CGPath (rect: r, transform:nil)
        layer.strokeColor = NSColor.lightGray.cgColor
        layer.fillColor = NSColor.lightGray.withAlphaComponent (0.2).cgColor
        layer.lineWidth = 1.0
        mBoardView?.selectionRectangleLayer.sublayers = [layer]
        let indexSet = boardView.indexesOfObjects (intersecting:r)
        var newSelectedSet = Set <MergerBoardInstance> ()
        var objects = mModel?.propval ?? []
        for idx in indexSet {
          newSelectedSet.insert (objects [idx])
        }
        self.mSelectedSet = newSelectedSet
      }else if let lastMouseDraggedLocation = mLastMouseDraggedLocation {
        let accepted = wantsToTranslateSelection (
          byX:mouseDraggedLocation.x - lastMouseDraggedLocation.x,
          byY:mouseDraggedLocation.y - lastMouseDraggedLocation.y
        )
        if accepted {
          mLastMouseDraggedLocation = mouseDraggedLocation
        }
      }
    }
  }

  //····················································································································

  func mouseUp (with inEvent : NSEvent) {
    mLastMouseDraggedLocation = nil
    mSelectionRectangleOrigin = nil
    mBoardView?.selectionRectangleLayer.sublayers = nil
  }

  //····················································································································
  // key Events
  //····················································································································

  func keyDown (with inEvent: NSEvent) {
    let amount : CGFloat = inEvent.modifierFlags.contains (.shift) ? 36.0 : 9.0 ;
    for character in (inEvent.characters ?? "").unicodeScalars {
      switch (Int (character.value)) {
      case NSUpArrowFunctionKey :
        _ = wantsToTranslateSelection (byX: 0.0, byY:amount)
      case NSDownArrowFunctionKey :
        _ = wantsToTranslateSelection (byX: 0.0, byY:-amount)
      case NSLeftArrowFunctionKey :
        _ = wantsToTranslateSelection (byX: -amount, byY:0.0)
      case NSRightArrowFunctionKey :
        _ = wantsToTranslateSelection (byX: amount, byY:0.0)
      case 0x7F, NSDeleteFunctionKey :
        deleteSelection ()
      default :
        break
      }
    }
  }

  //····················································································································

  private func deleteSelection () {
    var objects = mModel?.propval ?? []
    for object in mSelectedSet {
      if let idx = objects.index (of: object) {
        objects.remove(at: idx)
        mMergerDocument?.managedObjectContext().removeManagedObject (object)
      }
    }
    mModel?.setProp (objects)
    mSelectedSet = Set ()
  }

  //····················································································································

  private func wantsToTranslateSelection (byX inDx: CGFloat, byY inDy: CGFloat) -> Bool {
    var accepted = true
    for object in mSelectedSet {
      if !object.acceptToTranslate (xBy: inDx, yBy:inDy) {
        accepted = false
        break
      }
    }
    if accepted {
      for object in mSelectedSet {
        object.translate (xBy: inDx, yBy:inDy)
      }
    }
    return accepted
  }

  //····················································································································
  //   Menu actions
  //····················································································································

  func selectAllObjects () {
    let objects = mModel?.propval ?? []
    mSelectedSet = Set (objects)
  }

  //····················································································································

  private final func sortedIndexArrayOfSelectedObjects () -> [Int] {
    var result = [Int] ()
    let objects = mModel?.propval ?? []
    for object in mSelectedSet {
      let idx = objects.index (of:object)!
      result.append (idx)
    }
    return result.sorted ()
  }

  //····················································································································
  // BRING FORWARD
  //····················································································································

  func canBringForward () -> Bool {
    let objects = mModel?.propval ?? []
    var result = (objects.count > 1) && (mSelectedSet.count > 0)
    if result {
      let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
      result = sortedIndexArray.last! < (objects.count - 1)
    }
    return result
  }

  //····················································································································

  func bringForward () {
    var objects = mModel?.propval ?? []
    let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
    for idx in sortedIndexArray.reversed () {
       let object = objects [idx]
       objects.remove (at: idx)
       objects.insert (object, at:idx+1)
    }
    mModel?.setProp (objects)
  }

  //····················································································································
  // BRING TO FRONT
  //····················································································································

  func canBringToFront () -> Bool {
    let objects = mModel?.propval ?? []
    if (objects.count > 1) && (mSelectedSet.count > 0) {
      let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
      var top = objects.count - 1
      for idx in sortedIndexArray.reversed () {
        if idx < top {
          return true
        }
        top -= 1
      }
    }
    return false
  }

  //····················································································································

  func bringToFront () {
    var objects = mModel?.propval ?? []
    let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
    for idx in sortedIndexArray {
      let object = objects [idx]
      objects.remove (at: idx)
      objects.append (object)
    }
    mModel?.setProp (objects)
  }

  //····················································································································
  // SEND BACKWARD
  //····················································································································

  func canSendBackward () -> Bool {
    let objects = mModel?.propval ?? []
    var result = (objects.count > 1) && (mSelectedSet.count > 0)
    if result {
      let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
      result = sortedIndexArray [0] > 0
    }
    return result
  }

  //····················································································································

  func sendBackward () {
    var objects = mModel?.propval ?? []
    let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
    for idx in sortedIndexArray.reversed () {
      let object = objects [idx]
      objects.remove (at: idx)
      objects.insert (object, at:idx-1)
    }
    mModel?.setProp (objects)
  }
  
  //····················································································································
  // SEND TO BACK
  //····················································································································

  func canSendToBack () -> Bool {
    let objects = mModel?.propval ?? []
    if (objects.count > 1) && (mSelectedSet.count > 0) {
      let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
      var bottom = 0
      for idx in sortedIndexArray {
        if idx > bottom {
          return true
        }
        bottom += 1
      }
    }
    return false
  }

  //····················································································································

  func sendToBack () {
    var objects = mModel?.propval ?? []
    let sortedIndexArray = self.sortedIndexArrayOfSelectedObjects ()
    for idx in sortedIndexArray.reversed () {
      let object = objects [idx]
      objects.remove (at: idx)
      objects.insert (object, at:0)
    }
    mModel?.setProp (objects)
  }

  //····················································································································
  //   Compute selection layer
  //····················································································································

  private func computeSelectionLayer () {
    var layers = [CALayer] ()
    for object in mSelectedSet {
      if let layer = object.selectionLayer {
        layers.append (layer)
      }
    }
    mBoardView?.objectSelectionLayer.sublayers = layers
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION MergerBoardInstance
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension MergerBoardInstance {

  //····················································································································

  func acceptToTranslate (xBy inDx: CGFloat, yBy inDy: CGFloat) -> Bool {
    let newX = self.x + cocoaToCanariUnit (inDx)
    let newY = self.y + cocoaToCanariUnit (inDy)
    return (newX >= 0) && (newY >= 0)
  }

  //····················································································································

  func translate (xBy inDx: CGFloat, yBy inDy: CGFloat) {
    self.x += cocoaToCanariUnit (inDx)
    self.y += cocoaToCanariUnit (inDy)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CALayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CALayer {

  //····················································································································

  func findLayer (at inPoint : CGPoint) -> CALayer? {
    for layer in (self.sublayers ?? []).reversed () {
      let possibleResult = layer.findLayer (at: inPoint)
      if let result = possibleResult {
        if (result.name == nil) && (self.name != nil) {
          return self
        }else{
          return result
        }
      }
    }
    return nil
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CAShapeLayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CAShapeLayer {

  //····················································································································

  override func findLayer (at inPoint : CGPoint) -> CALayer? {
    var r = super.findLayer (at: inPoint)
  //--- Test in filled path
    if let path = self.path, r == nil, self.fillColor != nil, path.contains (inPoint) {
      r = self
    }
  //--- Test in stroke path
    if let path = self.path, r == nil, self.strokeColor != nil, self.lineWidth > 0.0 {
      let possibleStrokePath = CGPath (
        __byStroking: path,
        transform:nil,
        lineWidth: self.lineWidth,
        lineCap: .round,
        lineJoin: .round,
        miterLimit: self.miterLimit
      )
      if let strokePath = possibleStrokePath, strokePath.contains (inPoint) {
        r = self
      }
    }
  //---
    return r
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CALayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CALayer {

  //····················································································································

  func findIndexesOfObjects (intersecting inRect : CGRect) -> Set <Int> {
     var result = Set <Int> ()
     if let name = self.name, let idx = Int (name) {
       var intersect = false
       for layer in self.sublayers ?? [] {
         if layer.intersects (inRect) {
           intersect = true
           break
         }
       }
       if intersect {
         result.insert (idx)
       }
     }else{
       for layer in self.sublayers ?? [] {
         let r = layer.findIndexesOfObjects (intersecting: inRect)
         result.formUnion (r)
       }
     }
     return result
  }

  //····················································································································

  func intersects (_ inRect : CGRect) -> Bool {
    return false
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION CAShapeLayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension CAShapeLayer {

  //····················································································································

//  override func findIndexesOfObjects (intersecting inRect : CGRect) -> [Int] {
//     var result = super.findIndexesOfObjects (intersecting: inRect)
//     for layer in self.sublayers ?? [] {
//       let r = layer.findIndexesOfObjects (intersecting: inRect)
//       result += r
//     }
//     return result
//  }

  //····················································································································

  override func intersects (_ inRect : CGRect) -> Bool {
    if let boundingBox = self.path?.boundingBox {
      return inRect.intersects (boundingBox)
    }else{
      return false
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
