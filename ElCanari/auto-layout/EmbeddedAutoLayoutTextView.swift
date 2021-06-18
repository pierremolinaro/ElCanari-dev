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

  //--- REQUIRED!!! Declaring theses properties ensures they are retained (required for ElCapitan)
  private let mTextStorage = NSTextStorage () // Subclassing NSTextStorage requires defining string, …
  private let mLayoutManager = EmbeddedLayoutManager ()

  //····················································································································

  init () {
    let textContainer = NSTextContainer (size: NSSize (width: 300, height: 300))
    self.mTextStorage.addLayoutManager (self.mLayoutManager)
    self.mLayoutManager.addTextContainer (textContainer)

    super.init (frame: NSRect (x: 0, y: 0, width: 50, height: 50), textContainer: textContainer)
    noteObjectAllocation (self)
 //   self.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT
//    Swift.print ("init () \(self)")
  }

  //····················································································································

  override init (frame : NSRect, textContainer : NSTextContainer?) { // Required, otherwise run time error
    fatalError ("init(frame:textContainer:) has not been implemented")
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func ebCleanUp () {
    self.layoutManager?.removeTextContainer (at: 0)
    self.mTextStorage.removeLayoutManager (self.mLayoutManager)
    self.textContainer?.layoutManager = nil
    self.textContainer = nil
    super.ebCleanUp ()
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
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------

fileprivate final class EmbeddedLayoutManager : NSLayoutManager, EBUserClassNameProtocol {

  //····················································································································

  override init () {
    super.init ()
    noteObjectAllocation (self)
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

}

//----------------------------------------------------------------------------------------------------------------------

//fileprivate final class EmbeddedTextStorage : NSTextStorage, EBUserClassNameProtocol {
//
//  //····················································································································
//
//  override init (s) {
//    super.init ()
//    noteObjectAllocation (self)
//  }
//
//  //····················································································································
//
//  required init? (coder inCoder : NSCoder) {
//    fatalError ("init(coder:) has not been implemented")
//  }
//
//  //····················································································································
//
//  deinit {
//    noteObjectDeallocation (self)
//  }
//
//  //····················································································································
//
//}

//----------------------------------------------------------------------------------------------------------------------
