//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutRTFTextView : NSScrollView {

  //····················································································································

  fileprivate let mTextView = AutoLayoutBase_NSTextView ()

  //····················································································································

  init (editable inIsEditable : Bool) {
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.mTextView.isEditable = inIsEditable
    self.mTextView.isSelectable = true
    self.mTextView.isVerticallyResizable = true
    self.mTextView.isHorizontallyResizable = true
    self.mTextView.isRichText = true
    self.mTextView.importsGraphics = false
    self.mTextView.allowsImageEditing = false
    self.mTextView.mTextDidChangeCallBack = { [weak self] in self?.ebTextDidChange () }

    let MAX_SIZE : CGFloat = 1_000_000.0 // CGFloat.greatestFiniteMagnitude
    self.mTextView.minSize = NSSize (width: 0.0, height: contentSize.height)
    self.mTextView.maxSize = NSSize (width: MAX_SIZE, height: MAX_SIZE)
    self.mTextView.textContainer?.containerSize = NSSize (width: contentSize.width, height: MAX_SIZE)
    self.mTextView.textContainer?.widthTracksTextView = true
    self.mTextView.setContentHuggingPriority (.defaultLow, for: .horizontal)
    self.mTextView.setContentHuggingPriority (.defaultLow, for: .vertical)

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

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func populateWithContententsOf (url inURL : URL)-> Self {
    if let rtfData = try? Data (contentsOf: inURL) {
      self.mTextView.replaceCharacters (in: NSRange (), withRTF: rtfData)
    }
    return self
  }

  //····················································································································

  var string : String {
    get { return self.mTextView.string }
    set { self.mTextView.string = newValue }
  }

//  var textStorage : NSTextStorage? { self.mTextView.textStorage }

//  var isEditable : Bool {
//    get { return self.mTextView.isEditable }
//    set { self.mTextView.isEditable = newValue }
//  }

  //····················································································································

  fileprivate func ebTextDidChange () {
    self.mValueController?.updateModel (withValue: self.string)
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func update (from inObject : EBObservableProperty <String>) {
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

  final func bind_value (_ inObject : EBObservableMutableProperty <String>) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
