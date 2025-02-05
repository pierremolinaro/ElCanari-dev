//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBGraphicView
//--------------------------------------------------------------------------------------------------

extension EBGraphicView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   final func applyZoomToFit (rect inRect : NSRect) {
     if let scrollView = self.enclosingScrollView, !inRect.isEmpty {
     //--- Compute new scale
       let horizontalScale = scrollView.documentVisibleRect.size.width / inRect.size.width
       let verticalScale = scrollView.documentVisibleRect.size.height / inRect.size.height
       let newScale = min (horizontalScale, verticalScale) * self.actualScale
     //--- Set New Zoom
       let newZoom = Int ((newScale * 100.0).rounded (.toNearestOrEven))
       self.mZoomController?.updateModel (withValue: newZoom)
     //---
       DispatchQueue.main.async { self.scrollToVisible (inRect) }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func applyZoom () {
    if let scrollView = self.enclosingScrollView {
      var box = self.contentsBoundingBox
      self.mWorkingArea?.union (withRect: &box)
      if self.mZoomPropertyCache == 0 {
        if !box.isEmpty {
          scrollView.magnify (toFit: box)
        }
      }else{
        scrollView.magnification = CGFloat (self.mZoomPropertyCache) / 100.0
      }
      var newBounds = box
      let visibleRect = scrollView.documentVisibleRect
      if visibleRect.maxX > newBounds.maxX {
        newBounds.size.width = visibleRect.maxX - newBounds.origin.x
      }
      if visibleRect.maxY > newBounds.maxY {
        newBounds.size.height = visibleRect.maxY - newBounds.origin.y
      }
      self.frame.size = newBounds.size
      self.bounds = newBounds
      let newZoom = Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))
      self.mZoomDidChangeCallback? (newZoom)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final var actualScale : CGFloat {
    return self.enclosingScrollView?.magnification ?? 1.0
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // https://stackoverflow.com/questions/34124676/magnify-nsscrollview-at-cursor-location
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addEndLiveMagnificationObserver () {
    if let scrollView = self.enclosingScrollView {
      let nc = NotificationCenter.default
      nc.addObserver (
        self,
        selector: #selector (Self.didEndLiveMagnification (_:)),
        name: NSScrollView.didEndLiveMagnifyNotification,
        object: scrollView
      )
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func didEndLiveMagnification (_ inNotification : Notification) {
    let newZoom = Int ((self.actualScale * 100.0).rounded (.toNearestOrEven))
    self.mZoomController?.updateModel (withValue: newZoom)
    self.needsDisplay = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Live Resize
  //  Appelé quand l'utilisateur redimensionne la vue graphique, via la fonction tile de la scrollView
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func scrollViewIsLiveResizing () {
    self.applyZoom ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
