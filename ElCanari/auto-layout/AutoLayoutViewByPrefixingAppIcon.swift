//
//  AutoLayoutViewByPrefixingAppIcon.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutViewByPrefixingAppIcon : AutoLayoutHorizontalStackView {

  //····················································································································

  init (prefixedView inView : NSView) {
    super.init ()
    let vStack = AutoLayoutVerticalStackView ().set (margins: 20)
    vStack.appendFlexibleSpace ()
    vStack.appendView (AutoLayoutApplicationImage ())
    vStack.appendFlexibleSpace ()
    self.appendView (vStack)
    self.appendView (inView)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
