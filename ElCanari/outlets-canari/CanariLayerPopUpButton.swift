//
//  CanariLayerPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 18/09/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariLayerPopUpButton : EBPopUpButton {

  //····················································································································

  override func awakeFromNib () {
    while (self.numberOfItems > 0) {
      self.removeItem (at: 0)
    }
    self.addItems (withTitles: ["2", "4", "6"])
  }

  //····················································································································

  private var mController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_layerConfiguration (_ inLayerConfiguration : EBReadOnlyProperty_LayerConfiguration) {
    self.mController = EBObservablePropertyController (
      observedObjects: [inLayerConfiguration],
      callBack: { self.update (from: inLayerConfiguration) }
    )
  }

  //····················································································································

  final func unbind_layerConfiguration () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

  func update (from model : EBReadOnlyProperty_LayerConfiguration) {
    switch model.selection {
    case .empty :
      self.enableFromValueBinding (false)
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.selectItem (at: v.rawValue)
    case .multiple :
      self.enableFromValueBinding (false)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
