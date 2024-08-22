//
//  AutoLayoutVerticalScrollView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 04/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/53239922/nsscrollview-vertical-align
// https://github.com/mattiasjahnke/NSStackView-Scroll
//--------------------------------------------------------------------------------------------------

class AutoLayoutVerticalScrollView : ALB_NSScrollView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (content inDocumentView : NSView) {
    super.init ()

 //   self.contentView = InternalFlippedClipView () // So is aligned to top (instead of bottom)
    self.drawsBackground = false
    self.documentView = inDocumentView
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
    self.automaticallyAdjustsContentInsets = true
//    inDocumentView.setContentHuggingPriority (.defaultLow, for: .horizontal)

//    var constraintArray = [NSLayoutConstraint] ()
//    constraintArray.add (rightOf: self.contentView, equalToRightOf: inDocumentView)
//
//    self.addConstraints (constraintArray)

  //  Swift.print ("Vertical Scroller \(self.verticalScroller)")
//    if let verticalScroller = self.verticalScroller {
//      let c = NSLayoutConstraint (
//        item: self,
//        attribute: .width,
//        relatedBy: .equal,
//        toItem: inDocumentView,
//        attribute: .width,
//        multiplier: 1.0,
//        constant: verticalScroller.frame.size.width
//      )
//      self.addConstraint (c)
//    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func set (width inWidth : Int) -> Self {
//    let c = NSLayoutConstraint (
//      item: self,
//      attribute: .width,
//      relatedBy: .equal,
//      toItem: nil,
//      attribute: .notAnAttribute,
//      multiplier: 1.0,
//      constant: CGFloat (inWidth)
//    )
//    self.addConstraint (c)
//    return self
//  }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

//fileprivate final class InternalFlippedClipView : NSClipView {
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  init () {
//    super.init (frame: .zero)
//    noteObjectAllocation (self)
//    self.pmConfigureForAutolayout (hStretchingResistance: .low, vStrechingResistance: .low)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  required init? (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  deinit {
//    noteObjectDeallocation (self)
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
////  override var isFlipped : Bool { return true }  // So is aligned to top (instead of bottom)
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//}

//--------------------------------------------------------------------------------------------------
