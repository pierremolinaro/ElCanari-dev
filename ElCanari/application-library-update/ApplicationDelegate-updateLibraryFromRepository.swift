
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func updateLibrary (_ inSender : AnyObject) {
    if let logTextView = g_Preferences?.mLibraryUpdateLogTextView {
      g_Preferences?.mCheckingForLibraryUpdateProgressIndicator?.startAnimation (nil)
      let optionKey : Bool = NSApp.currentEvent?.modifierFlags.contains (.option) ?? false
      // Swift.print ("optionKey \(optionKey)")
      if optionKey {
        startLibraryRevisionListOperation (logTextView)
      }else{
        startLibraryUpdateOperation (g_Preferences?.mCheckingForLibraryUpdateWindow, logTextView)
      }
    }
  }

  //····················································································································

  @IBAction func cancelLibraryUpdateAction (_ inSender : AnyObject) {
    cancelLibraryUpdate ()
  }

  //····················································································································

  @IBAction func performLibraryUpdateAction (_ inSender : AnyObject) {
    startLibraryUpdate ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
