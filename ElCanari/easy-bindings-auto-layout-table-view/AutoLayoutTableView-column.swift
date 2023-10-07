//
//  AutoLayoutTableView-column.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// AutoLayoutTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor class AutoLayoutTableColumn : NSTableColumn {

  //····················································································································

  let mContentAlignment : NSTextAlignment
  let mSortDelegate : Optional < (_ inAscending : Bool) -> Void>

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : Int,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : TextAlignment) {
    self.mContentAlignment = inContentAlignment.cocoaAlignment
    self.mSortDelegate = inSortDelegate
    let name = String (inName)
    super.init (identifier: NSUserInterfaceItemIdentifier (rawValue: name))
    noteObjectAllocation (self)

    if inSortDelegate != nil {
      self.sortDescriptorPrototype = NSSortDescriptor (key: name, ascending: true)
    }
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
