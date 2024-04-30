//
//  AutoLayoutStaticImageView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutStaticImageView
//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutStaticImageView : ALB_NSImageView {

  //································································································

  init (name inImageName : String) {
    super.init ()

    self.image = NSImage (named: inImageName)
    self.imageScaling = .scaleProportionallyUpOrDown
    self.imageFrameStyle = .none

    self.frame.size = self.intrinsicContentSize
  }

  //································································································

  init (image inImage : NSImage?) {
    super.init ()

    self.image = inImage
    self.imageScaling = .scaleProportionallyUpOrDown
    self.imageFrameStyle = .none

    self.frame.size = self.intrinsicContentSize
  }

  //································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————
