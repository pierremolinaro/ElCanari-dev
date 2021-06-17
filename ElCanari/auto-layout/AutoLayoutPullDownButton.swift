//
//  AutoLayoutPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutPullDownButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (title inTitle : String, small inSmall : Bool) {
    super.init (frame: NSRect (), pullsDown: true)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.controlSize = inSmall ? .small : .regular
    self.bezelStyle = BUTTON_STYLE
    self.autoenablesItems = false
    self.addItem (withTitle: inTitle)
    let fontSize = inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: fontSize)
    ]
    let attributedTitle = NSAttributedString (string: inTitle, attributes: textAttributes)
    self.lastItem?.attributedTitle = attributedTitle
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  var mControlerArray = [EBReadOnlyPropertyController] ()

  //····················································································································

  override func ebCleanUp () {
    for controller in self.mControlerArray {
      controller.unregister ()
//    self.mSelectedTagController = nil
    }
    super.ebCleanUp ()
  }

  //····················································································································

  final func add (item inMenuItemDescriptor : AutoLayoutMenuItemDescriptor) -> Self {
    self.addItem (withTitle: inMenuItemDescriptor.title)
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    let attributedTitle = NSAttributedString (string: inMenuItemDescriptor.title, attributes: textAttributes)
    self.lastItem?.attributedTitle = attributedTitle
    self.lastItem?.target = inMenuItemDescriptor.target
    self.lastItem?.action = inMenuItemDescriptor.selector
  //--- Add Enabled binding ?
    if inMenuItemDescriptor.observedObjects.count > 0 {
      let lastItem = self.lastItem
      let controller = EBReadOnlyPropertyController (
        observedObjects: inMenuItemDescriptor.observedObjects,
        callBack: { [weak self] in self?.enable (item: lastItem, from: inMenuItemDescriptor.computeFunction ()) }
      )
      self.mControlerArray.append (controller)
    }
  //---
    return self
  }

  //····················································································································

  fileprivate func enable (item inMenuItem : NSMenuItem?, from inObject : EBSelection <Bool>) {
    switch inObject {
    case .empty, .multiple :
      inMenuItem?.isEnabled = false
    case .single (let v) :
      inMenuItem?.isEnabled = v
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
