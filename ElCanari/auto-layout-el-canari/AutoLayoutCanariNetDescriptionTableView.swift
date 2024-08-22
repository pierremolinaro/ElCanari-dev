//
//  AutoLayoutCanariNetDescriptionTableView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 14/12/2021.
//
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutCanariNetDescriptionTableView : AutoLayoutVerticalStackView, AutoLayoutTableViewDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mTableView = AutoLayoutTableView (size: .regular, addControlButtons: false)
  private var mDataSource = NetInfoArray ()
  private weak var mDocument : AutoLayoutProjectDocument? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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
        let n = self?.mDataSource [$0].subnets.count ?? 0
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setDocument (_ inDocument : AutoLayoutProjectDocument) {
    self.mDocument = inDocument
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  selectedNet
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedNet : NetInfo? {
    if self.mTableView.selectedRow >= 0 {
      return self.mDataSource [self.mTableView.selectedRow]
    }else{
      return nil
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  AutoLayoutTableViewDelegate functions
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_selectionDidChange (selectedRows inSelectedRows: IndexSet) {
    self.reloadSelectedNetVerticalScrollView (selectedRows: inSelectedRows)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_indexesOfSelectedObjects() -> IndexSet {
    return IndexSet ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_addEntry () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_removeSelectedEntries () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_beginSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func tableViewDelegate_endSorting () {
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  $unconnectedPads binding
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mController : EBObservablePropertyController? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_netInfo (_ model : EBObservableProperty <NetInfoArray>) -> Self {
    self.mController = EBObservablePropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.updateUnconnectedPadList (from: model) }
    )
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func updateUnconnectedPadList (from inModel : EBObservableProperty <NetInfoArray>) {
    switch inModel.selection {
    case .empty, .multiple :
      self.mDataSource = []
    case .single (let unconnectedPadArray) :
      self.mDataSource = unconnectedPadArray
    }
    self.mTableView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //  mPinsOfSelectedNetTableView
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mSelectedNetVerticalStackView : AutoLayoutVerticalStackView? = nil

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setSelectedNetVerticalStackView (_ inSelectedNetVerticalStackView : AutoLayoutVerticalStackView) {
    self.mSelectedNetVerticalStackView = inSelectedNetVerticalStackView
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func reloadSelectedNetVerticalScrollView (selectedRows inSelectedRows : IndexSet) {
    if let vStack = mSelectedNetVerticalStackView {
    //--- Remove all items of vStack
      for view in vStack.subviews {
        vStack.removeView (view)
      }
    //--- If one selected net, add description views
      if inSelectedRows.count == 1 {
        let selectedNetInfo : NetInfo = self.mDataSource [inSelectedRows.first!]
        _ = vStack.appendView (AutoLayoutStaticLabel (title: selectedNetInfo.netName, bold: true, size: .small, alignment: .center).expandableWidth ())
        for subnet : SubnetDescriptor in selectedNetInfo.subnets {
          let optionalImage : NSImage?
          switch subnet.status {
          case .ok :
            optionalImage = nil
          case .warning :
            optionalImage = NSImage.statusWarning
          case .error :
            optionalImage = NSImage.statusError
          }
          vStack.appendHorizontalSeparator ()
          do{
            let hStack = AutoLayoutHorizontalStackView ()
              .appendView (AutoLayoutStaticLabel (title: "Subnet", bold: true, size: .small, alignment: .left).notExpandableWidth ())
            if let image = optionalImage {
              _ = hStack.appendView (AutoLayoutStaticImageView (image: image).notExpandableWidth ())
            }
            let title = subnet.showExactlyOneLabelMessage ? "(exactly one label for this net)" : ""
            _ = hStack.appendView (AutoLayoutStaticLabel (title: title, bold: true, size: .small, alignment: .left).expandableWidth ())
            _ = vStack.appendView (hStack)
          }
          for pin in subnet.pins {
           let title = "Pin: \(pin.pinName) in sheet #\(pin.sheetIndex) at \(pin.location.string)"
            let button = SelectedNetButton (
              title: title,
              sheetIndex: pin.sheetIndex,
              rowIndex: pin.location.row,
              columnIndex: pin.location.column,
              locationInSheet: pin.locationInSheet,
              document: self.mDocument
            )
            _ = vStack.appendView (button)
          }
          for label in subnet.labels {
           let title = "Label in sheet #\(label.sheetIndex) at \(label.location.string)"
            let button = SelectedNetButton (
              title: title,
              sheetIndex: label.sheetIndex,
              rowIndex: label.location.row,
              columnIndex: label.location.column,
              locationInSheet: label.locationInSheet,
              document: self.mDocument
            )
            _ = vStack.appendView (button)
          }
        }
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

fileprivate class SelectedNetButton : ALB_NSButton {

  private let mSheetIndex : Int
  private let mRowIndex : Int
  private let mColumnIndex : Int
  private let mLocationInSheet : NSPoint
  private weak var mDocument : AutoLayoutProjectDocument?

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init (title inTitle : String,
        sheetIndex inSheetIndex : Int,
        rowIndex inRowIndex : Int,
        columnIndex inColumnIndex : Int,
        locationInSheet inPoint : CanariPoint,
        document inDocument : AutoLayoutProjectDocument?) {
    self.mSheetIndex = inSheetIndex
    self.mRowIndex = inRowIndex
    self.mColumnIndex = inColumnIndex
    self.mLocationInSheet = inPoint.cocoaPoint
    self.mDocument = inDocument
    super.init (title: inTitle, size: .small)
    _ = self.expandableWidth ()
    self.target = self
    self.action = #selector (Self.gotoSchematicSheet (_:))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func gotoSchematicSheet (_ _ : Any?) {
    if let document = self.mDocument, self.mSheetIndex > 0 {
      document.rootObject.mSelectedPageIndex = 2 // Schematics
      document.rootObject.mSelectedSheet = document.rootObject.mSheets [self.mSheetIndex - 1]
      document.rootObject.mSchematicEnableHiliteColumnAndRow = true
      document.rootObject.mSchematicHilitedRowIndex = self.mRowIndex
      document.rootObject.mSchematicHilitedColumnIndex = self.mColumnIndex
      document.mSchematicsView?.mGraphicView.scroll (self.mLocationInSheet)
 //       document.mSchematicsView?.mGraphicView.selectObject (at: self.mLocationInSheet)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
