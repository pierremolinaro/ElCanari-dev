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

    self.drawsBackground = false
    self.hasHorizontalScroller = false
    self.hasVerticalScroller = true
    self.automaticallyAdjustsContentInsets = true

    self.contentView = InternalFlippedClipView () // So is aligned to top (instead of bottom)
    self.documentView = inDocumentView
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Constraints
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mConstraints = [NSLayoutConstraint] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func updateConstraints () {
  //--- Remove all constraints
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll (keepingCapacity: true)
  //--- Build constraints
//    self.mConstraints.add (leftOf: self, equalToLeftOf: self.contentView)
//    self.mConstraints.add (rightOf: self, equalToRightOf: self.contentView)
//    self.mConstraints.add (topOf: self, equalToTopOf: self.contentView)
//    self.mConstraints.add (bottomOf: self, equalToBottomOf: self.contentView)

    if let documentView = self.documentView {
      self.mConstraints.add (x: documentView.leftAnchor, equalTo: self.contentView.leftAnchor)
      self.mConstraints.add (x: documentView.rightAnchor, equalTo: self.contentView.rightAnchor)
      self.mConstraints.add (y: documentView.topAnchor, equalTo: self.contentView.topAnchor)
    }
  //--- Apply constaints
    self.addConstraints (self.mConstraints)
  //--- This should the last instruction: call super method
    super.updateConstraints ()
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
//    self.translatesAutoresizingMaskIntoConstraints = false // Only do that
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
