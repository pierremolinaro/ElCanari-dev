//
//  AutoLayoutTableView-column-NSImage.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension AutoLayoutTableView {

  //····················································································································

  func addColumn_NSImage (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSImage?,
                          valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : NSImage) -> Void >,
                          sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                          title inTitle : String,
                          minWidth inMinWidth : Int,
                          maxWidth inMaxWidth : Int,
                          headerAlignment inHeaderAlignment : TextAlignment,
                          contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalImageValueTableColumn (
      withIdentifierNamed: String (self.columnCount),
      sortDelegate: inSortDelegate,
      contentAlignment: inContentAlignment.cocoaAlignment,
      valueGetterDelegate: inGetterDelegate
    )
    column.title = inTitle
    column.headerCell.alignment = inHeaderAlignment.cocoaAlignment
    column.minWidth = CGFloat (inMinWidth)
    column.maxWidth = CGFloat (inMaxWidth)
    column.width = (column.minWidth + column.maxWidth) / 2.0
  //--- Add Column
    self.appendTableColumn (column)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// InternalImageValueTableColumn
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class InternalImageValueTableColumn : AutoLayoutTableColumn {

  //····················································································································

  private let mValueGetterDelegate : (_ inRow : Int) -> NSImage?

  //····················································································································
  // INIT
  //····················································································································

  init (withIdentifierNamed inName : String,
        sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        contentAlignment inContentAlignment : NSTextAlignment,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSImage?) {
    self.mValueGetterDelegate = inGetterDelegate
    super.init (withIdentifierNamed: inName, sortDelegate: inSortDelegate, contentAlignment: inContentAlignment)
    self.isEditable = false
  }

  //····················································································································

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    let imageView = NSImageView ()
    imageView.translatesAutoresizingMaskIntoConstraints = false

    imageView.tag = inRowIndex
    imageView.isEditable = false
    imageView.image = self.mValueGetterDelegate (inRowIndex)
    return imageView
  }

  //····················································································································

}
