//
//  AutoLayoutComboBox.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutComboBox
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutComboBox : NSComboBox, NSComboBoxDelegate {

  //····················································································································

  private var mWidth : CGFloat

  //····················································································································

  init (width inWidth : Int) {
    self.mWidth = CGFloat (inWidth)
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false


    self.delegate = self
//    self.isContinuous = true
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    return NSSize (width: self.mWidth, height: s.height)
  }

  //····················································································································

  var mTextDidChange : Optional < (_ inOutlet : AutoLayoutComboBox) -> Void > = nil {
    didSet {
      self.mTextDidChange? (self)
    }
  }

  //····················································································································

  override func textDidChange (_ inNotification : Notification) {
    super.textDidChange (inNotification)
    self.mTextDidChange? (self)
  }


  //····················································································································

//  func controlTextDidEndEditing (_ notification : Notification) {
//    self.mTextDidChange? (self)
//  }

  //····················································································································
  // NSComboBoxDelegate functions
  //····················································································································

  func comboBoxSelectionDidChange (_ inNotification : Notification) {
    DispatchQueue.main.async { self.mTextDidChange? (self) }
  }

  //····················································································································

  func controlTextDidChange (_ inNotification : Notification) {
    self.mTextDidChange? (self)
  }

  //····················································································································

  func controlTextDidEndEditing (_ notification : Notification) {
    self.mTextDidChange? (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

