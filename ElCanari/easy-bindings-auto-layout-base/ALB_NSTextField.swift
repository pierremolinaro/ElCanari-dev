//
//  ALB_NSTextField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//   ALB_NSTextField
//--------------------------------------------------------------------------------------------------

class ALB_NSTextField : NSTextField, @MainActor NSTextFieldDelegate, NSControlTextEditingDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mWidth : CGFloat?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // https://www.generacodice.com/en/articolo/4221090/how-to-let-nstextfield-grow-with-the-text-in-auto-layout
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private final var mAutomaticallyAdjustHeight = false

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (optionalWidth inOptionalWidth : Int?,
        bold inBold : Bool,
        size inSize : NSControl.ControlSize) {
    if let w = inOptionalWidth {
      self.mWidth = CGFloat (w)
    }else{
      self.mWidth = nil
    }
    super.init (frame: .zero)
    noteObjectAllocation (self)
    self.pmConfigureForAutolayout (hStretchingResistance: .higher, vStrechingResistance: .higher)

    self.delegate = self

    self.controlSize = inSize
    let size = NSFont.systemFontSize (for: self.controlSize)
    self.font = inBold ? NSFont.boldSystemFont (ofSize:size) : NSFont.systemFont (ofSize: size)
    self.alignment = .center

    self.cell?.sendsActionOnEndEditing = true // Send an action when focus is lost
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
    objectDidDeinitSoReleaseHiddenControllers ()
    objectDidDeinitSoReleaseEnabledBindingController ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // NE PAS DÉFINIR acceptsFirstResponder, SINON UN CHAMP SANS SÉLECTION RESTE ACTIF
  //  final override var acceptsFirstResponder: Bool { return true }
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setHorizontalStretchingResistance (_ inHorizontalStrechingResistance : LayoutStrechingConstraintPriority) -> Self {
    self.setContentHuggingPriority (inHorizontalStrechingResistance.cocoaPriority, for: .horizontal)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func setHorizontalCompressionResistance (_ inHorizontalCompressionResistance : LayoutCompressionConstraintPriority) -> Self {
    self.setContentCompressionResistancePriority (inHorizontalCompressionResistance.cocoaPriority, for: .horizontal)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (alignment inAlignment : TextAlignment) -> Self {
    self.alignment = inAlignment.cocoaAlignment
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (width inWidth : Int) -> Self {
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .equal,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inWidth)
    )
    self.addConstraint (c)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func set (minWidth inWidth : Int) -> Self {
    let c = NSLayoutConstraint (
      item: self,
      attribute: .width,
      relatedBy: .greaterThanOrEqual,
      toItem: nil,
      attribute: .notAnAttribute,
      multiplier: 1.0,
      constant: CGFloat (inWidth)
    )
    self.addConstraint (c)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func automaticallyAdjustHeight (maxWidth inMaxWidth : Int) -> Self {
    self.mAutomaticallyAdjustHeight = true
    self.preferredMaxLayoutWidth = CGFloat (inMaxWidth)
    self.cell?.wraps = true
    self.lineBreakMode = .byWordWrapping
    self.invalidateIntrinsicContentSize ()
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func textDidChange (_ notification : Notification) {
    super.textDidChange (notification)
    self.invalidateIntrinsicContentSize ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    if let w = self.mWidth {
      s.width = w
    }
    if self.mAutomaticallyAdjustHeight, let cell = self.cell {
      var frame = self.frame
    //--- Make the frame very high, while keeping the width
      frame.size.height = CGFloat.greatestFiniteMagnitude
    //--- Calculate new height within the frame with practically infinite height.
      s.height = cell.cellSize (forBounds: frame).height
    }
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK:    NSTextFieldDelegate delegate function
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func control (_ control : NSControl,
                      didFailToFormatString string : String,
                      errorDescription error : String?) -> Bool {
    return true
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //MARK:   NSControlTextEditingDelegate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func control (_ control: NSControl,
                      textView: NSTextView,
                      doCommandBy inCommandSelector: Selector) -> Bool {
    if inCommandSelector == #selector (Self.insertLineBreak (_:)) {
      return true
    }else if inCommandSelector == #selector (Self.insertNewlineIgnoringFieldEditor (_:)) {
      return true
    }else{
      return false
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc override var lastBaselineRepresentativeView : NSView? { self }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Changing isHidden does not invalidate constraints !!!!
  // So we perform this operation manually
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidHide () {
    if let superview = unsafe self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
      buildResponderKeyChainForWindowThatContainsView (self)
    }
    super.viewDidHide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func viewDidUnhide () {
    if let superview = unsafe self.superview, !superview.isHidden {
      superview.invalidateIntrinsicContentSize ()
    }
    super.viewDidUnhide ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func removeFromSuperview () {
    buildResponderKeyChainForWindowThatContainsView (self)
    super.removeFromSuperview ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
