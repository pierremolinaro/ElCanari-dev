//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBGraphicView
//--------------------------------------------------------------------------------------------------

extension EBGraphicView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_overObjectsDisplay (_ model : EBObservableProperty <EBShape>) {
    self.mOverObjectsDisplayController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateOverObjectsDisplay (from: model) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_overObjectsDisplay () {
//    self.mOverObjectsDisplayController?.unregister ()
//    self.mOverObjectsDisplayController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final private func updateOverObjectsDisplay (from model : EBObservableProperty <EBShape>) {
    switch model.selection {
    case .empty, .multiple :
      self.mOverObjectsDisplay = EBShape ()
    case .single (let v) :
      self.mOverObjectsDisplay =  v
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
