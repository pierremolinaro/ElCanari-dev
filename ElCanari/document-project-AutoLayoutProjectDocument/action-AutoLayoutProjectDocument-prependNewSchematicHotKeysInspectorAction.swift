//--- START OF USER ZONE 1


//--- END OF USER ZONE 1
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutProjectDocument {
  @objc func prependNewSchematicHotKeysInspectorAction (_ sender : NSObject?) {
//--- START OF USER ZONE 2
        if let hBaseStack = self.mSchematicsView?.superview as? AutoLayoutHorizontalStackView {
          prepend (inspector: self.schematicsHotKeysInspectorView (), toHStack: hBaseStack)
        }
//--- END OF USER ZONE 2
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————