//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView {

  //····················································································································

  final func bind_arrowKeyMagnitude (_ model : EBObservableProperty <Int>) {
    self.mArrowKeyMagnitudeController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateArrowKeyMagnitude (from: model) }
    )
  }

  //····················································································································

//  final func unbind_arrowKeyMagnitude () {
//    self.mArrowKeyMagnitudeController?.unregister ()
//    self.mArrowKeyMagnitudeController = nil
//  }

  //····················································································································

  final private func updateArrowKeyMagnitude (from model : EBObservableProperty <Int>) {
    switch model.selection {
    case .empty :
      break
    case .single (let v) :
      self.set (arrowKeyMagnitude: v)
    case .multiple :
      break
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————