//
//  AutoLayoutImageButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutImageButton : AutoLayoutBase_NSButton {

  //····················································································································

  private var mWidth : CGFloat
  private var mHeight : CGFloat

  //····················································································································

  init (imageName inImageName : String, tooltip inTooltip : String, width inWidth : Int, height inHeight : Int) {
    self.mWidth = CGFloat (inWidth)
    self.mHeight = CGFloat (inHeight)
    super.init (title: "", size: .regular)

    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentCompressionResistancePriority (.required, for: .vertical)
    self.setContentHuggingPriority (.required, for: .horizontal)
    self.setContentHuggingPriority (.required, for: .vertical)

    self.toolTip = inTooltip
    self.image = NSImage (named: inImageName)
    self.imageScaling = .scaleProportionallyUpOrDown
    self.isBordered = false
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    return NSSize (width: self.mWidth, height: self.mHeight)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
