//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    Derived selection controller AutoLayoutProjectDocument schematicLabelSelectionController
//--------------------------------------------------------------------------------------------------

@MainActor final class SelectionController_AutoLayoutProjectDocument_schematicLabelSelectionController {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  init () {
    noteObjectAllocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  //································································································
  //   Selection observable property: mOrientation
  //································································································

  final let mOrientation_property = EBComputedProperty_QuadrantRotation ()

  //································································································
  //   Selection observable property: location
  //································································································

  final let location_property = EBTransientProperty <CanariPoint> ()

  //································································································
  //   Selection observable property: netName
  //································································································

  final let netName_property = EBTransientProperty <String> ()

  //································································································
  //   Selection observable property: selectionDisplay
  //································································································

  final let selectionDisplay_property = EBTransientProperty <EBShape> ()

  //································································································
  //   Selection observable property: netClassName
  //································································································

  final let netClassName_property = EBTransientProperty <String> ()

  //································································································
  //   Selection observable property: objectDisplay
  //································································································

  final let objectDisplay_property = EBTransientProperty <EBShape> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   Selected array (not observable)
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  var selectedArray : EBReferenceArray <LabelInSchematic> { return self.selectedArray_property.propval }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   BIND SELECTION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

   let selectedArray_property = TransientArrayOfSuperOf_LabelInSchematic <SchematicObject> ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_selection (model : ReadOnlyArrayOf_SchematicObject) {
    self.selectedArray_property.setDataProvider (model)
    self.bind_property_mOrientation ()
    self.bind_property_location ()
    self.bind_property_netName ()
    self.bind_property_selectionDisplay ()
    self.bind_property_netClassName ()
    self.bind_property_objectDisplay ()
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   UNBIND SELECTION
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  /* final func unbind_selection () {
    self.selectedArray_property.setDataProvider (nil)
  //--- mOrientation
    self.mOrientation_property.mReadModelFunction = nil 
    self.mOrientation_property.mWriteModelFunction = nil 
    self.selectedArray_property.toMany_mOrientation_StopsBeingObserved (by: self.mOrientation_property)
  //--- location
    self.location_property.mReadModelFunction = nil 
    self.selectedArray_property.toMany_location_StopsBeingObserved (by: self.location_property)
  //--- netName
    self.netName_property.mReadModelFunction = nil 
    self.selectedArray_property.toMany_netName_StopsBeingObserved (by: self.netName_property)
  //--- selectionDisplay
    self.selectionDisplay_property.mReadModelFunction = nil 
    self.selectedArray_property.toMany_selectionDisplay_StopsBeingObserved (by: self.selectionDisplay_property)
  //--- netClassName
    self.netClassName_property.mReadModelFunction = nil 
    self.selectedArray_property.toMany_netClassName_StopsBeingObserved (by: self.netClassName_property)
  //--- objectDisplay
    self.objectDisplay_property.mReadModelFunction = nil 
    self.selectedArray_property.toMany_objectDisplay_StopsBeingObserved (by: self.objectDisplay_property)
  } */

  //································································································

  private final func bind_property_mOrientation () {
    self.selectedArray_property.toMany_mOrientation_StartsBeingObserved (by: self.mOrientation_property)
    self.mOrientation_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <QuadrantRotation> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mOrientation_property.selection {
            case .empty :
              return .empty
            case .multiple :
              isMultipleSelection = true
            case .single (let vProp) :
              s.insert (vProp)
            }
          }
          if isMultipleSelection {
            return .multiple
          }else if s.count == 0 {
            return .empty
          }else if s.count == 1 {
            return .single (s.first!)
          }else{
            return .multiple
          }
        }
      }else{
        return .empty
      }
    }
    self.mOrientation_property.mWriteModelFunction = { [weak self] (inValue : QuadrantRotation) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mOrientation_property.setProp (inValue)
          }
        }
      }
    }
  }
  //································································································

  private final func bind_property_location () {
    self.selectedArray_property.toMany_location_StartsBeingObserved (by: self.location_property)
    self.location_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <CanariPoint> ()
          var isMultipleSelection = false
          for object in v {
            switch object.location_property.selection {
            case .empty :
              return .empty
            case .multiple :
              isMultipleSelection = true
            case .single (let vProp) :
              s.insert (vProp)
            }
          }
          if isMultipleSelection {
            return .multiple
          }else if s.count == 0 {
            return .empty
          }else if s.count == 1 {
            return .single (s.first!)
          }else{
            return .multiple
          }
        }
      }else{
        return .empty
      }
    }
  }
  //································································································

  private final func bind_property_netName () {
    self.selectedArray_property.toMany_netName_StartsBeingObserved (by: self.netName_property)
    self.netName_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <String> ()
          var isMultipleSelection = false
          for object in v {
            switch object.netName_property.selection {
            case .empty :
              return .empty
            case .multiple :
              isMultipleSelection = true
            case .single (let vProp) :
              s.insert (vProp)
            }
          }
          if isMultipleSelection {
            return .multiple
          }else if s.count == 0 {
            return .empty
          }else if s.count == 1 {
            return .single (s.first!)
          }else{
            return .multiple
          }
        }
      }else{
        return .empty
      }
    }
  }
  //································································································

  private final func bind_property_selectionDisplay () {
    self.selectedArray_property.toMany_selectionDisplay_StartsBeingObserved (by: self.selectionDisplay_property)
    self.selectionDisplay_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <EBShape> ()
          var isMultipleSelection = false
          for object in v {
            switch object.selectionDisplay_property.selection {
            case .empty :
              return .empty
            case .multiple :
              isMultipleSelection = true
            case .single (let vProp) :
              s.insert (vProp)
            }
          }
          if isMultipleSelection {
            return .multiple
          }else if s.count == 0 {
            return .empty
          }else if s.count == 1 {
            return .single (s.first!)
          }else{
            return .multiple
          }
        }
      }else{
        return .empty
      }
    }
  }
  //································································································

  private final func bind_property_netClassName () {
    self.selectedArray_property.toMany_netClassName_StartsBeingObserved (by: self.netClassName_property)
    self.netClassName_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <String> ()
          var isMultipleSelection = false
          for object in v {
            switch object.netClassName_property.selection {
            case .empty :
              return .empty
            case .multiple :
              isMultipleSelection = true
            case .single (let vProp) :
              s.insert (vProp)
            }
          }
          if isMultipleSelection {
            return .multiple
          }else if s.count == 0 {
            return .empty
          }else if s.count == 1 {
            return .single (s.first!)
          }else{
            return .multiple
          }
        }
      }else{
        return .empty
      }
    }
  }
  //································································································

  private final func bind_property_objectDisplay () {
    self.selectedArray_property.toMany_objectDisplay_StartsBeingObserved (by: self.objectDisplay_property)
    self.objectDisplay_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <EBShape> ()
          var isMultipleSelection = false
          for object in v {
            switch object.objectDisplay_property.selection {
            case .empty :
              return .empty
            case .multiple :
              isMultipleSelection = true
            case .single (let vProp) :
              s.insert (vProp)
            }
          }
          if isMultipleSelection {
            return .multiple
          }else if s.count == 0 {
            return .empty
          }else if s.count == 1 {
            return .single (s.first!)
          }else{
            return .multiple
          }
        }
      }else{
        return .empty
      }
    }
  }


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
