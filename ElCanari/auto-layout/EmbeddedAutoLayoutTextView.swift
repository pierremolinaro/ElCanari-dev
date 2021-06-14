//----------------------------------------------------------------------------------------------------------------------
//
//  EmbeddedAutoLayoutTextView.swift
//
//  Created by Pierre Molinaro on 28/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/11237622/using-autolayout-with-expanding-nstextviews
//----------------------------------------------------------------------------------------------------------------------

final class EmbeddedAutoLayoutTextView : NSTextView, EBUserClassNameProtocol {

  //····················································································································

  var mTextDidChangeCallBack : Optional < () -> Void > = nil

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect, textContainer : NSTextContainer?) { // Required, otherwise run time error
    super.init (frame: frame, textContainer: textContainer)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    let textContainer = self.textContainer!
    let layoutManager = self.layoutManager!
    layoutManager.ensureLayout (for: textContainer)
    return layoutManager.usedRect (for: textContainer).size
  }

  //····················································································································

  override func didChangeText () {
    super.didChangeText ()
    self.invalidateIntrinsicContentSize ()
    self.mTextDidChangeCallBack? ()
 //   _ = self.mValueController?.updateModel (withCandidateValue: self.string, windowForSheet: self.window)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
