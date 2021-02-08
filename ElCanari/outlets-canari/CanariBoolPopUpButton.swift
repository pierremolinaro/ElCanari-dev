//----------------------------------------------------------------------------------------------------------------------
//
//  CanariBoolPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/01/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class CanariBoolPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  private func populatePopUpButton () {
    self.removeAllItems ()
    switch self.mModel {
    case .empty :
      self.addItem (withTitle: "No Selection")
      self.enableFromValueBinding (false)
    case .multiple :
      self.addItem (withTitle: "Multiple Selection")
      self.addItem (withTitle: self.mItem0Title)
      self.lastItem?.tag = 0
      self.lastItem?.target = self
      self.lastItem?.action = #selector (Self.popUpButtonSelectionDidChange (_:))
      self.addItem (withTitle: self.mItem1Title)
      self.lastItem?.tag = 1
      self.lastItem?.target = self
      self.lastItem?.action = #selector (Self.popUpButtonSelectionDidChange (_:))
      self.selectItem (at: 0)
      self.enableFromValueBinding (true)
    case .single (let v) :
      self.addItem (withTitle: self.mItem0Title)
      self.lastItem?.tag = 0
      self.lastItem?.target = self
      self.lastItem?.action = #selector (Self.popUpButtonSelectionDidChange (_:))
      self.addItem (withTitle: self.mItem1Title)
      self.lastItem?.tag = 1
      self.lastItem?.target = self
      self.lastItem?.action = #selector (Self.popUpButtonSelectionDidChange (_:))
      self.selectItem (at: v ? 1 : 0)
      self.enableFromValueBinding (true)
    }
  }

  //····················································································································

  @objc private func popUpButtonSelectionDidChange (_ inSender : NSMenuItem) {
    let v = inSender.tag != 0
    _ = self.mValueController?.updateModel (withCandidateValue: v, windowForSheet: self.window)
  }

  //····················································································································
  //  value binding
  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <Bool>? = nil
  private var mItem0Title = ""
  private var mItem1Title = ""
  private var mModel = EBSelection <Bool>.empty

  //····················································································································

  func bind_value (_ inObject : EBGenericReadWriteProperty <Bool>,
                   item0 inItem0Title : String,
                   item1 inItem1Title : String) {
    self.mItem0Title = inItem0Title
    self.mItem1Title = inItem1Title
    self.mValueController = EBGenericReadWritePropertyController <Bool> (
      observedObject: inObject,
      callBack: { [weak self] in
        self?.mModel = inObject.selection
        self?.populatePopUpButton ()
      }
    )
  }

  //····················································································································

  func unbind_value () {
    self.mValueController?.unregister ()
    self.mValueController = nil
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
