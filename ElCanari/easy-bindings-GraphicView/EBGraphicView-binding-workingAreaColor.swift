//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   EBGraphicView
//——————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_workingAreaColor (_ inModel : EBObservableProperty <NSColor>) {
    self.mWorkingAreaColorController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateWorkingAreaColor (from: inModel) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_WorkingAreaColor () {
//    self.mWorkingAreaColorController?.unregister ()
//    self.mWorkingAreaColorController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final private func updateWorkingAreaColor (from model : EBObservableProperty <NSColor>) {
    switch model.selection {
    case .empty, .multiple :
      ()
    case .single (let v) :
      self.mWorkingArea?.set (color: v)
      self.needsDisplay = true
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
