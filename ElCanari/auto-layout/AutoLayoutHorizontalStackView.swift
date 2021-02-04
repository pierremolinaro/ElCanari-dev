//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

@discardableResult func hStack (margin inMargin : UInt, _ inContents : () -> Void) -> AutoLayoutHorizontalStackView {
  let h = AutoLayoutHorizontalStackView (margin: inMargin)
  gCurrentStack?.addView (h, in: .leading)
  let savedCurrentStack = gCurrentStack
  gCurrentStack = h
  inContents ()
  gCurrentStack = savedCurrentStack
  return h
}

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutHorizontalStackView : AutoLayoutStackView {

  //····················································································································
  //   INIT
  //····················································································································

  init (margin inMargin : UInt) {
    super.init (orientation: .horizontal, margin: inMargin)
  }

  //····················································································································

  init (margin inMargin : UInt, _ inContents : () -> Void) {
    super.init (orientation: .horizontal, margin: inMargin)
    let savedCurrentStack = gCurrentStack
    gCurrentStack = self
    inContents ()
    gCurrentStack = savedCurrentStack
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  // SET FLEXIBLE WIDTH
  //····················································································································

  @discardableResult func fillEqualy () -> Self {
    self.distribution = .fillEqually
    return self
  }

  //····················································································································

  private var mConstraints = [NSLayoutConstraint] ()

  override func updateConstraints () {
    // Swift.print ("H STACK \(self)")
    self.removeConstraints (self.mConstraints)
    self.mConstraints.removeAll ()
    var spaceViewArray = [AutoLayoutFlexibleSpaceView] ()
    for view in self.subviews {
      if let spaceView = view as? AutoLayoutFlexibleSpaceView {
        spaceViewArray.append (spaceView)
      }
    }
    if let oneSpaceView = spaceViewArray.popLast () {
      for spaceView in spaceViewArray {
        let c = NSLayoutConstraint (item: oneSpaceView, attribute: .width, relatedBy: .equal, toItem: spaceView, attribute: .width, multiplier: 1.0, constant: 0.0)
        self.mConstraints.append (c)
      }
      self.addConstraints (self.mConstraints)
    }
    super.updateConstraints ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
