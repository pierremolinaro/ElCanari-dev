//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBView {

  //····················································································································

  func applyZoom (_ inZoom : Int) {
    if let scrollView = self.enclosingScrollView {
      if inZoom == 0 {
        let box = self.objectsAndIssueBoundingBox
        if !box.isEmpty {
          scrollView.magnify (toFit: box)
        }
      }else{
        scrollView.magnification = CGFloat (inZoom) / 100.0
      }
      let zoomTitle = "\(Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))) %"
      self.mZoomPopUpButton?.menu?.item (at:0)?.title = (0 == inZoom) ? ("(\(zoomTitle))") : zoomTitle
    }
  }

  //····················································································································

  var actualScale : CGFloat {
    var result : CGFloat = 1.0
    if let scrollView = self.enclosingScrollView {
      result = scrollView.magnification
    }
    return result
  }

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
