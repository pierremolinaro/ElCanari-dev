//
//  AutoLayoutGridView2.swift
//  essai-gridview
//
//  Created by Pierre Molinaro on 01/11/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutGridView2 : AutoLayoutVerticalStackView {

  //····················································································································

  private var mRows = [(NSView, NSView)] () // left, right

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // OBSOLETE FUNCTION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addFirstBaseLineAligned (left inLeftView : NSView, right inRightView : NSView) -> Self { // §
   return self.append (left: inLeftView, right: inRightView)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addCenterYAligned (left inLeftView : NSView, right inRightView : NSView) -> Self { // §
   return self.append (left: inLeftView, right: inRightView)
//   return self.add ([inLeftView, inRightView], alignment: .centerY)
  }

  //····················································································································

  final func append (left inLeftView : NSView, right inRightView : NSView) -> Self {
    let hStack = AutoLayoutHorizontalStackView (horizontal: .fill, vertical: .fill)
      .set (spacing: self.mHorizontalSpacing)
      .appendView (inLeftView)
      .appendView (inRightView)
    self.mRows.append ((inLeftView, inRightView))
    self.addSubview (hStack)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func add (single inView : NSView) -> Self {
    _ = self.appendView (inView)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addSeparator () -> Self {
    self.appendHorizontalSeparator ()
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------

  private var mHorizontalSpacing : Int = 12

  //--------------------------------------------------------------------------------------------------------------------

  final func set (horizontalSpacing inSpacing : Int) -> Self {
    self.mHorizontalSpacing = inSpacing
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //--------------------------------------------------------------------------------------------------------------------
  //  Constraints
  //--------------------------------------------------------------------------------------------------------------------

  private var mConstraints = [NSLayoutConstraint] ()

  //--------------------------------------------------------------------------------------------------------------------

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Constraints for colum alignment
    var optionalLastRow : (NSView, NSView)? = nil
    for row in self.mRows {
      if let lastRow = optionalLastRow {
        self.mConstraints.add (widthOf: lastRow.0, equalToWidthOf: row.0)
        self.mConstraints.add (widthOf: lastRow.1, equalToWidthOf: row.1)
      }
      optionalLastRow = row
    }
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
  }

  //--------------------------------------------------------------------------------------------------------------------

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
