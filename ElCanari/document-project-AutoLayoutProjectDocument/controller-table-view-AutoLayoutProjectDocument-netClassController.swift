//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Auto Layout Table View Controller AutoLayoutProjectDocument netClassController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_AutoLayoutProjectDocument_netClassController : EBObjcBaseObject, AutoLayoutTableViewDelegate {

  //····················································································································
  //    Constant properties
  //····················································································································

  private let allowsEmptySelection = true
  private let allowsMultipleSelection = true

  //····················································································································
  //    Undo manager
  //····················································································································

  private var mUndoManager : EBUndoManager? = nil
  var ebUndoManager : EBUndoManager? { return self.mUndoManager }

  //····················································································································
  //   Sorted Array
  //····················································································································

  let sortedArray_property = TransientArrayOf_NetClassInProject ()

  //····················································································································

  private var mSortDescriptorArray = [(NetClassInProject, NetClassInProject) -> ComparisonResult] ()

  //····················································································································
  //    Model
  //····················································································································

  private var mModel : ReadWriteArrayOf_NetClassInProject? = nil

  //····················································································································

  var objects : EBReferenceArray <NetClassInProject> {
    if let objects = self.mModel?.propval {
      return objects
    }else{
      return EBReferenceArray ()
    }
  }

  //····················································································································

  final func bind_model (_ inModel : ReadWriteArrayOf_NetClassInProject, _ inUndoManager : EBUndoManager) {
    self.mModel = inModel
    self.mUndoManager = inUndoManager
    self.sortedArray_property.setDataProvider (
      inModel,
      sortCallback: { (left, right) in self.isOrderedBefore (left, right) },
      addSortObserversCallback: { (observer) in
        inModel.addEBObserverOf_allowTracksOnBackSideString (observer)
        inModel.addEBObserverOf_allowTracksOnFrontSideString (observer)
        inModel.addEBObserverOf_allowTracksOnInner1LayerString (observer)
        inModel.addEBObserverOf_allowTracksOnInner3LayerString (observer)
        inModel.addEBObserverOf_allowTracksOnInner4LayerString (observer)
        inModel.addEBObserverOf_mNetClassName (observer)
        inModel.addEBObserverOf_netUsage (observer)
        inModel.addEBObserverOf_trackWidthString (observer)
        inModel.addEBObserverOf_viaHoleDiameter (observer)
        inModel.addEBObserverOf_viaPadDiameter (observer)
      },
      removeSortObserversCallback: {(observer) in
        inModel.removeEBObserverOf_allowTracksOnBackSideString (observer)
        inModel.removeEBObserverOf_allowTracksOnFrontSideString (observer)
        inModel.removeEBObserverOf_allowTracksOnInner1LayerString (observer)
        inModel.removeEBObserverOf_allowTracksOnInner3LayerString (observer)
        inModel.removeEBObserverOf_allowTracksOnInner4LayerString (observer)
        inModel.removeEBObserverOf_mNetClassName (observer)
        inModel.removeEBObserverOf_netUsage (observer)
        inModel.removeEBObserverOf_trackWidthString (observer)
        inModel.removeEBObserverOf_viaHoleDiameter (observer)
        inModel.removeEBObserverOf_viaPadDiameter (observer)
      }
    )
  }

  //····················································································································

  final func isOrderedBefore (_ left : NetClassInProject, _ right : NetClassInProject) -> Bool {
    var order = ComparisonResult.orderedSame
    for sortDescriptor in self.mSortDescriptorArray.reversed () {
      order = sortDescriptor (left, right)
      if order != .orderedSame {
        break // Exit from for loop
      }
    }
    return order == .orderedAscending
  }

  //····················································································································

  final func unbind_model () {
    self.sortedArray_property.resetDataProvider ()
    self.mModel = nil
    self.mUndoManager = nil
 }

  //····················································································································
  //   Selected Array
  //····················································································································

  private let mInternalSelectedArrayProperty = StandAloneArrayOf_NetClassInProject ()

  //····················································································································

  var selectedArray_property : ReadOnlyArrayOf_NetClassInProject { return self.mInternalSelectedArrayProperty }

  //····················································································································

  var selectedArray : EBReferenceArray <NetClassInProject> { return self.selectedArray_property.propval }

  //····················································································································

  var selectedSet : EBReferenceSet <NetClassInProject> { return EBReferenceSet (self.selectedArray_property.propval.values) }

  //····················································································································

  var selectedIndexesSet : Set <Int> {
    let selectedObjectSet = self.selectedSet
    var result = Set <Int> ()
    var idx = 0
    if let model = self.mModel {
      for object in model.propval.values {
        if selectedObjectSet.contains (object) {
          result.insert (idx)
        }
        idx += 1
      }
    }
    return result
  }

  //····················································································································

  func setSelection (_ inObjects : [NetClassInProject]) {
    self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (inObjects))
  }

  //····················································································································
  //    Explorer
  //····················································································································

  final func addExplorer (name : String, y : inout CGFloat, view : NSView) {
  }

  //····················································································································
  //    sorted array observer
  //····················································································································

  private var mSortedArrayValuesObserver = EBOutletEvent ()

  //····················································································································

  override init () {
    super.init ()
    self.sortedArray_property.addEBObserver (self.mSortedArrayValuesObserver)
  //--- Observe 'mNetClassName' column
    self.sortedArray_property.addEBObserverOf_mNetClassName (self.mSortedArrayValuesObserver)
  //--- Observe 'trackWidthString' column
    self.sortedArray_property.addEBObserverOf_trackWidthString (self.mSortedArrayValuesObserver)
  //--- Observe 'viaHoleDiameter' column
    self.sortedArray_property.addEBObserverOf_viaHoleDiameter (self.mSortedArrayValuesObserver)
  //--- Observe 'viaPadDiameter' column
    self.sortedArray_property.addEBObserverOf_viaPadDiameter (self.mSortedArrayValuesObserver)
  //--- Observe 'allowTracksOnFrontSideString' column
    self.sortedArray_property.addEBObserverOf_allowTracksOnFrontSideString (self.mSortedArrayValuesObserver)
  //--- Observe 'allowTracksOnBackSideString' column
    self.sortedArray_property.addEBObserverOf_allowTracksOnBackSideString (self.mSortedArrayValuesObserver)
  //--- Observe 'allowTracksOnInner1LayerString' column
    self.sortedArray_property.addEBObserverOf_allowTracksOnInner1LayerString (self.mSortedArrayValuesObserver)
  //--- Observe 'allowTracksOnInner2LayerString' column
    self.sortedArray_property.addEBObserverOf_allowTracksOnInner2LayerString (self.mSortedArrayValuesObserver)
     self.sortedArray_property.addEBObserverOf_allowTracksOnInner3LayerString (self.mSortedArrayValuesObserver)
  //--- Observe 'allowTracksOnInner1LayerString' column
    self.sortedArray_property.addEBObserverOf_allowTracksOnInner1LayerString (self.mSortedArrayValuesObserver)
     self.sortedArray_property.addEBObserverOf_allowTracksOnInner3LayerString (self.mSortedArrayValuesObserver)
  //--- Observe 'allowTracksOnInner4LayerString' column
    self.sortedArray_property.addEBObserverOf_allowTracksOnInner4LayerString (self.mSortedArrayValuesObserver)
  //--- Observe 'netUsage' column
    self.sortedArray_property.addEBObserverOf_netUsage (self.mSortedArrayValuesObserver)
  //---
    self.mSortedArrayValuesObserver.mEventCallBack = { [weak self] in
       for tableView in self?.mTableViewArray ?? [] {
        tableView.sortAndReloadData ()
      }
    }
  }

  //····················································································································
  //    bind_tableView
  //····················································································································

  private var mTableViewArray = [AutoLayoutTableView] ()

  //····················································································································

  final func bind_tableView (_ inTableView : AutoLayoutTableView) {
    inTableView.configure (
      allowsEmptySelection: allowsEmptySelection,
      allowsMultipleSelection: allowsMultipleSelection,
      rowCountCallBack: { [weak self] in self?.sortedArray_property.propval.count ?? 0 },
      delegate: self
    )
  //--- Configure 'mNetClassName' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].mNetClassName },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.mNetClassName_property, ascending, right.mNetClassName_property) })
      },
      title: "Name",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'trackWidthString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].trackWidthString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.trackWidthString_property, ascending, right.trackWidthString_property) })
      },
      title: "Width",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'viaHoleDiameter' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].viaHoleDiameter },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.viaHoleDiameter_property, ascending, right.viaHoleDiameter_property) })
      },
      title: "Via Hole Diameter",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'viaPadDiameter' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].viaPadDiameter },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.viaPadDiameter_property, ascending, right.viaPadDiameter_property) })
      },
      title: "Via Pad Diameter",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'allowTracksOnFrontSideString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].allowTracksOnFrontSideString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.allowTracksOnFrontSideString_property, ascending, right.allowTracksOnFrontSideString_property) })
      },
      title: "Front Tracks",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'allowTracksOnBackSideString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].allowTracksOnBackSideString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.allowTracksOnBackSideString_property, ascending, right.allowTracksOnBackSideString_property) })
      },
      title: "Back Tracks",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'allowTracksOnInner1LayerString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].allowTracksOnInner1LayerString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.allowTracksOnInner1LayerString_property, ascending, right.allowTracksOnInner1LayerString_property) })
      },
      title: "Inner 1 Tracks",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'allowTracksOnInner2LayerString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].allowTracksOnInner2LayerString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.allowTracksOnInner3LayerString_property, ascending, right.allowTracksOnInner3LayerString_property) })
      },
      title: "Inner 2 Tracks",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'allowTracksOnInner1LayerString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].allowTracksOnInner1LayerString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.allowTracksOnInner3LayerString_property, ascending, right.allowTracksOnInner3LayerString_property) })
      },
      title: "Inner 3 Tracks",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'allowTracksOnInner4LayerString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].allowTracksOnInner4LayerString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.allowTracksOnInner4LayerString_property, ascending, right.allowTracksOnInner4LayerString_property) })
      },
      title: "Inner 4 Tracks",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'netUsage' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].netUsage },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : NetClassInProject, _ right : NetClassInProject) in return compare_String_properties (left.netUsage_property, ascending, right.netUsage_property) })
      },
      title: "Used by…",
      minWidth: 60,
      maxWidth: 150,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //---
    self.mTableViewArray.append (inTableView)
  }

  //····················································································································
  //   Select a single object
  //····················································································································

  func select (object inObject: NetClassInProject) {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        ()
      case .single (let objectArray) :
        let array = EBReferenceArray (objectArray)
        if array.contains (inObject) {
          self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (inObject))
        }
      }
    }
  }

  //····················································································································
  //    remove
  //····················································································································

  @objc func remove (_ sender : Any) {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        break
      case .single (let model_prop) :
      //------------- Find the object to be selected after selected object removing
      //--- Dictionary of object sorted indexes
        var sortedObjectDictionary = EBReferenceDictionary <NetClassInProject, Int> ()
        for (index, object) in model_prop.enumerated () {
          sortedObjectDictionary [object] = index
        }
        var indexArrayOfSelectedObjects = [Int] ()
        for object in self.selectedArray_property.propset.values {
          let index = sortedObjectDictionary [object]
          if let idx = index {
            indexArrayOfSelectedObjects.append (idx)
          }
        }
      //--- Sort
        indexArrayOfSelectedObjects.sort { $0 < $1 }
      //--- Find the first index of a non selected object
        var newSelectionIndex = indexArrayOfSelectedObjects [0] + 1
        for index in indexArrayOfSelectedObjects {
          if newSelectionIndex < index {
            break
          }else{
            newSelectionIndex = index + 1
          }
        }
      /*  var newSelectedObject : NetClassInProject? = nil
        if (newSelectionIndex >= 0) && (newSelectionIndex < model_prop.count) {
          newSelectedObject = model_prop [newSelectionIndex]
        } */
      //----------------------------------------- Remove selected object
      //--- Dictionary of object absolute indexes
        var objectDictionary = EBReferenceDictionary <NetClassInProject, Int> ()
        for (index, object) in model_prop.enumerated () {
          objectDictionary [object] = index
        }
      //--- Build selected objects index array
        var selectedObjectIndexArray = [Int] ()
        for object in self.selectedArray_property.propset.values {
          let index = objectDictionary [object]
          if let idx = index {
            selectedObjectIndexArray.append (idx)
          }
        }
      //--- Sort in reverse order
        selectedObjectIndexArray.sort { $1 < $0 }
      //--- Remove objects, in reverse of order of their index
        var newObjectArray = EBReferenceArray (model_prop)
        for index in selectedObjectIndexArray {
          newObjectArray.remove (at: index)
        }
      //----------------------------------------- Set new selection
 /*       var newSelectionSet = EBReferenceSet <NetClassInProject> ()
        if let object = newSelectedObject {
          newSelectionSet.insert (object)
        }
        self.selectedSet = newSelectionSet */
      //----------------------------------------- Set new object array
        model.setProp (newObjectArray)
      }
    }
  }
  //····················································································································


  //····················································································································
  // IMPLEMENTATION OF AutoLayoutTableViewDelegate
  //····················································································································

