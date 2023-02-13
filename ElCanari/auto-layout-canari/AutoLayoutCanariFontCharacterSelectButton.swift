import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariFontCharacterSelectButton : AutoLayoutBase_NSButton {
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

  init () {
    super.init (title: "", size: .small)

//    self.controlSize = .small
//    self.font = NSFont.boldSystemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.bezelStyle = .rounded
  }

  //····················································································································

  required init? (coder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func setDefinedCharacterSet (_ inSet : Set <Int>) {
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
    self.mSelectionView = selectionView
    self.mCharacterSelectionPopover = popover
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
      self.mSelectionView?.mouseDraggedAtScreenPoint (rr)
    }
  }

  //····················································································································

  override func mouseUp (with inEvent : NSEvent) {
    if let selectionView = self.mSelectionView {
      let selectedCharacterCode = selectionView.selectedCharacterCode ()
      if selectedCharacterCode != 0 {
        self.mSelectedCharacterCode = selectionView.selectedCharacterCode ()
        self.mCodePointController?.updateModel (withValue: self.mSelectedCharacterCode)
      }
    }
    self.mCharacterSelectionPopover?.close ()
    self.mCharacterSelectionPopover = nil ;
    self.mSelectionView = nil ;
  }

  //····················································································································
  //  $codePoint binding
  //····················································································································

  private var mCodePointController : EBGenericReadWritePropertyController <Int>?

  //····················································································································

  final func bind_codePoint (_ object : EBReadWriteProperty_Int) -> Self {
    self.mCodePointController = EBGenericReadWritePropertyController <Int> (
      observedObject: object,
      callBack: { [weak self] in self?.updateCodePoint (object) }
    )
    return self
  }

  //····················································································································

//  final func unbind_codePoint () {
//    self.mCodePointController?.unregister ()
//    self.mCodePointController = nil
//  }

  //····················································································································
  //  $characters binding
  //····················································································································

  fileprivate func updateCodePoint (_ object : EBReadOnlyProperty_Int) {
    switch object.selection {
    case .empty :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.title = ""
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.mSelectedCharacterCode = v
    case .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
      self.title = ""
    }
  }

  //····················································································································
  //  $characters binding
  //····················································································································

  private var mCharactersController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_characters (_ inModel : EBTransientProperty_DefinedCharactersInDevice) -> Self {
    self.mCharactersController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in
        switch inModel.selection {
        case .empty, .multiple :
          self?.setDefinedCharacterSet ([])
        case .single (let s) :
          self?.setDefinedCharacterSet (s.values)
        }
      }
    )
    return self
  }

  //····················································································································

//  final func unbind_characters () {
//    self.mCharactersController?.unregister ()
//    self.mCharactersController = nil
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
