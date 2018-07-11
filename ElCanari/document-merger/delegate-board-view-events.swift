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
//   ViewEventProtocol
//   Note: cannot use optional in @objc protocols
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//@objc protocol ViewEventProtocol {
//
//  func mouseDown (with inEvent: NSEvent, objectIndex inObjectIndex : Int)
//}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   DelegateForMergerBoardViewEvents
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class DelegateForMergerBoardViewEvents : EBSimpleClass { // , ViewEventProtocol {

  //····················································································································
  //  Outlets
  //····················································································································

  @IBOutlet private weak var mMergerDocument : MergerDocument? = nil
  @IBOutlet private weak var mBoardView : CanariBoardModelView? = nil

  //····················································································································
  // Properties
  //····················································································································

  private var mSelectedSet = Set <MergerBoardInstance> () {
    didSet {
      if mSelectedSet != oldValue {
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
      }
    }
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

  func mouseDown (with inEvent: NSEvent, objectIndex inObjectIndex : Int) {
    // NSLog ("\(inObjectIndex)")
    let objects = mMergerDocument?.rootObject.boardInstances_property.propval ?? []
    var newSelectedSet = Set <MergerBoardInstance> ()
    if inObjectIndex >= 0 {
      newSelectedSet.insert (objects [inObjectIndex])
    }
    mSelectedSet = newSelectedSet
  }

  //····················································································································
  // key Events
  //····················································································································

  func keyDown (with inEvent: NSEvent) {
    let amount : CGFloat = inEvent.modifierFlags.contains (.shift) ? 36.0 : 9.0 ;
    for character in (inEvent.characters ?? "").unicodeScalars {
      switch (Int (character.value)) {
      case NSUpArrowFunctionKey :
        wantsToMoveSelection (byX: 0.0, byY:amount)
      case NSDownArrowFunctionKey :
        wantsToMoveSelection (byX: 0.0, byY:-amount)
      case NSLeftArrowFunctionKey :
        wantsToMoveSelection (byX: -amount, byY:0.0)
      case NSRightArrowFunctionKey :
        wantsToMoveSelection (byX: amount, byY:0.0)
      case 0x7F, NSDeleteFunctionKey :
        deleteSelection ()
      default :
        break
      }
    }
  }

  //····················································································································

  private func deleteSelection () {
    var objects = mMergerDocument?.rootObject.boardInstances_property.propval ?? []
    for object in mSelectedSet {
      if let idx = objects.index (of: object) {
        objects.remove(at: idx)
        mMergerDocument?.managedObjectContext().removeManagedObject (object)
      }
    }
    mMergerDocument?.rootObject.boardInstances_property.setProp (objects)
    mSelectedSet = Set ()
  }

  //····················································································································

  private func wantsToMoveSelection (byX inDx: CGFloat, byY inDy: CGFloat) {
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
    mBoardView?.selectionLayer.sublayers = layers
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
