//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

@discardableResult func vStack (margin inMargin : UInt, _ inContents : () -> Void) -> AutoLayoutVerticalStackView {
  let savedCurrentStack = gCurrentStack
  let v = AutoLayoutVerticalStackView (margin: inMargin)
  savedCurrentStack?.addView (v, in: .leading)
  gCurrentStack = v
  inContents ()
  gCurrentStack = savedCurrentStack
  return v
}

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutVerticalStackView : AutoLayoutStackView {

  //····················································································································
  //   INIT
  //····················································································································

  init (margin inMargin : UInt) {
    super.init (orientation: .vertical, margin: inMargin)
  }

  //····················································································································

  init (margin inMargin : UInt, _ inContents : () -> Void) {
    super.init (orientation: .vertical, margin: inMargin)
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

  private var mConstraints = [NSLayoutConstraint] ()

  override func updateConstraints () {
//    Swift.print ("V STACK \(self)")
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
        let c = NSLayoutConstraint (item: oneSpaceView, attribute: .height, relatedBy: .equal, toItem: spaceView, attribute: .height, multiplier: 1.0, constant: 0.0)
        self.mConstraints.append (c)
      }
      self.addConstraints (self.mConstraints)
    }
    super.updateConstraints ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
