//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBView {

  //····················································································································
  // https://stackoverflow.com/questions/34124676/magnify-nsscrollview-at-cursor-location
  //····················································································································

  override func magnify (with inEvent : NSEvent) {
 //   if let clipView = self.superview as? NSClipView {
      let currentScale = self.actualScale ()
      let newZoom = Int ((currentScale * 100.0 * (inEvent.magnification + 1.0)).rounded (.toNearestOrEven))
//      let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
//      let q = clipView.convert (mouseDownLocation, from:self)
//      let currentOrigin = self.visibleRect.origin
      self.scaleToZoom (newZoom, self.horizontalFlip, self.verticalFlip)
//      let sf = CGFloat (newZoom) / CGFloat (self.mZoom)
      self.mZoom = newZoom
//    let scaleFactor = self.actualScale () / currentScale
  //  Swift.print ("\(inEvent.magnification), \(self.actualScale ()), \(currentScale), \(scaleFactor), \(sf)")

 //   let p = NSPoint (x: mouseDownLocation.x * (1.0 + inEvent.magnification), y: mouseDownLocation.y * (1.0 + inEvent.magnification))
 //   let p = NSPoint (x: -mouseDownLocation.x * (0.0 + inEvent.magnification), y: -mouseDownLocation.y * (0.0 + inEvent.magnification))
//      let p = NSPoint (x: -q.x * (0.0 + inEvent.magnification), y: -q.y * (0.0 + inEvent.magnification))
//let p = NSPoint ()
//      clipView.scroll (to: p)
//    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
