//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutSpinningProgressIndicator : ALB_NSProgressIndicator {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init ()

    self.setContentCompressionResistancePriority (.required, for: .horizontal)
    self.setContentCompressionResistancePriority (.required, for: .vertical)

    self.isIndeterminate = true
    self.style = .spinning
    self.usesThreadedAnimation = true
    self.controlSize = inSize.cocoaControlSize
    self.isDisplayedWhenStopped = true
    self.startAnimation (nil)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}


//——————————————————————————————————————————————————————————————————————————————————————————————————
