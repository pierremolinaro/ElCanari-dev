//
//  extension-ProjectDocument-checkBeforeLaunchFreeRouter.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 13/11/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutProjectDocument {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func checkSchematicsAndLaunchFreeRouteur (_ inCallBack : @MainActor @escaping @Sendable () -> Void) {
     if !self.rootObject.schematicHasErrorOrWarning! {
      self.checkAllComponentsAreInBoard (inCallBack)
    }else{
      let alert = NSAlert ()
      alert.messageText = "There are issues in schematics. Continue anyway?"
      _ = alert.addButton (withTitle: "Cancel")
      _ = alert.addButton (withTitle: "Continue")
      alert.beginSheetModal (for: self.windowForSheet!) { (response : NSApplication.ModalResponse) in
        if response == .alertSecondButtonReturn {
          DispatchQueue.main.async {
            self.checkAllComponentsAreInBoard (inCallBack)
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor fileprivate func checkAllComponentsAreInBoard (_ inCallBack : @MainActor @escaping @Sendable () -> Void) {
    var unplacedComponentNames = [String] ()
    for component in self.rootObject.mComponents.values {
      if !component.isPlacedInBoard! {
        unplacedComponentNames.append (component.componentName!)
      }
    }
    if unplacedComponentNames.isEmpty {
      inCallBack ()
    }else{
      unplacedComponentNames.sort ()
      let alert = NSAlert ()
      alert.messageText = (unplacedComponentNames.count == 1)
        ? "There is 1 unplaced component in board. Continue anyway?"
        : "There are \(unplacedComponentNames.count) unplaced components in board. Continue anyway?"
      alert.informativeText = unplacedComponentNames.joined (separator: ", ")
      _ = alert.addButton (withTitle: "Cancel")
      _ = alert.addButton (withTitle: "Continue")
      alert.beginSheetModal (for: self.windowForSheet!) { (inResponse : NSApplication.ModalResponse) in
        if inResponse == .alertSecondButtonReturn {
          DispatchQueue.main.async { inCallBack () }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
