//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  final func configure_selectedNetVerticalScrollViewConfigurator (_ inOutlet : AutoLayoutVerticalScrollView) {
//--- START OF USER ZONE 2
        if let docView = inOutlet.documentView as? AutoLayoutVerticalStackView {
          self.mNetInfoTableView?.setSelectedNetVerticalStackView (docView)
        }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————