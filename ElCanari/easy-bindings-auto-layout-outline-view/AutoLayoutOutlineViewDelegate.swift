//
//  AutoLayoutOutlineViewDelegate.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 28/11/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor protocol AutoLayoutOutlineViewDelegate : AnyObject {

  func outlineViewDelegate_selectionDidChange (selectedRows inSelectedRows : IndexSet)
  func outlineViewDelegate_indexesOfSelectedObjects () -> IndexSet
  func outlineViewDelegate_addEntry ()
  func outlineViewDelegate_removeSelectedEntries ()

  func outlineViewDelegate_beginSorting ()
  func outlineViewDelegate_endSorting ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————
