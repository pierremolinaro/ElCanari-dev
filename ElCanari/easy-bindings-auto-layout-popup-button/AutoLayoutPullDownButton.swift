//
//  AutoLayoutPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutPullDownButton : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (title inTitle : String, size inSize : EBControlSize) {
    super.init (pullsDown: true, size: inSize.cocoaControlSize)

    self.addItem (withTitle: inTitle)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var mControllerArray = [EBObservablePropertyController] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func add (item inMenuItemDescriptor : AutoLayoutMenuItemDescriptor) -> Self {
    self.addItem (withTitle: inMenuItemDescriptor.title)
    self.lastItem?.target = inMenuItemDescriptor.target
    self.lastItem?.action = inMenuItemDescriptor.selector
  //---
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func enable (itemIndex inIndex : Int, from inObject : MultipleBindingBooleanExpression) {
    let menuItem = self.item (at: inIndex)
    switch inObject.compute () {
    case .empty, .multiple :
      menuItem?.isEnabled = false
    case .single (let v) :
      menuItem?.isEnabled = v
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $items binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mItemsController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_items (_ inObject : EBObservableProperty <StringArray>) -> Self {
    self.mItemsController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func update (from model : EBObservableProperty <StringArray>) {
    switch model.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .single (let titleArray) :
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      while self.numberOfItems > 1 {
        self.removeItem (at: self.numberOfItems - 1)
      }
      for itemTitle in titleArray {
        self.addItem (withTitle: itemTitle)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func populate (from inMenuItems : [MenuItem]) {
    let pullDownButtonMenu = self.menu!
    while pullDownButtonMenu.numberOfItems > 1 {
      pullDownButtonMenu.removeItem (at: pullDownButtonMenu.numberOfItems - 1)
    }
    self.autoenablesItems = false
    self.recursivePopulate (menu: pullDownButtonMenu, from: inMenuItems)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func recursivePopulate (menu inMenu : NSMenu,
                                  from inMenuItems : [MenuItem]) {
    for menuItem in inMenuItems {
      inMenu.addItem (withTitle: menuItem.title, action: nil, keyEquivalent: "")
      if let item = inMenu.item (at: inMenu.numberOfItems - 1) {
        item.representedObject = RepresentedObject (
          userObject: menuItem.userObject,
          action: menuItem.action
        )
        item.action = #selector (Self.pullDownButtonItemAction(_:))
        item.target = self
        if !menuItem.items.isEmpty {
          let subMenu = NSMenu ()
          self.recursivePopulate (menu: subMenu, from: menuItem.items)
          item.submenu = subMenu
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func pullDownButtonItemAction (_ inSender : Any?) {
    if let sender = inSender as? NSMenuItem,
       let representedObject = sender.representedObject as? RepresentedObject {
      representedObject.action? (representedObject.userObject)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private struct RepresentedObject {
    let userObject : Any?
    let action : Action?
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  typealias Action = (_ inUserObject: Any?) -> Void

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  struct MenuItem {
    let title : String
    let userObject : Any?
    let action : Action?
    let items : [MenuItem]
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
