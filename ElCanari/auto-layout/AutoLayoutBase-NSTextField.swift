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

class AutoLayoutBase_NSTextField : NSTextField, EBUserClassNameProtocol {

  private let mWidth : CGFloat

  //····················································································································

  init (width inWidth : Int, size inSize : EBControlSize) {
    self.mWidth = CGFloat (inWidth)
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentCompressionResistancePriority (.required, for: .vertical)

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.boldSystemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
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

  final override var acceptsFirstResponder: Bool { return true }

  //····················································································································

  final func set (alignment inAlignment : TextAlignment) -> Self {
    self.alignment = inAlignment.cocoaAlignment
    return self
  }

  //····················································································································

  final func multiLine () -> Self {
    self.usesSingleLineMode = false
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .vertical)
    return self
  }

  //····················································································································
  //  By Default, super.intrinsicContentSize.width is -1, meaning the text field is invisible
  //  So we need to define intrinsicContentSize.width explicitly
  //  super.intrinsicContentSize.height is valid (19.0 for small size, 22.0 for regular size, ...)-
  //····················································································································

  final override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    // Swift.print ("AutoLayoutTextField height \(s.height)")
    return NSSize (width: self.mWidth, height: s.height)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————