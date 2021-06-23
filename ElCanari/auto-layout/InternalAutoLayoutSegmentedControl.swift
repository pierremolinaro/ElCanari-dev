//
//  InternalAutoLayoutSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 20/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class InternalAutoLayoutSegmentedControl : NSSegmentedControl, EBUserClassNameProtocol {

  //····················································································································

  private let mEqualWidth : Bool

  //····················································································································

  init (equalWidth inEqualWidth : Bool, small inSmall : Bool) {
    self.mEqualWidth = inEqualWidth
    super.init (frame: NSRect ())
    noteObjectAllocation (self)

    self.translatesAutoresizingMaskIntoConstraints = false
    self.segmentStyle = autoLayoutCurrentStyle ().segmentedControlStyle

    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))

    if #available (OSX 10.13, *) {
      self.setValue (NSNumber (value: 2), forKey: "segmentDistribution") // fillEqually
    }
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

  final func makeWidthExpandable () -> Self {
    self.setContentHuggingPriority (.init (rawValue: 1.0), for: .horizontal)
    return self
  }

  //····················································································································

  override final func resizeSubviews (withOldSize oldSize : NSSize) {
    super.resizeSubviews (withOldSize: oldSize)
    //Swift.print ("\(self.bounds)")
    if #available (OSX 10.13, *) {
    }else{
      if self.mEqualWidth, self.segmentCount > 1 {
        let width = self.bounds.size.width / CGFloat (self.segmentCount) - 3.0
        for i in 0 ..< self.segmentCount {
          self.setWidth (width, forSegment: i)
        }
      }
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
