//
//  EBChoiceMenu.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 26/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class EBChoiceMenu : NSMenu, EBUserClassNameProtocol {

  //····················································································································

  required init (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  init () {
    super.init (title: "")
    noteObjectAllocation (self)

//    var idx = 0
//    for item in self.items {
//      item.target = self
//      item.action = #selector (Self.menuItemAction (_:))
//      item.tag = idx
//      idx += 1
//    }
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
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

//  @objc fileprivate func menuItemAction (_ inSender : NSMenuItem) {
//    self.mSelectedIndexController?.updateModel (inSender)
//  }

  //····················································································································
  //  selectedIndex binding
  //····················································································································

  fileprivate func updateOutletFromSelectedIndexController (_ inObject : EBReadWriteObservableEnumProtocol) {
    if let v = inObject.rawValue () {
      self.enableItems (true)
      self.checkItemAtIndex (v)
    }else{
      self.enableItems (false)
    }
  }

  //····················································································································

  private var mSelectedIndexController : Controller_EBChoiceMenu_selectedIndex? = nil

  //····················································································································

  final func bind_selectedIndex (_ object : EBReadWriteObservableEnumProtocol) {
    self.mSelectedIndexController = Controller_EBChoiceMenu_selectedIndex (object: object, outlet: self)
  }

  //····················································································································

  final func unbind_selectedIndex () {
    self.mSelectedIndexController?.unregister ()
    self.mSelectedIndexController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_EBChoiceMenu_selectedIndex
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_EBChoiceMenu_selectedIndex : EBObservablePropertyController {

  //····················································································································

  private let mObject : EBReadWriteObservableEnumProtocol
  private let mOutlet : EBChoiceMenu

  //····················································································································

  init (object : EBReadWriteObservableEnumProtocol, outlet : EBChoiceMenu) {
    self.mObject = object
    self.mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateOutletFromSelectedIndexController (object) } )
    var idx = 0
    for item in outlet.items {
      item.target = self
      item.action = #selector (Self.updateModelAction (_:))
      item.tag = idx
      idx += 1
    }
  }

  //····················································································································

  @objc fileprivate func updateModelAction (_ inSender : NSMenuItem) {
    self.mObject.setFrom (rawValue: inSender.tag)
//    var idx = 0
//    for item in self.mOutlet.items {
//      if item === inSender {
//        self.mObject.setFrom (rawValue: idx)
//      }
//      idx += 1
//    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————