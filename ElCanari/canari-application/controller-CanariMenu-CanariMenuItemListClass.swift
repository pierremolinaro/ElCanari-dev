//
//  controller-CanariMenu-CanariMenuItemListClass.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/11/2016.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariMenu_CanariMenuItemListClass
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariMenu_CanariMenuItemListClass : EBSimpleController {

  private let mObject : EBReadOnlyProperty_CanariMenuItemListClass
  private let mOutlet : CanariMenu

  //····················································································································

  init (object : EBReadOnlyProperty_CanariMenuItemListClass, outlet : CanariMenu) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object], outlet: outlet)
    self.eventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch mObject.prop {
    case .empty, .multiple :
      mOutlet.removeAllItems ()
    case .single (let itemList) :
      mOutlet.removeAllItems ()
      for title in itemList.items {
        let item = mOutlet.addItem (withTitle: title, action: #selector (Controller_CanariMenu_CanariMenuItemListClass.revealInFinder(_:)), keyEquivalent: "")
        item.target = self
      }
    }
  }

  //····················································································································

  func revealInFinder (_ sender : NSMenuItem) {
    #if swift(>=4)
      let ws = NSWorkspace.shared
    #else
      let ws = NSWorkspace.shared ()
    #endif
    let title = sender.title
    let ok = ws.openFile (title)
    if !ok {
      #if swift(>=4)
        __NSBeep ()
      #else
        NSBeep ()
      #endif
      let alert = NSAlert ()
      alert.messageText = "Cannot open the \(title) directory"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = "This directory does not exist."
      alert.runModal ()
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
