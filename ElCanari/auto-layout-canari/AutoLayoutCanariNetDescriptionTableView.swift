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
  private weak var mDocument : AutoLayoutProjectDocument? = nil

  //····················································································································

  override init () {
    super.init ()

    self.mTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in self?.mDataSource.count ?? 0 },
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
    self.mTableView.addColumn_NSImage_Int (
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
      maxWidth: 60,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_Int (
      valueGetterDelegate: { [weak self] in
        return self?.mDataSource [$0].labelCount ?? 0
      },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort { ascending ? ($0.labelCount < $1.labelCount) : ($0.labelCount > $1.labelCount) }
      },
      title: "Labels",
      minWidth: 60,
      maxWidth: 60,
      headerAlignment: .left,
      contentAlignment: .center
    )
    self.mTableView.addColumn_Bool (
      valueGetterDelegate: { [weak self] in
        return self?.mDataSource [$0].warnsExactlyOneLabel ?? false
      },
      valueSetterDelegate: { [weak self] (inRowIndex : Int, inValue : Bool) in
         if let rootObject = self?.mDocument?.rootObject, let dataSource = self?.mDataSource {
           let netName = dataSource [inRowIndex].netName
           for netClass in rootObject.mNetClasses.values {
             for net in netClass.mNets.values {
               if net.mNetName == netName {
                 net.mWarnsExactlyOneLabel = inValue
               }
             }
           }
         }
      },
      sortDelegate: { [weak self] (ascending) in
        self?.mDataSource.sort {
          let key0 = $0.warnsExactlyOneLabel && ($0.labelCount == 1)
          let key1 = $1.warnsExactlyOneLabel && ($1.labelCount == 1)
          return ascending ? (key0 < key1) : (key0 > key1)
        }
      },
      title: "Warns One Label",
      minWidth: 60,
      maxWidth: 100,
      headerAlignment: .left,
      contentAlignment: .center
    )
    self.mTableView.addColumn_NSImage_Int (
      valueGetterDelegate: { [weak self] in
        let n = self?.mDataSource [$0].subnets.count
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
      maxWidth: 60,
      headerAlignment: .left,
      contentAlignment: .left
    )
    self.mTableView.addColumn_NSImage_Int (
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
      maxWidth: 100,
      headerAlignment: .left,
      contentAlignment: .left
    )
    _ = self.appendView (self.mTableView)
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  func setDocument (_ inDocument : AutoLayoutProjectDocument) {
    self.mDocument = inDocument
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
  //  AutoLayoutTableViewDelegate functions
  //····················································································································

  func tableViewSelectionDidChange (selectedRows inSelectedRows: IndexSet) {
    self.mPinsOfSelectedNetTableView?.sortAndReloadData ()
  }

  //····················································································································

  func indexesOfSelectedObjects() -> IndexSet {
    return IndexSet ()
  }

  //····················································································································

  func addEntry () {
  }

  //····················································································································

  func removeSelectedEntries () {
  }

  //····················································································································

  func beginSorting () {
  }

  //····················································································································

  func endSorting () {
  }

  //····················································································································
  //  $unconnectedPads binding
  //····················································································································

  private var mController : EBObservablePropertyController? = nil

  //····················································································································

  final func bind_netInfo (_ model : EBReadOnlyProperty_NetInfoArray) -> Self {
    self.mController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateUnconnectedPadList (from: model) }
    )
    return self
  }

  //····················································································································

//  final func unbind_netInfo () {
//    self.mController?.unregister ()
//    self.mController = nil
//  }

  //····················································································································

  func updateUnconnectedPadList (from inModel : EBReadOnlyProperty_NetInfoArray) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mDataSource = []
    case .single (let unconnectedPadArray) :
      self.mDataSource = unconnectedPadArray
    }
    self.mTableView.sortAndReloadData ()
  }

  //····················································································································
  //  mPinsOfSelectedNetTableView
  //····················································································································

  private weak var mPinsOfSelectedNetTableView : AutoLayoutTableView? = nil

  func setPinsOfSelectedNetTableView (_ inPinsOfSelectedNetTableView : AutoLayoutTableView) {
    self.mPinsOfSelectedNetTableView = inPinsOfSelectedNetTableView

    inPinsOfSelectedNetTableView.configure (
      allowsEmptySelection: false,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in return self?.selectedNet?.subnets.count ?? 0 },
      delegate: nil
    )

    inPinsOfSelectedNetTableView.addColumn_NSImage_String (
      valueGetterDelegate: { [weak self] in
        let optN  = self?.selectedNet?.subnets [$0].string
        let image : NSImage?
        if let status = self?.selectedNet?.subnets [$0].status {
          switch status {
          case .ok :
            image = NSImage (named: okStatusImageName)
          case .warning :
            image = NSImage (named: warningStatusImageName)
          case .error :
            image = NSImage (named: errorStatusImageName)
          }
        }else{
          image = nil
        }
        return (optN, image)
      },
      sortDelegate: nil,
//      sortDelegate: { [weak self] (ascending) in
//        self?.mDataSource.sort { return ascending ? ($0.pinCount < $1.pinCount) : ($0.pinCount > $1.pinCount) }
//      },
      title: "Subnets",
      minWidth: 60,
      maxWidth: 600,
      headerAlignment: .left,
      contentAlignment: .left
    )

  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
