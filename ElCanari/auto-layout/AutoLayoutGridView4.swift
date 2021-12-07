//
//  AutoLayoutGridView4.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 07/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutGridView4 : AutoLayoutVerticalStackView {

  private var mLastView = [NSView?] (repeating: nil, count: 4) // 0 -> left, 3 -> right

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

  final func addFirstBaseLineAligned (first inView0 : NSView,
                                      second inView1 : NSView,
                                      third inView2 : NSView,
                                      fourth inView3 : NSView) -> Self {
    return self.add ([inView0, inView1, inView2, inView3], alignment: .firstBaseline)
  }

  //····················································································································

  final func addCenterYAligned (first inView0 : NSView,
                                second inView1 : NSView,
                                third inView2 : NSView,
                                fourth inView3 : NSView) -> Self {
    return self.add ([inView0, inView1, inView2, inView3], alignment: .centerY)
  }

  //····················································································································

  final private func add (_ inViews : [NSView],
                          alignment inAlignement : NSLayoutConstraint.Attribute) -> Self {
    let hStack = AutoLayoutHorizontalStackView ()
    for i in 0 ..< 4 {
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
      hStack.appendView (inViews [i])
      self.mLastView [i] = inViews [i]
    }
    hStack.alignment = inAlignement
    self.appendView (hStack)
    return self
  }

  //····················································································································

  final func add (single inView : NSView) -> Self {
    self.appendView (inView)
    return self
  }

  //····················································································································

  final func addSeparator () -> Self {
    self.appendHorizontalSeparator ()
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
