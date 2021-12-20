//
//  CanariChoiceMenu.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/01/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariChoiceMenu : NSMenu, EBUserClassNameProtocol {

  //····················································································································

  required init (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
    self.performInit ()
  }

  //····················································································································

  init () {
    super.init (title: "")
    noteObjectAllocation (self)
    self.performInit ()
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  fileprivate func performInit () {
    for item in self.items {
      item.target = self
      item.action = #selector (menuItemAction (_:))
    }
  }

  //····················································································································

  fileprivate func enableItems (_ inValue : Bool) {
    for item in self.items {
      item.isEnabled = inValue
    }
  }

  //····················································································································

  fileprivate func checkItemAtIndex (_ inIndex : Int) {
    var idx = 0
    for item in self.items {
      item.state = (idx == inIndex) ? .on : .off
      idx += 1
    }
  }

  //····················································································································

  fileprivate func checkItemWithTag (_ inTag : Int) {
    for item in self.items {
      item.state = (item.tag == inTag) ? .on : .off
    }
  }

  //····················································································································

  @objc fileprivate func menuItemAction (_ inSender : Any?) {
  }

  //····················································································································
  //  selectedTag binding
  //····················································································································

  fileprivate func updateOutletFromSelectedTagController (_ object : EBReadOnlyProperty_Int) {
    switch object.selection {
    case .empty, .multiple :
      self.enableItems (false)
    case .single (let v) :
      self.enableItems (true)
      self.checkItemWithTag (v)
    }
  }

  //····················································································································

  private var mSelectedTagController : Controller_CanariChoiceMenu_selectedTag? = nil

  //····················································································································

  final func bind_selectedTag (_ object : EBReadWriteProperty_Int) {
    self.mSelectedTagController = Controller_CanariChoiceMenu_selectedTag (object: object, outlet: self)
  }

  //····················································································································

  final func unbind_selectedTag () {
    self.mSelectedTagController?.unregister ()
    self.mSelectedTagController = nil
  }

  //····················································································································
  //  selectedIndex binding
  //····················································································································

  fileprivate func updateOutletFromSelectedIndexController (_ object : EBReadWriteObservableEnumProtocol) {
    if let v = object.rawValue () {
      self.enableItems (true)
      self.checkItemAtIndex (v)
    }else{
      self.enableItems (false)
    }
  }

  //····················································································································

  private var mSelectedIndexController : Controller_CanariChoiceMenu_selectedIndex? = nil

  //····················································································································

  final func bind_selectedIndex (_ object : EBReadWriteObservableEnumProtocol) {
    self.mSelectedIndexController = Controller_CanariChoiceMenu_selectedIndex (object: object, outlet: self)
  }

  //····················································································································

  final func unbind_selectedIndex () {
    self.mSelectedIndexController?.unregister ()
    self.mSelectedIndexController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariChoiceMenu_selectedTag
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariChoiceMenu_selectedTag : EBObservablePropertyController {

  //····················································································································

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : CanariChoiceMenu

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : CanariChoiceMenu) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateOutletFromSelectedTagController (object) })
    for item in outlet.items {
      item.target = self
      item.action = #selector (Controller_CanariChoiceMenu_selectedTag.updateModel (_:))
    }
  }

  //····················································································································

  @objc fileprivate func updateModel (_ inSender : NSMenuItem) {
    _ = mObject.validateAndSetProp (inSender.tag, windowForSheet: nil)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariChoiceMenu_selectedIndex
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariChoiceMenu_selectedIndex : EBObservablePropertyController {

  //····················································································································

  private let mObject : EBReadWriteObservableEnumProtocol
  private let mOutlet : CanariChoiceMenu

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet : CanariChoiceMenu) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], callBack: { outlet.updateOutletFromSelectedIndexController (object) } )
    for item in outlet.items {
      item.target = self
      item.action = #selector (Controller_CanariChoiceMenu_selectedIndex.updateModel (_:))
    }
  }

  //····················································································································

  @objc fileprivate func updateModel (_ inSender : NSMenuItem) {
    var idx = 0
    for item in self.mOutlet.items {
      if item === inSender {
        self.mObject.setFrom (rawValue: idx)
      }
      idx += 1
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
