//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutTaggedPopUpButton : InternalAutoLayoutPopUpButton {

  //····················································································································

  init () {
    super.init (pullsDown: false, small: true)
//    noteObjectAllocation (self)
//    self.translatesAutoresizingMaskIntoConstraints = false
//
//    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
//    if let cell = self.cell as? NSPopUpButtonCell {
//      cell.arrowPosition = .arrowAtBottom
//    }
//
//    self.controlSize = .small
//    self.font = NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
//    self.font = NSFont.systemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

//  deinit {
//    noteObjectDeallocation (self)
//  }

  //····················································································································

  override func ebCleanUp () {
    self.mSelectedTagController?.unregister ()
    self.mSelectedTagController = nil
    super.ebCleanUp ()
  }

  //····················································································································

//  override func updateAutoLayoutUserInterfaceStyle () {
//    super.updateAutoLayoutUserInterfaceStyle ()
//    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
//  }

  //····················································································································

  final func add (title inTitle : String, withTag inTag : Int) -> Self {
    self.addItem (withTitle: "")
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    let attributedTitle = NSAttributedString (string: inTitle, attributes: textAttributes)
    self.lastItem?.attributedTitle = attributedTitle
    self.lastItem?.tag = inTag
    return self
  }

  //····················································································································

  func updateTag (from inObject : EBGenericReadWriteProperty <Int>) {
    switch inObject.selection {
    case .single (let v) :
      self.enable (fromValueBinding: true)
      self.selectItem (withTag: v)
    case .empty :
      self.enable (fromValueBinding: false)
    case .multiple :
      self.enable (fromValueBinding: false)
    }
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    _ = self.mSelectedTagController?.updateModel (withCandidateValue: self.selectedTag (), windowForSheet: self.window)
    return super.sendAction (action, to: to)
  }

  //····················································································································
  //  $selectedTag binding
  //····················································································································

  private var mSelectedTagController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_selectedTag (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mSelectedTagController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
