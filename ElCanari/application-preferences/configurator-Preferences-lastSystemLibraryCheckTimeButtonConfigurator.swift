//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension Preferences {
  final func configure_lastSystemLibraryCheckTimeButtonConfigurator (_ inOutlet : AutoLayoutPopUpButton) {
//--- START OF USER ZONE 2
        inOutlet.addItem (withTitle: "Daily")
        inOutlet.lastItem?.tag = 0
        inOutlet.addItem (withTitle: "Weekly")
        inOutlet.lastItem?.tag = 1
        inOutlet.addItem (withTitle: "Monthly")
        inOutlet.lastItem?.tag = 2
        inOutlet.bind (
          NSBindingName.selectedTag,
          to: UserDefaults.standard,
          withKeyPath: Preferences_systemLibraryCheckTimeInterval,
          options: nil
        )
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————