import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class CanariViewWithKeyView : NSView, EBUserClassNameProtocol {

  //····················································································································

  required init? (coder : NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame : NSRect) {
    super.init (frame: frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  override var mouseDownCanMoveWindow : Bool { return false }

  //····················································································································
  // First responder
  //····················································································································

  private var mSavedFirstResponder : NSResponder? = nil

  //····················································································································

  func saveFirstResponder () {
    self.mSavedFirstResponder = self.window?.firstResponder
  }

  //····················································································································

  func restoreFirstResponder () {
    if let savedFirstResponder = self.mSavedFirstResponder as? NSView, savedFirstResponder.window == self.window {
      // Swift.print ("Saved : \(savedFirstResponder)")
      _ = self.window?.makeFirstResponder (savedFirstResponder)
    }
  }

  //····················································································································

  override func ebCleanUp () {
    // Swift.print ("ebCleanUp")
    self.mSavedFirstResponder = nil
    super.ebCleanUp ()
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
