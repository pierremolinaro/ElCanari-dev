//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   EBGraphicView
//--------------------------------------------------------------------------------------------------

extension EBGraphicView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func validateMenuItem (_ inMenuItem : NSMenuItem) -> Bool {
    let validate : Bool
    let action = inMenuItem.action
    if action == #selector (EBGraphicView.selectAll(_:)) {
      validate = (self.mViewController?.objectCount ?? 0) > 0
    }else if action == #selector (EBGraphicView.cut(_:)) {
      validate = self.mViewController?.canCut (self.mPasteboardType) ?? false
    }else if action == #selector (EBGraphicView.copy(_:)) {
      validate = self.mViewController?.canCopy (self.mPasteboardType) ?? false
    }else if action == #selector (EBGraphicView.paste(_:)) {
      validate = self.mViewController?.canPaste (self.mPasteboardType) ?? false
    }else if action == #selector (EBGraphicView.delete(_:)) {
      validate = self.mViewController?.canDelete () ?? false
    }else if action == #selector (EBGraphicView.bringToFront(_:)) {
      validate = self.mViewController?.canBringToFront ?? false
    }else if action == #selector (EBGraphicView.bringForward(_:)) {
      validate = self.mViewController?.canBringForward ?? false
    }else if action == #selector (EBGraphicView.sendToBack(_:)) {
      validate = self.mViewController?.canSendToBack ?? false
    }else if action == #selector (EBGraphicView.sendBackward(_:)) {
      validate = self.mViewController?.canSendBackward ?? false
    }else if action == #selector (EBGraphicView.snapToGrid(_:)) {
      validate = self.mViewController?.canSnapToGrid (self.mArrowKeyMagnitude) ?? false
    }else if action == #selector (EBGraphicView.flipHorizontally(_:)) {
      validate = self.mViewController?.canFlipHorizontally ?? false
    }else if action == #selector (EBGraphicView.flipVertically(_:)) {
      validate = self.mViewController?.canFlipVertically ?? false
    }else if action == #selector (EBGraphicView.rotate90Clockwise(_:)) {
      validate = self.mViewController?.canRotate90 ?? false
    }else if action == #selector (EBGraphicView.rotate90CounterClockwise(_:)) {
      validate = self.mViewController?.canRotate90 ?? false
    }else{
      validate = false
    }
    return validate
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func cut (_ : Any?) {
    let translation = CanariPoint (x: self.mShiftArrowKeyMagnitude, y: self.mShiftArrowKeyMagnitude)
    self.mViewController?.cutSelectedObjectsIntoPasteboard (self.mPasteboardType, pasteOffset: translation)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func copy (_ : Any?) {
    let translation = CanariPoint (x: self.mShiftArrowKeyMagnitude, y: self.mShiftArrowKeyMagnitude)
    self.mViewController?.copySelectedObjectsIntoPasteboard (self.mPasteboardType, pasteOffset: translation)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func paste (_ : Any?) {
    if let windowForSheet = self.window {
      self.mViewController?.pasteFromPasteboard (self.mPasteboardType, windowForSheet)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func delete (_ : Any?) {
    self.deleteSelection ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func deleteSelection () {
    self.mViewController?.deleteSelectedObjects ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override final func selectAll (_ : Any?) {
    self.mViewController?.selectAllObjects ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func bringForward () {
    self.mViewController?.bringForward ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func bringToFront (_ : Any?) {
    self.mViewController?.bringToFront ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func bringForward (_ : Any?) {
    self.mViewController?.bringForward ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func sendToBack (_ : Any?) {
    self.mViewController?.sendToBack ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func sendBackward (_ : Any?) {
    self.mViewController?.sendBackward ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func snapToGrid (_ : Any?) {
    self.mViewController?.snapToGrid (self.mArrowKeyMagnitude)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func flipHorizontally (_ : Any?) {
    self.mViewController?.flipHorizontally ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func flipVertically (_ : Any?) {
    self.mViewController?.flipVertically ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func rotate90Clockwise (_ : Any?) {
    self.mViewController?.rotate90Clockwise ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc final func rotate90CounterClockwise (_ : Any?) {
    self.mViewController?.rotate90CounterClockwise ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
