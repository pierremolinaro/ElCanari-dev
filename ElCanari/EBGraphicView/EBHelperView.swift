//
//  EBHelperView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/11/2020.
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class EBHelperView : NSView, EBUserClassNameProtocol {

  //····················································································································
  // MARK: -
  //····················································································································

  internal var mHelperArray = [NSView] ()

  //····················································································································
  // MARK: -
  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }

  //····················································································································

  override func awakeFromNib () {
    super.awakeFromNib ()
    for view in self.subviews {
      if let focusView = view as? EBFocusRingView {
        var r = focusView.frame
        r.size.height -= 21.0 ;
        focusView.frame = r
      }
    }
  }

  //····················································································································

  final func addHelperView (_ inView : NSView) {
    if !self.mHelperArray.contains (inView) {
      inView.frame.origin.y = self.bounds.size.height - inView.frame.size.height - 1.0
      inView.frame.origin.x = FOCUS_RING_MARGIN
      for view in self.mHelperArray {
        inView.frame.origin.x += view.frame.size.width + 2.0
      }
      inView.autoresizingMask = .minYMargin
      self.mHelperArray.append (inView)
      self.addSubview (inView)
    }
  }

  //····················································································································

  final func addLastHelperView (_ inView : NSView) {
    inView.frame.origin.y = self.bounds.size.height - inView.frame.size.height - 3.0
    inView.frame.origin.x = FOCUS_RING_MARGIN
    for view in self.mHelperArray {
      inView.frame.origin.x += view.frame.size.width + 2.0
    }
    inView.frame.size.width = self.bounds.maxX - inView.frame.origin.x - 2.0
    inView.autoresizingMask = [.minYMargin, .width]
    self.addSubview (inView)
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
