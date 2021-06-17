//
//  AutoLayoutCanariDimensionUnitSetterPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutCanariDimensionUnitSetterPullDownButton : NSPopUpButton, EBUserClassNameProtocol {

  //····················································································································

  init (small inSmall : Bool) {
    super.init (frame: NSRect (), pullsDown: true)
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false
    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.systemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
    self.bezelStyle = BUTTON_STYLE
    self.autoenablesItems = false
    self.addItem (withTitle: "Set All Pop-Up Units")
    self.add (title: "inch", withTag: 2_286_000)
    self.add (title: "mil", withTag: 2_286)
    self.add (title: "pt", withTag: 31_750)
    self.add (title: "cm", withTag: 900_000)
    self.add (title: "mm", withTag: 90_000)
    self.add (title: "µm", withTag: 90)
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

  fileprivate func add (title inTitle : String, withTag inTag : Int) {
    self.addItem (withTitle: inTitle)
    self.lastItem?.tag = inTag
    self.lastItem?.target = self
    self.lastItem?.action = #selector (Self.menuItemAction (_:))
  }

  //····················································································································

  @objc func menuItemAction (_ inSender : NSMenuItem) {
    let newUnit = inSender.tag
    for object in mObjects {
      object.setProp (newUnit)
    }
  }

  //····················································································································
  //  $setterN bindings
  //····················································································································

  private var mObjects = [EBGenericReadWriteProperty <Int>] ()

  //····················································································································

  final func bind_setter4 (_ inObject1 : EBGenericReadWriteProperty <Int>,
                           _ inObject2 : EBGenericReadWriteProperty <Int>,
                           _ inObject3 : EBGenericReadWriteProperty <Int>,
                           _ inObject4 : EBGenericReadWriteProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4]
    return self
  }

  //····················································································································

  final func bind_setter5 (_ inObject1 : EBGenericReadWriteProperty <Int>,
                           _ inObject2 : EBGenericReadWriteProperty <Int>,
                           _ inObject3 : EBGenericReadWriteProperty <Int>,
                           _ inObject4 : EBGenericReadWriteProperty <Int>,
                           _ inObject5 : EBGenericReadWriteProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5]
    return self
  }

  //····················································································································

  final func bind_setter6 (_ inObject1 : EBGenericReadWriteProperty <Int>,
                           _ inObject2 : EBGenericReadWriteProperty <Int>,
                           _ inObject3 : EBGenericReadWriteProperty <Int>,
                           _ inObject4 : EBGenericReadWriteProperty <Int>,
                           _ inObject5 : EBGenericReadWriteProperty <Int>,
                           _ inObject6 : EBGenericReadWriteProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5, inObject6]
    return self
  }

  //····················································································································

  final func bind_setter7 (_ inObject1 : EBGenericReadWriteProperty <Int>,
                           _ inObject2 : EBGenericReadWriteProperty <Int>,
                           _ inObject3 : EBGenericReadWriteProperty <Int>,
                           _ inObject4 : EBGenericReadWriteProperty <Int>,
                           _ inObject5 : EBGenericReadWriteProperty <Int>,
                           _ inObject6 : EBGenericReadWriteProperty <Int>,
                           _ inObject7 : EBGenericReadWriteProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5, inObject6, inObject7]
    return self
  }

  //····················································································································

  final func bind_setter8 (_ inObject1 : EBGenericReadWriteProperty <Int>,
                           _ inObject2 : EBGenericReadWriteProperty <Int>,
                           _ inObject3 : EBGenericReadWriteProperty <Int>,
                           _ inObject4 : EBGenericReadWriteProperty <Int>,
                           _ inObject5 : EBGenericReadWriteProperty <Int>,
                           _ inObject6 : EBGenericReadWriteProperty <Int>,
                           _ inObject7 : EBGenericReadWriteProperty <Int>,
                           _ inObject8 : EBGenericReadWriteProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5, inObject6, inObject7, inObject8]
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
