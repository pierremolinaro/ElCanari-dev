//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class CanariMenu : NSMenu {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (coder : NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $populateSubmenus binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc func revealInFinder (_ sender : NSMenuItem) {
    let ws = NSWorkspace.shared
    let title = sender.title
    let ok = ws.open (URL (fileURLWithPath: title))
    if !ok {
      NSSound.beep ()
      let alert = NSAlert ()
      alert.messageText = "Cannot open the \(title) directory"
      alert.informativeText = "This directory does not exist."
      _ = alert.runModal ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor private func updateOutlet (_ object : EBObservableProperty <StringArray>) {
    switch object.selection {
    case .empty, .multiple :
      self.removeAllItems ()
    case .single (let itemList) :
      self.removeAllItems ()
      for title in itemList {
        let item = self.addItem (withTitle: title, action: #selector (CanariMenu.revealInFinder(_:)), keyEquivalent: "")
        item.target = self
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mValueController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor final func bind_populateSubmenus (_ object : EBObservableProperty <StringArray>) {
    self.mValueController = EBObservablePropertyController (
      observedObjects: [object],
      callBack: { self.updateOutlet (object) }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final func unbind_populateSubmenus () {
//    self.mValueController?.unregister ()
//    self.mValueController = nil
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
