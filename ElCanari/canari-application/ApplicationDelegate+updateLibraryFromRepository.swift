
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func updateLibrary (_ inSender : AnyObject) {
    g_Preferences?.mCheckingForLibraryUpdateProgressIndicator?.startAnimation (nil)
    performLibraryUpdate (g_Preferences?.mCheckingForLibraryUpdateWindow)
    g_Preferences?.systemLibraryCheckTimeIntervalAction (nil)
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
