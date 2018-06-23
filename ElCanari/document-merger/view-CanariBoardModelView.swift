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
//   CanariCharacterView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariBoardModelView : NSView, EBUserClassNameProtocol {

   var mBackgroundLayer = CAShapeLayer ()
   var mNoModelTextLayer = CATextLayer ()
   var mViaLayer = CALayer ()

  //····················································································································

  override init(frame frameRect: NSRect) {
    super.init (frame: frameRect)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
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

  func setSize (width : Int, height : Int) {
    let noModel = (width == 0) || (height == 0)
    if noModel {
      let newRect = CGRect (x:0.0, y:0.0, width:200.0, height:200.0)
      self.bounds = newRect
      self.frame = newRect
      mBackgroundLayer.fillColor = nil
      mBackgroundLayer.strokeColor = nil
      mNoModelTextLayer.frame = newRect
      mNoModelTextLayer.foregroundColor = NSColor.black.cgColor
      mNoModelTextLayer.contentsScale = NSScreen.main ()!.backingScaleFactor
      mNoModelTextLayer.alignmentMode = kCAAlignmentRight
      mNoModelTextLayer.string = "No Model"
    }else{
      let newRect = CGRect (x:0.0, y:0.0, width:canariUnitToCocoa (width), height:canariUnitToCocoa (height))
      self.bounds = newRect
      self.frame = newRect
      mBackgroundLayer.path = CGPath (rect: self.bounds.insetBy (dx: 0.5, dy: 0.5), transform: nil)
      mBackgroundLayer.position = CGPoint (x:0.0, y:0.0)
      mBackgroundLayer.fillColor = NSColor.white.cgColor
      mBackgroundLayer.strokeColor = NSColor.black.cgColor
      mBackgroundLayer.lineWidth = 1.0
      mNoModelTextLayer.string = ""
    }
  }

  //····················································································································
  //  First responder
  //····················································································································

  override var acceptsFirstResponder : Bool { get { return true } }

  //····················································································································
  //  Focus ring (https://developer.apple.com/library/content/qa/qa1785/_index.html)
  //····················································································································

  override var focusRingMaskBounds: NSRect { get { return self.bounds } }

  //····················································································································

  override func drawFocusRingMask () {
    NSRectFill (self.bounds)
  }

  //····················································································································
  //    binding
  //····················································································································

  private var mController : Controller_CanariBoardModelView_size?

  func bind_size (_ width:EBReadOnlyProperty_Int, _ height:EBReadOnlyProperty_Int, file:String, line:Int) {
    mController = Controller_CanariBoardModelView_size (width:width, height:height, outlet:self, file:file, line:line)
  }

  func unbind_size () {
    mController?.unregister ()
    mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariBoardModelView_size
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariBoardModelView_size : EBSimpleController {

  private let mWidth : EBReadOnlyProperty_Int
  private let mHeight : EBReadOnlyProperty_Int
  private let mOutlet : CanariBoardModelView

  //····················································································································

  init (width : EBReadOnlyProperty_Int, height : EBReadOnlyProperty_Int, outlet : CanariBoardModelView, file : String, line : Int) {
    mWidth = width
    mHeight = height
    mOutlet = outlet
    super.init (objects:[width, height], outlet:outlet)
    mWidth.addEBObserver (self)
    mHeight.addEBObserver (self)
  }

  //····················································································································
  
  func unregister () {
    mWidth.removeEBObserver (self)
    mHeight.removeEBObserver (self)
  }

  //····················································································································

  override func sendUpdateEvent () {
    var newWidth = 0
    switch mWidth.prop {
    case .noSelection :
      ()
    case .singleSelection (let v) :
      newWidth = v
    case .multipleSelection :
      ()
    }
    var newHeight = 0
    switch mHeight.prop {
    case .noSelection :
      ()
    case .singleSelection (let v) :
      newHeight = v
    case .multipleSelection :
      ()
    }
    //NSLog ("width \(newWidth), height \(newHeight)")
    mOutlet.setSize (width:newWidth, height:newHeight)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
