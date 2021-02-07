//
//  AutoLayoutTwoColumnsGridView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutTwoColumnsGridView : AutoLayoutVerticalStackView {

  private var mLastRightView : NSView? = nil
  private var mLastLeftView : NSView? = nil

  //····················································································································
  //   INIT
  //····················································································································

  override init () {
    super.init ()
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  func add (left inLeftView : NSView, right inRightView : NSView) -> Self {
    if let lastLeftView = self.mLastLeftView {
      let c = NSLayoutConstraint (
        item: inLeftView,
        attribute: .width,
        relatedBy: .equal,
        toItem: lastLeftView,
        attribute: .width,
        multiplier: 1.0,
        constant: 0.0
      )
      self.addConstraint (c)
    }
    if let lastRightView = self.mLastRightView {
      let c = NSLayoutConstraint (
        item: inRightView,
        attribute: .width,
        relatedBy: .equal,
        toItem: lastRightView,
        attribute: .width,
        multiplier: 1.0,
        constant: 0.0
      )
      self.addConstraint (c)
    }
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (inLeftView)
    hStack.appendView (inRightView)
    self.appendView (hStack)
    self.mLastLeftView = inLeftView
    self.mLastRightView = inRightView
    return self
  }

  //····················································································································

  func add (single inView : NSView) -> Self {
    self.appendView (inView)
    return self
  }

  //····················································································································

  func separator () -> Self {
    self.appendView (AutoLayoutSeparator ())
    return self
  }

  //····················································································································

  func separator (withTitle inTitle : String) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (AutoLayoutStaticLabel (title: inTitle, bold: true, small: true))
    hStack.appendView (AutoLayoutSeparator ())
    self.appendView (hStack)
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
