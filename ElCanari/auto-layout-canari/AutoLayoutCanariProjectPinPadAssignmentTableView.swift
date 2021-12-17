//
//  AutoLayoutCanariProjectPinPadAssignmentTableView.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 13/12/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   AutoLayoutCanariProjectPinPadAssignmentTableView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariProjectPinPadAssignmentTableView : AutoLayoutTableView {

  //····················································································································
  // INIT
  //····················································································································

  required init? (coder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (size: inSize, addControlButtons: false)
    self.configure (
      allowsEmptySelection: true,
      allowsMultipleSelection: false,
      rowCountCallBack: { [weak self] in return self?.mModelArray.count ?? 0 },
      delegate: nil
    )
    self.addColumn_String (
      valueGetterDelegate: { [weak self] (_ inRow : Int) in return self?.mModelArray [inRow].mLeft },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (inAscending : Bool) in
        self?.mModelArray.sort { String.numericCompare ($0.mLeft, inAscending, $1.mLeft) }
      },
      title: "Pad",
      minWidth: 30,
      maxWidth: 200,
      headerAlignment: .center,
      contentAlignment: .right
    )
    self.addColumn_String (
      valueGetterDelegate: { [weak self] (_ inRow : Int) in return self?.mModelArray [inRow].mCenter },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (inAscending : Bool) in
        self?.mModelArray.sort { inAscending ? ($0.mCenter < $1.mCenter) : ($0.mCenter > $1.mCenter) }
      },
      title: "Symbol",
      minWidth: 30,
      maxWidth: 200,
      headerAlignment: .center,
      contentAlignment: .center
    )
    self.addColumn_String (
      valueGetterDelegate: { [weak self] (_ inRow : Int) in return self?.mModelArray [inRow].mRight },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (inAscending : Bool) in
        self?.mModelArray.sort { inAscending ? ($0.mRight < $1.mRight) : ($0.mRight > $1.mRight) }
      },
      title: "Pin",
      minWidth: 30,
      maxWidth: 200,
      headerAlignment: .center,
      contentAlignment: .left
    )
  }

  //····················································································································
  //    Table view data source protocol
  //····················································································································

  private var mModelArray = ThreeStringArray ()

  //····················································································································

  private func setModel (_ inModel : ThreeStringArray) {
  //--- Assignment
    self.mModelArray = inModel
  //--- Tell Table view to reload
    self.sortAndReloadData ()
  }

  //····················································································································
  //    $array binding
  //····················································································································

  private var mArrayController : EBReadOnlyPropertyController? = nil

  final func bind_array (_ model : EBReadOnlyProperty_ThreeStringArray) -> Self {
    self.mArrayController = EBReadOnlyPropertyController (
      observedObjects: [model],
      callBack: { [weak self] in self?.update (from: model) }
    )
    return self
  }

  //····················································································································

  final func unbind_array () {
    self.mArrayController?.unregister ()
    self.mArrayController = nil
  }

  //····················································································································

  func update (from model : EBReadOnlyProperty_ThreeStringArray) {
    switch model.selection {
    case .empty, .multiple :
      self.setModel ([])
    case .single (let v) :
      self.setModel (v)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
