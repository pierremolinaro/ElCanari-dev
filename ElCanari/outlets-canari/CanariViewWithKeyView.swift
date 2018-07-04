import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@objc(CanariViewWithKeyView) class CanariViewWithKeyView : NSView, EBUserClassNameProtocol {
  private weak var mSavedFirstResponder : NSResponder?

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder:coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  override init (frame:NSRect) {
    super.init (frame:frame)
    noteObjectAllocation (self)
  }
  
  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  final func saveFirstResponder () {
//    if let savedKeyView = self.window?.firstResponder as? NSView, savedKeyView.isDescendant (of: self) {
//      mSavedFirstResponder = self.window?.firstResponder
//    }else{
//      mSavedFirstResponder = nil
//    }
    //  NSLog ("saveFirstResponder: \(String(describing: mSavedFirstResponder))")
  }

  //····················································································································

   func restoreFirstResponder () {
     // NSLog ("restoreFirstResponder: \(String(describing: mSavedFirstResponder)), window \(String(describing: self.window)))")
 //    self.window?.makeFirstResponder (mSavedFirstResponder)
 //    DispatchQueue.main.asyncAfter (deadline: .now (), execute: { self.window?.makeFirstResponder (self.mSavedFirstResponder) })
  }

  //····················································································································

  override var mouseDownCanMoveWindow : Bool { return false }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
