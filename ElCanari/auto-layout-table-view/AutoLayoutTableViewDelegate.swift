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

  func tableViewSelectionDidChange (selectedRows inSelectedRows : IndexSet)
  func indexesOfSelectedObjects () -> IndexSet
  func addEntry ()
  func removeSelectedEntries ()

  func beginSorting ()
  func endSorting ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
