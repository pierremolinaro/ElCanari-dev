//
//  AutoLayoutIntObserverField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutIntObserverField
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutIntObserverField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  private let mNumberFormatter = NumberFormatter ()

  //····················································································································

  init (small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.controlSize = inSmall ? .small : .regular
    self.font = NSFont.boldSystemFont (ofSize: inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize)
    self.alignment = .center
    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEditable = false
//--- Number formatter
    self.mNumberFormatter.formatterBehavior = .behavior10_4
    self.mNumberFormatter.numberStyle = .decimal
    self.mNumberFormatter.localizesFormat = true
    self.mNumberFormatter.minimumFractionDigits = 0
    self.mNumberFormatter.maximumFractionDigits = 0
    self.mNumberFormatter.isLenient = true
    self.formatter = self.mNumberFormatter
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
    self.mController?.unregister ()
    self.mController = nil
    super.ebCleanUp ()
  }

  //····················································································································

  final func set (format inFormatString : String) -> Self {
    self.mNumberFormatter.format = inFormatString
    return self
  }

  //····················································································································
  //  observedValue binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_observedValue (_ inObject : EBReadOnlyProperty_Int) -> Self {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [inObject],
      callBack:  { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  private func update (from model : EBReadOnlyProperty_Int) {
    switch model.selection {
    case .empty :
      self.enable (fromValueBinding: false)
      self.placeholderString = "No Selection"
      self.stringValue = ""
    case .single (let v) :
      self.enable (fromValueBinding: true)
      self.placeholderString = nil
      self.intValue = Int32 (v)
    case .multiple :
      self.enable (fromValueBinding: false)
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
