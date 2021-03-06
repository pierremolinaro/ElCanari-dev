//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Build PDF image data
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func buildPDFimageData (frame inFrame : NSRect,
                        shape inShape : EBShape,
                        backgroundColor inBackColor : NSColor? = nil) -> Data {
  let origin = inFrame.origin
  var tr = AffineTransform ()
  tr.translate (x: -origin.x, y: -origin.y)
  let view = EBOffscreenView (frame: NSRect (origin: NSPoint (), size: inFrame.size))
  view.setBackColor (inBackColor)
  view.setShape (inShape.transformed (by: tr))
  let data = view.dataWithPDF (inside: view.bounds)
  return data
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Build PDF image
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func buildPDFimage (frame inFrame : NSRect,
                    shape inShape : EBShape,
                    backgroundColor inBackColor : NSColor? = nil) -> NSImage {
  let image = NSImage (data: buildPDFimageData (frame: inFrame, shape: inShape, backgroundColor: inBackColor))
  return image ?? NSImage ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBOffscreenView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class EBOffscreenView : NSView, EBUserClassNameProtocol {

  private var mShape = EBShape ()
  private var mBackColor : NSColor? = nil

  //····················································································································

  override var isFlipped : Bool  { return false }

  //····················································································································

  override init (frame frameRect: NSRect) {
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
  //  Set paths
  //····················································································································

  func setShape (_ inShape : EBShape) {
    self.mShape = inShape
  }

  //····················································································································
  //  Set back color
  //····················································································································

  func setBackColor (_ inColor : NSColor?) {
    self.mBackColor = inColor
  }

  //····················································································································
  //  Draw Rect
  //····················································································································

  override func draw (_ inDirtyRect : NSRect) {
    if let backColor = self.mBackColor {
      backColor.setFill ()
      NSBezierPath.fill (inDirtyRect)
    }
    self.mShape.draw (inDirtyRect)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
