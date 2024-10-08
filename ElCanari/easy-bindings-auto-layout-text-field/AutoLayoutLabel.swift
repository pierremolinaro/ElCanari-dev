//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutLabel : ALB_NSTextField {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mBold : Bool

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (bold inBold : Bool, size inSize : EBControlSize) {
    self.mBold = inBold

    super.init (optionalWidth: nil, bold: inBold, size: inSize.cocoaControlSize)

    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEnabled = true
    self.isEditable = false
    self.controlSize = inSize.cocoaControlSize
  //  self.usesSingleLineMode = true
    let fontSize = NSFont.systemFontSize (for: self.controlSize)
    self.font = inBold ? NSFont.boldSystemFont (ofSize: fontSize) : NSFont.systemFont (ofSize: fontSize)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // SET TEXT color
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setTextColor (_ inTextColor : NSColor) -> Self {
    self.textColor = inTextColor
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // setRedTextColor
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setRedTextColor () -> Self {
    self.textColor = .red
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK:  $textColor binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mColorController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_textColor (_ inObject : EBObservableProperty <NSColor>) -> Self {
    self.mColorController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateColor (from: inObject.selection) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateColor (from inObjectSelection : EBSelection <NSColor>) {
    switch inObjectSelection {
    case .empty, .multiple :
      ()
    case .single (let v) :
      self.textColor = v
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK:  $size binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSizeController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_size (_ inObject : EBObservableProperty <EBControlSize>) -> Self {
    self.mSizeController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.updateSize (from: inObject.selection) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func updateSize (from inObjectSelection : EBSelection <EBControlSize>) {
    switch inObjectSelection {
    case .empty, .multiple :
      ()
    case .single (let v) :
      self.controlSize = v.cocoaControlSize
      let fontSize = NSFont.systemFontSize (for: self.controlSize)
      self.font = self.mBold ? NSFont.boldSystemFont (ofSize: fontSize) : NSFont.systemFont (ofSize: fontSize)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK:  $title binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTitleController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_title (_ inObject : EBObservableProperty <String>) -> Self {
    self.mTitleController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject.selection) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func update (from inObjectSelection : EBSelection <String>) {
    switch inObjectSelection {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.placeholderString = nil
      self.stringValue = v
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

