//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutTaggedPopUpButton : ALB_NSPopUpButton {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private struct TaggedTitle {
    let title : String
    let tag : Int
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTitles : [TaggedTitle] = []

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (size inSize : EBControlSize) {
    super.init (pullsDown: false, size: inSize.cocoaControlSize)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func add (title inTitle : String, withTag inTag : Int) -> Self {
    self.mTitles.append (TaggedTitle (title: inTitle, tag: inTag))
    self.addItem (withTitle: inTitle)
    self.lastItem?.tag = inTag
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateTag (from inObject : EBObservableMutableProperty <Int>) {
    self.removeAllItems ()
    switch inObject.selection {
    case .single (let v) :
      for item in self.mTitles {
        self.addItem (withTitle: item.title)
        self.lastItem?.tag = item.tag
      }
      self.enable (fromValueBinding: true, self.enabledBindingController ())
      self.selectItem (withTag: v)
    case .empty :
      self.addItem (withTitle: "No Selection")
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    case .multiple :
      for item in self.mTitles {
        self.addItem (withTitle: item.title)
        self.lastItem?.tag = item.tag
      }
      self.addItem (withItalicTitle: "Multiple Selection")
      self.enable (fromValueBinding: false, self.enabledBindingController ())
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func sendAction (_ action : Selector?, to : Any?) -> Bool {
    if self.indexOfSelectedItem < self.mTitles.count { // Prevent from "Multiple Selection"
      self.mSelectedTagController?.updateModel (withValue: self.selectedTag ())
    }
    return super.sendAction (action, to: to)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $selectedTag binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSelectedTagController : EBGenericReadWritePropertyController <Int>? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_selectedTag (_ inObject : EBObservableMutableProperty <Int>) -> Self {
    self.mSelectedTagController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  Closure action
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

//  final private var mClosureAction : Optional < () -> Void > = nil
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//  final func setClosureAction (_ inClosureAction : @escaping () -> Void) -> Self {
//    self.mClosureAction = inClosureAction
//    self.target = self
//    self.action = #selector (Self.runClosureAction (_:))
//    return self
//  }
//
//  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
//   @objc private final func runClosureAction (_ _ : Any?) {
//     self.mClosureAction? ()
//  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
