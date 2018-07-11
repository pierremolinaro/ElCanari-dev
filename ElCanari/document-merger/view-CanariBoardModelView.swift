//
//  CanariBoardModelView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate let OPAQUE_LAYERS = true ;
fileprivate let DRAWS_ASYNCHRONOUSLY = true ;

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariBoardModelView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardModelView : CanariViewWithZoomAndFlip {

  //····················································································································
  //  Outlets
  //····················································································································

   @IBOutlet fileprivate weak var mViewEventDelegate : DelegateForMergerBoardViewEvents? = nil

  //····················································································································
  //  Properties
  //····················································································································

   fileprivate var mObjectLayer = CALayer ()
   fileprivate var mSelectionLayer = CALayer ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    self.layer?.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.isOpaque = OPAQUE_LAYERS

    self.mObjectLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mObjectLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mObjectLayer)
    self.layer?.addSublayer (mSelectionLayer)
  }

  //····················································································································
  //  acceptsFirstResponder
  //····················································································································

  override var acceptsFirstResponder : Bool { return true }

  
  //····················································································································
  //    Object Layer
  //····················································································································

  private var mObjectLayerController : Controller_CanariBoardModelView_objectLayer?

  func bind_objectLayer (_ layer:EBReadOnlyProperty_CALayer, file:String, line:Int) {
    mObjectLayerController = Controller_CanariBoardModelView_objectLayer (layer:layer, outlet:self)
  }

  //····················································································································

  func unbind_objectLayer () {
    mObjectLayerController?.unregister ()
    mObjectLayerController = nil
  }

  //····················································································································
  //    Selection Layer
  //····················································································································

  var selectionLayer : CALayer { return mSelectionLayer }

  //····················································································································
  // Mouse Events
  //····················································································································

  override func mouseDown (with inEvent: NSEvent) {
    let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
    if let result = self.mObjectLayer.findLayer (at: mouseDownLocation) {
      if let name = result.name, let idx = Int (name) {
        mViewEventDelegate?.mouseDown (with:inEvent, objectIndex:idx) // No object
      }else{
        mViewEventDelegate?.mouseDown (with:inEvent, objectIndex:-1) // No object
      }
    }else{
      mViewEventDelegate?.mouseDown (with: inEvent, objectIndex: -1) // No object
    }
    super.mouseDown (with: inEvent)
  }

  //····················································································································

  override func mouseDragged (with inEvent : NSEvent) {
    mViewEventDelegate?.mouseDragged (with: inEvent)
  }

  //····················································································································

  override func mouseUp (with inEvent : NSEvent) {
    mViewEventDelegate?.mouseUp (with: inEvent)
  }

  //····················································································································
  // key Events
  //····················································································································

  override func keyDown (with inEvent: NSEvent) {
    mViewEventDelegate?.keyDown (with:inEvent)
  }

  //····················································································································
  // Menu Events
  //····················································································································

  func validateMenuItem (inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    let action = inMenuItem.action
    if action == #selector (selectAll(_:)) {
      validate = (mViewEventDelegate?.objectCount ?? 0) > 0
    }else if action == #selector (bringToFront(_:)) {
      validate = (mViewEventDelegate?.objectCount ?? 0) > 0
    }else if action == #selector (bringForward(_:)) {
      validate = (mViewEventDelegate?.objectCount ?? 0) > 0
    }else if action == #selector (sendToBack(_:)) {
      validate = (mViewEventDelegate?.objectCount ?? 0) > 0
    }else if action == #selector (sendBackward(_:)) {
      validate = (mViewEventDelegate?.objectCount ?? 0) > 0
    }else{
      validate = super.validateMenuItem (inMenuItem)
//    }else if (action == @selector (rotateCounterclockwiseSelectedObjects:)) {
//      validate = mGraphicController.canSelectedObjectsRotate ;
//    }else if (action == @selector (rotateClockwiseSelectedObjects:)) {
//      validate = mGraphicController.canSelectedObjectsRotate ;
//    }else if (action == @selector (horizontalFlipSelectedObjects:)) {
//      validate = mGraphicController.canSelectedObjectsFlipHorizontally ;
//    }else if (action == @selector (verticalFlipSelectedObjects:)) {
//      validate = mGraphicController.canSelectedObjectsFlipVertically ;
//    }else if (action == @selector (lockSelectedObjects:)) {
//      validate = YES ;
//    }else if (action == @selector (unlockSelectedObjects:)) {
//      validate = YES ;
//    }else if (action == @selector (groupSelectedObjects:)) {
//      validate = [self canGroupSelectedObjects] ;
//    }else if (action == @selector (ungroupSelectedObjects:)) {
//      validate = [self canUngroupSelectedObjects] ;
//    }else if (action == @selector (selectAll:)) {
//      validate = [[self allObjects] count] > 0 ;
//    }else if (action == @selector (copy:)) {
//      validate = ([mGeneralPasteboardPrivateObjectType length] != 0) && mGraphicController.oneOrMoreObjectsSelected ;
//    }else if (action == @selector (cut:)) {
//      validate = ([mGeneralPasteboardPrivateObjectType length] != 0) && mGraphicController.oneOrMoreObjectsSelected ;
//    }else if (action == @selector (paste:)) {
//      NSPasteboard * gp = [NSPasteboard generalPasteboard] ;
//      validate = ([mGeneralPasteboardPrivateObjectType length] != 0)
//        && ([gp availableTypeFromArray:[NSArray arrayWithObject:mGeneralPasteboardPrivateObjectType]] != nil)
//      ;
//    }else if (action == @selector (delete:)) {
//      validate = mGraphicController.oneOrMoreObjectsSelected ;
//    }else if (action == @selector (actionDuplicate:)) {
//      validate = mGraphicController.oneOrMoreObjectsSelected ;
//    }else if (action == @selector (snapToGridSelectedObjects:)) {
//      validate = [mGraphicController canSnapSelectedObjectsToGrid:self.placementGrid] ;
//    }else{
//      validate = [super validateMenuItem:inMenuItem] ;
    }
    return validate
  }

  //····················································································································

  override func selectAll (_ : Any?) {
    mViewEventDelegate?.selectAllObjects ()
  }

  //····················································································································

  func bringToFront (_ : Any?) {
    mViewEventDelegate?.bringToFront ()
  }

  //····················································································································

  func bringForward (_ : Any?) {
    mViewEventDelegate?.bringForward ()
  }

  //····················································································································

  func sendToBack (_ : Any?) {
    mViewEventDelegate?.sendToBack ()
  }

  //····················································································································

  func sendBackward (_ : Any?) {
    mViewEventDelegate?.sendBackward ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_objectLayer
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class Controller_CanariBoardModelView_objectLayer : EBSimpleController {

  private let mLayer : EBReadOnlyProperty_CALayer
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (layer : EBReadOnlyProperty_CALayer, outlet : CanariBoardModelView) {
    mLayer = layer
    mOutlet = outlet
    super.init (observedObjects:[layer], outlet:outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mLayer.prop {
    case .empty :
      mOutlet.mObjectLayer.sublayers = nil
    case .single (let v) :
      mOutlet.mObjectLayer.sublayers = [v]
    case .multiple :
      mOutlet.mObjectLayer.sublayers = nil
    }
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
