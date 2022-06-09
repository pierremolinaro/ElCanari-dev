//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutTextView : NSScrollView, EBUserClassNameProtocol {

  //····················································································································

  fileprivate let mTextView = AutoLayoutBase_NSTextView ()

  //····················································································································

  init () {
    super.init (frame: NSRect (x: 0, y: 0, width: 100, height: 100))
    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false // DO NOT UNCOMMENT

    self.mTextView.isEditable = true
    self.mTextView.isSelectable = true
    self.mTextView.isVerticallyResizable = true
    self.mTextView.isHorizontallyResizable = true
    self.mTextView.isRichText = false
    self.mTextView.importsGraphics = false
    self.mTextView.allowsImageEditing = false
    self.mTextView.mTextDidChangeCallBack = { [weak self] in self?.ebTextDidChange () }
//    self.mTextView.backgroundColor = .yellow
//    self.mTextView.drawsBackground = true

//    Swift.print ("min size \(self.mTextView.minSize)")
//    Swift.print ("max size \(self.mTextView.maxSize)")

    let MAX_SIZE : CGFloat = CGFloat.greatestFiniteMagnitude
    self.mTextView.minSize = NSSize (width: 0.0, height: contentSize.height)
    self.mTextView.maxSize = NSSize (width: MAX_SIZE, height: MAX_SIZE)
    self.mTextView.textContainer?.containerSize = NSSize (width: contentSize.width, height: MAX_SIZE)
    self.mTextView.textContainer?.widthTracksTextView = true

    self.drawsBackground = false
    self.documentView = self.mTextView
    self.hasHorizontalScroller = true
    self.hasVerticalScroller = true
//    Swift.print ("self.automaticallyAdjustsContentInsets \(self.automaticallyAdjustsContentInsets)")
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

  var string : String {
    get { return self.mTextView.string }
    set { self.mTextView.string = newValue }
  }

  //····················································································································

  var textStorage : NSTextStorage? { self.mTextView.textStorage }

  //····················································································································

  fileprivate func ebTextDidChange () {
    self.mValueController?.updateModel (withValue: self.string)
  }

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
//      self.mTextView.sizeToFit ()
    }
  }

  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <String>? = nil

  //····················································································································

  final func bind_value (_ inObject : EBReadWriteProperty_String) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
