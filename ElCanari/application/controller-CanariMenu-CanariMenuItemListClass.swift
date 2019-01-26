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
    super.init (observedObjects:[object])
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

  @objc func revealInFinder (_ sender : NSMenuItem) {
    let ws = NSWorkspace.shared
    let title = sender.title
    let ok = ws.openFile (title)
    if !ok {
      __NSBeep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot open the \(title) directory"
      alert.informativeText = "This directory does not exist."
      _ = alert.runModal ()
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
