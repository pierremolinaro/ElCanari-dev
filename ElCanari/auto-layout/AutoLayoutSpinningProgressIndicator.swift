//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutSpinningProgressIndicator : NSProgressIndicator, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.isIndeterminate = true
    self.style = .spinning
    self.usesThreadedAnimation = true
    self.startAnimation (nil)
  }

  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //----------------------------------------------------------------------------------------------------------------------

  @discardableResult static func make () -> AutoLayoutSpinningProgressIndicator {
    let b = AutoLayoutSpinningProgressIndicator ()
    gCurrentStack?.addView (b, in: .leading)
    return b
  }

  //····················································································································

}


//----------------------------------------------------------------------------------------------------------------------
