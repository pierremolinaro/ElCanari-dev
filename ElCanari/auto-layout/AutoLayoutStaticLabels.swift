//
//  AutoLayoutStaticLabels.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutStaticLabels
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutStaticLabels : AutoLayoutHorizontalStackView {

  //····················································································································

  init (left inLeft : String, right inRight : String, bold inBold : Bool, small inSmall : Bool) {
    super.init ()
    self.appendView (AutoLayoutStaticLabel (title: inLeft, bold: inBold, small: inSmall))
    self.appendView (AutoLayoutFlexibleSpace ())
    self.appendView (AutoLayoutStaticLabel (title: inRight, bold: inBold, small: inSmall))
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
