//
//  AutoLayoutCanariUnconnectedSymbolPinsInDeviceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutCanariUnconnectedSymbolPinsInDeviceTableView : AutoLayoutVerticalStackView, AutoLayoutTableViewDelegate {

  //····················································································································

  private let mTableView = AutoLayoutTableView (small: false, addControlButtons: false)
  private var mDataSource = UnconnectedSymbolPinsInDevice ()

  //····················································································································

  override init () {
    super.init ()

    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      delegate: self
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].symbolInstanceName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return values_String_are_ordered ($0.symbolInstanceName, ascending, $1.symbolInstanceName) }
      },
      title: "Symbol",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .center,
      contentAlignment: .center
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].pinName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return values_String_are_ordered ($0.pinName, ascending, $1.pinName) }
      },
      title: "Pin",
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
  //  selectedSymbolPin
  //····················································································································

  var selectedSymbolPin : UnconnectedSymbolPinsInDevice.Element? {
    if self.mTableView.selectedRow >= 0 {
      return self.mDataSource [self.mTableView.selectedRow]
    }else{
      return nil
    }
  }

  //····················································································································
  //  $unconnectedPins binding
  //····················································································································

  private var mController : EBReadOnlyPropertyController? = nil

  //····················································································································

  final func bind_unconnectedPins (_ model : EBReadOnlyProperty_UnconnectedSymbolPinsInDevice) -> Self {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateUnconnectedPinList (from: model) }
    )
    return self
  }

  //····················································································································

  final func unbind_assignedPadProxies () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

  func updateUnconnectedPinList (from inModel : EBReadOnlyProperty_UnconnectedSymbolPinsInDevice) {
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

//----------------------------------------------------------------------------------------------------------------------

