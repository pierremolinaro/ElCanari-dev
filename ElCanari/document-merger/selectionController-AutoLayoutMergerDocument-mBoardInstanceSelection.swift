//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Base Selection Controller AutoLayoutMergerDocument mBoardInstanceSelection
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class SelectionController_AutoLayoutMergerDocument_mBoardInstanceSelection : EBSwiftBaseObject {

  //····················································································································
  //   Selection observable property: boardLimitWidth
  //····················································································································

  var boardLimitWidth_property = EBTransientProperty_Int ()

  //····················································································································
  //   Selection observable property: instanceRect
  //····················································································································

  var instanceRect_property = EBTransientProperty_CanariRect ()

  //····················································································································
  //   Selection observable property: instanceRotation
  //····················································································································

  var instanceRotation_property = EBPropertyProxy_QuadrantRotation ()

  //····················································································································
  //   Selection observable property: modelName
  //····················································································································

  var modelName_property = EBTransientProperty_String ()

  //····················································································································
  //   Selection observable property: myModel
  //····················································································································

  //····················································································································
  //   Selection observable property: myRoot
  //····················································································································

  //····················································································································
  //   Selection observable property: objectDisplay
  //····················································································································

  var objectDisplay_property = EBTransientProperty_EBShape ()

  //····················································································································
  //   Selection observable property: selectionDisplay
  //····················································································································

  var selectionDisplay_property = EBTransientProperty_EBShape ()

  //····················································································································
  //   Selection observable property: x
  //····················································································································

  var x_property = EBPropertyProxy_Int ()

  //····················································································································
  //   Selection observable property: y
  //····················································································································

  var y_property = EBPropertyProxy_Int ()

  //····················································································································
  //   BIND SELECTION
  //····················································································································

  private var mModel : ReadOnlyArrayOf_MergerBoardInstance? = nil

  //····················································································································

  final func bind_selection (model : ReadOnlyArrayOf_MergerBoardInstance) {
    self.mModel = model
    self.bind_property_boardLimitWidth (model: model)
    self.bind_property_instanceRect (model: model)
    self.bind_property_instanceRotation (model: model)
    self.bind_property_modelName (model: model)
    self.bind_property_objectDisplay (model: model)
    self.bind_property_selectionDisplay (model: model)
    self.bind_property_x (model: model)
    self.bind_property_y (model: model)
  }

  //····················································································································
  //   UNBIND SELECTION
  //····················································································································

  final func unbind_selection () {
  //--- boardLimitWidth
    self.boardLimitWidth_property.mReadModelFunction = nil 
    self.mModel?.removeEBObserverOf_boardLimitWidth (self.boardLimitWidth_property)
  //--- instanceRect
    self.instanceRect_property.mReadModelFunction = nil 
    self.mModel?.removeEBObserverOf_instanceRect (self.instanceRect_property)
  //--- instanceRotation
    self.instanceRotation_property.mReadModelFunction = nil 
    self.instanceRotation_property.mWriteModelFunction = nil 
    self.instanceRotation_property.mValidateAndWriteModelFunction = nil 
    self.mModel?.removeEBObserverOf_instanceRotation (self.instanceRotation_property)
  //--- modelName
    self.modelName_property.mReadModelFunction = nil 
    self.mModel?.removeEBObserverOf_modelName (self.modelName_property)
  //--- objectDisplay
    self.objectDisplay_property.mReadModelFunction = nil 
    self.mModel?.removeEBObserverOf_objectDisplay (self.objectDisplay_property)
  //--- selectionDisplay
    self.selectionDisplay_property.mReadModelFunction = nil 
    self.mModel?.removeEBObserverOf_selectionDisplay (self.selectionDisplay_property)
  //--- x
    self.x_property.mReadModelFunction = nil 
    self.x_property.mWriteModelFunction = nil 
    self.x_property.mValidateAndWriteModelFunction = nil 
    self.mModel?.removeEBObserverOf_x (self.x_property)
  //--- y
    self.y_property.mReadModelFunction = nil 
    self.y_property.mWriteModelFunction = nil 
    self.y_property.mValidateAndWriteModelFunction = nil 
    self.mModel?.removeEBObserverOf_y (self.y_property)
  //---
    self.mModel = nil
  }

  //····················································································································
  //    Explorer
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    private var mValueExplorer : NSButton?
    private var mExplorerWindow : NSWindow?
  #endif

  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    final func addExplorer (name : String, y : inout CGFloat, view : NSView) {
      let font = NSFont.boldSystemFont (ofSize: NSFont.smallSystemFontSize)
      let tf = NSTextField (frame:secondColumn (y))
      tf.isEnabled = true
      tf.isEditable = false
      tf.stringValue = name
      tf.font = font
      view.addSubview (tf)
      let valueExplorer = NSButton (frame:thirdColumn (y))
      valueExplorer.font = font
      valueExplorer.title = self.explorerIndexString + " " + String (describing: type (of: self))
      valueExplorer.target = self
      valueExplorer.action = #selector(SelectionController_AutoLayoutMergerDocument_mBoardInstanceSelection.showObjectWindowFromExplorerButton(_:))
      view.addSubview (valueExplorer)
      mValueExplorer = valueExplorer
      y += EXPLORER_ROW_HEIGHT
    }
  #endif

  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    func buildExplorerWindow () {
    //-------------------------------------------------- Create Window
      let r = NSRect (x:20.0, y:20.0, width:10.0, height:10.0)
      mExplorerWindow = NSWindow (contentRect: r, styleMask: [.titled, .closable], backing: .buffered, defer: true, screen: nil)
    //-------------------------------------------------- Adding properties
      let view = NSView (frame:r)
      var y : CGFloat = 0.0
      createEntryForPropertyNamed (
        "instanceRotation",
        object: self.instanceRotation_property,
        y: &y,
        view: view,
        observerExplorer: &self.instanceRotation_property.mObserverExplorer,
        valueExplorer: &self.instanceRotation_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "x",
        object: self.x_property,
        y: &y,
        view: view,
        observerExplorer: &self.x_property.mObserverExplorer,
        valueExplorer: &self.x_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "y",
        object: self.y_property,
        y: &y,
        view: view,
        observerExplorer: &self.y_property.mObserverExplorer,
        valueExplorer: &self.y_property.mValueExplorer
      )
    //-------------------------------------------------- Finish Window construction
    //--- Resize View
      let viewFrame = NSRect (x:0.0, y:0.0, width:EXPLORER_ROW_WIDTH, height:y)
      view.frame = viewFrame
    //--- Set content size
      mExplorerWindow?.setContentSize (NSSize (width:EXPLORER_ROW_WIDTH + 16.0, height:fmin (600.0, y)))
    //--- Set close button as 'remove window' button
      let closeButton : NSButton? = mExplorerWindow?.standardWindowButton (.closeButton)
      closeButton?.target = self
      closeButton?.action = #selector(SelectionController_AutoLayoutMergerDocument_mBoardInstanceSelection.deleteSelectionControllerWindowAction(_:))
    //--- Set window title
      let windowTitle = self.explorerIndexString + " " + String (describing: type (of: self))
      mExplorerWindow!.title = windowTitle
    //--- Add Scroll view
      let frame = NSRect (x:0.0, y:0.0, width:EXPLORER_ROW_WIDTH, height:y)
      let sw = NSScrollView (frame:frame)
      sw.hasVerticalScroller = true
      sw.documentView = view
      mExplorerWindow!.contentView = sw
    }
  #endif
  //····················································································································
  //   showObjectWindowFromExplorerButton
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    @objc func showObjectWindowFromExplorerButton (_ : Any) {
      if mExplorerWindow == nil {
        buildExplorerWindow ()
      }
      mExplorerWindow?.makeKeyAndOrderFront(nil)
    }
  #endif

  //····················································································································
  //   deleteSelectionControllerWindowAction
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    @objc func deleteSelectionControllerWindowAction (_ : Any) {
      clearObjectExplorer ()
    }
  #endif

  //····················································································································
  //   clearObjectExplorer
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    func clearObjectExplorer () {
      let closeButton = mExplorerWindow?.standardWindowButton (.closeButton)
      closeButton!.target = nil
      mExplorerWindow?.orderOut (nil)
      mExplorerWindow = nil
    }
  #endif

  //···················································································································*

  private final func bind_property_boardLimitWidth (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_boardLimitWidth (self.boardLimitWidth_property)
    self.boardLimitWidth_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <Int> ()
          var isMultipleSelection = false
          for object in v {
            switch object.boardLimitWidth_property.selection {
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

  //···················································································································*

  private final func bind_property_instanceRect (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_instanceRect (self.instanceRect_property)
    self.instanceRect_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <CanariRect> ()
          var isMultipleSelection = false
          for object in v {
            switch object.instanceRect_property.selection {
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

  //···················································································································*

  private final func bind_property_instanceRotation (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_instanceRotation (self.instanceRotation_property)
    self.instanceRotation_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <QuadrantRotation> ()
          var isMultipleSelection = false
          for object in v {
            switch object.instanceRotation_property.selection {
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
    self.instanceRotation_property.mWriteModelFunction = { [weak self] (inValue : QuadrantRotation) in
      if let model = self?.mModel {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.instanceRotation_property.setProp (inValue)
          }
        }
      }
    }
    self.instanceRotation_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : QuadrantRotation, windowForSheet : NSWindow?) in
      if let model = self?.mModel {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.instanceRotation_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
            if !result {
              return false
            }
          }
          return true
        }
      }else{
        return false
      }
    }
  }

  //···················································································································*

  private final func bind_property_modelName (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_modelName (self.modelName_property)
    self.modelName_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <String> ()
          var isMultipleSelection = false
          for object in v {
            switch object.modelName_property.selection {
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

  //···················································································································*

  private final func bind_property_objectDisplay (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_objectDisplay (self.objectDisplay_property)
    self.objectDisplay_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
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

  //···················································································································*

  private final func bind_property_selectionDisplay (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_selectionDisplay (self.selectionDisplay_property)
    self.selectionDisplay_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
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

  //···················································································································*

  private final func bind_property_x (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_x (self.x_property)
    self.x_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <Int> ()
          var isMultipleSelection = false
          for object in v {
            switch object.x_property.selection {
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
    self.x_property.mWriteModelFunction = { [weak self] (inValue : Int) in
      if let model = self?.mModel {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.x_property.setProp (inValue)
          }
        }
      }
    }
    self.x_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : Int, windowForSheet : NSWindow?) in
      if let model = self?.mModel {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.x_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
            if !result {
              return false
            }
          }
          return true
        }
      }else{
        return false
      }
    }
  }

  //···················································································································*

  private final func bind_property_y (model : ReadOnlyArrayOf_MergerBoardInstance) {
    model.addEBObserverOf_y (self.y_property)
    self.y_property.mReadModelFunction = { [weak self] in
      if let model = self?.mModel {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <Int> ()
          var isMultipleSelection = false
          for object in v {
            switch object.y_property.selection {
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
    self.y_property.mWriteModelFunction = { [weak self] (inValue : Int) in
      if let model = self?.mModel {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.y_property.setProp (inValue)
          }
        }
      }
    }
    self.y_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : Int, windowForSheet : NSWindow?) in
      if let model = self?.mModel {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.y_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
            if !result {
              return false
            }
          }
          return true
        }
      }else{
        return false
      }
    }
  }



  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
