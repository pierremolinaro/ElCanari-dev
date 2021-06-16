//----------------------------------------------------------------------------------------------------------------------
//
//  AutoLayout-extension-NSView.swift
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   Hidden binding
//----------------------------------------------------------------------------------------------------------------------

private var gHiddenBindingDictionary = [NSView : EBReadOnlyPropertyController] ()

//----------------------------------------------------------------------------------------------------------------------

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

  final func bind_hidden (observedObjects inObjects : [EBObservableObjectProtocol],
                          computeFunction inFunction : @escaping () -> EBSelection <Bool>) -> Self {
    let controller = EBReadOnlyPropertyController (
      observedObjects: inObjects,
      callBack: { [weak self] in self?.update (from: inFunction ()) }
    )
    gHiddenBindingDictionary [self] = controller
    return self
  }

  //····················································································································

  fileprivate func update (from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      self.isHidden = true
    case .single (let v) :
      self.isHidden = v
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
