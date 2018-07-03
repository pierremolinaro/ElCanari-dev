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

  func hole_modelDidChange (_ inHoles : EBSelection <MergerHoleArray>) {
    let paths = CGMutablePath ()
    switch inHoles {
    case .single (let v) :
      for hole in v.holeArray {
        let x : CGFloat = canariUnitToCocoa (hole.x)
        let y : CGFloat = canariUnitToCocoa (hole.y)
        let holeDiameter = canariUnitToCocoa (hole.holeDiameter)
        let r = CGRect (x: x - holeDiameter / 2.0, y: y - holeDiameter / 2.0, width:holeDiameter, height:holeDiameter)
        paths.addEllipse (in: r)
      }
    default :
      break
    }
    let shape = CAShapeLayer ()
    shape.path = paths
    shape.position = CGPoint (x:0.0, y:0.0)
    shape.fillColor = NSColor.white.cgColor
    self.mHolesLayer.sublayers = [shape]
  }

  //····················································································································
  //  Outlets
  //····················································································································

  //····················································································································
  //  Properties
  //····················································································································

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

//    self.mNoModelTextLayer.isOpaque = OPAQUE_LAYERS
    self.mNoModelTextLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mNoModelTextLayer)

    self.mBackPackagesLayer.isOpaque = OPAQUE_LAYERS
    self.mBackPackagesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackPackagesLayer)

    self.mBackLegendTextsLayer.isOpaque = OPAQUE_LAYERS
    self.mBackLegendTextsLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackLegendTextsLayer)

    self.mBackComponentNamesLayer.isOpaque = OPAQUE_LAYERS
    self.mBackComponentNamesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackComponentNamesLayer)

    self.mBackComponentValuesLayer.isOpaque = OPAQUE_LAYERS
    self.mBackComponentValuesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackComponentValuesLayer)

    self.mBackTracksLayer.isOpaque = OPAQUE_LAYERS
    self.mBackTracksLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackTracksLayer)

    self.mBackLayoutTextsLayer.isOpaque = OPAQUE_LAYERS
    self.mBackLayoutTextsLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackLayoutTextsLayer)

    self.mBackgroundLayer.isOpaque = OPAQUE_LAYERS
    self.mBackgroundLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.layer?.addSublayer (mBackPadsLayer)

    self.mFrontTracksLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontTracksLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontTracksLayer)

    self.mFrontLayoutTextsLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontLayoutTextsLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontLayoutTextsLayer)

    self.mFrontPackagesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontPackagesLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontPackagesLayer)

    self.mFrontLegendTextsLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontLegendTextsLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontLegendTextsLayer)

    self.mFrontComponentValuesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontComponentValuesLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontComponentValuesLayer)

    self.mFrontComponentNamesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontComponentNamesLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontComponentNamesLayer)

    self.mFrontPadsLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mFrontPadsLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mFrontPadsLayer)

    self.mBoardLimitsLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mBoardLimitsLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mBoardLimitsLayer)

    self.mViaPadLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mViaPadLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mViaPadLayer)

    self.mHolesLayer.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
    self.mHolesLayer.isOpaque = OPAQUE_LAYERS
    self.layer?.addSublayer (mHolesLayer)
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
    self.notifyTransaction ()
    let paths = CGMutablePath ()
    for via in inVias {
      let xf : CGFloat = canariUnitToCocoa (via.x)
      let yf : CGFloat = canariUnitToCocoa (via.y)
      let pdf : CGFloat = canariUnitToCocoa (via.padDiameter)
      let rPad = NSRect (x : xf - pdf / 2.0, y: yf - pdf / 2.0, width:pdf, height:pdf)
      paths.addEllipse (in: rPad)
    }
    let viaPad = CAShapeLayer ()
    viaPad.path = paths
    viaPad.position = CGPoint (x:0.0, y:0.0)
    viaPad.fillColor = NSColor.red.cgColor
    mViaPadLayer.sublayers = [viaPad]
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.orange.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.blue.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.green.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.brown.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.brown.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.blue.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.blue.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
        self.notifyTransaction ()
        var components = [CAShapeLayer] ()
        for segment in inSegments {
          let shape = segment.segmentShape (color:NSColor.gray.cgColor)
          shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
          shape.isOpaque = OPAQUE_LAYERS
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
    self.notifyTransaction ()
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
      shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
      shape.isOpaque = OPAQUE_LAYERS
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
    self.notifyTransaction ()
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
      shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
      shape.isOpaque = OPAQUE_LAYERS
      components.append (shape)
    }
