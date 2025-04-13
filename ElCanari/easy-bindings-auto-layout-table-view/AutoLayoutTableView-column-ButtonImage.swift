//
//  AutoLayoutTableView-column-ButtonImage.swift
//  essai-editeur-texte-swift
//
//  Created by Pierre Molinaro on 08/10/2023.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

extension AutoLayoutTableView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addColumn_ButtonImage (valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSImage?,
                                    valueSetterDelegate inSetterDelegate : Optional < (_ inRow : Int, _ inNewValue : NSImage) -> Void >,
                                    actionDelegate inActionDelegate : @escaping (_ inRow : Int) -> Void,
                                    sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
                                    title inTitle : String,
                                    minWidth inMinWidth : Int,
                                    maxWidth inMaxWidth : Int,
                                    headerAlignment inHeaderAlignment : TextAlignment,
                                    contentAlignment inContentAlignment : TextAlignment) {
    let column = InternalButtonImageTableColumn (
      sortDelegate: inSortDelegate,
      title: inTitle,
      minWidth: inMinWidth,
      maxWidth: inMaxWidth,
      headerAlignment: inHeaderAlignment,
      contentAlignment: inContentAlignment,
      valueGetterDelegate: inGetterDelegate,
      actionDelegate: inActionDelegate
    )
  //--- Add Column
    self.appendTableColumn (column)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
// InternalButtonImageTableColumn
//--------------------------------------------------------------------------------------------------

fileprivate class InternalButtonImageTableColumn : AutoLayoutTableColumn {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mValueGetterDelegate : (_ inRow : Int) -> NSImage?
  private let mActionDelegate : (_ inRow : Int) -> Void

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (sortDelegate inSortDelegate : Optional < (_ inAscending : Bool) -> Void>,
        title inTitle : String,
        minWidth inMinWidth : Int,
        maxWidth inMaxWidth : Int,
        headerAlignment inHeaderAlignment : TextAlignment,
        contentAlignment inContentAlignment : TextAlignment,
        valueGetterDelegate inGetterDelegate : @escaping (_ inRow : Int) -> NSImage?,
        actionDelegate inActionDelegate : @escaping (_ inRow : Int) -> Void) {
    self.mValueGetterDelegate = inGetterDelegate
    self.mActionDelegate = inActionDelegate
    super.init (
      sortDelegate: inSortDelegate,
      title: inTitle,
      minWidth: inMinWidth,
      maxWidth: inMaxWidth,
      headerAlignment: inHeaderAlignment,
      contentAlignment: inContentAlignment
    )
    self.isEditable = false
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func configureTableCellView (forRowIndex inRowIndex : Int) -> NSView? {
    if let image = self.mValueGetterDelegate (inRowIndex) {
      let button = NSButton ()
      button.translatesAutoresizingMaskIntoConstraints = false

      button.bezelStyle = .regularSquare
      button.isBordered = false
      button.imagePosition = .imageOnly

      button.target = self
      button.action = #selector (Self.buttonAction (_:))

      button.tag = inRowIndex
      button.image = image
      return button
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor @objc private func buttonAction (_ inSender : NSButton) {
    let rowIndex = inSender.tag
    self.mActionDelegate (rowIndex)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
