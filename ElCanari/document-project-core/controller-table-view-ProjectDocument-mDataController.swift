//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Table View Controller ProjectDocument mDataController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class Controller_ProjectDocument_mDataController : ReadOnlyAbstractGenericRelationshipProperty, EBTableViewDelegate {

  private var mDelegate = Delegate_ProjectDocument_mDataController ()
  
  //····················································································································

  override init () {
    super.init ()
    self.mDelegate.setController (self)
  }

  //····················································································································
  //    Constant properties
  //····················································································································

  private let allowsEmptySelection = false
  private let allowsMultipleSelection = false

  //····················································································································
  //   Sorted Array
  //····················································································································

  let sortedArray_property = TransientArrayOf_ArtworkFileGenerationParameters ()

  //····················································································································

  var sortedArray : EBReferenceArray <ArtworkFileGenerationParameters> { return self.sortedArray_property.propval }

  //····················································································································

  fileprivate var mSortDescriptorArray = [NSSortDescriptor] ()

  //····················································································································
  //    Model
  //····················································································································

  private var mModel : ReadWriteArrayOf_ArtworkFileGenerationParameters? = nil

  //····················································································································

  var objects : EBReferenceArray <ArtworkFileGenerationParameters> {
    if let objects = self.mModel?.propval {
      return objects
    }else{
      return EBReferenceArray ()
    }
  }

  //····················································································································

  var objectCount : Int {
    if let objects = self.mModel?.propval {
      return objects.count
    }else{
      return 0
    }
  }

  //····················································································································

  final func bind_model (_ inModel : ReadWriteArrayOf_ArtworkFileGenerationParameters, _ inUndoManager : EBUndoManager) {
  //--- Set sort descriptors
    self.mSortDescriptorArray = []
    self.mSortDescriptorArray.append (NSSortDescriptor (key: "name", ascending: true))
    for tableView in self.mTableViewArray {
      for sortDescriptor in self.mSortDescriptorArray {
        if let key = sortDescriptor.key, let column = tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: key)) {
          column.sortDescriptorPrototype = sortDescriptor
        }
      }
      tableView.sortDescriptors = self.mSortDescriptorArray
    }
  //---
    self.mModel = inModel
    self.mUndoManager = inUndoManager
    self.sortedArray_property.setDataProvider (
      inModel,
      sortCallback: { (left, right) in self.isOrderedBefore (left, right) },
      addSortObserversCallback: { (observer) in
        inModel.addEBObserverOf_name (observer)
      },
      removeSortObserversCallback: {(observer) in
        inModel.removeEBObserverOf_name (observer)
      }
    )
    inModel.attachClient (self)
  }

  //····················································································································

  final func unbind_model () {
    self.sortedArray_property.resetDataProvider ()
    self.mModel?.detachClient (self)
    for tvc in self.mTableViewDataSourceControllerArray {
      self.sortedArray_property.removeEBObserver (tvc)
    }
    for tvc in self.mTableViewSelectionControllerArray {
      self.mInternalSelectedArrayProperty.removeEBObserver (tvc)
    }
  //---
    self.mModel = nil
    self.mUndoManager = nil
 }

  //····················································································································
  //    Observing model change
  //····················································································································

  override func notifyModelDidChange () {
    super.notifyModelDidChange ()
    // NSLog ("self.sortedArray \(self.sortedArray.count)")
    let oldSelectionSet = self.selectedSet
    var newSelectedArray = EBReferenceArray <ArtworkFileGenerationParameters> ()
    for object in self.sortedArray.values {
      if oldSelectionSet.contains (object) {
        newSelectedArray.append (object)
      }
    }
    self.mInternalSelectedArrayProperty.setProp (newSelectedArray)
  }

  //····················································································································
  //    Undo manager
  //····················································································································

  private var mUndoManager : EBUndoManager? = nil
  var ebUndoManager : EBUndoManager? { return self.mUndoManager }

  //····················································································································
  //   Selected Array
  //····················································································································

  fileprivate let mInternalSelectedArrayProperty = StandAloneArrayOf_ArtworkFileGenerationParameters ()

  //····················································································································

  var selectedArray_property : ReadOnlyArrayOf_ArtworkFileGenerationParameters { return self.mInternalSelectedArrayProperty }

  //····················································································································

  var selectedArray : EBReferenceArray <ArtworkFileGenerationParameters> { return self.selectedArray_property.propval }

  //····················································································································

  var selectedSet : EBReferenceSet <ArtworkFileGenerationParameters> { return EBReferenceSet (self.selectedArray.values) }

  //····················································································································

  var selectedIndexesSet : Set <Int> {
    var result = Set <Int> ()
    var idx = 0
    for object in self.objects.values {
      if self.selectedSet.contains (object) {
        result.insert (idx)
      }
      idx += 1
    }
    return result
  }

  //····················································································································

  func setSelection (_ inObjects : [ArtworkFileGenerationParameters]) {
    self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (inObjects))
  }

  //····················································································································

  func isOrderedBefore (_ left : ArtworkFileGenerationParameters, _ right : ArtworkFileGenerationParameters) -> Bool {
    var order = ComparisonResult.orderedSame
    for sortDescriptor in self.mSortDescriptorArray {
      if sortDescriptor.key == "name" {
        order = compare_String_properties (left.name_property, sortDescriptor.ascending, right.name_property)
      }
      if order != .orderedSame {
        break // Exit from for
      }
    }
    return order == .orderedAscending
  }

  //····················································································································
  //    Explorer
  //····················································································································

  final func addExplorer (name : String, y : inout CGFloat, view : NSView) {
  }

  //····················································································································
  //    bind_tableView
  //····················································································································

  private var mTableViewDataSourceControllerArray = [DataSource_EBTableView_controller] ()
  private var mTableViewSelectionControllerArray = [Selection_EBTableView_controller] ()
  fileprivate var mTableViewArray = [EBTableView] ()

  //····················································································································

  final func bind_tableView (_ inTableView : EBTableView?) {
    if let tableView = inTableView {
      tableView.allowsEmptySelection = allowsEmptySelection
      tableView.allowsMultipleSelection = allowsMultipleSelection
      tableView.dataSource = self.mDelegate
      tableView.delegate = self.mDelegate
    //--- Set table view data source controller
      let dataSourceTableViewController = DataSource_EBTableView_controller (delegate:self, tableView:tableView)
      self.sortedArray_property.addEBObserver (dataSourceTableViewController)
      self.mTableViewDataSourceControllerArray.append (dataSourceTableViewController)
    //--- Set table view selection controller
      let selectionTableViewController = Selection_EBTableView_controller (delegate:self, tableView:tableView)
      self.mInternalSelectedArrayProperty.addEBObserver (selectionTableViewController)
      self.mTableViewSelectionControllerArray.append (selectionTableViewController)
    //--- Check 'name' column
      if let column : NSTableColumn = tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: "name")) {
        column.sortDescriptorPrototype = nil
      }else{
        presentErrorWindow (#file, #line, "\"name\" column view unknown")
      }
    //--- Set table view sort descriptors
      for sortDescriptor in self.mSortDescriptorArray {
        if let key = sortDescriptor.key, let column = tableView.tableColumn (withIdentifier: NSUserInterfaceItemIdentifier (rawValue: key)) {
          column.sortDescriptorPrototype = sortDescriptor
        }
      }
      tableView.sortDescriptors = self.mSortDescriptorArray
    //---
      self.mTableViewArray.append (tableView)
    }
  }

  //····················································································································

  final func unbind_tableView (_ inTableView : EBTableView?) {
    if let tableView = inTableView, let idx = self.mTableViewArray.firstIndex (of:tableView) {
      self.sortedArray_property.removeEBObserver (self.mTableViewDataSourceControllerArray [idx])
      self.mInternalSelectedArrayProperty.removeEBObserver (self.mTableViewSelectionControllerArray [idx])
      self.mTableViewArray.remove (at: idx)
      self.mTableViewDataSourceControllerArray.remove (at: idx)
      self.mTableViewSelectionControllerArray.remove (at: idx)
    }
  }

 //····················································································································

  func selectedObjectIndexSet () -> NSIndexSet {
    switch self.sortedArray_property.selection {
    case .empty, .multiple :
       return NSIndexSet ()
    case .single (let v) :
    //--- Dictionary of object indexes
      var objectDictionary = EBReferenceDictionary <ArtworkFileGenerationParameters, Int> ()
      for (index, object) in v.enumerated () {
        objectDictionary [object] = index
      }
      let indexSet = NSMutableIndexSet ()
      for object in self.selectedSet.values {
        if let index = objectDictionary [object] {
          indexSet.add (index)
        }
      }
      return indexSet
    }
  }

  //····················································································································
  //   Select a single object
  //····················································································································

  func select (object inObject: ArtworkFileGenerationParameters) {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        break
      case .single (let objectArray) :
        let array = EBReferenceArray (objectArray)
        if array.contains (inObject) {
          self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (inObject))
        }
      }
    }
  }

  //····················································································································
  //    add
  //····················································································································

   @objc func add (_ sender : Any) {
    if let model = self.mModel {
      switch model.selection {
      case .empty, .multiple :
        break
      case .single (let v) :
        let newObject = ArtworkFileGenerationParameters (self.ebUndoManager)
        var array = EBReferenceArray (v)
        array.append (newObject)
        model.setProp (array)
      //--- New object is the selection
        self.mInternalSelectedArrayProperty.setProp (EBReferenceArray (newObject))
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
        switch self.sortedArray_property.selection {
        case .empty, .multiple :
          break
        case .single (let sortedArray_prop) :
        //------------- Find the object to be selected after selected object removing
        //--- Dictionary of object sorted indexes
          var sortedObjectDictionary = EBReferenceDictionary <ArtworkFileGenerationParameters, Int> ()
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
              break
            }else{
              newSelectionIndex = index + 1
            }
          }
          var newSelectedObject : ArtworkFileGenerationParameters? = nil
          if (newSelectionIndex >= 0) && (newSelectionIndex < sortedArray_prop.count) {
            newSelectedObject = sortedArray_prop [newSelectionIndex]
          }
        //----------------------------------------- Remove selected object
        //--- Dictionary of object absolute indexes
          var objectDictionary = EBReferenceDictionary <ArtworkFileGenerationParameters, Int> ()
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

fileprivate final class Delegate_ProjectDocument_mDataController : EBObjcBaseObject, NSTableViewDataSource, NSTableViewDelegate {

  //····················································································································

  weak var mController : Controller_ProjectDocument_mDataController? = nil

  //····················································································································

  func setController (_ inController : Controller_ProjectDocument_mDataController) {
    self.mController = inController
  }

  //····················································································································
  //    T A B L E V I E W    D A T A S O U R C E : numberOfRows (in:)
  //····················································································································

  func numberOfRows (in _ : NSTableView) -> Int {
    if let controller = self.mController {
      switch controller.sortedArray_property.selection {
      case .empty, .multiple :
        return 0
      case .single (let v) :
        return v.count
      }
    }else{
      return 0
    }
  }

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : tableViewSelectionDidChange:
  //····················································································································

  func tableViewSelectionDidChange (_ notification : Notification) {
    if let controller = self.mController {
      switch controller.sortedArray_property.selection {
      case .empty, .multiple :
        break
      case .single (let v) :
        let tableView = notification.object as! EBTableView
        var newSelectedObjects = EBReferenceArray <ArtworkFileGenerationParameters> ()
        for index in tableView.selectedRowIndexes {
          newSelectedObjects.append (v [index])
        }
        controller.mInternalSelectedArrayProperty.setProp (newSelectedObjects)
      }
    }
  }

  //····················································································································
  //    T A B L E V I E W    S O U R C E : tableView:sortDescriptorsDidChange:
  //····················································································································

  func tableView (_ tableView : NSTableView, sortDescriptorsDidChange oldDescriptors : [NSSortDescriptor]) {
    if let controller = self.mController {
      controller.mSortDescriptorArray = tableView.sortDescriptors
  /*    for s in tableView.sortDescriptors {
        Swift.print ("key \(s.key), ascending \(s.ascending)")
      } */
      for tableView in controller.mTableViewArray {
        tableView.sortDescriptors = controller.mSortDescriptorArray
      }
      controller.sortedArray_property.notifyModelDidChange ()
    }
  }

  //····················································································································
  //    T A B L E V I E W    D E L E G A T E : tableView:viewForTableColumn:row:
  //····················································································································

  func tableView (_ tableView : NSTableView,
                  viewFor inTableColumn: NSTableColumn?,
                  row inRowIndex: Int) -> NSView? {
    if let controller = self.mController {
      switch controller.sortedArray_property.selection {
      case .empty, .multiple :
        return nil
      case .single (let v) :
        if let tableColumnIdentifier = inTableColumn?.identifier,
          let result = tableView.makeView (withIdentifier: tableColumnIdentifier, owner:self) as? NSTableCellView {
          if !reuseTableViewCells () {
            result.identifier = nil // So result cannot be reused, will be freed
          }
          let object = v [inRowIndex]
          if tableColumnIdentifier.rawValue == "name", let cell = result as? EBTextObserverField_TableViewCell {
            cell.mUnbindFunction = { [weak cell] in
              cell?.mCellOutlet?.unbind_valueObserver ()
            }
            cell.mUnbindFunction? ()
            cell.mCellOutlet?.bind_valueObserver (object.name_property)
            cell.update ()
          }else{
            NSLog ("Unknown column '\(String (describing: inTableColumn?.identifier))'")
          }
          return result
        }else{
          return nil
        }
      }
    }else{
      return nil
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————