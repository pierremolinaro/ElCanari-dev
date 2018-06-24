//
//  CanariScrollViewWithPlacard.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 24/06/2018.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariScrollViewWithPlacard) class CanariScrollViewWithPlacard : NSScrollView, EBUserClassNameProtocol {

  fileprivate var mPlacardArray = [NSView] ()

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func addPlacard (_ inView : NSView) {
    if !mPlacardArray.contains (inView) {
      mPlacardArray.append (inView)
      self.addSubview (inView)
    }
  }

  //····················································································································

  func removePlacard (_ inView : NSView) {
    if mPlacardArray.contains (inView) {
      inView.removeFromSuperview ()
      if let index = mPlacardArray.index (of: inView) {
        mPlacardArray.remove (at: index)
      }
    }
  }

  //····················································································································

  override func tile () {
    super.tile ()
    if let horizScroller = self.horizontalScroller, mPlacardArray.count > 0 {
      var horizScrollerFrame : NSRect = horizScroller.frame
      for placard in mPlacardArray {
        var placardFrame : NSRect = placard.frame

      //--- Now we'll just adjust the horizontal scroller size and set the placard size and location.
        horizScrollerFrame.size.width -= placardFrame.size.width;
        horizScroller.setFrameSize (horizScrollerFrame.size)

      // Put placard where the horizontal scroller is
        placardFrame.origin.x = NSMinX (horizScrollerFrame);
        
      // Move horizontal scroller over to the right of the placard
        horizScrollerFrame.origin.x = NSMaxX(placardFrame);
        horizScroller.setFrameOrigin (horizScrollerFrame.origin)

      // Adjust height of placard
        placardFrame.size.height = horizScrollerFrame.size.height + 1.0
        placardFrame.origin.y = self.bounds.size.height - placardFrame.size.height
      
      // Move the placard into place
        placard.frame = placardFrame
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
