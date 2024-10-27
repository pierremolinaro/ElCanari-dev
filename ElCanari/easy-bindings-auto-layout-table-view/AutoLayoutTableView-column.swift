//
//  AutoLayoutTableView-column.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
// AutoLayoutTableColumn
//--------------------------------------------------------------------------------------------------

class AutoLayoutTableColumn : NSTableColumn {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let mContentAlignment : NSTextAlignment
  let mSortDelegate : Optional < (_ inAscending : Bool) -> Void >

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        title inTitle : String,
        minWidth inMinWidth : Int,
        maxWidth inMaxWidth : Int,
        headerAlignment inHeaderAlignment : TextAlignment,
        contentAlignment inContentAlignment : TextAlignment) {
    self.mContentAlignment = inContentAlignment.cocoaAlignment
    self.mSortDelegate = inSortDelegate
    super.init (identifier: NSUserInterfaceItemIdentifier (rawValue: ""))
    noteObjectAllocation (self)

    self.title = inTitle
    self.headerCell.alignment = inHeaderAlignment.cocoaAlignment
    self.minWidth = CGFloat (inMinWidth)
    self.maxWidth = CGFloat (inMaxWidth)
//    self.width = (self.minWidth + self.maxWidth) / 2.0
    self.width = self.minWidth // §§

    let name : String = "\(ObjectIdentifier (self))"
    self.identifier =  NSUserInterfaceItemIdentifier (rawValue: name)
    if inSortDelegate != nil {
      self.sortDescriptorPrototype = NSSortDescriptor (key: name, ascending: true)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? { // Abstract method
    return nil
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
