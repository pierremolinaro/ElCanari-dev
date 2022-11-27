//
//  AutoLayoutStaticTextView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/07/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutStaticTextView : NSScrollView {

  //····················································································································

  fileprivate let mTextView = AutoLayoutBase_NSTextView ()

  //····················································································································

  init (drawsBackground inDrawsBackground : Bool,
        horizontalScroller inHorizontalScroller : Bool,
        verticalScroller inVerticalScroller : Bool) {
    super.init (frame: NSRect (x: 0, y: 0, width: 100, height: 100))
    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT

    self.mTextView.isEditable = false
    self.mTextView.isSelectable = true
    self.mTextView.isVerticallyResizable = true
    self.mTextView.isHorizontallyResizable = true
    self.mTextView.isRichText = false
    self.mTextView.importsGraphics = false
    self.mTextView.allowsImageEditing = false
    self.mTextView.drawsBackground = inDrawsBackground
    self.mTextView.string = ""

    let MAX_SIZE : CGFloat = 1_000_000.0 // CGFloat.greatestFiniteMagnitude
    self.mTextView.minSize = NSSize (width: 0.0, height: contentSize.height)
    self.mTextView.maxSize = NSSize (width: MAX_SIZE, height: MAX_SIZE)
    self.mTextView.textContainer?.containerSize = NSSize (width: contentSize.width, height: MAX_SIZE)
    self.mTextView.textContainer?.widthTracksTextView = true
    self.mTextView.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.mTextView.setContentHuggingPriority (.defaultLow, for: .vertical)

    self.drawsBackground = false
    self.documentView = self.mTextView
    self.hasHorizontalScroller = inHorizontalScroller
    self.hasVerticalScroller = inVerticalScroller
    self.automaticallyAdjustsContentInsets = true
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

//  final func set (drawsBackground inDrawsBackground : Bool) -> Self {
//    self.mTextView.drawsBackground = inDrawsBackground
//    return self
//  }

  //····················································································································

//  final func setScroller (horizontal inHorizontal : Bool, vertical inVertical : Bool) -> Self {
//    self.hasHorizontalScroller = inHorizontal
//    self.hasVerticalScroller = inVertical
//    return self
//  }

  //····················································································································

  final func setRedTextColor () -> Self {
    self.mTextView.textColor = .red
    return self
  }

  //····················································································································

  var string : String {
    get { return self.mTextView.string }
    set { self.mTextView.string = newValue }
  }

  var textStorage : NSTextStorage? { self.mTextView.textStorage }

  //····················································································································

  func clear () {
    if let ts = self.mTextView.layoutManager?.textStorage {
      let str = NSAttributedString (string: "", attributes: nil)
      ts.setAttributedString (str)
    }
  }

  //····················································································································

  func appendAttributedString (_ inAttributedString : NSAttributedString) {
    if let ts = self.mTextView.layoutManager?.textStorage {
      ts.append (inAttributedString)
      let endOfText = NSRange (location: ts.length, length: 0)
      self.mTextView.scrollRangeToVisible (endOfText)
    }
  }

  //····················································································································

  func appendMessageString (_ inString : String) {
    let attributes : [NSAttributedString.Key : NSObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize),
      NSAttributedString.Key.foregroundColor : NSColor.black
    ]
    let str = NSAttributedString (string:inString, attributes:attributes)
    self.appendAttributedString (str)
  }

  //····················································································································

  func appendMessageString (_ inString : String, color : NSColor) {
    let attributes : [NSAttributedString.Key : NSObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize),
      NSAttributedString.Key.foregroundColor : color
    ]
    let str = NSAttributedString (string:inString, attributes: attributes)
    self.appendAttributedString (str)
  }

  //····················································································································

  func appendCodeString (_ inString : String, color : NSColor) {
    let font = NSFont.userFixedPitchFont (ofSize: NSFont.smallSystemFontSize) ?? NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
    let attributes : [NSAttributedString.Key : NSObject] = [
      NSAttributedString.Key.font : font,
      NSAttributedString.Key.foregroundColor : color
    ]
    let str = NSAttributedString (string: inString, attributes: attributes)
    self.appendAttributedString (str)
  }

  //····················································································································

  func appendErrorString (_ inString : String) {
    self.appendMessageString (inString, color: .red)
  }

  //····················································································································

  func appendWarningString (_ inString : String) {
    self.appendMessageString (inString, color: .orange)
  }

  //····················································································································

  func appendSuccessString (_ inString : String) {
    self.appendMessageString (inString, color: .blue)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
