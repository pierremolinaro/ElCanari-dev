//
//  AutoLayout-style.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   Public function
//----------------------------------------------------------------------------------------------------------------------

func autoLayoutCurrentStyle () -> AutoLayoutUserInterfaceStyleDescriptor {
  return gCurrentStyle
}

//----------------------------------------------------------------------------------------------------------------------

func changeAutoLayoutUserInterfaceStyle (to inStyle : AutoLayoutUserInterfaceStyle) {
  switch inStyle {
  case .roundedBezel :
    gCurrentStyle = AutoLayoutUserInterfaceStyleDescriptor (buttonStyle: .rounded, segmentedControlStyle: .rounded)
  case .roundRect :
    gCurrentStyle = AutoLayoutUserInterfaceStyleDescriptor (buttonStyle: .roundRect, segmentedControlStyle: .roundRect)
  case .texturedRounded :
    gCurrentStyle = AutoLayoutUserInterfaceStyleDescriptor (buttonStyle: .texturedRounded, segmentedControlStyle: .texturedRounded)
  case .texturedSquare :
    gCurrentStyle = AutoLayoutUserInterfaceStyleDescriptor (buttonStyle: .texturedSquare, segmentedControlStyle: .texturedSquare)
  case .shadowlessSquare :
    gCurrentStyle = AutoLayoutUserInterfaceStyleDescriptor (buttonStyle: .shadowlessSquare, segmentedControlStyle: .texturedSquare)
  }
  for window in NSApp.windows {
    if let mainView = window.contentView {
      mainView.updateAutoLayoutUserInterfaceStyle ()
    }
  }

}

//----------------------------------------------------------------------------------------------------------------------

struct AutoLayoutUserInterfaceStyleDescriptor {
  let buttonStyle : NSButton.BezelStyle
  let segmentedControlStyle : NSSegmentedControl.Style
}

//----------------------------------------------------------------------------------------------------------------------

fileprivate var gCurrentStyle = AutoLayoutUserInterfaceStyleDescriptor (buttonStyle: .rounded, segmentedControlStyle: .rounded)

//----------------------------------------------------------------------------------------------------------------------

extension NSView {

  //····················································································································

  @objc func updateAutoLayoutUserInterfaceStyle () {
    for view in self.subviews {
      view.updateAutoLayoutUserInterfaceStyle ()
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
