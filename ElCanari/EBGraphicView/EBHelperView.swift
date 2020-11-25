//
//  EBHelperView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 25/11/2020.
import Cocoa

//----------------------------------------------------------------------------------------------------------------------


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

  deinit {
    noteObjectDeallocation (self)
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
  // MARK: -
  //····················································································································

  final func addPlacard (_ inPlacardView : NSView) {
    if !self.mHelperArray.contains (inPlacardView) {
//      Swift.print ("inPlacardView.frame \(inPlacardView.frame)")
//      Swift.print ("self.bounds \(self.bounds)")
//      Swift.print ("self.frame \(self.frame)")
      inPlacardView.frame.origin.y = self.bounds.size.height - inPlacardView.frame.size.height - 1
      inPlacardView.frame.origin.x += FOCUS_RING_MARGIN
      for view in self.mHelperArray {
        inPlacardView.frame.origin.x += view.frame.size.width + 2.0
      }
      inPlacardView.autoresizingMask = .minYMargin
      self.mHelperArray.append (inPlacardView)
      self.addSubview (inPlacardView)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
