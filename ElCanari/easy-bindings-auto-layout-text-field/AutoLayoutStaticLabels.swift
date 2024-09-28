//
//  AutoLayoutStaticLabels.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   AutoLayoutStaticLabels
//--------------------------------------------------------------------------------------------------

final class AutoLayoutStaticLabels : AutoLayoutHorizontalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (left inLeft : String, right inRight : String, bold inBold : Bool, size inSize : EBControlSize) {
    super.init ()
    _ = self.appendView (AutoLayoutStaticLabel (title: inLeft, bold: inBold, size: inSize, alignment: .left).notExpandableWidth ())
      .appendFlexibleSpace ()
      .appendView (AutoLayoutStaticLabel (title: inRight, bold: inBold, size: inSize, alignment: .right).notExpandableWidth ())
      .set (spacing: .zero)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
