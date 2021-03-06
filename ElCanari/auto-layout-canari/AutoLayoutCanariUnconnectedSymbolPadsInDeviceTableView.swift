//
//  AutoLayoutCanariUnconnectedSymbolPadsInDeviceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariUnconnectedSymbolPadsInDeviceTableView : AutoLayoutVerticalStackView, AutoLayoutTableViewDelegate {

  //····················································································································

  private let mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
  private var mDataSource = [String] ()

  //····················································································································

  override init () {
    super.init ()

    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      delegate: self
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0] ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return values_String_are_ordered ($0, ascending, $1) }
      },
      title: "Pad",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .center,
      contentAlignment: .center
    )
    self.appendView (self.mTableView)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  //  selectedPadName
  //····················································································································

  var selectedPadName : String? {
    if self.mTableView.selectedRow >= 0 {
      return self.mDataSource [self.mTableView.selectedRow]
    }else{
      return nil
    }
  }

  //····················································································································
  //  $unconnectedPads binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_unconnectedPads (_ model : EBReadOnlyProperty_StringArray) -> Self {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateUnconnectedPadList (from: model) }
    )
    return self
  }

  //····················································································································

  final func unbind_assignedPadProxies () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

  func updateUnconnectedPadList (from inModel : EBReadOnlyProperty_StringArray) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mDataSource = []
      self.mTableView.sortAndReloadData ()
    case .single (let unconnectedPadArray) :
      self.mDataSource = unconnectedPadArray
      self.mTableView.sortAndReloadData ()
    }
  }

  //····················································································································
  // IMPLEMENTATION OF AutoLayoutTableViewDelegate
  //····················································································································

  func rowCount() -> Int {
    return self.mDataSource.count
  }

  //····················································································································

  func tableViewSelectionDidChange (selectedRows inSelectedRows : IndexSet) {
  }

  //····················································································································

  func indexesOfSelectedObjects () -> IndexSet {
    return IndexSet ()
  }

  //····················································································································

  func addEntry() {
  }

  //····················································································································

  func removeSelectedEntries() {
  }

  //····················································································································

  func beginSorting() {
  }

  //····················································································································

  func endSorting() {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

