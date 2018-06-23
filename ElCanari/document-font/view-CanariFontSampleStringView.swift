//
//  CanariCharacterView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariFontSampleStringView : NSView, EBUserClassNameProtocol {

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

  override func awakeFromNib () {
  //--- Background Layer
    let layer = CAShapeLayer ()
    layer.path = CGPath (rect: self.bounds.insetBy (dx: 0.5, dy: 0.5), transform: nil)
    layer.position = CGPoint (x:0.0, y:0.0)
    layer.fillColor = NSColor.white.cgColor
    layer.strokeColor = NSColor.black.cgColor
    layer.lineWidth = 1.0
    self.layer?.addSublayer (layer)
  //--- Sample String layer
    mSampleStringLayer.strokeColor = NSColor.black.cgColor
    mSampleStringLayer.lineWidth = 2.0
    mSampleStringLayer.lineCap = kCALineCapRound
    self.layer?.addSublayer (mSampleStringLayer)
  }

  //····················································································································
  //  update display
  //····················································································································

  private var mSampleStringLayer = CAShapeLayer ()

  //····················································································································

  func updateDisplayFromBezierPathController (_ bezierPath : CGPath) {
    mSampleStringLayer.path = bezierPath
    mSampleStringLayer.position = CGPoint (
      x:(self.bounds.size.width - bezierPath.boundingBox.size.width) * 0.5,
      y:(self.bounds.size.height - bezierPath.boundingBox.size.height) * 0.5
    )
  }

  //····················································································································
  
  func updateDisplayFromFontSizeController (_ fontSize : Double) {
    mSampleStringLayer.lineWidth = 2.0 * CGFloat (fontSize) / 14.0
  }
  
  //····················································································································
  //  $bezierPath binding
  //····················································································································

  private var mBezierPathBindingController : Controller_CanariFontSampleStringView_bezierPath?

  final func bind_bezierPath (_ object:EBReadOnlyProperty_CGPath, file:String, line:Int) {
    mBezierPathBindingController = Controller_CanariFontSampleStringView_bezierPath (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_bezierPath () {
    mBezierPathBindingController?.unregister ()
    mBezierPathBindingController = nil
  }

  //····················································································································
  //  $sampleStringFontSize binding
  //····················································································································

  private var mSampleStringFontSizeBindingController : Controller_CanariFontSampleStringView_sampleStringFontSize?

  final func bind_sampleStringFontSize (_ object:EBReadOnlyProperty_Double, file:String, line:Int) {
    mSampleStringFontSizeBindingController = Controller_CanariFontSampleStringView_sampleStringFontSize (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_sampleStringFontSize () {
    mSampleStringFontSizeBindingController?.unregister ()
    mSampleStringFontSizeBindingController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
