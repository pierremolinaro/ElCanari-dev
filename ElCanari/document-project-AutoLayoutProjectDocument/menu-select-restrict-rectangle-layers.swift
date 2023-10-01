//
//  menu-select-restrict-rectangle-layers.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 24/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor final class CanariSelectRestrictRectanglesMenu : NSMenu {

  //····················································································································

  private var mValue = 0

  //····················································································································
  // INIT
  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (title: "")
    noteObjectAllocation (self)
    let fontSize = NSFont.systemFontSize (for: inSize.cocoaControlSize)
    self.font = NSFont.systemFont (ofSize: fontSize)

    self.autoenablesItems = false

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
    let value = self.mValue ^ (1 << inSender.tag)
    self.mLayersController?.updateModel (withValue: value)
  }

  //····················································································································
  //  $layers binding
  //····················································································································

  private func updateOutlet (_ object : EBObservableProperty <Int>) {
    switch object.selection {
    case .empty, .multiple :
      for item in self.items {
        item.isEnabled = false
        item.state = .off
      }
    case .single (let value) :
      self.mValue = value
      var v = value
      for item in self.items {
        let flag = (v & 1) != 0
        item.state = flag ? .on : .off
        if value.nonzeroBitCount <= 1 {
          item.isEnabled = !flag
        }else{
          item.isEnabled = true
        }
        v >>= 1
      }
    }
  }

  //····················································································································

  private var mLayersController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_layers (_ object : EBReadWriteProperty_Int) {
    self.mLayersController = EBGenericReadWritePropertyController <Int> (
      observedObject: object,
      callBack: { [weak self] in self?.updateOutlet (object) }
    )
  }

  //····················································································································

  final func unbind_layers () {
    self.mLayersController?.unregister ()
    self.mLayersController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
