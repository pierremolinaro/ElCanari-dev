//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  AutoLayout-extension-NSView.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Hidden binding
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gHiddenBindingDictionary = [NSView : EBReadOnlyPropertyController] ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension NSView {

  //····················································································································

  override func ebCleanUp () {
    self.autoLayoutCleanUp ()
    super.ebCleanUp ()
  }

  //····················································································································

  @objc func autoLayoutCleanUp () {
    gHiddenBindingDictionary [self] = nil
  }

  //····················································································································
  //  $hidden binding
  //····················································································································

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    var modelArray = [EBObservableObjectProtocol] ()
    inExpression.addModelsTo (&modelArray)
    let controller = EBReadOnlyPropertyController (
      observedObjects: modelArray,
      callBack: { [weak self] in self?.updateHiddenState (from: inExpression.compute ()) }
    )
    gHiddenBindingDictionary [self] = controller
    return self
  }

  //····················································································································

  fileprivate func updateHiddenState (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.isHidden = true
    case .single (let v) :
      self.isHidden = v
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
