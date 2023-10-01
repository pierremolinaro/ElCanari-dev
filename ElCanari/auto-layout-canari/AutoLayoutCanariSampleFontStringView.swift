//
//  AutoLayoutCanariSampleFontStringView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 28/11/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariSampleFontStringView : AutoLayoutBase_NSView {

  //····················································································································

  override init () {
    super.init ()
    self.setContentHuggingPriority (.required, for: .vertical)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  //  update display
  //····················································································································

  private var mSampleStringBezierPath = NSBezierPath ()

  //····················································································································

  func updateDisplayFromBezierPathController (_ inBezierPath : NSBezierPath) {
    self.mSampleStringBezierPath = inBezierPath
    self.needsDisplay = true
  }

  //····················································································································
  //  intrinsicContentSize
  //····················································································································

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    s.height = 60.0
    return s
  }

  //····················································································································
  //  isOpaque
  //····················································································································

  override var isOpaque : Bool { return true }

  //····················································································································
  //  drawRect
  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
    NSColor.white.setFill ()
    NSBezierPath.fill (inDirtyRect)
    NSColor.black.setStroke ()
    var bp = NSBezierPath (rect: self.bounds.insetBy(dx: 0.5, dy: 0.5))
    bp.lineWidth = 1.0
    bp.stroke ()
    if !self.mSampleStringBezierPath.isEmpty {
      let size = self.mSampleStringBezierPath.bounds.size
      let tr = NSAffineTransform ()
      tr.translateX (by: (self.bounds.size.width - size.width) * 0.5, yBy: (self.bounds.size.height - size.height) * 0.5)
      bp = tr.transform (self.mSampleStringBezierPath)
      NSColor.black.setStroke ()
      bp.lineJoinStyle = .round
      bp.lineCapStyle = .round
      bp.stroke ()
    }
  }

  //····················································································································
  //  $bezierPath binding
  //····················································································································

  final private func updateBezierPath (_ object : EBObservableProperty <NSBezierPath>) {
    switch object.selection {
    case .empty, .multiple :
      break ;
    case .single (let bezierPath) :
      self.updateDisplayFromBezierPathController (bezierPath)
    }
  }

  //····················································································································

  private var mBezierPathBindingController : EBObservablePropertyController?

  final func bind_bezierPath (_ object : EBObservableProperty <NSBezierPath>) -> Self {
    self.mBezierPathBindingController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { [weak self] in self?.updateBezierPath (object) }
    )
    return self
  }

  //····················································································································

//  final func unbind_bezierPath () {
//    self.mBezierPathBindingController?.unregister ()
//    self.mBezierPathBindingController = nil
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
