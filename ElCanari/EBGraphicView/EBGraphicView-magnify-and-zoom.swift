//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   EBGraphicView
//----------------------------------------------------------------------------------------------------------------------

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
      let newZoom = Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))
      self.mZoomDidChangeCallback? (newZoom)
    }
  }

  //····················································································································

  final var actualScale : CGFloat {
    return self.enclosingScrollView?.magnification ?? 1.0
  }

  //····················································································································
  // https://stackoverflow.com/questions/34124676/magnify-nsscrollview-at-cursor-location
  //····················································································································

  final internal func addEndLiveMagnificationObserver () {
 //   NSLog ("addEndLiveMagnificationObserver \(self.enclosingScrollView)")
    if let scrollView = self.enclosingScrollView {
      let nc = NotificationCenter.default
      nc.addObserver (
        self,
        selector: #selector (EBGraphicView.didEndLiveMagnification (_:)),
        name: NSScrollView.didEndLiveMagnifyNotification,
        object: scrollView
      )
    }
  }

  //····················································································································

  @objc final private func didEndLiveMagnification (_ inNotification : Notification) {
    let newZoom = Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))
//    NSLog ("didEndLiveMagnification \(newZoom)")
    _ = self.mZoomController?.updateModel (withCandidateValue: newZoom, windowForSheet: self.window)
  }

  //····················································································································
  //  Live Resize
  //  Appelé quand l'utilisateur redimensionne la vue graphique, via la fonction tile de la scrollView
  //····················································································································

  final internal func scrollViewIsLiveResizing () {
//    NSLog ("scrollViewIsLiveResizing \(self.mZoomPropertyCache) \(self)")
    if self.mZoomPropertyCache == 0, let scrollView = self.enclosingScrollView {
      let box = self.objectsAndIssueBoundingBox
      if !box.isEmpty {
        scrollView.magnify (toFit: box)
      }
      let newZoom = Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))
      self.mZoomDidChangeCallback? (newZoom)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
