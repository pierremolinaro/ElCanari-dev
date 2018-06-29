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
   fileprivate var mHolesLayer = CALayer ()
   fileprivate var mFrontComponentNamesLayer = CALayer ()
   fileprivate var mFrontTracksLayer = CALayer ()
   fileprivate var mBackTracksLayer = CALayer ()
   fileprivate var mBackComponentNamesLayer = CALayer ()
   fileprivate var mFrontComponentValuesLayer = CALayer ()
   fileprivate var mBackComponentValuesLayer = CALayer ()
   fileprivate var mFrontPackagesLayer = CALayer ()
   fileprivate var mBackPackagesLayer = CALayer ()
   fileprivate var mBoardLimitsLayer = CALayer ()
   fileprivate var mFrontPadsLayer = CALayer ()
   fileprivate var mBackPadsLayer = CALayer ()
   fileprivate var mFrontLegendTextsLayer = CALayer ()
   fileprivate var mFrontLayoutTextsLayer = CALayer ()
   fileprivate var mBackLegendTextsLayer = CALayer ()
   fileprivate var mBackLayoutTextsLayer = CALayer ()

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
   // CATransaction.begin()
    self.layer?.addSublayer (mBackgroundLayer)
    self.layer?.addSublayer (mNoModelTextLayer)
    self.layer?.addSublayer (mBackPackagesLayer)
    self.layer?.addSublayer (mBackLegendTextsLayer)
    self.layer?.addSublayer (mBackComponentNamesLayer)
    self.layer?.addSublayer (mBackComponentValuesLayer)
    self.layer?.addSublayer (mBackTracksLayer)
    self.layer?.addSublayer (mBackLayoutTextsLayer)
    self.layer?.addSublayer (mBackPadsLayer)
    self.layer?.addSublayer (mFrontTracksLayer)
    self.layer?.addSublayer (mFrontLayoutTextsLayer)
    self.layer?.addSublayer (mFrontPackagesLayer)
    self.layer?.addSublayer (mFrontLegendTextsLayer)
    self.layer?.addSublayer (mFrontComponentValuesLayer)
    self.layer?.addSublayer (mFrontComponentNamesLayer)
    self.layer?.addSublayer (mFrontPadsLayer)
    self.layer?.addSublayer (mBoardLimitsLayer)
    self.layer?.addSublayer (mViaPadLayer)
    self.layer?.addSublayer (mHolesLayer)
 //   CATransaction.commit ()
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
      mBackgroundLayer.fillColor = NSColor.lightGray.blended (withFraction: 0.5, of: .white)!.cgColor
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
    for via in inVias {
    //--- Pad
      let padShape = via.viaPad (color : NSColor.red.cgColor)
      viaPadLayerComponents.append (padShape)
    }
    mViaPadLayer.sublayers = viaPadLayerComponents
  }

  //····················································································································
  //    Front component names
  //····················································································································

  private var mFrontComponentNamesController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_frontComponentNames (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontComponentNamesController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.orange.cgColor)
          components.append (shape)
        }
        self.mFrontComponentNamesLayer.sublayers = components
      }
    )
  }

  func unbind_frontComponentNames () {
    mFrontComponentNamesController?.unregister ()
    mFrontComponentNamesController = nil
  }

  //····················································································································
  //    Back component names
  //····················································································································

  private var mBackComponentNamesController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_backComponentNames (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackComponentNamesController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          components.append (shape)
        }
        self.mBackComponentNamesLayer.sublayers = components
      }
    )
  }

  func unbind_backComponentNames () {
    mBackComponentNamesController?.unregister ()
    mBackComponentNamesController = nil
  }

  //····················································································································
  //    Front tracks
  //····················································································································

  private var mFrontTracksController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_frontTracks (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontTracksController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.blue.cgColor)
          components.append (shape)
        }
        self.mFrontTracksLayer.sublayers = components
      }
    )
  }

  func unbind_frontTracks () {
    mFrontTracksController?.unregister ()
    mFrontTracksController = nil
  }

  //····················································································································
  //    Back tracks
  //····················································································································

  private var mBackTracksController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_backTracks (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackTracksController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.green.cgColor)
          components.append (shape)
        }
        self.mBackTracksLayer.sublayers = components
      }
    )
  }

  func unbind_backTracks () {
    mBackTracksController?.unregister ()
    mBackTracksController = nil
  }

  //····················································································································
  //    Front component values
  //····················································································································

  private var mFrontComponentValuesController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_frontComponentValues (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontComponentValuesController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.brown.cgColor)
          components.append (shape)
        }
        self.mFrontComponentValuesLayer.sublayers = components
      }
    )
  }

  func unbind_frontComponentValues () {
    mFrontComponentValuesController?.unregister ()
    mFrontComponentValuesController = nil
  }

  //····················································································································
  //    Back component values
  //····················································································································

  private var mBackComponentValuesController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_backComponentValues (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackComponentValuesController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          components.append (shape)
        }
        self.mBackComponentValuesLayer.sublayers = components
      }
    )
  }

  func unbind_backComponentValues () {
    mBackComponentValuesController?.unregister ()
    mBackComponentValuesController = nil
  }

  //····················································································································
  //    Front packages
  //····················································································································

  private var mFrontPackagesController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  func bind_frontPackages (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontPackagesController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.brown.cgColor)
          components.append (shape)
        }
        self.mFrontPackagesLayer.sublayers = components
      }
    )
  }

  func unbind_frontPackages () {
    mFrontPackagesController?.unregister ()
    mFrontPackagesController = nil
  }

  //····················································································································
  //    Back packages
  //····················································································································

  private var mBackPackagesController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  //····················································································································

  func bind_backPackages (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackPackagesController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          components.append (shape)
        }
        self.mBackPackagesLayer.sublayers = components
      }
    )
  }

  //····················································································································

  func unbind_backPackages () {
    mBackPackagesController?.unregister ()
    mBackPackagesController = nil
  }

  //····················································································································
  //    Front Legend Texts packages
  //····················································································································

  private var mFrontLegendTextsController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  //····················································································································

  func bind_frontLegendTexts (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontLegendTextsController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.blue.cgColor)
          components.append (shape)
        }
        self.mFrontLegendTextsLayer.sublayers = components
      }
    )
  }

  //····················································································································

  func unbind_frontLegendTexts () {
    mFrontLegendTextsController?.unregister ()
    mFrontLegendTextsController = nil
  }

  //····················································································································
  //    Back Legend Texts packages
  //····················································································································

  private var mBackLegendTextsController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  //····················································································································

  func bind_backLegendTexts (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackLegendTextsController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.blue.cgColor)
          components.append (shape)
        }
        self.mBackLegendTextsLayer.sublayers = components
      }
    )
  }

  //····················································································································

  func unbind_backLegendTexts () {
    mBackLegendTextsController?.unregister ()
    mBackLegendTextsController = nil
  }

  //····················································································································
  //    Front Layout Texts packages
  //····················································································································

  private var mFrontLayoutTextsController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  //····················································································································

  func bind_frontLayoutTexts (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mFrontLayoutTextsController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          components.append (shape)
        }
        self.mFrontLayoutTextsLayer.sublayers = components
      }
    )
  }

  //····················································································································

  func unbind_frontLayoutTexts () {
    mFrontLayoutTextsController?.unregister ()
    mFrontLayoutTextsController = nil
  }

  //····················································································································
  //    Back Layout Texts packages
  //····················································································································

  private var mBackLayoutTextsController : Controller_CanariBoardModelView_generic_MergerSegmentArray?

  //····················································································································

  func bind_backLayoutTexts (_ segments:EBReadOnlyProperty_MergerSegmentArray, file:String, line:Int) {
    mBackLayoutTextsController = Controller_CanariBoardModelView_generic_MergerSegmentArray (
      segments:segments,
      outlet:self,
      callBack: { (_ inSegments : [MergerSegment]) in
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          components.append (shape)
        }
        self.mBackLayoutTextsLayer.sublayers = components
      }
    )
  }

  //····················································································································

  func unbind_backLayoutTexts () {
    mBackLayoutTextsController?.unregister ()
    mBackLayoutTextsController = nil
  }

  //····················································································································
  //    Board limits
  //····················································································································

  private var mBoardLimitsController : Controller_CanariBoardModelView_boardLimits?

  func bind_boardLimits (_ limits:EBReadOnlyProperty_MergerBoardLimits, file:String, line:Int) {
    mBoardLimitsController = Controller_CanariBoardModelView_boardLimits (limits:limits, outlet:self)
  }

  //····················································································································

  func unbind_boardLimits () {
    mBoardLimitsController?.unregister ()
    mBoardLimitsController = nil
  }

  //····················································································································

  func setBoardLimits (_ inLimits : MergerBoardLimits) {
   var components = [CAShapeLayer] ()
    if inLimits.lineWidth > 0 {
      let boardWith = canariUnitToCocoa (inLimits.boardWidth)
      let boardHeight = canariUnitToCocoa (inLimits.boardHeight)
      let lineWidth = canariUnitToCocoa (inLimits.lineWidth)
      let path = CGMutablePath ()
      path.move    (to:CGPoint (x:lineWidth / 2.0,             y:lineWidth / 2.0))
      path.addLine (to:CGPoint (x:lineWidth / 2.0,             y:boardHeight - lineWidth / 2.0))
      path.addLine (to:CGPoint (x:boardWith - lineWidth / 2.0, y:boardHeight - lineWidth / 2.0))
      path.addLine (to:CGPoint (x:boardWith - lineWidth / 2.0, y:lineWidth / 2.0))
      path.addLine (to:CGPoint (x:lineWidth / 2.0,             y:lineWidth / 2.0))
      let shape = CAShapeLayer ()
      shape.path = path
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.strokeColor = NSColor.brown.cgColor
      shape.fillColor = nil
      shape.lineWidth = lineWidth
      shape.lineCap = kCALineCapSquare
      shape.lineJoin = kCALineJoinMiter
      components.append (shape)
    }
    self.mBoardLimitsLayer.sublayers = components
  }

  //····················································································································
  //    Front Pads
  //····················································································································

  private var mFrontPadsController : Controller_CanariBoardModelView_frontPads?

  //····················································································································

  func bind_frontPads (_ pads:EBReadOnlyProperty_MergerPadArray, file:String, line:Int) {
    mFrontPadsController = Controller_CanariBoardModelView_frontPads (pads:pads, outlet:self)
  }

  //····················································································································

  func unbind_frontPads () {
    mFrontPadsController?.unregister ()
    mFrontPadsController = nil
  }

  //····················································································································

  func setFrontPads (_ padArray : [MergerPad]) {
    var components = [CAShapeLayer] ()
    for pad in padArray {
      let x = canariUnitToCocoa (pad.x)
      let y = canariUnitToCocoa (pad.y)
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = CGRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      var transform = CGAffineTransform (translationX:x, y:y).rotated (by:canariRotationToRadians (pad.rotation))
      let path : CGPath
      switch pad.shape {
      case .rectangular :
        path = CGPath (rect:r, transform:&transform)
      case .round :
        if pad.width < pad.height {
          path = CGPath (roundedRect:r, cornerWidth:width / 2.0, cornerHeight:width / 2.0, transform:&transform)
        }else if pad.width > pad.height {
          path = CGPath (roundedRect:r, cornerWidth:height / 2.0, cornerHeight:height / 2.0, transform:&transform)
        }else{
          path = CGPath (ellipseIn:r, transform:&transform)
        }
      }
      let shape = CAShapeLayer ()
      shape.path = path
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.strokeColor = nil
      shape.fillColor = NSColor.brown.cgColor
      components.append (shape)
    }
    self.mFrontPadsLayer.sublayers = components
  }

  //····················································································································
  //    Back Pads
  //····················································································································

  private var mBackPadsController : Controller_CanariBoardModelView_backPads?

  //····················································································································

  func bind_backPads (_ pads:EBReadOnlyProperty_MergerPadArray, file:String, line:Int) {
    mBackPadsController = Controller_CanariBoardModelView_backPads (pads:pads, outlet:self)
  }

  //····················································································································

  func unbind_backPads () {
    mBackPadsController?.unregister ()
    mBackPadsController = nil
  }

  //····················································································································

  func setBackPads (_ padArray : [MergerPad]) {
    var components = [CAShapeLayer] ()
    for pad in padArray {
      let x = canariUnitToCocoa (pad.x)
      let y = canariUnitToCocoa (pad.y)
      let width = canariUnitToCocoa (pad.width)
      let height = canariUnitToCocoa (pad.height)
      let r = CGRect (x: -width / 2.0, y: -height / 2.0, width:width, height:height)
      var transform = CGAffineTransform (translationX:x, y:y).rotated (by:canariRotationToRadians (pad.rotation))
      let path : CGPath
      switch pad.shape {
      case .rectangular :
        path = CGPath (rect:r, transform:&transform)
      case .round :
        if pad.width < pad.height {
          path = CGPath (roundedRect:r, cornerWidth:width / 2.0, cornerHeight:width / 2.0, transform:&transform)
        }else if pad.width > pad.height {
          path = CGPath (roundedRect:r, cornerWidth:height / 2.0, cornerHeight:height / 2.0, transform:&transform)
        }else{
          path = CGPath (ellipseIn:r, transform:&transform)
        }
      }
      let shape = CAShapeLayer ()
      shape.path = path
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.strokeColor = nil
      shape.fillColor = NSColor.orange.cgColor
      components.append (shape)
    }
    self.mBackPadsLayer.sublayers = components
  }

  //····················································································································
  //    Holes
  //····················································································································

  private var mHolesController : Controller_CanariBoardModelView_holes?

  //····················································································································

  func bind_holes (_ holes:EBReadOnlyProperty_MergerHoleArray, file:String, line:Int) {
    mHolesController = Controller_CanariBoardModelView_holes (holes:holes, outlet:self)
  }

  //····················································································································

  func unbind_holes () {
    mHolesController?.unregister ()
    mHolesController = nil
  }

  //····················································································································

  func setHoles (_ inHoleArray : [MergerHole]) {
    var components = [CAShapeLayer] ()
    for hole in inHoleArray {
      let x = canariUnitToCocoa (hole.x)
      let y = canariUnitToCocoa (hole.y)
      let holeDiameter = canariUnitToCocoa (hole.holeDiameter)
      let r = CGRect (x: x - holeDiameter / 2.0, y: y - holeDiameter / 2.0, width:holeDiameter, height:holeDiameter)
      let path = CGPath (ellipseIn:r, transform:nil)
      let shape = CAShapeLayer ()
      shape.path = path
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.strokeColor = nil
      shape.fillColor = NSColor.white.cgColor
      components.append (shape)
    }
    self.mHolesLayer.sublayers = components
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
//   Controller_CanariBoardModelView_generic_MergerSegmentArray
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_generic_MergerSegmentArray : EBSimpleController {

  private let mSegments : EBReadOnlyProperty_MergerSegmentArray
  private let mOutlet : CanariBoardModelView
  private let mCallBack : ([MergerSegment]) -> Void

  //····················································································································

  init (segments : EBReadOnlyProperty_MergerSegmentArray, outlet : CanariBoardModelView, callBack inCallBack : @escaping ([MergerSegment]) -> Void) {
    mSegments = segments
    mOutlet = outlet
    mCallBack = inCallBack
    super.init (observedObjects:[segments], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mSegments.prop {
    case .noSelection :
      mCallBack ([])
    case .singleSelection (let v) :
      mCallBack (v.segmentArray)
    case .multipleSelection :
      mCallBack ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_boardLimits
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_boardLimits : EBSimpleController {

  private let mLimits : EBReadOnlyProperty_MergerBoardLimits
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (limits : EBReadOnlyProperty_MergerBoardLimits, outlet : CanariBoardModelView) {
    mLimits = limits
    mOutlet = outlet
    super.init (observedObjects:[limits], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mLimits.prop {
    case .noSelection :
      mOutlet.setBoardLimits (MergerBoardLimits ())
    case .singleSelection (let v) :
      mOutlet.setBoardLimits (v)
    case .multipleSelection :
      mOutlet.setBoardLimits (MergerBoardLimits ())
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_frontPads
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_frontPads : EBSimpleController {

  private let mPads : EBReadOnlyProperty_MergerPadArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (pads : EBReadOnlyProperty_MergerPadArray, outlet : CanariBoardModelView) {
    mPads = pads
    mOutlet = outlet
    super.init (observedObjects:[pads], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mPads.prop {
    case .noSelection :
      mOutlet.setFrontPads ([])
    case .singleSelection (let v) :
      mOutlet.setFrontPads (v.padArray)
    case .multipleSelection :
      mOutlet.setFrontPads ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_backPads
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_backPads : EBSimpleController {

  private let mPads : EBReadOnlyProperty_MergerPadArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (pads : EBReadOnlyProperty_MergerPadArray, outlet : CanariBoardModelView) {
    mPads = pads
    mOutlet = outlet
    super.init (observedObjects:[pads], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mPads.prop {
    case .noSelection :
      mOutlet.setBackPads ([])
    case .singleSelection (let v) :
      mOutlet.setBackPads (v.padArray)
    case .multipleSelection :
      mOutlet.setBackPads ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_holes
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_holes : EBSimpleController {

  private let mHoles : EBReadOnlyProperty_MergerHoleArray
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (holes : EBReadOnlyProperty_MergerHoleArray, outlet : CanariBoardModelView) {
    mHoles = holes
    mOutlet = outlet
    super.init (observedObjects:[holes], outlet:outlet)
  }

  //····················································································································

  override func sendUpdateEvent () {
    switch mHoles.prop {
    case .noSelection :
      mOutlet.setHoles ([])
    case .singleSelection (let v) :
      mOutlet.setHoles (v.holeArray)
    case .multipleSelection :
      mOutlet.setHoles ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
