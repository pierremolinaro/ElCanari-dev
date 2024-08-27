//
//  AutoLayoutDisclosureTriangle.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/08/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------

final class AutoLayoutDisclosureTriangle : ALB_NSButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (title: "", size: inSize.cocoaControlSize)
    self.bezelStyle = .disclosure
    self.setButtonType (.pushOnPushOff)
    self.allowsMixedState = false
    self.state = .off
    self.setClosureAction { [weak self] in self?.boutonAction () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func boutonAction () {
    self.mExpansionController?.updateModel (withValue: self.state == .on)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate var mExpansionController : EBGenericReadWritePropertyController <Bool>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_expanded (_ inObject : EBObservableMutableProperty <Bool>) -> Self {
    self.mExpansionController = EBGenericReadWritePropertyController <Bool> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateValue (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateValue (from inObject : EBObservableMutableProperty <Bool>) {
    switch inObject.selection {
    case .empty, .multiple :
       self.state = .off
    case .single (let v) :
      self.state = v ? .on : .off
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
