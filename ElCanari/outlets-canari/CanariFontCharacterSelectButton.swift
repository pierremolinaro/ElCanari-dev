import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariFontCharacterSelectButton : NSButton, EBUserClassNameProtocol {
  private var mCharacterSelectionPopover : NSPopover? = nil
  private var mSelectionView : CanariFontCharacterSelectView? = nil

  //····················································································································

  fileprivate var mSelectedCharacterCode : Int = 0x167 {
    didSet {
      self.title = String (Unicode.Scalar (mSelectedCharacterCode)!)
    }
  }

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
    noteObjectDeallocation (String (describing: type(of: self)))
  }

  //····················································································································

  override func mouseDown (with inEvent : NSEvent) {
    let eventLocationInWindowCoordinates = inEvent.locationInWindow
    let s = CanariFontCharacterSelectView.requiredSize ()
    let r = NSRect (x:eventLocationInWindowCoordinates.x + 30.0,
                    y:eventLocationInWindowCoordinates.y - s.height / 2.0,
                    width:s.width,
                    height:s.height)
    let viewController = NSViewController.init (nibName:nil, bundle:nil)
    let selectionView = CanariFontCharacterSelectView (frame:r)
    selectionView.setMouseDownSelectedCharacterCode (mSelectedCharacterCode)
    viewController.view = selectionView
    let popover = NSPopover ()
    popover.contentSize = s
    popover.contentViewController = viewController
    popover.animates = true
    popover.show (relativeTo: self.bounds, of:self, preferredEdge:NSRectEdge.maxX)
    mSelectionView = selectionView
    mCharacterSelectionPopover = popover
  }

  //····················································································································

  override func mouseDragged (with inEvent : NSEvent) {
    if let unwWindow = self.window {
      let eventLocationInWindowCoordinates = inEvent.locationInWindow
      let r = NSRect (x:eventLocationInWindowCoordinates.x,
                      y:eventLocationInWindowCoordinates.y,
                      width:0.0,
                      height:0.0)
      let rr = unwWindow.convertToScreen (r)
      mSelectionView?.mouseDraggedAtScreenPoint (rr)
    }
  }

  //····················································································································

  override func mouseUp (with inEvent : NSEvent) {
    if let selectionView = mSelectionView {
      let selectedCharacterCode = selectionView.selectedCharacterCode ()
      if selectedCharacterCode != 0 {
        mSelectedCharacterCode = selectionView.selectedCharacterCode ()
        mController?.updateModel ()
      }
    }
    mCharacterSelectionPopover?.close ()
    mCharacterSelectionPopover = nil ;
    mSelectionView = nil ;
  }

  //····················································································································
  //  codePoint binding                                                                                                *
  //····················································································································

  private var mController : Controller_CanariFontCharacterSelectButton_codePoint?

  func bind_codePoint (_ object:EBReadWriteProperty_Int, file:String, line:Int) {
    mController = Controller_CanariFontCharacterSelectButton_codePoint (object:object, outlet:self, file:file, line:line)
  }

  func unbind_codePoint () {
    mController?.unregister ()
    mController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariFontCharacterSelectButton_codePoint                                                              *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariFontCharacterSelectButton_codePoint : EBSimpleController {

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : CanariFontCharacterSelectButton

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : CanariFontCharacterSelectButton, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects:[object])
    self.mEventCallBack = { [weak self] in self?.updateOutlet () }
  }

  //····················································································································

  private func updateOutlet () {
    switch self.mObject.prop {
    case .empty :
      self.mOutlet.enableFromValueBinding (false)
      self.mOutlet.title = ""
    case .single (let v) :
      self.mOutlet.enableFromValueBinding (true)
      self.mOutlet.mSelectedCharacterCode = v
    case .multiple :
      self.mOutlet.enableFromValueBinding (false)
      self.mOutlet.title = ""
    }
  }

  //····················································································································

  fileprivate func updateModel () {
    _ = self.mObject.validateAndSetProp (Int (self.mOutlet.mSelectedCharacterCode), windowForSheet:mOutlet.window)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
