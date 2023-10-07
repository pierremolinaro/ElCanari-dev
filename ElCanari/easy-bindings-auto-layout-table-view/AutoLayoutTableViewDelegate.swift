//
//  AutoLayoutTableViewDelegate.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

@MainActor protocol AutoLayoutTableViewDelegate : AnyObject {

  func tableViewDelegate_selectionDidChange (selectedRows inSelectedRows : IndexSet)
  func tableViewDelegate_indexesOfSelectedObjects () -> IndexSet
  func tableViewDelegate_addEntry ()
  func tableViewDelegate_removeSelectedEntries ()

  func tableViewDelegate_beginSorting ()
  func tableViewDelegate_endSorting ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
