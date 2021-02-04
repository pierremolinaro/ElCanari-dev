//
//  ALLabelledSeparator.swift
//  essai-contraintes-sans-ib
//
//  Created by Pierre Molinaro on 29/11/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class ALLabelledSeparator : AutoLayoutHorizontalStackView {

  //····················································································································

  init (_ inTitle : String) {
    super.init (margin: 0)
    let label = ALLabel (inTitle, bold: true)
    self.addView (label, in: .leading)
    let box = NSBox (frame: NSRect ())
    box.boxType = .separator
    self.addView (box, in: .leading)
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  @discardableResult static func make (_ title : String) -> ALLabelledSeparator {
    let b = ALLabelledSeparator (title)
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································
  // SET TEXT color
  //····················································································································

  @discardableResult func setTextColor (_ inTextColor : NSColor) -> Self {
    if self.subviews.count > 0, let textfield = self.subviews [0] as? ALLabel {
      textfield.textColor = inTextColor
    }
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
