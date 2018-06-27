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
   fileprivate var mBackTracksLayer = CALayer ()
   fileprivate var mBackComponentNamesLayer = CALayer ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    CATransaction.begin()
    self.layer?.addSublayer (mBackgroundLayer)
    self.layer?.addSublayer (mNoModelTextLayer)
    self.layer?.addSublayer (mViaPadLayer)
    self.layer?.addSublayer (mBackComponentNamesLayer)
    self.layer?.addSublayer (mBackTracksLayer)
    self.layer?.addSublayer (mFrontTracksLayer)
    self.layer?.addSublayer (mFrontComponentNamesLayer)
    self.layer?.addSublayer (mViaHoleLayer)
    CATransaction.commit ()
  }

  //····················································································································
  //  Set size
  //····················································································································

  override func setBoardModelSize (width : Int, height : Int) {
    super.setBoardModelSize (width:width, height:height)
    let noModel = (width == 0) || (height == 0)
    if noModel {
      mBackgroundLayer.fillColor = nil
      mBackgroundLayer.strokeColor = nil
      mNoModelTextLayer.frame = self.bounds
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
    var viaPadLayerComponents = [CAShapeLayer] ()
    var viaHoleLayerComponents = [CAShapeLayer] ()
    for via in inVias {
    //--- Pad
      let padShape = via.viaPad (color : NSColor.black.cgColor)
      viaPadLayerComponents.append (padShape)
    //--- Hole
      let holeShape = via.viaHole (color : NSColor.white.cgColor)
      viaHoleLayerComponents.append (holeShape)
    }
    mViaPadLayer.sublayers = viaPadLayerComponents
    mViaHoleLayer.sublayers = viaHoleLayerComponents
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
    var frontComponentNamesLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      frontComponentNamesLayerComponents.append (shape)
    }
    mFrontComponentNamesLayer.sublayers = frontComponentNamesLayerComponents
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
    var backComponentNamesLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      backComponentNamesLayerComponents.append (shape)
    }
    mBackComponentNamesLayer.sublayers = backComponentNamesLayerComponents
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
    // NSLog ("setFrontTracks \(inSegments.count)")
    var frontTracksLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      frontTracksLayerComponents.append (shape)
    }
    mFrontTracksLayer.sublayers = frontTracksLayerComponents
  }

  //····················································································································
  //    Back tracks
  //····················································································································

  private var mBackTracksController : Controller_CanariBoardModelView_backTracks?

  func bind_backTracks (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackTracksController = Controller_CanariBoardModelView_backTracks (segments:segments, outlet:self, file:file, line:line)
  }

  func unbind_backTracks () {
    mBackTracksController?.unregister ()
    mBackTracksController = nil
  }

  //····················································································································

  func setBackTracks (_ inSegments : [MergerSegment]) {
    var backTracksLayerComponents = [CAShapeLayer] ()
    for segment in inSegments {
      let shape = segment.segmentShape (color:NSColor.black.cgColor)
      backTracksLayerComponents.append (shape)
    }
    mBackTracksLayer.sublayers = backTracksLayerComponents
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
    segments.addEBObserver (self)
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
//   Controller_CanariBoardModelView_backTracks
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_backTracks : EBSimpleController {

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
      mOutlet.setBackTracks ([])
    case .singleSelection (let v) :
      mOutlet.setBackTracks (v.segmentArray)
    case .multipleSelection :
      mOutlet.setBackTracks ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
