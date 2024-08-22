//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutTextView : ALB_NSTextView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    super.init (
      drawsBackground: true,
      horizontalScroller: true,
      verticalScroller: true,
      editable: true
    )

    self.mTextView.mTextDidChangeCallBack = { [weak self] in self?.ebTextDidChange () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func ebTextDidChange () {
    self.mValueController?.updateModel (withValue: self.string)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  value binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValueController : EBGenericReadWritePropertyController <String>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_value (_ inObject : EBObservableMutableProperty <String>) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <String> (
      observedObject: inObject,
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setSelectedRange (_ inSelectedRange : NSRange) {
    self.mTextView.setSelectedRange (inSelectedRange)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedRange : NSRange {
    return self.mTextView.selectedRange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
