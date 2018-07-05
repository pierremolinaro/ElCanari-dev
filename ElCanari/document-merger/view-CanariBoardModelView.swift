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

   fileprivate var mObjectLayer = CALayer ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    self.layer?.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.isOpaque = OPAQUE_LAYERS

    self.mObjectLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mObjectLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mObjectLayer)
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
