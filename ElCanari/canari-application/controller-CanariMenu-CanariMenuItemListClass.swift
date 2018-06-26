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
//    mObject.addEBObserver (self)
  }

  //····················································································································

  final override func sendUpdateEvent () {
    switch mObject.prop {
    case .noSelection, .multipleSelection :
      mOutlet.removeAllItems ()
    case .singleSelection (let itemList) :
      mOutlet.removeAllItems ()
      for title in itemList.items {
        let item = mOutlet.addItem (withTitle: title, action: #selector (Controller_CanariMenu_CanariMenuItemListClass.revealInFinder(_:)), keyEquivalent: "")
        item.target = self
      }
    }
  }

  //····················································································································

  func revealInFinder (_ sender : NSMenuItem) {
    let title = sender.title
    let ws = NSWorkspace.shared ()
    let ok = ws.openFile (title)
    if !ok {
      NSBeep ()
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
