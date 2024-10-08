//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  final func configure_addLineButton (_ inOutlet : AutoLayoutDragSourceButtonWithMenus) {
//--- START OF USER ZONE 2
    inOutlet.register (
      draggedType: kDragAndDropBoardLine,
      draggedObjectFactory: {
        return AutoLayoutDragSourceButton.DraggedObjectFactoryDescriptor (BoardLine (nil))
      },
      scaleProvider: self.boardObjectsController
    )
    inOutlet.set (image: NSImage (named: "line-in-symbol"))
    let menu = CanariChoiceMenu ()
    menu.addItem (withTitle: "Legend, Front Side", action: nil, keyEquivalent: "")
    menu.addItem (withTitle: "Legend, Back Side",  action: nil, keyEquivalent: "")
    menu.bind_selectedIndex (self.rootObject.mBoardLayerForNewLine_property)
    inOutlet.set (rightContextualMenu: menu)
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
