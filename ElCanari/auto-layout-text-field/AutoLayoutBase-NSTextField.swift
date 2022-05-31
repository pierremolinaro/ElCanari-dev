//
//  AutoLayoutBase-NSTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutBase_NSTextField
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSTextField : NSTextField, EBUserClassNameProtocol, NSTextFieldDelegate, NSControlTextEditingDelegate {

  //····················································································································

  private var mWidth : CGFloat?

  //····················································································································
  // https://www.generacodice.com/en/articolo/4221090/how-to-let-nstextfield-grow-with-the-text-in-auto-layout
  //····················································································································

  private var mAutomaticallyAdjustHeight = false

  //····················································································································

  init (optionalWidth inOptionalWidth : Int?, bold inBold : Bool, size inSize : EBControlSize) {
    if let w = inOptionalWidth {
      self.mWidth = CGFloat (w)
    }else{
      self.mWidth = nil
    }
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentCompressionResistancePriority (.required, for: .vertical)

    self.delegate = self

    self.controlSize = inSize.cocoaControlSize
    let size = NSFont.systemFontSize (for: self.controlSize)
    self.font = inBold ? NSFont.boldSystemFont (ofSize:size) : NSFont.systemFont (ofSize: size)
    self.alignment = .center
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
  // NE PAS DÉFINIR acceptsFirstResponder, SINON UN CHAMP SANS SÉLECTION RESTE ACTIF
  //  final override var acceptsFirstResponder: Bool { return true }
  //····················································································································

  final func set (alignment inAlignment : TextAlignment) -> Self {
    self.alignment = inAlignment.cocoaAlignment
    return self
  }

  //····················································································································

  final func set (minWidth inWidth : Int) -> Self {
    self.mWidth = CGFloat (inWidth)
    return self
  }

  //····················································································································

  final func automaticallyAdjustHeight (maxWidth inMaxWidth : Int) -> Self {
 //   self.usesSingleLineMode = false
    self.mAutomaticallyAdjustHeight = true
    self.preferredMaxLayoutWidth = CGFloat (inMaxWidth)
    self.cell?.wraps = true
    self.lineBreakMode = .byWordWrapping
    self.invalidateIntrinsicContentSize ()
    return self
  }

  //····················································································································

  override func textDidChange (_ notification : Notification) {
    super.textDidChange (notification)
    self.invalidateIntrinsicContentSize ()
  }

  //····················································································································
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  //····················································································································

  override var intrinsicContentSize : NSSize {
    if self.mAutomaticallyAdjustHeight, let cell = self.cell {
      var frame = self.frame
      let width = self.mWidth ?? frame.size.width
      // Make the frame very high, while keeping the width
      frame.size.height = CGFloat.greatestFiniteMagnitude;
      // Calculate new height within the frame
      // with practically infinite height.
      let height = cell.cellSize (forBounds: frame).height
      return NSSize (width: width, height: height)
    }else{
      var s = super.intrinsicContentSize
      if let w = self.mWidth {
        s.width = w
      }
      return s
    }
  }

  //····················································································································
  //MARK:   NSControlTextEditingDelegate
  //····················································································································

  func control (_ control: NSControl,
                textView: NSTextView,
                doCommandBy inCommandSelector: Selector) -> Bool {
    //Swift.print ("commandSelector \(inCommandSelector)")
    if inCommandSelector == #selector (Self.insertLineBreak (_:)) {
      return true
    }else if inCommandSelector == #selector (Self.insertNewlineIgnoringFieldEditor (_:)) {
      return true
    }else{
      return false
    }
  }

  //····················································································································
  //MARK:  $enabled binding
  //····················································································································

  private var mEnabledBindingController : EnabledBindingController? = nil
  var enabledBindingController : EnabledBindingController? { return self.mEnabledBindingController }

  //····················································································································

  final func bind_enabled (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mEnabledBindingController = EnabledBindingController (inExpression, self)
    return self
  }

  //····················································································································
  //MARK:  $hidden binding
  //····················································································································

  private var mHiddenBindingController : HiddenBindingController? = nil
  var hiddenBindingController : HiddenBindingController? { return self.mHiddenBindingController }

  //····················································································································

  final func bind_hidden (_ inExpression : EBMultipleBindingBooleanExpression) -> Self {
    self.mHiddenBindingController = HiddenBindingController (inExpression, self)
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
