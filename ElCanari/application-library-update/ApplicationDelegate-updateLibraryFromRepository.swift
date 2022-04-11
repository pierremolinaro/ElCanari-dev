
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func updateLibrary (_ inSender : AnyObject) {
    if let logTextView = g_Preferences?.mLibraryUpdateLogTextView {
      let optionKey : Bool = NSApp.currentEvent?.modifierFlags.contains (.option) ?? false
      if optionKey {
        startLibraryRevisionListOperation (logTextView)
      }else{
        startLibraryUpdateOperation (showProgressWindow: true, logTextView)
      }
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
