//
//  AutoLayoutCanariDimensionUnitSetterPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 17/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariDimensionUnitSetterPullDownButton : AutoLayoutBase_NSPopUpButton {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (pullsDown: true,size: inSize)

//    self.controlSize = inSize.cocoaControlSize
//    self.font = NSFont.systemFont (ofSize: NSFont.systemFontSize (for: self.controlSize))
    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
    if let cell = self.cell as? NSPopUpButtonCell {
      cell.arrowPosition = .arrowAtBottom
    }

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

  override var acceptsFirstResponder: Bool { return false }

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

  private var mObjects = [EBObservableMutableProperty <Int>] ()

  //····················································································································

  final func bind_setter4 (_ inObject1 : EBObservableMutableProperty <Int>,
                           _ inObject2 : EBObservableMutableProperty <Int>,
                           _ inObject3 : EBObservableMutableProperty <Int>,
                           _ inObject4 : EBObservableMutableProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4]
    return self
  }

  //····················································································································

  final func bind_setter5 (_ inObject1 : EBObservableMutableProperty <Int>,
                           _ inObject2 : EBObservableMutableProperty <Int>,
                           _ inObject3 : EBObservableMutableProperty <Int>,
                           _ inObject4 : EBObservableMutableProperty <Int>,
                           _ inObject5 : EBObservableMutableProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5]
    return self
  }

  //····················································································································

  final func bind_setter6 (_ inObject1 : EBObservableMutableProperty <Int>,
                           _ inObject2 : EBObservableMutableProperty <Int>,
                           _ inObject3 : EBObservableMutableProperty <Int>,
                           _ inObject4 : EBObservableMutableProperty <Int>,
                           _ inObject5 : EBObservableMutableProperty <Int>,
                           _ inObject6 : EBObservableMutableProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5, inObject6]
    return self
  }

  //····················································································································

  final func bind_setter7 (_ inObject1 : EBObservableMutableProperty <Int>,
                           _ inObject2 : EBObservableMutableProperty <Int>,
                           _ inObject3 : EBObservableMutableProperty <Int>,
                           _ inObject4 : EBObservableMutableProperty <Int>,
                           _ inObject5 : EBObservableMutableProperty <Int>,
                           _ inObject6 : EBObservableMutableProperty <Int>,
                           _ inObject7 : EBObservableMutableProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5, inObject6, inObject7]
    return self
  }

  //····················································································································

  final func bind_setter8 (_ inObject1 : EBObservableMutableProperty <Int>,
                           _ inObject2 : EBObservableMutableProperty <Int>,
                           _ inObject3 : EBObservableMutableProperty <Int>,
                           _ inObject4 : EBObservableMutableProperty <Int>,
                           _ inObject5 : EBObservableMutableProperty <Int>,
                           _ inObject6 : EBObservableMutableProperty <Int>,
                           _ inObject7 : EBObservableMutableProperty <Int>,
                           _ inObject8 : EBObservableMutableProperty <Int>) -> Self {
    self.mObjects = [inObject1, inObject2, inObject3, inObject4, inObject5, inObject6, inObject7, inObject8]
    return self
  }

  //····················································································································

//  override func updateAutoLayoutUserInterfaceStyle () {
//    super.updateAutoLayoutUserInterfaceStyle ()
//    self.bezelStyle = autoLayoutCurrentStyle ().buttonStyle
//  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
