//
//  AutoLayoutComboBox.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutComboBox
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutComboBox : NSComboBox, EBUserClassNameProtocol, NSComboBoxDelegate {

  //····················································································································

  private var mWidth : CGFloat

  //····················································································································

  init (width inWidth : Int) {
    self.mWidth = CGFloat (inWidth)
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

//    self.delegate = self
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

  func controlTextDidEndEditing (_ notification : Notification) {
    self.mTextDidChange? (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
