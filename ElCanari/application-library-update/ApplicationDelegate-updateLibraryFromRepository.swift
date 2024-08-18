
import AppKit

//--------------------------------------------------------------------------------------------------

extension ApplicationDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @IBAction func updateLibrary (_ inSender : AnyObject) {
    let optionKey : Bool = NSApplication.shared.currentEvent?.modifierFlags.contains (.option) ?? false
    if optionKey {
      self.startLibraryRevisionListOperation ()
    }else{
      startLibraryUpdateOperation (showProgressWindow: true)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
