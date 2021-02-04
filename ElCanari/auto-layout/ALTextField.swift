//
//  ALTextField.swift
//  essai-custom-stack-view
//
//  Created by Pierre Molinaro on 20/10/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//
// https://stackoverflow.com/questions/14643180/nstextfield-width-and-autolayout
// https://stackoverflow.com/questions/1992950/nsstring-sizewithattributes-content-rect/1993376#1993376
// https://stackoverflow.com/questions/35356225/nstextfieldcells-cellsizeforbounds-doesnt-match-wrapping-behavior
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class ALTextField : NSTextField, NSTextFieldDelegate {

  //····················································································································

  private var mWidth : CGFloat

  //····················································································································

  init (_ inWidth : CGFloat) {
    self.mWidth = inWidth
    super.init (frame: NSRect ())
    self.delegate = self
    self.stringValue = "textfield"
    self.usesSingleLineMode =  false
    self.lineBreakMode = .byCharWrapping
    self.cell?.wraps = true
    self.cell?.isScrollable = false
    self.maximumNumberOfLines = 10
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // INTRINSIC CONTENT SIZE
  //····················································································································

   override var intrinsicContentSize : NSSize {
   //--- Forces updating from the field editor
     self.validateEditing ()
   //--- Compute size that fits
     let preferredSize = NSSize (width: 10_000.0, height: 10_000.0)
     var s = self.sizeThatFits (preferredSize)
     s.width = self.mWidth
   //---
     return s
   }

  //····················································································································

  func controlTextDidChange (_ inNotification : Notification) {
    // Swift.print ("controlTextDidChange")
    self.invalidateIntrinsicContentSize ()
  }

  //····················································································································
  // VERTICAL ALIGNMENT
  //····················································································································

//  fileprivate var mVerticalAlignment = VerticalAlignment.lastBaseline
//
//  //····················································································································
//
//  @discardableResult func setVerticalAlignment (_ inAlignment : VerticalAlignment) -> Self {
//    self.mVerticalAlignment = inAlignment
//    return self
//  }

  //····················································································································

//  override func verticalAlignment () -> VerticalAlignment { return self.mVerticalAlignment }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

