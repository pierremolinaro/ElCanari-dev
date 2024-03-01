//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EBGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView {

  //································································································

  final func bind_foregroundImageData (_ model : EBObservableProperty <Data>) {
    self.mForegroundImageDataController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateForegroundImageData (from: model) }
    )
  }

  //································································································

//  final func unbind_foregroundImageData () {
//    self.mForegroundImageDataController?.unregister ()
//    self.mForegroundImageDataController = nil
//  }

  //································································································

  final private func updateForegroundImageData (from model : EBObservableProperty <Data>) {
    if self.mForegroundImage != nil {
      self.mForegroundImage = nil
      self.setNeedsDisplayAndUpdateViewBounds ()
    }
    switch model.selection {
    case .empty :
      break
    case .single (let v) :
      if let ciImage = CIImage (data: v) {
        self.mForegroundImage = ciImage
        self.setNeedsDisplayAndUpdateViewBounds ()
      }
    case .multiple :
      break
    }
  }

  //································································································

  final func bind_foregroundImageOpacity (_ model : EBObservableProperty <Double>) {
    self.mForegroundImageOpacityController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateForegroundImageOpacity (from: model) }
    )
  }

  //································································································

//  final func unbind_foregroundImageOpacity () {
//    self.mForegroundImageOpacityController?.unregister ()
//    self.mForegroundImageOpacityController = nil
//  }

  //································································································

  final private func updateForegroundImageOpacity (from model : EBObservableProperty <Double>) {
    switch model.selection {
    case .empty :
      break
    case .single (let v) :
      self.mForegroundImageOpacity = CGFloat (v)
      self.needsDisplay = true
    case .multiple :
      break
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
