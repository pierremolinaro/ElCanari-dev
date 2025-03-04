//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {
  final func configure_addTextButton (_ inOutlet : AutoLayoutDragSourceButtonWithMenus) {
//--- START OF USER ZONE 2
    inOutlet.register (
      draggedType: kDragAndDropBoardText,
      draggedObjectImage: { [weak self] in return self?.boardTextImageFactory () },
      scaleProvider: self.boardObjectsController
    )
    inOutlet.set (image: NSImage (named: "text-in-symbol"))
    let menu = CanariChoiceMenu ()
    menu.addItem (withTitle: "Legend, Front Side", action: nil, keyEquivalent: "")
    menu.addItem (withTitle: "Layout, Front Side", action: nil, keyEquivalent: "")
    menu.addItem (withTitle: "Layout, Back Side",  action: nil, keyEquivalent: "")
    menu.addItem (withTitle: "Legend, Back Side",  action: nil, keyEquivalent: "")
    menu.bind_selectedIndex (self.rootObject.mBoardLayerForNewText_property)
    inOutlet.set (rightContextualMenu: menu)
//--- END OF USER ZONE 2
  }
}

//--------------------------------------------------------------------------------------------------
