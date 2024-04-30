//
//  AutoLayoutTextObserverView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutTextObserverView : NSScrollView {

  //································································································

  fileprivate let mTextView = ALB_NSTextView ()
  private let mFontSize : CGFloat

  //································································································

  init (size inSize : EBControlSize) {
    switch inSize {
    case .mini :
      self.mFontSize = NSFont.smallSystemFontSize * 0.8
   case .regular :
      self.mFontSize = NSFont.smallSystemFontSize
    case .small :
      self.mFontSize = NSFont.systemFontSize
   }
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.mTextView.isEditable = false
    self.mTextView.isSelectable = true
    self.mTextView.isVerticallyResizable = true
    self.mTextView.isHorizontallyResizable = true
    self.mTextView.isRichText = false
    self.mTextView.importsGraphics = false
    self.mTextView.allowsImageEditing = false

    let MAX_SIZE : CGFloat = CGFloat.greatestFiniteMagnitude
    self.mTextView.minSize = NSSize (width: 0.0, height: contentSize.height)
    self.mTextView.maxSize = NSSize (width: MAX_SIZE, height: MAX_SIZE)
    self.mTextView.textContainer?.containerSize = NSSize (width: contentSize.width, height: MAX_SIZE)
    self.mTextView.textContainer?.widthTracksTextView = true

    self.drawsBackground = false
    self.documentView = self.mTextView
    self.hasHorizontalScroller = true
    self.hasVerticalScroller = true
    self.automaticallyAdjustsContentInsets = true
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································

  private var mHeight : Int? = nil
  private var mMaxWidth : CGFloat? = nil

  //································································································

  func set (height inHeight : Int) -> Self {
    self.mHeight = inHeight
    self.mTextView.invalidateIntrinsicContentSize ()
    return self
  }

  //································································································

  func set (maxWidth inMaxWidth : Int) -> Self {
    self.mMaxWidth = CGFloat (inMaxWidth)
    self.mTextView.invalidateIntrinsicContentSize ()
    return self
  }

  //································································································

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    if let h = self.mHeight {
      s.height = CGFloat (h)
    }
    if let w = self.mMaxWidth, s.width > w {
      s.width = w
    }
    return s
  }

  //································································································

  final func setNoBackground () -> Self {
    self.mTextView.drawsBackground = false
    return self
  }

  //································································································

  final func setNoVerticalScroller () -> Self {
    self.hasVerticalScroller = false
    return self
  }

  //································································································

  final func setNoHorizontalScroller () -> Self {
    self.hasHorizontalScroller = false
    return self
  }

  //································································································

  final func set (font inFont : NSFont) -> Self {
    self.mTextView.font = inFont
    return self
  }

  //································································································
  // setRedTextColor
  //································································································

  final func setRedTextColor () -> Self {
    self.mTextView.textColor = .red
    return self
  }

  //································································································

  var string : String {
    get { return self.mTextView.string }
    set { self.mTextView.string = newValue }
  }

//  var textStorage : NSTextStorage? { self.mTextView.textStorage }

  //································································································
  //  value binding
  //································································································

  fileprivate func update (from inObject : EBObservableProperty <String>) {
    switch inObject.selection {
    case .empty, .multiple :
      self.mTextView.string = ""
      self.mTextView.invalidateIntrinsicContentSize ()
    case .single (let propertyValue) :
      let currentSelectedRangeValues = self.mTextView.selectedRanges
      self.mTextView.string = propertyValue
      self.mTextView.selectedRanges = currentSelectedRangeValues
      self.mTextView.invalidateIntrinsicContentSize ()
    }
  }

  //································································································

  private var mValueController : EBObservablePropertyController? = nil

  //································································································

  final func bind_observedValue (_ inObject : EBObservableProperty <String>) -> Self {
    self.mValueController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //································································································

  func clear () {
    if let ts = self.mTextView.layoutManager?.textStorage {
      let str = NSAttributedString (string: "", attributes: nil)
      ts.setAttributedString (str)
    }
  }

  //································································································

  func appendAttributedString (_ inAttributedString : NSAttributedString) {
    if let ts = self.mTextView.layoutManager?.textStorage {
      ts.append (inAttributedString)
      let endOfText = NSRange (location: ts.length, length: 0)
      self.mTextView.scrollRangeToVisible (endOfText)
    }
  }

  //································································································

  func appendMessageString (_ inString : String) {
    let attributes : [NSAttributedString.Key : NSObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: self.mFontSize),
      NSAttributedString.Key.foregroundColor : NSColor.black
    ]
    let str = NSAttributedString (string:inString, attributes:attributes)
    self.appendAttributedString (str)
  }

  //································································································

  func appendMessageString (_ inString : String, color : NSColor) {
    let attributes : [NSAttributedString.Key : NSObject] = [
      NSAttributedString.Key.font : NSFont.boldSystemFont (ofSize: self.mFontSize),
      NSAttributedString.Key.foregroundColor : color
    ]
    let str = NSAttributedString (string:inString, attributes: attributes)
    self.appendAttributedString (str)
  }

  //································································································

  func appendCodeString (_ inString : String, color : NSColor) {
    let font = NSFont.userFixedPitchFont (ofSize: self.mFontSize) ?? NSFont.boldSystemFont (ofSize: self.mFontSize)
    let attributes : [NSAttributedString.Key : NSObject] = [
      NSAttributedString.Key.font : font,
      NSAttributedString.Key.foregroundColor : color
    ]
    let str = NSAttributedString (string:inString, attributes: attributes)
    self.appendAttributedString (str)
  }

  //································································································

  func appendErrorString (_ inString : String) {
    self.appendMessageString (inString, color: NSColor.red)
  }

  //································································································

  func appendWarningString (_ inString : String) {
    self.appendMessageString (inString, color: NSColor.orange)
  }

  //································································································

  func appendSuccessString (_ inString : String) {
    self.appendMessageString (inString, color: NSColor.blue)
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
