//
//  CanariComboBox.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 21/04/2019.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class CanariComboBox : NSComboBox, EBUserClassNameProtocol, NSComboBoxDelegate {

  //····················································································································

  var textDidChangeCallBack : Optional < (_ outlet : CanariComboBox) -> Void > = nil {
    didSet {
      self.textDidChangeCallBack? (self)
    }
  }

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    self.delegate = self
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
    self.delegate = self
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // NSComboBoxDelegate functions
  //····················································································································

  @objc func controlTextDidChange (_ inNotification : Notification) {
    // Swift.print ("CanariComboBox, controlTextDidChange '\(self.stringValue)' '\(String(describing: self.objectValueOfSelectedItem))'")
    self.textDidChangeCallBack? (self)
  }

  //····················································································································

  func controlTextDidEndEditing (_ notification : Notification) {
    // Swift.print ("CanariComboBox, controlTextDidEndEditing '\(self.stringValue)' '\(String(describing: self.objectValueOfSelectedItem))'")
    self.textDidChangeCallBack? (self)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
