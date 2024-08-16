//
//  AutoLayoutComboBox.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutComboBox
//--------------------------------------------------------------------------------------------------

final class AutoLayoutComboBox : ALB_NSComboBox {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mWidth : CGFloat

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (width inWidth : Int) {
    self.mWidth = CGFloat (inWidth)
    super.init ()

    self.delegate = self
//    self.isContinuous = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    return NSSize (width: self.mWidth, height: s.height)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mTextDidChange : Optional < (_ inOutlet : AutoLayoutComboBox) -> Void > = nil {
    didSet {
      self.mTextDidChange? (self)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    self.mTextDidChange? (self)
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  func controlTextDidEndEditing (_ notification : Notification) {
//    self.mTextDidChange? (self)
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // NSComboBoxDelegate functions
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func comboBoxSelectionDidChange (_ inNotification : Notification) {
    DispatchQueue.main.async { self.mTextDidChange? (self) }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func controlTextDidChange (_ inNotification : Notification) {
    self.mTextDidChange? (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func controlTextDidEndEditing (_ notification : Notification) {
    self.mTextDidChange? (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

