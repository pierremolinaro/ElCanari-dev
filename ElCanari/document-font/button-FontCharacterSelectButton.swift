import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class FontCharacterSelectButton : NSButton, EBUserClassNameProtocol {
  private var mCharacterSelectionPopover : NSPopover? = nil
  private var mSelectionView : FontCharacterSelectView? = nil
  private var mDefinedCharacterSet = Set <Int> ()

  //····················································································································

  fileprivate var mSelectedCharacterCode : Int = 0x167 {
    didSet {
      self.title = String (Unicode.Scalar (self.mSelectedCharacterCode)!)
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
    noteObjectDeallocation (self)
  }

  //····················································································································

  internal func setDefinedCharacterSet (_ inSet : Set <Int>) {
    self.mDefinedCharacterSet = inSet
    self.isEnabled = inSet.count > 0
  }

  //····················································································································

  override func mouseDown (with inEvent : NSEvent) {
    let eventLocationInWindowCoordinates = inEvent.locationInWindow
    let s = FontCharacterSelectView.requiredSizeForCharacterSet (self.mDefinedCharacterSet, self.window)
    let r = NSRect (x:eventLocationInWindowCoordinates.x + 30.0,
                    y:eventLocationInWindowCoordinates.y - s.height / 2.0,
                    width:s.width,
                    height:s.height)
    let viewController = NSViewController.init (nibName:nil, bundle:nil)
    let selectionView = FontCharacterSelectView (frame:r)
    selectionView.setDefinedCharacterSet (self.mDefinedCharacterSet)
    selectionView.setMouseDownSelectedCharacterCode (self.mSelectedCharacterCode)
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
        mCodePointController?.updateModel ()
      }
    }
    mCharacterSelectionPopover?.close ()
    mCharacterSelectionPopover = nil ;
    mSelectionView = nil ;
  }

  //····················································································································
  //  $codePoint binding                                                                                                *
  //····················································································································

  private var mCodePointController : Controller_CanariFontCharacterSelectButton_codePoint?

  func bind_codePoint (_ object:EBReadWriteProperty_Int, file:String, line:Int) {
    self.mCodePointController = Controller_CanariFontCharacterSelectButton_codePoint (object:object, outlet:self, file:file, line:line)
  }

  func unbind_codePoint () {
    self.mCodePointController?.unregister ()
    self.mCodePointController = nil
  }

  //····················································································································
  //  $characters binding                                                                                                *
  //····················································································································

  fileprivate func updateCodePoint (_ object : EBReadOnlyProperty_Int) {
    switch object.prop {
    case .empty :
      self.enableFromValueBinding (false)
      self.title = ""
    case .single (let v) :
      self.enableFromValueBinding (true)
      self.mSelectedCharacterCode = v
    case .multiple :
      self.enableFromValueBinding (false)
      self.title = ""
    }
  }

  //····················································································································

  private var mCharactersController : EBReadOnlyController_DefinedCharactersInDevice?

  func bind_characters (_ model : EBTransientProperty_DefinedCharactersInDevice, file : String, line : Int) {
    self.mCharactersController = EBReadOnlyController_DefinedCharactersInDevice (
      observedObjects: [model],
      callBack: { [weak self] in
        switch model.prop {
        case .empty, .multiple :
          self?.setDefinedCharacterSet ([])
        case .single (let s) :
          self?.setDefinedCharacterSet (s.values)
        }
      }
    )
  }

  func unbind_characters () {
    self.mCharactersController?.unregister ()
    self.mCharactersController = nil
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Controller_CanariFontCharacterSelectButton_codePoint                                                              *
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_CanariFontCharacterSelectButton_codePoint : EBSimpleController {

  private let mObject : EBReadWriteProperty_Int
  private let mOutlet : FontCharacterSelectButton

  //····················································································································

  init (object : EBReadWriteProperty_Int, outlet : FontCharacterSelectButton, file : String, line : Int) {
    mObject = object
    mOutlet = outlet
    super.init (observedObjects: [object], callBack: { outlet.updateCodePoint (object) })
  }

  //····················································································································

  fileprivate func updateModel () {
    _ = self.mObject.validateAndSetProp (Int (self.mOutlet.mSelectedCharacterCode), windowForSheet:mOutlet.window)
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