/*  final func rowCount () -> Int {
    return self.sortedArray_property.propval.count
  } */

  //····················································································································

  final func tableViewSelectionDidChange (selectedRows inSelectedRows : IndexSet) {
    switch self.sortedArray_property.selection {
    case .empty, .multiple :
      ()
    case .single (let v) :
      var newSelectedObjects = EBReferenceArray <NetClassInProject> ()
      for index in inSelectedRows {
        newSelectedObjects.append (v [index])
      }
      self.mInternalSelectedArrayProperty.setProp (newSelectedObjects)
    }
  }

  //····················································································································

  final func indexesOfSelectedObjects () -> IndexSet {
    var indexSet = IndexSet ()
    var idx = 0
    let selectedObjectSet = EBReferenceSet (self.selectedArray_property.propval.values)
    for object in self.sortedArray_property.propval.values {
      if selectedObjectSet.contains (object) {
        indexSet.insert (idx)
      }
      idx += 1
    }
    return indexSet
  }

  //····················································································································

  final func addEntry () {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        ()
      case .single (let v) :
        let newObject = NetClassInProject (self.ebUndoManager)
        var array = EBReferenceArray (v)
        array.append (newObject)
        model.setProp (array)
      //--- New object is the selection
        self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (newObject))
      }
    }
  }

  //····················································································································

  final func removeSelectedEntries () {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        ()
      case .single (let model_prop) :
        switch self.sortedArray_property.selection {
        case .empty, .multiple :
          ()
        case .single (let sortedArray_prop) :
        //------------- Find the object to be selected after selected object removing
        //--- Dictionary of object sorted indexes
          var sortedObjectDictionary = EBReferenceDictionary <NetClassInProject, Int> ()
          for (index, object) in sortedArray_prop.enumerated () {
            sortedObjectDictionary [object] = index
          }
          var indexArrayOfSelectedObjects = [Int] ()
          for object in self.selectedSet.values {
            let index = sortedObjectDictionary [object]
            if let idx = index {
              indexArrayOfSelectedObjects.append (idx)
            }
          }
        //--- Sort
          indexArrayOfSelectedObjects.sort { $0 < $1 }
        //--- Find the first index of a non selected object
          var newSelectionIndex = indexArrayOfSelectedObjects [0] + 1
          for index in indexArrayOfSelectedObjects {
            if newSelectionIndex < index {
              ()
            }else{
              newSelectionIndex = index + 1
            }
          }
          var newSelectedObject : NetClassInProject? = nil
          if (newSelectionIndex >= 0) && (newSelectionIndex < sortedArray_prop.count) {
            newSelectedObject = sortedArray_prop [newSelectionIndex]
          }
        //----------------------------------------- Remove selected object
        //--- Dictionary of object absolute indexes
          var objectDictionary = EBReferenceDictionary <NetClassInProject, Int> ()
          for (index, object) in model_prop.enumerated () {
            objectDictionary [object] = index
          }
        //--- Build selected objects index array
          var selectedObjectIndexArray = [Int] ()
          for object in self.selectedSet.values {
            let index = objectDictionary [object]
            if let idx = index {
              selectedObjectIndexArray.append (idx)
            }
          }
        //--- Sort in reverse order
          selectedObjectIndexArray.sort { $1 < $0 }
        //--- Remove objects, in reverse of order of their index
          var newObjectArray = EBReferenceArray (model_prop)
          for index in selectedObjectIndexArray {
            newObjectArray.remove (at: index)
          }
        //----------------------------------------- Set new object array
          model.setProp (newObjectArray)
        //----------------------------------------- Set new selection
          if let object = newSelectedObject {
            self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (object))
          }else{
            self.mInternalSelectedArrayProperty.setProp (EBReferenceArray ())
          }
        }
      }
    }
  }

  //····················································································································

  func beginSorting () {
    self.mSortDescriptorArray.removeAll ()
  }

  //····················································································································

  func endSorting () {
    self.sortedArray_property.notifyModelDidChange ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————