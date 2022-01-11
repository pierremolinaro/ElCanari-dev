//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSpinningProgressIndicator : NSProgressIndicator, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentCompressionResistancePriority (.required, for: .vertical)

    self.isIndeterminate = true
    self.style = .spinning
    self.usesThreadedAnimation = true
    self.controlSize = .regular
    self.isDisplayedWhenStopped = true
    self.startAnimation (nil)
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

//  override func ebCleanUp () {
//    self.stopAnimation (nil)
//    self.usesThreadedAnimation = false
//    super.ebCleanUp ()
//  }

  //····················································································································

}


//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
