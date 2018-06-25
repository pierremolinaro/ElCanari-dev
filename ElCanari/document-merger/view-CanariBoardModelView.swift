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
//   CanariBoardModelView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardModelView : CanariViewWithZoomAndFlip {

   fileprivate var mBackgroundLayer = CAShapeLayer ()
   fileprivate var mNoModelTextLayer = CATextLayer ()
   fileprivate var mViaLayer = CALayer ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    CATransaction.begin()
    self.layer?.addSublayer (mBackgroundLayer)
    self.layer?.addSublayer (mNoModelTextLayer)
    self.layer?.addSublayer (mViaLayer)
    CATransaction.commit ()
  }

  //····················································································································
  //  Set size
  //····················································································································

  override func setSize (width : Int, height : Int) {
    super.setSize (width:width, height:height)
    let noModel = (width == 0) || (height == 0)
    if noModel {
      mBackgroundLayer.fillColor = nil
      mBackgroundLayer.strokeColor = nil
      mNoModelTextLayer.frame = self.frame
      mNoModelTextLayer.foregroundColor = NSColor.black.cgColor
      mNoModelTextLayer.contentsScale = NSScreen.main ()!.backingScaleFactor
      mNoModelTextLayer.alignmentMode = kCAAlignmentCenter
      mNoModelTextLayer.string = "No Model"
    }else{
      mBackgroundLayer.path = CGPath (rect: self.bounds.insetBy (dx: 0.5, dy: 0.5), transform: nil)
      mBackgroundLayer.position = CGPoint (x:0.0, y:0.0)
      mBackgroundLayer.fillColor = NSColor.white.cgColor
      mBackgroundLayer.strokeColor = NSColor.black.cgColor
      mBackgroundLayer.lineWidth = 1.0
      mNoModelTextLayer.string = ""
    }
  }

  //····················································································································
  //    vias
  //····················································································································

  private var mViasController : Controller_CanariBoardModelView_vias?

  func bind_vias (_ vias:EBReadOnlyProperty_ViaShapes, file:String, line:Int) {
    mViasController = Controller_CanariBoardModelView_vias (vias:vias, outlet:self, file:file, line:line)
  }

  func unbind_vias () {
    mViasController?.unregister ()
    mViasController = nil
  }

  //····················································································································

  func setVias (_ vias : [CAShapeLayer]) {
    mViaLayer.sublayers = vias
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariViewWithZoomAndFlip_verticalFlip
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_vias : EBSimpleController {

  private let mVias : EBReadOnlyProperty_ViaShapes
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (vias : EBReadOnlyProperty_ViaShapes, outlet : CanariBoardModelView, file : String, line : Int) {
    mVias = vias
    mOutlet = outlet
    super.init (objects:[vias], outlet:outlet)
    mVias.addEBObserver (self)
  }

  //····················································································································
  
  func unregister () {
    mVias.removeEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mVias.prop {
    case .noSelection :
      mOutlet.setVias ([])
    case .singleSelection (let v) :
      mOutlet.setVias (v.shapeArray)
    case .multipleSelection :
      mOutlet.setVias ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
