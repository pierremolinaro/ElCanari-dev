//
//  AutoLayoutCanariUnitPopUpButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 06/02/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

class AutoLayoutCanariUnitPopUpButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init () {
    super.init (frame: NSRect (), pullsDown: false)
    noteObjectAllocation (self)
    self.controlSize = .small
    self.bezelStyle = .roundRect
    self.add (title: "inch", withTag: 2_286_000)
    self.add (title: "mil", withTag: 2_286)
    self.add (title: "pt", withTag: 31_750)
    self.add (title: "cm", withTag: 900_000)
    self.add (title: "mm", withTag: 90_000)
    self.add (title: "µm", withTag: 90)
    self.add (title: "pc", withTag: 381_000)
    self.add (title: "m", withTag: 90_000_000)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
  //····················································································································

  override func ebCleanUp () {
    self.mSelectedUnitController?.unregister ()
    self.mSelectedUnitController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  override var intrinsicContentSize : NSSize {
    let s = super.intrinsicContentSize
    return NSSize (width: 60.0, height: s.height)
  }

  //····················································································································

  fileprivate func add (title inTitle : String, withTag inTag : Int) {
    self.addItem (withTitle: "")
    let textAttributes : [NSAttributedString.Key : Any] = [
      NSAttributedString.Key.font : NSFont.systemFont (ofSize: NSFont.smallSystemFontSize)
    ]
    let attributedTitle = NSAttributedString (string: inTitle, attributes: textAttributes)
    self.lastItem?.attributedTitle = attributedTitle
    self.lastItem?.tag = inTag
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
    _ = self.mSelectedUnitController?.updateModel (withCandidateValue: self.selectedTag (), windowForSheet: self.window)
    return super.sendAction (action, to: to)
  }

  //····················································································································
  //  $selectedUnit binding
  //····················································································································

  private var mSelectedUnitController : EBGenericReadWritePropertyController <Int>? = nil

  //····················································································································

  func bind_unit (_ inObject : EBGenericReadWriteProperty <Int>) -> Self {
    self.mSelectedUnitController = EBGenericReadWritePropertyController <Int> (
      observedObject: inObject,
      callBack: { [weak self] in self?.updateTag (from: inObject) }
    )
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
