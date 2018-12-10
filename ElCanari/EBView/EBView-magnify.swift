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
    if let scrollView = self.enclosingScrollView {
      let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
      scrollView.setMagnification (scrollView.magnification + inEvent.magnification, centeredAt: mouseDownLocation)
      let newZoom = Int ((scrollView.magnification * 100.0).rounded (.toNearestOrEven))
      self.mZoomController?.updateModel (self, newZoom)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
