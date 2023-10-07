//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutTaggedPopUpButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  final func add (title inTitle : String, withTag inTag : Int) -> Self {
    self.addItem (withTitle: inTitle)
    self.lastItem?.tag = inTag
    return self
  }

  //····················································································································

  func updateTag (from inObject : EBObservableMutableProperty <Int>) {
    switch inObject.selection {
    case .single (let v) :
      self.enable (fromValueBinding: true, self.enabledBindingController)
      self.selectItem (withTag: v)
    case .empty :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    case .multiple :
      self.enable (fromValueBinding: false, self.enabledBindingController)
    }
  }

  //····················································································································

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    self.mSelectedTagController?.updateModel (withValue: self.selectedTag ())
    return super.sendAction (action, to: to)
  }

  //····················································································································
  //  $selectedTag binding
  //····················································································································

  private var mSelectedTagController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  final func bind_selectedTag (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mSelectedTagController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
