
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension ApplicationDelegate {

  //····················································································································

  @IBAction func updateLibrary (_ inSender : AnyObject) {
    if let logTextView = g_Preferences?.mLibraryUpdateLogTextView {
      g_Preferences?.mCheckingForLibraryUpdateProgressIndicator?.startAnimation (nil)
      performLibraryUpdate (g_Preferences?.mCheckingForLibraryUpdateWindow, logTextView)
    }else{
      NSLog ("g_Preferences?.mLibraryUpdateLogTextView is nil")
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
