//
//  AutoLayoutCanariAssignedPadProxysInDeviceTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 30/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariAssignedPadProxysInDeviceTableView : AutoLayoutVerticalStackView {

  //································································································

  private let mTableView = AutoLayoutTableView (size: .small, addControlButtons: false)
  private var mDataSource = [AssignedPadProxy] ()

  //································································································

  override init () {
    super.init ()

    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mDataSource.count ?? 0 },
      delegate: nil
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].padName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { values_String_are_ordered ($0.padName, ascending, $1.padName) }
      },
      title: "Pad",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .center,
      contentAlignment: .center
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].symbolInstanceName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { values_String_are_ordered ($0.symbolInstanceName, ascending, $1.symbolInstanceName) }
      },
      title: "Symbol",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .center,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].pinName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { values_String_are_ordered ($0.pinName, ascending, $1.pinName) }
      },
      title: "Pin",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .center,
      contentAlignment: .left
    )
    _ = self.appendView (self.mTableView)
  }

  //································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //································································································
  //  selectedPadProxy
  //································································································

  var selectedPadProxy : AssignedPadProxy? {
    if self.mTableView.selectedRow >= 0 {
      return self.mDataSource [self.mTableView.selectedRow]
    }else{
      return nil
    }
  }

  //································································································
  //  $assignedPadProxies binding
  //································································································

  private var mController : EBObservablePropertyController? = nil

  //································································································

  final func bind_assignedPadProxies (_ inModel : EBObservableProperty <AssignedPadProxiesInDevice>) -> Self {
    self.mController = EBObservablePropertyController (
      observedObjects: [inModel],
      callBack: { [weak self] in self?.updateUnconnectedPadList (from: inModel) }
    )
    return self
  }

  //································································································

//  final func unbind_assignedPadProxies () {
//    self.mController?.unregister ()
//    self.mController = nil
//  }

  //································································································

  func updateUnconnectedPadList (from inModel : EBObservableProperty <AssignedPadProxiesInDevice>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mDataSource = []
      self.mTableView.sortAndReloadData ()
    case .single (let unconnectedPadArray) :
      self.mDataSource = unconnectedPadArray
      self.mTableView.sortAndReloadData ()
    }
  }

  //································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————

