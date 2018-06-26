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
   fileprivate var mFrontComponentNamesLayer = CALayer ()
   fileprivate var mFrontTracksLayer = CALayer ()
   fileprivate var mBackComponentNamesLayer = CALayer ()

   fileprivate var mDisplayPads = true
   fileprivate var mDisplayHoles = true
   fileprivate var mDisplayFrontComponentNames = true
   fileprivate var mDisplayBackComponentNames = true
   fileprivate var mDisplayFrontTracks = true

   fileprivate var mViaPadLayerComponents = [CAShapeLayer] ()
   fileprivate var mViaHoleLayerComponents = [CAShapeLayer] ()
   fileprivate var mFrontComponentNamesLayerComponents = [CAShapeLayer] ()
   fileprivate var mFrontTracksLayerComponents = [CAShapeLayer] ()
   fileprivate var mBackComponentNamesLayerComponents = [CAShapeLayer] ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    CATransaction.begin()
    self.layer?.addSublayer (mBackgroundLayer)
    self.layer?.addSublayer (mNoModelTextLayer)
    self.layer?.addSublayer (mViaPadLayer)
    self.layer?.addSublayer (mBackComponentNamesLayer)
    self.layer?.addSublayer (mFrontTracksLayer)
    self.layer?.addSublayer (mFrontComponentNamesLayer)
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
      mBackgroundLayer.path = CGPath (rect: self.bounds, transform: nil)
      mBackgroundLayer.position = CGPoint (x:0.0, y:0.0)
      mBackgroundLayer.fillColor = NSColor.white.cgColor
      mNoModelTextLayer.string = ""
    }
  }

  //····················································································································
  //    Update via display
  //····················································································································

  func updateViaDisplay () {
    mViaPadLayer.sublayers = mDisplayPads ? mViaPadLayerComponents : nil
  }

  //····················································································································
  //    Update hole display
  //····················································································································

  func updateHoleDisplay () {
    mViaHoleLayer.sublayers = mDisplayHoles ? mViaHoleLayerComponents : nil
  }

  //····················································································································
  //    Update front component name display
  //····················································································································

  func updateFrontComponentNamesDisplay () {
    mFrontComponentNamesLayer.sublayers = mDisplayFrontComponentNames ? mFrontComponentNamesLayerComponents : nil
  }

  //····················································································································
  //    Update back component name display
  //····················································································································

  func updateBackComponentNamesDisplay () {
    mBackComponentNamesLayer.sublayers = mDisplayBackComponentNames ? mBackComponentNamesLayerComponents : nil
  }

  //····················································································································
  //    Update front tracks
  //····················································································································

  func updateFrontTracksDisplay () {
    mFrontTracksLayer.sublayers = mDisplayFrontTracks ? mFrontTracksLayerComponents : nil
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
    mViaPadLayerComponents = [CAShapeLayer] ()
    mViaHoleLayerComponents = [CAShapeLayer] ()
    for via in inVias {
    //--- Pad
      let padShape = via.viaPad (color : NSColor.black.cgColor)
      mViaPadLayerComponents.append (padShape)
    //--- Hole
      let holeShape = via.viaHole (color : NSColor.white.cgColor)
      mViaHoleLayerComponents.append (holeShape)
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
  //    Front component names
  //····················································································································

  private var mFrontComponentNamesController : Controller_CanariBoardModelView_frontComponentNameSegments?

  func bind_frontComponentNameSegments (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontComponentNamesController = Controller_CanariBoardModelView_frontComponentNameSegments (segments:segments, outlet:self, file:file, line:line)
  }

  func unbind_frontComponentNameSegments () {
    mFrontComponentNamesController?.unregister ()
    mFrontComponentNamesController = nil
  }

  //····················································································································

  func setFrontComponentNameSegments (_ inSegments : [MergerSegment]) {
    mFrontComponentNamesLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      mFrontComponentNamesLayerComponents.append (shape)
    }
    updateFrontComponentNamesDisplay ()
  }

  //····················································································································
  //    Back component names
  //····················································································································

  private var mBackComponentNamesController : Controller_CanariBoardModelView_backComponentNameSegments?

  func bind_backComponentNameSegments (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackComponentNamesController = Controller_CanariBoardModelView_backComponentNameSegments (segments:segments, outlet:self, file:file, line:line)
  }

  func unbind_backComponentNameSegments () {
    mBackComponentNamesController?.unregister ()
    mBackComponentNamesController = nil
  }

  //····················································································································

  func setBackComponentNameSegments (_ inSegments : [MergerSegment]) {
    mBackComponentNamesLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      mBackComponentNamesLayerComponents.append (shape)
    }
    updateBackComponentNamesDisplay ()
  }

  //····················································································································
  //    Display front component names
  //····················································································································

  private var mDisplayFrontComponentNamesController : Controller_CanariBoardModelView_displayFrontComponentNames?

  func bind_displayFrontComponentNames (_ display:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayFrontComponentNamesController = Controller_CanariBoardModelView_displayFrontComponentNames (display:display, outlet:self, file:file, line:line)
  }

  func unbind_displayFrontComponentNames () {
    mDisplayFrontComponentNamesController?.unregister ()
    mDisplayFrontComponentNamesController = nil
  }

  //····················································································································

  func setDisplayFrontComponentNames (_ inDisplay : Bool) {
    mDisplayFrontComponentNames = inDisplay
    updateFrontComponentNamesDisplay ()
  }

  //····················································································································
  //    Display back component names
  //····················································································································

  private var mDisplayBackComponentNamesController : Controller_CanariBoardModelView_displayBackComponentNames?

  func bind_displayBackComponentNames (_ display:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayBackComponentNamesController = Controller_CanariBoardModelView_displayBackComponentNames (display:display, outlet:self, file:file, line:line)
  }

  func unbind_displayBackComponentNames () {
    mDisplayBackComponentNamesController?.unregister ()
    mDisplayBackComponentNamesController = nil
  }

  //····················································································································

  func setDisplayBackComponentNames (_ inDisplay : Bool) {
    mDisplayBackComponentNames = inDisplay
    updateBackComponentNamesDisplay ()
  }

  //····················································································································
  //    Display front tracks
  //····················································································································

  private var mDisplayFrontTracksController : Controller_CanariBoardModelView_displayFrontTracks?

  func bind_displayFrontTracks (_ display:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayFrontTracksController = Controller_CanariBoardModelView_displayFrontTracks (display:display, outlet:self, file:file, line:line)
  }

  func unbind_displayFrontTracks () {
    mDisplayFrontTracksController?.unregister ()
    mDisplayFrontTracksController = nil
  }

  //····················································································································

  func setDisplayFrontTracks (_ inDisplay : Bool) {
    mDisplayFrontTracks = inDisplay
    updateFrontTracksDisplay ()
  }

  //····················································································································
  //    Front tracks
  //····················································································································

  private var mFrontTracksController : Controller_CanariBoardModelView_frontTracks?

  func bind_frontTracks (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontTracksController = Controller_CanariBoardModelView_frontTracks (segments:segments, outlet:self, file:file, line:line)
  }

  func unbind_frontTracks () {
    mFrontTracksController?.unregister ()
    mFrontTracksController = nil
  }

  //····················································································································

  func setFrontTracks (_ inSegments : [MergerSegment]) {
    mFrontTracksLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      mFrontTracksLayerComponents.append (shape)
    }
    updateFrontTracksDisplay ()
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
    super.init (observedObjects:[vias], outlet:outlet)
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
    super.init (observedObjects:[display], outlet:outlet)
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
    super.init (observedObjects:[display], outlet:outlet)
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
//   Controller_CanariBoardModelView_frontComponentNameSegments
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_frontComponentNameSegments : EBSimpleController {

  private let mSegments : EBReadOnlyProperty_MergerSegmentArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (segments : EBReadOnlyProperty_MergerSegmentArray, outlet : CanariBoardModelView, file : String, line : Int) {
    mSegments = segments
    mOutlet = outlet
    super.init (observedObjects:[segments], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mSegments.prop {
    case .noSelection :
      mOutlet.setFrontComponentNameSegments ([])
    case .singleSelection (let v) :
      mOutlet.setFrontComponentNameSegments (v.segmentArray)
    case .multipleSelection :
      mOutlet.setFrontComponentNameSegments ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_backComponentNameSegments
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_backComponentNameSegments : EBSimpleController {

  private let mSegments : EBReadOnlyProperty_MergerSegmentArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (segments : EBReadOnlyProperty_MergerSegmentArray, outlet : CanariBoardModelView, file : String, line : Int) {
    mSegments = segments
    mOutlet = outlet
    super.init (observedObjects:[segments], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mSegments.prop {
    case .noSelection :
      mOutlet.setBackComponentNameSegments ([])
    case .singleSelection (let v) :
      mOutlet.setBackComponentNameSegments (v.segmentArray)
    case .multipleSelection :
      mOutlet.setBackComponentNameSegments ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_displayFrontComponentNames
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_displayFrontComponentNames : EBSimpleController {

  private let mDisplay : EBReadOnlyProperty_Bool
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (display : EBReadOnlyProperty_Bool, outlet : CanariBoardModelView, file : String, line : Int) {
    mDisplay = display
    mOutlet = outlet
    super.init (observedObjects:[display], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mDisplay.prop {
    case .noSelection :
      mOutlet.setDisplayFrontComponentNames (false)
    case .singleSelection (let v) :
      mOutlet.setDisplayFrontComponentNames (v)
    case .multipleSelection :
      mOutlet.setDisplayFrontComponentNames (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_displayBackComponentNames
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_displayBackComponentNames : EBSimpleController {

  private let mDisplay : EBReadOnlyProperty_Bool
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (display : EBReadOnlyProperty_Bool, outlet : CanariBoardModelView, file : String, line : Int) {
    mDisplay = display
    mOutlet = outlet
    super.init (observedObjects:[display], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mDisplay.prop {
    case .noSelection :
      mOutlet.setDisplayBackComponentNames (false)
    case .singleSelection (let v) :
      mOutlet.setDisplayBackComponentNames (v)
    case .multipleSelection :
      mOutlet.setDisplayBackComponentNames (false)
    }
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_displayFrontTracks
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_displayFrontTracks : EBSimpleController {

  private let mDisplay : EBReadOnlyProperty_Bool
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (display : EBReadOnlyProperty_Bool, outlet : CanariBoardModelView, file : String, line : Int) {
    mDisplay = display
    mOutlet = outlet
    super.init (observedObjects:[display], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mDisplay.prop {
    case .noSelection :
      mOutlet.setDisplayFrontTracks (false)
    case .singleSelection (let v) :
      mOutlet.setDisplayFrontTracks (v)
    case .multipleSelection :
      mOutlet.setDisplayFrontTracks (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_frontTracks
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_frontTracks : EBSimpleController {

  private let mSegments : EBReadOnlyProperty_MergerSegmentArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (segments : EBReadOnlyProperty_MergerSegmentArray, outlet : CanariBoardModelView, file : String, line : Int) {
    mSegments = segments
    mOutlet = outlet
    super.init (observedObjects:[segments], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mSegments.prop {
    case .noSelection :
      mOutlet.setFrontTracks ([])
    case .singleSelection (let v) :
      mOutlet.setFrontTracks (v.segmentArray)
    case .multipleSelection :
      mOutlet.setFrontTracks ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
