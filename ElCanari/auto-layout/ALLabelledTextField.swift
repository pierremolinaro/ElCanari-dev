//
//  ALLabelledTextField.swift
//  essai-contraintes-sans-ib
//
//  Created by Pierre Molinaro on 29/11/2020.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class ALLabelledTextField : AutoLayoutHorizontalStackView {

  //····················································································································

  init (_ inTitle : String, _ inTextfieldWidth : CGFloat, spaceBefore inSpaceBefore : Bool) {
    super.init (margin: 0)
    if inSpaceBefore {
      self.addView (AutoLayoutFlexibleSpaceView (), in: .leading)
    }
    let label = ALLabel (inTitle).setTitleAlignment (.right)
    self.addView (label, in: .leading)
    let textfield = ALTextField (inTextfieldWidth)
    self.addView (textfield, in: .leading)
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  //····················································································································

  @discardableResult static func make (_ inTitle : String, _ inTextFieldWidth : CGFloat, spaceBefore inSpaceBefore : Bool) -> ALLabelledTextField {
    let b = ALLabelledTextField (inTitle, inTextFieldWidth, spaceBefore: inSpaceBefore)
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································
  // SET TEXT color
  //····················································································································

  @discardableResult func setTextColor (_ inTextColor : NSColor) -> Self {
    if self.subviews.count > 0, let textfield = self.subviews [0] as? ALTextField {
      textfield.textColor = inTextColor
    }
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
