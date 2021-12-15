//
//  AutoLayoutCanariNetDescriptionTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariNetDescriptionTableView : AutoLayoutVerticalStackView, AutoLayoutTableViewDelegate {

  //····················································································································

  private let mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
  private var mDataSource = NetInfoArray ()

  //····················································································································

  override init () {
    super.init ()

    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      delegate: self
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].netName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return values_String_are_ordered ($0.netName, ascending, $1.netName) }
      },
      title: "Net Name",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.mDataSource [$0].netClassName ?? "" },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return values_String_are_ordered ($0.netClassName, ascending, $1.netClassName) }
      },
      title: "Class Name",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_ImageInt (
      valueGetterDelegate: { [weak self] in
        let optN = self?.mDataSource [$0].pinCount
        let image : NSImage?
        if let n = optN, let warningImage = NSImage (named: warningStatusImageName) {
          image = (n < 2) ? warningImage : NSImage (size: warningImage.size)
        }else{
          image = nil
        }
        return (optN, image)
      },
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return ascending ? ($0.pinCount < $1.pinCount) : ($0.pinCount > $1.pinCount) }
      },
      title: "Pins",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_ImageInt (
      valueGetterDelegate: { [weak self] in
        let n = self?.mDataSource [$0].pinCount
        let image : NSImage?
        if let uwSelf = self, let warningImage = NSImage (named: warningStatusImageName) {
          image = uwSelf.mDataSource [$0].subnetsHaveWarning ? NSImage (named: warningStatusImageName) : NSImage (size: warningImage.size)
        }else{
          image = nil
        }
        return (n, image)
      },
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return ascending ? ($0.subnets.count < $1.subnets.count) : ($0.subnets.count > $1.subnets.count) }
      },
      title: "Subnets",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_ImageInt (
      valueGetterDelegate: { [weak self] in
        let optN = self?.mDataSource [$0].trackCount
        let image : NSImage?
        if let n = optN, let warningImage = NSImage (named: warningStatusImageName) {
          image = (n == 0) ? warningImage : NSImage (size: warningImage.size)
        }else{
          image = nil
        }
        return (optN, image)
      },
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { return ascending ? ($0.trackCount < $1.trackCount) : ($0.trackCount > $1.trackCount) }
      },
      title: "Tracks in Board",
      minWidth: 60,
      maxWidth: 250,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.appendView (self.mTableView)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································
  //  selectedNet
  //····················································································································

  var selectedNet : NetInfo? {
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

  final func bind_netInfo (_ model : EBReadOnlyProperty_NetInfoArray) -> Self {
    self.mController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateUnconnectedPadList (from: model) }
    )
    return self
  }

  //····················································································································

  final func unbind_netInfo () {
    self.mController?.unregister ()
    self.mController = nil
  }

  //····················································································································

  func updateUnconnectedPadList (from inModel : EBReadOnlyProperty_NetInfoArray) {
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
