//——————————————————————————————————————————————————————————————————————————————————————————————————
//
//  AutoLayoutBase-NSTextView.swift
//
//  Created by Pierre Molinaro on 28/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
// https://stackoverflow.com/questions/11237622/using-autolayout-with-expanding-nstextviews
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutBase_NSTextView : NSTextView {

  //····················································································································

  final var mTextDidChangeCallBack : Optional < () -> Void > = nil

  //--- REQUIRED!!! Declaring theses properties ensures they are retained (required for ElCapitan)
  private final let mTextStorage = NSTextStorage () // Subclassing NSTextStorage requires defining string, …
  private final let mLayoutManager = EmbeddedLayoutManager ()

  //····················································································································
  // https://developer.apple.com/library/archive/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextSystemArchitecture/ArchitectureOverview.html#//apple_ref/doc/uid/TP40009459-CH7-CJBJHGAG
  //····················································································································

  init () {
    let textContainer = NSTextContainer (size: NSSize (width: 300, height: 300))
    self.mTextStorage.addLayoutManager (self.mLayoutManager)
    self.mLayoutManager.addTextContainer (textContainer)

    super.init (frame: .zero, textContainer: textContainer)
//    super.init (frame: NSRect (x: 0, y: 0, width: 50, height: 50), textContainer: textContainer)
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

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // https://stackoverflow.com/questions/11237622/using-autolayout-with-expanding-nstextviews
  //····················································································································

  override final var intrinsicContentSize : NSSize {
    let textContainer = self.textContainer!
    let layoutManager = self.layoutManager!
    layoutManager.ensureLayout (for: textContainer)
    return layoutManager.usedRect (for: textContainer).size
  }

  //····················································································································

  override final func didChangeText () {
    super.didChangeText ()
    self.invalidateIntrinsicContentSize ()
    self.mTextDidChangeCallBack? ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class EmbeddedLayoutManager : NSLayoutManager {

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

//——————————————————————————————————————————————————————————————————————————————————————————————————
