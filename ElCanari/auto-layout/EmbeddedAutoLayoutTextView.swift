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

  convenience init () {
    let textStorage = NSTextStorage ()
    let layoutManager = NSLayoutManager ()
    textStorage.addLayoutManager (layoutManager)
    let textContainer = NSTextContainer (size: NSSize (width: 300, height: 300))
    layoutManager.addTextContainer (textContainer)

    self.init (frame: NSRect (x: 0, y: 0, width: 50, height: 50), textContainer: textContainer)
 //   self.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT
//    Swift.print ("init () \(self)")
  }

  //····················································································································

  override init (frame : NSRect, textContainer : NSTextContainer?) { // Required, otherwise run time error
    super.init (frame: frame, textContainer: textContainer)
    noteObjectAllocation (self)
 //   self.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT
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
//    Swift.print ("intrinsicContentSize \(self)")
    let textContainer = self.textContainer!
    let layoutManager = self.layoutManager!
    layoutManager.ensureLayout (for: textContainer)
    return layoutManager.usedRect (for: textContainer).size
  }

  //····················································································································

  override func didChangeText () {
//    Swift.print ("didChangeText \(self)")
    super.didChangeText ()
    self.invalidateIntrinsicContentSize ()
    self.mTextDidChangeCallBack? ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
