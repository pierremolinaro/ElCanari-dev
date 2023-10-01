//
//  AutoLayoutGenericTableView-column.swift.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 01/10/2023.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// AutoLayoutGenericTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor class AutoLayoutGenericTableColumn <ELEMENT : EBManagedObject> : NSTableColumn {

  //····················································································································

  let mContentAlignment : NSTextAlignment
  let mSortDelegate : Optional < (_ inAscending : Bool) -> Void>
  final weak var mSourceArray : ReadOnlyAbstractArrayProperty <ELEMENT>? = nil // SHOULD BE WEAK

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sourceArray inSourceArray : ReadOnlyAbstractArrayProperty <ELEMENT>?,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment) {
    self.mContentAlignment = inContentAlignment
    self.mSortDelegate = inSortDelegate
    self.mSourceArray = inSourceArray
    super.init (identifier: NSUserInterfaceItemIdentifier (rawValue: inName))
    noteObjectAllocation (self)

    if inSortDelegate != nil {
      self.sortDescriptorPrototype = NSSortDescriptor (key: inName, ascending: true)
    }
  }

  func setModel (_ inModel : ReadOnlyAbstractArrayProperty <ELEMENT>) {
    self.mSourceArray = inModel
    NSSound.beep()
  }
  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································

  func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? { // Abstract method
    return nil
  }

  //····················································································································

}

