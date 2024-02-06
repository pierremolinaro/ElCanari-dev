//
//  AutoLayoutGridView2.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutGridView2 : AutoLayoutVerticalStackView {

  private var mLastView = [NSView?] (repeating: nil, count: 2) // 0 -> left, 1 -> right

  //····················································································································

  final func addFirstBaseLineAligned (left inLeftView : NSView, right inRightView : NSView) -> Self {
   return self.add ([inLeftView, inRightView], alignment: .firstBaseline)
  }

  //····················································································································

  final func addCenterYAligned (left inLeftView : NSView, right inRightView : NSView) -> Self {
   return self.add ([inLeftView, inRightView], alignment: .centerY)
  }

  //····················································································································

  final private func add (_ inViews : [NSView],
                          alignment inAlignement : NSLayoutConstraint.Attribute) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    for i in 0 ..< 2 {
      if let v = self.mLastView [i] {
        let c = NSLayoutConstraint (
          item: inViews [i],
          attribute: .width,
          relatedBy: .equal,
          toItem: v,
          attribute: .width,
          multiplier: 1.0,
          constant: 0.0
        )
        self.addConstraint (c)
      }
      _ = hStack.appendView (inViews [i])
      self.mLastView [i] = inViews [i]
    }
    hStack.alignment = inAlignement
    _ = self.appendView (hStack)
    return self
  }

  //····················································································································

  final func add (single inView : NSView) -> Self {
    _ = self.appendView (inView)
    return self
  }

  //····················································································································

  final func addSeparator () -> Self {
    self.appendHorizontalSeparator ()
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