//    let aLayer = CALayer ()
//    aLayer.sublayers = components
//    let duplicatedLayer = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: aLayer)) as! CALayer
//    duplicatedLayer.position = CGPoint (x:10.0, y:10.0)
//    self.mFrontPadsLayer.sublayers = [aLayer, duplicatedLayer]

//   CALayer *layer = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:layer]];
//    let replicatorLayer = CAReplicatorLayer ()
//    replicatorLayer.instanceCount = 3
//    replicatorLayer.instanceTransform = CATransform3DMakeTranslation (10.0, 10.0, 0.0)
//    replicatorLayer.sublayers = components
//    self.mFrontPadsLayer.sublayers = [replicatorLayer]

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
    self.notifyTransaction ()
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
      shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
      shape.isOpaque = OPAQUE_LAYERS
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
    self.notifyTransaction ()
//    let paths = CGMutablePath ()
    var array = [CALayer] ()
    for hole in inHoleArray {
      let x : CGFloat = canariUnitToCocoa (hole.x)
      let y : CGFloat = canariUnitToCocoa (hole.y)
      let holeDiameter = canariUnitToCocoa (hole.holeDiameter)
      let r = CGRect (x: x - holeDiameter / 2.0, y: y - holeDiameter / 2.0, width:holeDiameter, height:holeDiameter)
      let shape = CAShapeLayer ()
      shape.path = CGPath (ellipseIn:r, transform: nil)
      shape.position = CGPoint (x:0.0, y:0.0)
      shape.fillColor = NSColor.white.cgColor
      shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
      shape.isOpaque = OPAQUE_LAYERS
      array.append (shape)
    //  paths.addEllipse (in: r)
    }
//    let shape = CAShapeLayer ()
//    shape.path = paths
//    shape.position = CGPoint (x:0.0, y:0.0)
//    shape.fillColor = NSColor.white.cgColor
//    shape.drawsAsynchronously = DRAWS_ASYNCHRONOUSLY
//    shape.isOpaque = OPAQUE_LAYERS
    self.mHolesLayer.sublayers = array // [shape]
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
    case .empty :
      mOutlet.setVias ([])
    case .single (let v) :
      mOutlet.setVias (v.shapeArray)
    case .multiple :
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
    case .empty :
      mCallBack ([])
    case .single (let v) :
      mCallBack (v.segmentArray)
    case .multiple :
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
    case .empty :
      mOutlet.setBoardLimits (MergerBoardLimits ())
    case .single (let v) :
      mOutlet.setBoardLimits (v)
    case .multiple :
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
    case .empty :
      mOutlet.setFrontPads ([])
    case .single (let v) :
      mOutlet.setFrontPads (v.padArray)
    case .multiple :
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
    case .empty :
      mOutlet.setBackPads ([])
    case .single (let v) :
      mOutlet.setBackPads (v.padArray)
    case .multiple :
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
    case .empty :
      mOutlet.setHoles ([])
    case .single (let v) :
      mOutlet.setHoles (v.holeArray)
    case .multiple :
      mOutlet.setHoles ([])
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   GenericController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class GenericController_MergerHoleArray : EBOutletEvent {

  private let mActionCallBack : (EBSelection <MergerHoleArray>) -> Void
  private let mGetPropertyValueCallBack : () -> EBSelection <MergerHoleArray>

  //····················································································································

  init (getPropertyValueCallBack inGetPropertyValueCallBack : @escaping () -> EBSelection <MergerHoleArray>,
        modelDidChange inActionCallBack : @escaping (EBSelection <MergerHoleArray>) -> Void) {
    mGetPropertyValueCallBack = inGetPropertyValueCallBack
    mActionCallBack = inActionCallBack
    super.init ()
  }

  //····················································································································

   override func sendUpdateEvent () {
    mActionCallBack (mGetPropertyValueCallBack ())
  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   GenericController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class GenericController_w_Int : EBOutletEvent {

  private let mActionCallBack : (EBSelection <Int>) -> Void
  private let mGetPropertyValueCallBack : () -> EBSelection <Int>

  //····················································································································

  init (getPropertyValueCallBack inGetPropertyValueCallBack : @escaping () -> EBSelection <Int>,
        modelDidChange inActionCallBack : @escaping (EBSelection <Int>) -> Void) {
    mGetPropertyValueCallBack = inGetPropertyValueCallBack
    mActionCallBack = inActionCallBack
    super.init ()

  }

  //····················································································································

   override func sendUpdateEvent () {
    mActionCallBack (mGetPropertyValueCallBack ())
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
