//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  AutoLayoutFontButton.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 26/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutFontButton : InternalAutoLayoutButton {

  //····················································································································

  private var mFont : NSFont? = nil

  //····················································································································

  init (small inSmall : Bool) {
    super.init (title: "", small: inSmall)
//    noteObjectAllocation (self)
//    self.controlSize = inSmall ? .small : .regular
//    self.font = NSFont.systemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
//    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
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

//  deinit {
//    noteObjectDeallocation (self)
//  }

  //····················································································································

//  override func updateAutoLayoutUserInterfaceStyle () {
//    super.updateAutoLayoutUserInterfaceStyle ()
//    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
//  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.showFontManager ()
    return super.sendAction (action, to: to)
  }

  //····················································································································

  func showFontManager () {
    if let font = self.mFont {
      let fontManager = NSFontManager.shared
      fontManager.setSelectedFont (font, isMultiple: false)
      fontManager.orderFrontFontPanel (self)
      fontManager.target = self
      fontManager.action = #selector (Self.changeFont (_:))
    }
  }

  //····················································································································

  @objc func changeFont (_ sender : Any?) {
    if let font = self.mFont, let fontManager = sender as? NSFontManager {
      let newFont = fontManager.convert (font)
      _ = self.mValueController?.updateModel (withCandidateValue: newFont, windowForSheet: self.window)
    }
  }

  //····················································································································

  func mySetFont (font : NSFont) {
    self.mFont = font
    let newTitle = String (format:"%@ - %g pt.", font.displayName!, font.pointSize)
    self.title = newTitle
  }

  //····················································································································
  //  $fontValue binding
  //····················································································································

  fileprivate func updateFont (_ object : EBReadOnlyProperty_NSFont) {
    switch object.selection {
    case .empty, .multiple :
      self.enable (fromValueBinding: false)
      self.title = "—"
    case .single (let v) :
      self.enable (fromValueBinding: true)
      self.mySetFont (font: v)
    }
  }

  //····················································································································

  private var mValueController : EBGenericReadWritePropertyController <NSFont>? = nil

  //····················································································································

  final func bind_fontValue (_ inObject : EBReadWriteProperty_NSFont) -> Self {
    self.mValueController = EBGenericReadWritePropertyController (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateFont (inObject) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
