//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    Auto Layout Table View Controller AutoLayoutProjectDocument projectDeviceController
//--------------------------------------------------------------------------------------------------

final class Controller_AutoLayoutProjectDocument_projectDeviceController : NSObject, AutoLayoutTableViewDelegate {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Constant properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let allowsEmptySelection = true
  private let allowsMultipleSelection = true

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Undo manager
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mUndoManager : UndoManager? = nil // SHOULD BE WEAK
  var undoManager : UndoManager? { return self.mUndoManager }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Sorted Array
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  let sortedArray_property = TransientArrayOf_DeviceInProject ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSortDescriptorArray = [(DeviceInProject, DeviceInProject) -> ComparisonResult] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Model
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private weak var mModel : ReadWriteArrayOf_DeviceInProject? = nil // SHOULD BE WEAK

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var objects : EBReferenceArray <DeviceInProject> {
    if let objects = self.mModel?.propval {
      return objects
    }else{
      return EBReferenceArray ()
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_model (_ inModel : ReadWriteArrayOf_DeviceInProject, _ inUndoManager : UndoManager?) {
    self.mModel = inModel
    self.mUndoManager = inUndoManager
    self.sortedArray_property.setDataProvider (
      inModel,
      sortCallback: { [weak self] (left, right) in self?.isOrderedBefore (left, right) ?? true },
      addSortObserversCallback: { (observer) in
        inModel.toMany_deviceComponentCountString_StartsBeingObserved (by: observer)
        inModel.toMany_mCategory_StartsBeingObserved (by: observer)
        inModel.toMany_mDeviceName_StartsBeingObserved (by: observer)
        inModel.toMany_mFileSystemStatusMessageForDeviceInProject_StartsBeingObserved (by: observer)
        inModel.toMany_sizeString_StartsBeingObserved (by: observer)
        inModel.toMany_versionString_StartsBeingObserved (by: observer)
      },
      removeSortObserversCallback: {(observer) in
        inModel.toMany_deviceComponentCountString_StopsBeingObserved (by: observer)
        inModel.toMany_mCategory_StopsBeingObserved (by: observer)
        inModel.toMany_mDeviceName_StopsBeingObserved (by: observer)
        inModel.toMany_mFileSystemStatusMessageForDeviceInProject_StopsBeingObserved (by: observer)
        inModel.toMany_sizeString_StopsBeingObserved (by: observer)
        inModel.toMany_versionString_StopsBeingObserved (by: observer)
      }
    )
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func isOrderedBefore (_ left : DeviceInProject, _ right : DeviceInProject) -> Bool {
    var order = ComparisonResult.orderedSame
    for sortDescriptor in self.mSortDescriptorArray.reversed () {
      order = sortDescriptor (left, right)
      if order != .orderedSame {
        break // Exit from for loop
      }
    }
    return order == .orderedAscending
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  /* final func unbind_model () {
    self.sortedArray_property.resetDataProvider ()
    self.mModel = nil
    self.mUndoManager = nil
  } */

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Selected Array
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mInternalSelectedArrayProperty = StandAloneArrayOf_DeviceInProject ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedArray_property : ReadOnlyArrayOf_DeviceInProject { return self.mInternalSelectedArrayProperty }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedArray : EBReferenceArray <DeviceInProject> { return self.selectedArray_property.propval }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedSet : EBReferenceSet <DeviceInProject> { return EBReferenceSet (self.selectedArray_property.propval.values) }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  func setSelection (_ inObjects : [DeviceInProject]) {
    self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (inObjects))
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    sorted array observer
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mSortedArrayValuesObserver = EBOutletEvent ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @MainActor override init () {
    super.init ()
    self.sortedArray_property.startsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'mDeviceName' column
    self.sortedArray_property.toMany_mDeviceName_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'mCategory' column
    self.sortedArray_property.toMany_mCategory_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'fileSystemStatusImage' column
    self.sortedArray_property.toMany_fileSystemStatusImage_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'mFileSystemStatusMessageForDeviceInProject' column
    self.sortedArray_property.toMany_mFileSystemStatusMessageForDeviceInProject_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'versionString' column
    self.sortedArray_property.toMany_versionString_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'sizeString' column
    self.sortedArray_property.toMany_sizeString_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //--- Observe 'deviceComponentCountString' column
    self.sortedArray_property.toMany_deviceComponentCountString_StartsBeingObserved (by: self.mSortedArrayValuesObserver)
  //---
    self.mSortedArrayValuesObserver.mEventCallBack = { [weak self] in
       for tableView in self?.mTableViewArray ?? [] {
        tableView.sortAndReloadData ()
      }
    }
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    bind_tableView
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private var mTableViewArray = [AutoLayoutTableView] ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_tableView (_ inTableView : AutoLayoutTableView) {
    inTableView.configure (
      allowsEmptySelection: allowsEmptySelection,
      allowsMultipleSelection: allowsMultipleSelection,
      rowCountCallBack: { [weak self] in self?.sortedArray_property.propval.count ?? 0 },
      delegate: self
    )
  //--- Configure 'mDeviceName' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].mDeviceName },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : DeviceInProject, _ right : DeviceInProject) in return compare_String_properties (left.mDeviceName_property, ascending, right.mDeviceName_property) })
      },
      title: "Name",
      minWidth: 200,
      maxWidth: 4000,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'mCategory' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].mCategory },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : DeviceInProject, _ right : DeviceInProject) in return compare_String_properties (left.mCategory_property, ascending, right.mCategory_property) })
      },
      title: "Category",
      minWidth: 100,
      maxWidth: 200,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'fileSystemStatusImage' column
    inTableView.addColumn_NSImage (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].fileSystemStatusImage },
      valueSetterDelegate: nil,
      sortDelegate: nil,
      title: "",
      minWidth: 20,
      maxWidth: 20,
      headerAlignment: .left,
      contentAlignment: .center
    )
  //--- Configure 'mFileSystemStatusMessageForDeviceInProject' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].mFileSystemStatusMessageForDeviceInProject },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : DeviceInProject, _ right : DeviceInProject) in return compare_String_properties (left.mFileSystemStatusMessageForDeviceInProject_property, ascending, right.mFileSystemStatusMessageForDeviceInProject_property) })
      },
      title: "Status in Device Library",
      minWidth: 150,
      maxWidth: 300,
      headerAlignment: .left,
      contentAlignment: .left
    )
  //--- Configure 'versionString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].versionString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : DeviceInProject, _ right : DeviceInProject) in return compare_String_properties (left.versionString_property, ascending, right.versionString_property) })
      },
      title: "Version",
      minWidth: 80,
      maxWidth: 80,
      headerAlignment: .center,
      contentAlignment: .center
    )
  //--- Configure 'sizeString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].sizeString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : DeviceInProject, _ right : DeviceInProject) in return compare_String_properties (left.sizeString_property, ascending, right.sizeString_property) })
      },
      title: "Size (bytes)",
      minWidth: 100,
      maxWidth: 100,
      headerAlignment: .center,
      contentAlignment: .center
    )
  //--- Configure 'deviceComponentCountString' column
    inTableView.addColumn_String (
      valueGetterDelegate: { [weak self] in return self?.sortedArray_property.propval [$0].deviceComponentCountString },
      valueSetterDelegate: nil,
      sortDelegate: { [weak self] (ascending) in
        self?.mSortDescriptorArray.append ({ (_ left : DeviceInProject, _ right : DeviceInProject) in return compare_String_properties (left.deviceComponentCountString_property, ascending, right.deviceComponentCountString_property) })
      },
      title: "Components",
      minWidth: 100,
      maxWidth: 100,
      headerAlignment: .center,
      contentAlignment: .center
    )
  //---
    self.mTableViewArray.append (inTableView)
    inTableView.sortAndReloadData ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Select a single object
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func select (object inObject: DeviceInProject) {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    remove
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  @objc func remove (_ _ : Any) {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        break
      case .single (let model_prop) :
      //------------- Find the object to be selected after selected object removing
      //--- Dictionary of object sorted indexes
        var sortedObjectDictionary = EBReferenceDictionary <DeviceInProject, Int> ()
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
      //----------------------------------------- Remove selected object
      //--- Dictionary of object absolute indexes
        var objectDictionary = EBReferenceDictionary <DeviceInProject, Int> ()
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
      //----------------------------------------- Set new object array
        model.setProp (newObjectArray)
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // IMPLEMENTATION OF AutoLayoutTableViewDelegate
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  
  final func tableViewDelegate_selectionDidChange (selectedRows inSelectedRows : IndexSet) {
    switch self.sortedArray_property.selection {
    case .empty, .multiple :
      ()
    case .single (let v) :
      var newSelectedObjects = EBReferenceArray <DeviceInProject> ()
      for index in inSelectedRows {
        newSelectedObjects.append (v [index])
      }
      self.mInternalSelectedArrayProperty.setProp (newSelectedObjects)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_indexesOfSelectedObjects () -> IndexSet {
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_addEntry () {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        ()
      case .single (let v) :
        let newObject = DeviceInProject (self.undoManager)
        var array = EBReferenceArray (v)
        array.append (newObject)
        model.setProp (array)
      //--- New object is the selection
        self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (newObject))
      }
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_removeSelectedEntries () {
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
          var sortedObjectDictionary = EBReferenceDictionary <DeviceInProject, Int> ()
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
          var newSelectedObject : DeviceInProject? = nil
          if (newSelectionIndex >= 0) && (newSelectionIndex < sortedArray_prop.count) {
            newSelectedObject = sortedArray_prop [newSelectionIndex]
          }
        //----------------------------------------- Remove selected object
        //--- Dictionary of object absolute indexes
          var objectDictionary = EBReferenceDictionary <DeviceInProject, Int> ()
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

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_beginSorting () {
    self.mSortDescriptorArray.removeAll ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func tableViewDelegate_endSorting () {
    self.sortedArray_property.notifyModelDidChange ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
