//
//  CanariPadRenumberingPullDownButton.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2018.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariPadRenumberingPullDownButton
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariPadRenumberingPullDownButton : NSPopUpButton, EBUserClassNameProtocol {

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
  // MARK: -
  //····················································································································

  private weak var mDocument : CustomizedPackageDocument? = nil

  //····················································································································

  func register (document inDocument : CustomizedPackageDocument?) {
    self.mDocument = inDocument
  }

  //····················································································································
  // MARK: -
  //····················································································································

  private var mCurrentNumberController : EBReadOnlyController_Int?
  private var mCurrentPadNumber = 0

  //····················································································································

  func bind_currentNumber (_ model : EBReadOnlyProperty_Int, file : String, line : Int) {
    self.mCurrentNumberController = EBReadOnlyController_Int (
      model: model,
      callBack: { [weak self] in self?.update (from: model) }
     )
  }

  //····················································································································

  func unbind_currentNumber () {
    self.mCurrentNumberController?.unregister ()
    self.mCurrentNumberController = nil
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.prop {
    case .empty, .multiple :
      self.isEnabled = false
    case .single (let v) :
      self.mCurrentPadNumber = v
      self.isEnabled = self.mDocument != nil
      if let document = self.mDocument {
        let allPads = document.rootObject.packagePads_property.propval.sorted (by: { $0.padNumber < $1.padNumber } )
        self.removeAllItems ()
        self.autoenablesItems = false
        self.addItem (withTitle: "Exchange with")
        for pad in allPads {
          self.addItem (withTitle: "\(pad.padNumber)")
          let menuItem = self.lastItem!
          menuItem.isEnabled = pad.padNumber != v
          menuItem.target = self
          menuItem.action = #selector (CanariPadRenumberingPullDownButton.performRenumbering (_:))
          menuItem.tag = pad.padNumber
        }
      }
    }
  }

  //····················································································································

  @objc func performRenumbering (_ inSender: NSMenuItem) {
   // Swift.print ("Exchange \(self.mCurrentPadNumber) <-> \(inSender.tag)")
    if let document = self.mDocument {
      let allPads = document.rootObject.packagePads_property.propval
      for pad in allPads {
        if pad.padNumber == self.mCurrentPadNumber {
          pad.padNumber = inSender.tag
        }else if pad.padNumber == inSender.tag {
          pad.padNumber = self.mCurrentPadNumber
        }
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
