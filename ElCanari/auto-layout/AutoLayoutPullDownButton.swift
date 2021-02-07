//
//  AutoLayoutPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutPullDownButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (title inTitle : String, small inSmall : Bool) {
    super.init (frame: NSRect (), pullsDown: true)
    noteObjectAllocation (self)
 //   self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    self.bezelStyle = .roundRect
    self.addItem (withTitle: inTitle)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func ebCleanUp () {
//    self.mSelectedTagController?.unregister ()
//    self.mSelectedTagController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  func add (item inMenuItemDescriptor : AutoLayoutMenuItemDescriptor) -> Self {
    self.addItem (withTitle: "")
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    let attributedTitle = NSAttributedString (string: inMenuItemDescriptor.title, attributes: textAttributes)
    self.lastItem?.attributedTitle = attributedTitle
    self.lastItem?.target = inMenuItemDescriptor.target
    self.lastItem?.action = inMenuItemDescriptor.selector
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
