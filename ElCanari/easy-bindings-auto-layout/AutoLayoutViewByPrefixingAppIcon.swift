//
//  AutoLayoutViewByPrefixingAppIcon.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutViewByPrefixingAppIcon : AutoLayoutHorizontalStackView {

  //····················································································································

  init (prefixedView inView : NSView) {
    super.init ()
    let vStack = AutoLayoutVerticalStackView ().set (margins: 20)
    _ = vStack.appendFlexibleSpace ()
    _ = vStack.appendView (AutoLayoutApplicationImage ())
    _ = vStack.appendFlexibleSpace ()
    _ = self.appendView (vStack)
    _ = self.appendView (inView)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
