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

  //····················································································································
  //  Properties
  //····················································································································

   fileprivate var mBackgroundLayer = CAShapeLayer ()
   fileprivate var mNoModelTextLayer = CATextLayer ()

   fileprivate var mObjectLayer = CALayer ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

//    // Leave the layer's contents alone. Never mark the layer as needing display, or draw the view's contents to the layer
//    case never
//
//    // Map view -setNeedsDisplay...: activity to the layer, and redraw affected layer parts by invoking the view's -drawRect:, but don't mark the view or layer as needing display when the view's size changes.
//    case onSetNeedsDisplay
//
//    // Resize the layer and redraw the view to the layer when the view's size changes. If the resize is animated, AppKit will drive the resize animation itself and will do this resize+redraw at each step of the animation. Affected parts of the layer will also be redrawn when the view is marked as needing display. (This mode is a superset of NSViewLayerContentsRedrawOnSetNeedsDisplay.) 
//    case duringViewResize
//
//    // Resize the layer and redraw the view to the layer when the view's size changes. This will be done just once at the beginning of a resize animation, not at each frame of the animation. Affected parts of the layer will also be redrawn when the view is marked as needing display. (This mode is a superset of NSViewLayerContentsRedrawOnSetNeedsDisplay.)
//    case beforeViewResize
//
//    // When a view is resized, the layer contents will be redrawn once and the contents will crossfade from the old value to the new value. Use this in conjunction with the layerContentsPlacement to get a nice crossfade animation for complex layer-backed views that can't correctly update on each step of the animation
//    @available(OSX 10.9, *)
//    case crossfade

  final override func awakeFromNib () {
//    self.layerContentsRedrawPolicy = .crossfade // .beforeViewResize

    self.layer?.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.isOpaque = OPAQUE_LAYERS
   // NSLog ("\(self.mBackgroundLayer.isOpaque)")
 //   self.mBackgroundLayer.isOpaque = OPAQUE_LAYERS
    self.mBackgroundLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackgroundLayer)

    self.mObjectLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mObjectLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mObjectLayer)
  }

  //····················································································································
  //  CATransaction begin / commit
  //····················································································································

  fileprivate var mTransactionNotified = false

  fileprivate func notifyTransaction () {
    if !mTransactionNotified {
      mTransactionNotified = true
      CATransaction.setAnimationDuration (0.5)
      CATransaction.begin ()
      DispatchQueue.main.asyncAfter (deadline: DispatchTime.now()) { self.commitTransaction () }
    }
  }

  fileprivate func commitTransaction () {
    mTransactionNotified = false
    CATransaction.commit ()
  }

  //····················································································································
  //  Set size
  //····················································································································

  override func setBoardModelSize (width : Int, height : Int) {
    super.setBoardModelSize (width:width, height:height)
    self.notifyTransaction ()
    let noModel = (width == 0) || (height == 0)
    if noModel {
      self.mBackgroundLayer.fillColor = nil
      self.mBackgroundLayer.strokeColor = nil
      self.mBackgroundLayer.isOpaque = false
      self.mNoModelTextLayer.frame = self.frame
      self.mNoModelTextLayer.foregroundColor = NSColor.gray.cgColor
      self.mNoModelTextLayer.contentsScale = NSScreen.main ()!.backingScaleFactor
      self.mNoModelTextLayer.alignmentMode = kCAAlignmentCenter
      self.mNoModelTextLayer.string = "No Model"
    }else{
      self.mBackgroundLayer.path = CGPath (rect: self.bounds, transform: nil)
      self.mBackgroundLayer.position = CGPoint (x:0.0, y:0.0)
      self.mBackgroundLayer.fillColor = NSColor.lightGray.blended (withFraction: 0.5, of: .white)!.cgColor
      self.mBackgroundLayer.isOpaque = OPAQUE_LAYERS
      self.mNoModelTextLayer.string = ""
    }
  }

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
  }

  //····················································································································

  override func sendUpdateEvent () {
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
