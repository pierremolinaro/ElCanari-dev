//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    Derived selection controller AutoLayoutProjectDocument commentInSchematicSelectionController
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class SelectionController_AutoLayoutProjectDocument_commentInSchematicSelectionController : EBSwiftBaseObject {

  //····················································································································
  //   Selection observable property: mColor
  //····················································································································

  let mColor_property = EBPropertyProxy_NSColor ()
  //····················································································································
  //   Selection observable property: mSize
  //····················································································································

  let mSize_property = EBPropertyProxy_Double ()
  //····················································································································
  //   Selection observable property: mHorizontalAlignment
  //····················································································································

  let mHorizontalAlignment_property = EBPropertyProxy_HorizontalAlignment ()
  //····················································································································
  //   Selection observable property: mVerticalAlignment
  //····················································································································

  let mVerticalAlignment_property = EBPropertyProxy_VerticalAlignment ()
  //····················································································································
  //   Selection observable property: mX
  //····················································································································

  let mX_property = EBPropertyProxy_Int ()
  //····················································································································
  //   Selection observable property: mY
  //····················································································································

  let mY_property = EBPropertyProxy_Int ()
  //····················································································································
  //   Selection observable property: mComment
  //····················································································································

  let mComment_property = EBPropertyProxy_String ()
  //····················································································································
  //   Selection observable property: objectDisplay
  //····················································································································

  let objectDisplay_property = EBTransientProperty_EBShape ()

  //····················································································································
  //   Selection observable property: selectionDisplay
  //····················································································································

  let selectionDisplay_property = EBTransientProperty_EBShape ()

  //····················································································································
  //   Selected array (not observable)
  //····················································································································

  var selectedArray : EBReferenceArray <CommentInSchematic> { return self.selectedArray_property.propval }

  //····················································································································
  //   BIND SELECTION
  //····················································································································

   let selectedArray_property = TransientArrayOfSuperOf_CommentInSchematic <SchematicObject> ()

  //····················································································································

  final func bind_selection (model : ReadOnlyArrayOf_SchematicObject) {
    self.selectedArray_property.setDataProvider (model)
    self.bind_property_mColor ()
    self.bind_property_mSize ()
    self.bind_property_mHorizontalAlignment ()
    self.bind_property_mVerticalAlignment ()
    self.bind_property_mX ()
    self.bind_property_mY ()
    self.bind_property_mComment ()
    self.bind_property_objectDisplay ()
    self.bind_property_selectionDisplay ()
  }

  //····················································································································
  //   UNBIND SELECTION
  //····················································································································

  final func unbind_selection () {
    self.selectedArray_property.setDataProvider (nil)
  //--- mColor
    self.mColor_property.mReadModelFunction = nil 
    self.mColor_property.mWriteModelFunction = nil 
    self.mColor_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mColor (self.mColor_property)
  //--- mSize
    self.mSize_property.mReadModelFunction = nil 
    self.mSize_property.mWriteModelFunction = nil 
    self.mSize_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mSize (self.mSize_property)
  //--- mHorizontalAlignment
    self.mHorizontalAlignment_property.mReadModelFunction = nil 
    self.mHorizontalAlignment_property.mWriteModelFunction = nil 
    self.mHorizontalAlignment_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mHorizontalAlignment (self.mHorizontalAlignment_property)
  //--- mVerticalAlignment
    self.mVerticalAlignment_property.mReadModelFunction = nil 
    self.mVerticalAlignment_property.mWriteModelFunction = nil 
    self.mVerticalAlignment_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mVerticalAlignment (self.mVerticalAlignment_property)
  //--- mX
    self.mX_property.mReadModelFunction = nil 
    self.mX_property.mWriteModelFunction = nil 
    self.mX_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mX (self.mX_property)
  //--- mY
    self.mY_property.mReadModelFunction = nil 
    self.mY_property.mWriteModelFunction = nil 
    self.mY_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mY (self.mY_property)
  //--- mComment
    self.mComment_property.mReadModelFunction = nil 
    self.mComment_property.mWriteModelFunction = nil 
    self.mComment_property.mValidateAndWriteModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_mComment (self.mComment_property)
  //--- objectDisplay
    self.objectDisplay_property.mReadModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_objectDisplay (self.objectDisplay_property)
  //--- selectionDisplay
    self.selectionDisplay_property.mReadModelFunction = nil 
    self.selectedArray_property.removeEBObserverOf_selectionDisplay (self.selectionDisplay_property)
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
      let valueExplorer = NSButton (frame: thirdColumn (y))
      valueExplorer.font = font
      valueExplorer.title = self.explorerIndexString + " " + String (describing: type (of: self))
      valueExplorer.target = self
      valueExplorer.action = #selector(SelectionController_AutoLayoutProjectDocument_commentInSchematicSelectionController.showObjectWindowFromExplorerButton(_:))
      view.addSubview (valueExplorer)
      self.mValueExplorer = valueExplorer
      y += EXPLORER_ROW_HEIGHT
    }
  #endif

  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    func buildExplorerWindow () {
    //-------------------------------------------------- Create Window
      let r = NSRect (x: 20.0, y: 20.0, width: 10.0, height: 10.0)
      self.mExplorerWindow = NSWindow (contentRect: r, styleMask: [.titled, .closable], backing: .buffered, defer: true, screen: nil)
    //-------------------------------------------------- Adding properties
      let view = NSView (frame: r)
      var y : CGFloat = 0.0
      createEntryForPropertyNamed (
        "mColor",
        object: self.mColor_property,
        y: &y,
        view: view,
        observerExplorer: &self.mColor_property.mObserverExplorer,
        valueExplorer: &self.mColor_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "mSize",
        object: self.mSize_property,
        y: &y,
        view: view,
        observerExplorer: &self.mSize_property.mObserverExplorer,
        valueExplorer: &self.mSize_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "mHorizontalAlignment",
        object: self.mHorizontalAlignment_property,
        y: &y,
        view: view,
        observerExplorer: &self.mHorizontalAlignment_property.mObserverExplorer,
        valueExplorer: &self.mHorizontalAlignment_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "mVerticalAlignment",
        object: self.mVerticalAlignment_property,
        y: &y,
        view: view,
        observerExplorer: &self.mVerticalAlignment_property.mObserverExplorer,
        valueExplorer: &self.mVerticalAlignment_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "mX",
        object: self.mX_property,
        y: &y,
        view: view,
        observerExplorer: &self.mX_property.mObserverExplorer,
        valueExplorer: &self.mX_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "mY",
        object: self.mY_property,
        y: &y,
        view: view,
        observerExplorer: &self.mY_property.mObserverExplorer,
        valueExplorer: &self.mY_property.mValueExplorer
      )
      createEntryForPropertyNamed (
        "mComment",
        object: self.mComment_property,
        y: &y,
        view: view,
        observerExplorer: &self.mComment_property.mObserverExplorer,
        valueExplorer: &self.mComment_property.mValueExplorer
      )
    //-------------------------------------------------- Finish Window construction
    //--- Resize View
      let viewFrame = NSRect (x: 0.0, y: 0.0, width: EXPLORER_ROW_WIDTH, height: y)
      view.frame = viewFrame
    //--- Set content size
      self.mExplorerWindow?.setContentSize (NSSize (width: EXPLORER_ROW_WIDTH + 16.0, height: fmin (600.0, y)))
    //--- Set close button as 'remove window' button
      let closeButton : NSButton? = self.mExplorerWindow?.standardWindowButton (.closeButton)
      closeButton?.target = self
      closeButton?.action = #selector(SelectionController_AutoLayoutProjectDocument_commentInSchematicSelectionController.deleteSelectionControllerWindowAction(_:))
    //--- Set window title
      let windowTitle = self.explorerIndexString + " " + String (describing: type (of: self))
      self.mExplorerWindow!.title = windowTitle
    //--- Add Scroll view
      let frame = NSRect (x: 0.0, y: 0.0, width: EXPLORER_ROW_WIDTH, height: y)
      let sw = NSScrollView (frame: frame)
      sw.hasVerticalScroller = true
      sw.documentView = view
      self.mExplorerWindow!.contentView = sw
    }
  #endif
  
  //····················································································································
  //   showObjectWindowFromExplorerButton
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    @objc func showObjectWindowFromExplorerButton (_ : Any) {
      if self.mExplorerWindow == nil {
        self.buildExplorerWindow ()
      }
      self.mExplorerWindow?.makeKeyAndOrderFront (nil)
    }
  #endif
  
  //····················································································································
  //   deleteSelectionControllerWindowAction
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    @objc func deleteSelectionControllerWindowAction (_ : Any) {
      self.clearObjectExplorer ()
    }
  #endif

  //····················································································································
  //   clearObjectExplorer
  //····················································································································

  #if BUILD_OBJECT_EXPLORER
    func clearObjectExplorer () {
      if let closeButton = self.mExplorerWindow?.standardWindowButton (.closeButton) {
        closeButton.target = nil
      }
      self.mExplorerWindow?.orderOut (nil)
      self.mExplorerWindow = nil
    }
  #endif

  //····················································································································

  private final func bind_property_mColor () {
    self.selectedArray_property.addEBObserverOf_mColor (self.mColor_property)
    self.mColor_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <NSColor> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mColor_property.selection {
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
    self.mColor_property.mWriteModelFunction = { [weak self] (inValue : NSColor) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mColor_property.setProp (inValue)
          }
        }
      }
    }
    self.mColor_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : NSColor, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mColor_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_mSize () {
    self.selectedArray_property.addEBObserverOf_mSize (self.mSize_property)
    self.mSize_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <Double> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mSize_property.selection {
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
    self.mSize_property.mWriteModelFunction = { [weak self] (inValue : Double) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mSize_property.setProp (inValue)
          }
        }
      }
    }
    self.mSize_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : Double, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mSize_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_mHorizontalAlignment () {
    self.selectedArray_property.addEBObserverOf_mHorizontalAlignment (self.mHorizontalAlignment_property)
    self.mHorizontalAlignment_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <HorizontalAlignment> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mHorizontalAlignment_property.selection {
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
    self.mHorizontalAlignment_property.mWriteModelFunction = { [weak self] (inValue : HorizontalAlignment) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mHorizontalAlignment_property.setProp (inValue)
          }
        }
      }
    }
    self.mHorizontalAlignment_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : HorizontalAlignment, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mHorizontalAlignment_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_mVerticalAlignment () {
    self.selectedArray_property.addEBObserverOf_mVerticalAlignment (self.mVerticalAlignment_property)
    self.mVerticalAlignment_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <VerticalAlignment> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mVerticalAlignment_property.selection {
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
    self.mVerticalAlignment_property.mWriteModelFunction = { [weak self] (inValue : VerticalAlignment) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mVerticalAlignment_property.setProp (inValue)
          }
        }
      }
    }
    self.mVerticalAlignment_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : VerticalAlignment, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mVerticalAlignment_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_mX () {
    self.selectedArray_property.addEBObserverOf_mX (self.mX_property)
    self.mX_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <Int> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mX_property.selection {
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
    self.mX_property.mWriteModelFunction = { [weak self] (inValue : Int) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mX_property.setProp (inValue)
          }
        }
      }
    }
    self.mX_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : Int, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mX_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_mY () {
    self.selectedArray_property.addEBObserverOf_mY (self.mY_property)
    self.mY_property.mReadModelFunction = { [weak self] in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty :
          return .empty
        case .multiple :
          return .multiple
        case .single (let v) :
          var s = Set <Int> ()
          var isMultipleSelection = false
          for object in v {
            switch object.mY_property.selection {
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
    self.mY_property.mWriteModelFunction = { [weak self] (inValue : Int) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mY_property.setProp (inValue)
          }
        }
      }
    }
    self.mY_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : Int, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mY_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_mComment () {
    self.selectedArray_property.addEBObserverOf_mComment (self.mComment_property)
    self.mComment_property.mReadModelFunction = { [weak self] in
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
            switch object.mComment_property.selection {
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
    self.mComment_property.mWriteModelFunction = { [weak self] (inValue : String) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          break
        case .single (let v) :
          for object in v {
            object.mComment_property.setProp (inValue)
          }
        }
      }
    }
    self.mComment_property.mValidateAndWriteModelFunction = { [weak self] (candidateValue : String, windowForSheet : NSWindow?) in
      if let model = self?.selectedArray_property {
        switch model.selection {
        case .empty, .multiple :
          return false
        case .single (let v) :
          for object in v {
            let result = object.mComment_property.validateAndSetProp (candidateValue, windowForSheet:windowForSheet)
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

  private final func bind_property_objectDisplay () {
    self.selectedArray_property.addEBObserverOf_objectDisplay (self.objectDisplay_property)
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
  //····················································································································

  private final func bind_property_selectionDisplay () {
    self.selectedArray_property.addEBObserverOf_selectionDisplay (self.selectionDisplay_property)
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


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
