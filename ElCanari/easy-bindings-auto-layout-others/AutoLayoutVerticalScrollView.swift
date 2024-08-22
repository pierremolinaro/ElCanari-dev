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
// https://dalzhim.github.io/2015/07/07/auto-layout-and-nsscrollview/
//--------------------------------------------------------------------------------------------------

class AutoLayoutVerticalScrollView : ALB_NSScrollView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (content inDocumentView : NSView) {
    super.init ()

    var constraintArray = [NSLayoutConstraint] ()

    self.contentView = InternalFlippedClipView () // So is aligned to top (instead of bottom)
    constraintArray.add (leftOf: self, equalToLeftOf: self.contentView)
    constraintArray.add (rightOf: self, equalToRightOf: self.contentView)
    constraintArray.add (topOf: self, equalToTopOf: self.contentView)
    constraintArray.add (bottomOf: self, equalToBottomOf: self.contentView)

    self.documentView = inDocumentView
    constraintArray.add (leftOf: inDocumentView, equalToLeftOf: self.contentView)
    constraintArray.add (rightOf: inDocumentView, equalToRightOf: self.contentView)
    constraintArray.add (topOf: inDocumentView, equalToTopOf: self.contentView)

    self.addConstraints (constraintArray)

    self.drawsBackground = false
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
    self.automaticallyAdjustsContentInsets = true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate final class InternalFlippedClipView : NSClipView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false // Only do that
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var isFlipped : Bool { true }  // So is aligned to top (instead of bottom)

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
