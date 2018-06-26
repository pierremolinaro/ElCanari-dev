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
   fileprivate var mViaPadLayer = CALayer ()
   fileprivate var mViaHoleLayer = CALayer ()

   fileprivate var mDisplayPads = true
   fileprivate var mDisplayHoles = true
   fileprivate var mViaPadLayerArray = [CAShapeLayer] ()
   fileprivate var mViaHoleLayerArray = [CAShapeLayer] ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    CATransaction.begin()
    self.layer?.addSublayer (mBackgroundLayer)
    self.layer?.addSublayer (mNoModelTextLayer)
    self.layer?.addSublayer (mViaPadLayer)
    self.layer?.addSublayer (mViaHoleLayer)
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
  //    Update via display
  //····················································································································

  func updateViaDisplay () {
    mViaPadLayer.sublayers = mDisplayPads ? mViaPadLayerArray : nil
  }

  //····················································································································
  //    Update hole display
  //····················································································································

  func updateHoleDisplay () {
    mViaHoleLayer.sublayers = mDisplayHoles ? mViaHoleLayerArray : nil
  }

  //····················································································································
  //    vias
  //····················································································································

  private var mViasController : Controller_CanariBoardModelView_vias?

  func bind_vias (_ vias:EBReadOnlyProperty_MergerViaShapeArray, file:String, line:Int) {
    mViasController = Controller_CanariBoardModelView_vias (vias:vias, outlet:self, file:file, line:line)
  }

  func unbind_vias () {
    mViasController?.unregister ()
    mViasController = nil
  }

  //····················································································································

  func setVias (_ inVias : [MergerViaShape]) {
    mViaPadLayerArray = [CAShapeLayer] ()
    mViaHoleLayerArray = [CAShapeLayer] ()
    for via in inVias {
      let x : CGFloat = canariUnitToCocoa (via.x)
      let y : CGFloat = canariUnitToCocoa (via.y)
      let padDiameter : CGFloat = canariUnitToCocoa (via.padDiameter)
      let holeDiameter : CGFloat = canariUnitToCocoa (via.holeDiameter)
    //--- Pad
      let rPad = NSRect (x : x - padDiameter / 2.0, y: y - padDiameter / 2.0, width:padDiameter, height:padDiameter)
      let padShape = CAShapeLayer ()
      padShape.path = CGPath (ellipseIn: rPad, transform: nil)
      padShape.position = CGPoint (x:0.0, y:0.0)
      padShape.fillColor = NSColor.black.cgColor
      mViaPadLayerArray.append (padShape)
    //--- Hole
      let rHole = NSRect (x : x - holeDiameter / 2.0, y: y - holeDiameter / 2.0, width:holeDiameter, height:holeDiameter)
      let holeShape = CAShapeLayer ()
      holeShape.path = CGPath (ellipseIn: rHole, transform: nil)
      holeShape.position = CGPoint (x:0.0, y:0.0)
      holeShape.fillColor = NSColor.white.cgColor
      mViaHoleLayerArray.append (holeShape)
    }
    updateViaDisplay ()
    updateHoleDisplay ()
  }

  //····················································································································
  //    Display pads
  //····················································································································

  private var mDisplayPadsController : Controller_CanariBoardModelView_displayPads?

  func bind_displayPads (_ display:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayPadsController = Controller_CanariBoardModelView_displayPads (display:display, outlet:self, file:file, line:line)
  }

  func unbind_displayPads () {
    mDisplayPadsController?.unregister ()
    mDisplayPadsController = nil
  }

  //····················································································································

  func setDisplayPads (_ inDisplay : Bool) {
    mDisplayPads = inDisplay
    updateViaDisplay ()
  }

  //····················································································································
  //    Display holes
  //····················································································································

  private var mDisplayHolesController : Controller_CanariBoardModelView_displayHoles?

  func bind_displayHoles (_ display:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayHolesController = Controller_CanariBoardModelView_displayHoles (display:display, outlet:self, file:file, line:line)
  }

  func unbind_displayHoles () {
    mDisplayHolesController?.unregister ()
    mDisplayHolesController = nil
  }

  //····················································································································

  func setDisplayHoles (_ inDisplay : Bool) {
    mDisplayHoles = inDisplay
    updateHoleDisplay ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_vias
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_vias : EBSimpleController {

  private let mVias : EBReadOnlyProperty_MergerViaShapeArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (vias : EBReadOnlyProperty_MergerViaShapeArray, outlet : CanariBoardModelView, file : String, line : Int) {
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
//   Controller_CanariBoardModelView_displayPads
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_displayPads : EBSimpleController {

  private let mDisplay : EBReadOnlyProperty_Bool
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (display : EBReadOnlyProperty_Bool, outlet : CanariBoardModelView, file : String, line : Int) {
    mDisplay = display
    mOutlet = outlet
    super.init (objects:[display], outlet:outlet)
    mDisplay.addEBObserver (self)
  }

  //····················································································································
  
  func unregister () {
    mDisplay.removeEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mDisplay.prop {
    case .noSelection :
      mOutlet.setDisplayPads (false)
    case .singleSelection (let v) :
      mOutlet.setDisplayPads (v)
    case .multipleSelection :
      mOutlet.setDisplayPads (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_displayHoles
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_displayHoles : EBSimpleController {

  private let mDisplay : EBReadOnlyProperty_Bool
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (display : EBReadOnlyProperty_Bool, outlet : CanariBoardModelView, file : String, line : Int) {
    mDisplay = display
    mOutlet = outlet
    super.init (objects:[display], outlet:outlet)
    mDisplay.addEBObserver (self)
  }

  //····················································································································
  
  func unregister () {
    mDisplay.removeEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mDisplay.prop {
    case .noSelection :
      mOutlet.setDisplayHoles (false)
    case .singleSelection (let v) :
      mOutlet.setDisplayHoles (v)
    case .multipleSelection :
      mOutlet.setDisplayHoles (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
