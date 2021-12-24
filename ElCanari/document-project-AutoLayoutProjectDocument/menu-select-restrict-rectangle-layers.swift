//
//  menu-select-restrict-rectangle-layers.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 24/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class CanariSelectRestrictRectanglesMenu : NSMenu, EBUserClassNameProtocol {

  //····················································································································

//  private var
  //····················································································································
  // INIT
  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (title: "")
    noteObjectAllocation (self)
    let fontSize = NSFont.systemFontSize (for: inSize.cocoaControlSize)
    self.font = NSFont.systemFont (ofSize: fontSize)

    var menuItem = self.addItem (withTitle: "Front Layer", action: #selector (Self.menuItemAction (_:)), keyEquivalent: "")
    menuItem.tag = 0
    menuItem.target = self

    menuItem = self.addItem (withTitle: "Back Layer", action: #selector (Self.menuItemAction (_:)), keyEquivalent: "")
    menuItem.tag = 1
    menuItem.target = self

    menuItem = self.addItem (withTitle: "Inner 1 Layer", action: #selector (Self.menuItemAction (_:)), keyEquivalent: "")
    menuItem.tag = 2
    menuItem.target = self

    menuItem = self.addItem (withTitle: "Inner 2 Layer", action: #selector (Self.menuItemAction (_:)), keyEquivalent: "")
    menuItem.tag = 3
    menuItem.target = self

    menuItem = self.addItem (withTitle: "Inner 3 Layer", action: #selector (Self.menuItemAction (_:)), keyEquivalent: "")
    menuItem.tag = 4
    menuItem.target = self

    menuItem = self.addItem (withTitle: "Inner 4 Layer", action: #selector (Self.menuItemAction (_:)), keyEquivalent: "")
    menuItem.tag = 5
    menuItem.target = self
  }

  //····················································································································

  required init (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // menuItemAction
  //····················································································································

  @objc private func menuItemAction (_ inSender : NSMenuItem) {
  }

  //····················································································································
  //  $populateSubmenus binding
  //····················································································································

  @objc func revealInFinder (_ sender : NSMenuItem) {
    let ws = NSWorkspace.shared
    let title = sender.title
    let ok = ws.open (URL (fileURLWithPath: title))
    if !ok {
      NSSound.beep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot open the \(title) directory"
      alert.informativeText = "This directory does not exist."
      _ = alert.runModal ()
    }
  }

  //····················································································································

  private func updateOutlet (_ object : EBReadOnlyProperty_StringArray) {
    switch object.selection {
    case .empty, .multiple :
      self.removeAllItems ()
    case .single (let itemList) :
      self.removeAllItems ()
      for title in itemList {
        let item = self.addItem (withTitle: title, action: #selector (CanariMenu.revealInFinder(_:)), keyEquivalent: "")
        item.target = self
      }
    }
  }

  //····················································································································

  private var mValueController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_populateSubmenus (_ object : EBReadOnlyProperty_StringArray) {
    self.mValueController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { self.updateOutlet (object) }
    )
  }

  //····················································································································

  final func unbind_populateSubmenus () {
    self.mValueController?.unregister ()
    self.mValueController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
