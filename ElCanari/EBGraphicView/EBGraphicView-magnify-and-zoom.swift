//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView {

  //····················································································································

  final func applyZoom () {
    if let scrollView = self.enclosingScrollView {
      if self.mZoomPropertyCache == 0 {
        let box = self.objectsAndIssueBoundingBox
        if !box.isEmpty {
          scrollView.magnify (toFit: box)
        }
      }else{
        scrollView.magnification = CGFloat (self.mZoomPropertyCache) / 100.0
      }
      let zoomTitle = "\(Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))) %"
      self.mZoomPopUpButton?.menu?.item (at:0)?.title = zoomTitle
    }
  }

  //····················································································································

  final var actualScale : CGFloat {
    var result : CGFloat = 1.0
    if let scrollView = self.enclosingScrollView {
      result = scrollView.magnification
    }
    return result
  }

  //····················································································································
  // https://stackoverflow.com/questions/34124676/magnify-nsscrollview-at-cursor-location
  //····················································································································

  final internal func addEndLiveMagnificationObserver () {
    if let scrollView = self.enclosingScrollView {
      let nc = NotificationCenter.default
      nc.addObserver (
        self,
        selector: #selector(EBGraphicView.didEndLiveScroll (_:)),
        name: NSScrollView.didEndLiveMagnifyNotification,
        object: scrollView
      )
    }
  }

  //····················································································································

  @objc final internal func didEndLiveScroll (_ inNotification : Notification) {
    let newZoom = Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))
    self.mZoomController?.updateModel (self, newZoom)
  }

  //····················································································································
  //  Live Resize
  //····················································································································

  final internal func scrollViewIsLiveResizing () {
    if self.mZoomPropertyCache == 0, let scrollView = self.enclosingScrollView {
      let box = self.objectsAndIssueBoundingBox
      if !box.isEmpty {
        scrollView.magnify (toFit: box)
      }
      let zoomTitle = "\(Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))) %"
      self.mZoomPopUpButton?.menu?.item (at:0)?.title = zoomTitle
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
