//--------------------------------------------------------------------------------------------------
//
//  AutoLayoutFontButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 26/02/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutFontButton : ALB_NSButton_enabled_hidden_bindings {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mFont : NSFont? = nil
  private var mWidth : CGFloat

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (width inWidth : Int, size inSize : EBControlSize) {
    self.mWidth = CGFloat (inWidth)
    super.init (title: "", size: inSize.cocoaControlSize)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.showFontManager ()
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override var intrinsicContentSize : NSSize {
    var s = super.intrinsicContentSize
    s.width = self.mWidth
    return s
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func showFontManager () {
    if let font = self.mFont {
      let fontManager = NSFontManager.shared
      fontManager.setSelectedFont (font, isMultiple: false)
      fontManager.target = self
      fontManager.action = #selector (Self.changeFont (_:))
      fontManager.orderFrontFontPanel (self)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc private func changeFont (_ sender : Any?) {
    if let font = self.mFont, let fontManager = sender as? NSFontManager {
      let newFont = fontManager.convert (font)
      self.mValueController?.updateModel (withValue: newFont)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func mySetFont (font : NSFont) {
    self.mFont = font
    let newTitle = String (format:"%@ - %g pt.", font.displayName ?? "?", font.pointSize)
    self.title = newTitle
    self.toolTip = newTitle
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $fontValue binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  fileprivate func updateFont (_ object : EBObservableProperty <NSFont>) {
    switch object.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.title = "—"
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.mySetFont (font: v)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValueController : EBGenericReadWritePropertyController <NSFont>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_fontValue (_ inObject : EBObservableMutableProperty <NSFont>) -> Self {
    self.mValueController = EBGenericReadWritePropertyController <NSFont> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateFont (inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
