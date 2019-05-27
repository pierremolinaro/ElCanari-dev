//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EBGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView {

  //····················································································································

  func bind_gridStep (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mGridStepController = EBSimpleController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateGridStep (from: model) }
    )
  }

  //····················································································································

  func unbind_gridStep () {
    self.mGridStepController?.unregister ()
    self.mGridStepController = nil
  }

  //····················································································································

  private func updateGridStep (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty, .multiple :
      self.mGridStepInCanariUnit = milsToCanariUnit (25)
    case .single (let v) :
      self.mGridStepInCanariUnit = v
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————