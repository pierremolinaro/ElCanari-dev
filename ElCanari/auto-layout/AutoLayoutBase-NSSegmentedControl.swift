//
//  AutoLayoutBase-NSSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class AutoLayoutBase_NSSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  init (equalWidth inEqualWidth : Bool, size inSize : EBControlSize) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)

    self.translatesAutoresizingMaskIntoConstraints = false
    self.segmentStyle = autoLayoutCurrentStyle ().segmentedControlStyle

    self.controlSize = inSize.cocoaControlSize
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))

    if inEqualWidth {
      self.segmentDistribution = .fillEqually // #available (OSX 10.13, *)
    }
//    if #available (OSX 10.13, *) {
//      self.setValue (NSNumber (value: 2), forKey: "segmentDistribution") // fillEqually
//    }
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override final func updateAutoLayoutUserInterfaceStyle () {
    super.updateAutoLayoutUserInterfaceStyle ()
    self.segmentStyle = autoLayoutCurrentStyle ().segmentedControlStyle
  }

  //····················································································································

//  override final func resizeSubviews (withOldSize oldSize : NSSize) {
//    super.resizeSubviews (withOldSize: oldSize)
//    //Swift.print ("\(self.bounds)")
//    if #available (OSX 10.13, *) {
//    }else{
//      if self.mEqualWidth, self.segmentCount > 1 {
//        let width = self.bounds.size.width / CGFloat (self.segmentCount) - 3.0
//        for i in 0 ..< self.segmentCount {
//          self.setWidth (width, forSegment: i)
//        }
//      }
//    }
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
