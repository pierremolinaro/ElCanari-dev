//
//  AutoLayoutWarningImageView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutWarningImageView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutWarningImageView : NSImageView, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.image = NSImage (named: warningStatusImageName)
    self.imageScaling = .scaleProportionallyUpOrDown
    self.imageFrameStyle = .none

    self.frame.size = self.intrinsicContentSize
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————