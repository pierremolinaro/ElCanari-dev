//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBGraphicView
//--------------------------------------------------------------------------------------------------

extension EBGraphicView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_verticalFlip (_ model : EBObservableProperty <Bool>) {
    self.mVerticalFlipController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateVerticalFlip (from: model) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_verticalFlip () {
//    self.mVerticalFlipController?.unregister ()
//    self.mVerticalFlipController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final private func updateVerticalFlip (from model : EBObservableProperty <Bool>) {
    switch model.selection {
    case .empty :
      self.setVerticalFlip (false)
    case .single (let v) :
      self.setVerticalFlip (v)
    case .multiple :
      self.setVerticalFlip (false)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
