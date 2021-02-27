//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutTextView : NSScrollView, EBUserClassNameProtocol {

  //····················································································································

  fileprivate let mTextView = EmbbeddedAutoLayoutTextView ()

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.mTextView.isEditable = true
    self.mTextView.isSelectable = true
    self.mTextView.isVerticallyResizable = true
    self.mTextView.isHorizontallyResizable = true
    self.mTextView.isRichText = false
    self.mTextView.importsGraphics = false
    self.mTextView.allowsImageEditing = false

    self.drawsBackground = false
    self.documentView = self.mTextView
    self.hasHorizontalScroller = true
    self.hasVerticalScroller = true
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func ebCleanUp () {
    self.mValueController?.unregister ()
    self.mValueController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  var string : String { self.mTextView.string }
  var textStorage : NSTextStorage? { self.mTextView.textStorage }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func update (from inObject : EBReadOnlyProperty_String) {
    switch inObject.selection {
    case .empty, .multiple :
      self.mTextView.string = ""
      self.mTextView.isEditable = false
      self.mTextView.invalidateIntrinsicContentSize ()
    case .single (let propertyValue) :
      let currentSelectedRangeValues = self.mTextView.selectedRanges
      self.mTextView.string = propertyValue
      self.mTextView.selectedRanges = currentSelectedRangeValues
      self.mTextView.isEditable = true
      self.mTextView.invalidateIntrinsicContentSize ()
    }
  }

  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <String>? = nil

  //····················································································································

  func bind_value (_ inObject : EBReadWriteProperty_String) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    self.mTextView.mValueController = self.mValueController
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
// https://stackoverflow.com/questions/11237622/using-autolayout-with-expanding-nstextviews
//----------------------------------------------------------------------------------------------------------------------

class EmbbeddedAutoLayoutTextView : NSTextView, EBUserClassNameProtocol {

  //····················································································································

  fileprivate weak var mValueController : EBGenericReadWritePropertyController <String>? = nil

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
    _ = self.mValueController?.updateModel (withCandidateValue: self.string, windowForSheet: self.window)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
