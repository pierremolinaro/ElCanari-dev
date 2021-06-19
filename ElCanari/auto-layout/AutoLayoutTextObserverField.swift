//
//  AutoLayoutTextObserverField.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 15/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------
//   AutoLayoutTextObserverField
//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutTextObserverField : NSTextField, EBUserClassNameProtocol {

  //····················································································································

  init (bold inBold : Bool, small inSmall : Bool) {
    super.init (frame: NSRect ())
    noteObjectAllocation (self)
    self.translatesAutoresizingMaskIntoConstraints = false

    self.controlSize = inSmall ? .small : .regular
    let s = inSmall ? NSFont.smallSystemFontSize : NSFont.systemFontSize
    self.font = inBold ? NSFont.boldSystemFont (ofSize: s) : NSFont.systemFont (ofSize: s)
    self.alignment = .center
    self.isBezeled = false
    self.isBordered = false
    self.drawsBackground = false
    self.isEditable = false
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

//  override var intrinsicContentSize : NSSize {
//    return NSSize (width: 56.0, height: 19.0)
//  }

  //····················································································································

  override func ebCleanUp () {
    self.mValueController?.unregister ()
    self.mValueController = nil
    super.ebCleanUp ()
  }

  //····················································································································
  //  value binding
  //····················································································································

  fileprivate func updateOutlet (_ inModel : EBReadOnlyProperty_String) {
    switch inModel.selection {
    case .empty :
      self.placeholderString = "No Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: false)
    case .multiple :
      self.placeholderString = "Multiple Selection"
      self.stringValue = ""
      self.enable (fromValueBinding: true)
    case .single (let propertyValue) :
      self.placeholderString = nil
      self.stringValue = propertyValue
      self.enable (fromValueBinding: true)
    }
  }

  //····················································································································

  private var mValueController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_observedValue (_ inModel : EBReadOnlyProperty_String) -> Self {
    self.mValueController = EBReadOnlyPropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateOutlet (inModel) }
    )
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
