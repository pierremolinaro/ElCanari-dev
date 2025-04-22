//
//  CanariChoiceMenu.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class CanariChoiceMenu : NSMenu {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (title: "")
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func enableItems (_ inValue : Bool) {
    for item in self.items {
      item.isEnabled = inValue
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func checkItemAtIndex (_ inIndex : Int) {
    var idx = 0
    for item in self.items {
      item.state = (idx == inIndex) ? .on : .off
      idx += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  selectedIndex binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor fileprivate func updateOutletFromSelectedIndexController (_ inObject : any EBEnumReadWriteObservableProtocol) {
    switch inObject.rawSelection {
    case .single (let rawValue) :
      self.enableItems (true)
      self.checkItemAtIndex (rawValue)
    case .empty, .multiple :
      self.enableItems (false)
    }

//    if let v = inObject.rawValue () {
//      self.enableItems (true)
//      self.checkItemAtIndex (v)
//    }else{
//      self.enableItems (false)
//    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedIndexController : Controller_CanariChoiceMenu_selectedIndex? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor final func bind_selectedIndex (_ object : any EBEnumReadWriteObservableProtocol) {
    self.mSelectedIndexController = Controller_CanariChoiceMenu_selectedIndex (object: object, outlet: self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_selectedIndex () {
//    self.mSelectedIndexController?.unregister ()
//    self.mSelectedIndexController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
//   Controller_CanariChoiceMenu_selectedIndex
//--------------------------------------------------------------------------------------------------

@MainActor final class Controller_CanariChoiceMenu_selectedIndex : EBObservablePropertyController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mObject : any EBEnumReadWriteObservableProtocol

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (object : any EBEnumReadWriteObservableProtocol,
        outlet inOutlet : CanariChoiceMenu) {
    self.mObject = object
    super.init (observedObjects: [object], callBack: { [weak inOutlet] in inOutlet?.updateOutletFromSelectedIndexController (object) } )
    var idx = 0
    for item in inOutlet.items {
      item.target = self
      item.action = #selector (Self.updateModelAction (_:))
      item.tag = idx
      idx += 1
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc fileprivate func updateModelAction (_ inSender : NSMenuItem) {
    self.mObject.setFrom (rawValue: inSender.tag)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
