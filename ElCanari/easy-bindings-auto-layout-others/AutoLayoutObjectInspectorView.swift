//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

final class AutoLayoutObjectInspectorView : AutoLayoutVerticalStackView {

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Properties
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private let mDefaultInspectorView = AutoLayoutVerticalStackView ()
  private let mDefaultLabel = AutoLayoutStaticLabel (title: "", bold: true, size: .small, alignment: .center)
  private var mGraphicController : (any EBGraphicViewControllerProtocol)? = nil
  private var mInspectors = [(EBManagedObject.Type, ALB_NSStackView)] ()
  private let mObserver = EBOutletEvent ()

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // INIT
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override init () {
  //--- Define default View
    _ = self.mDefaultInspectorView.appendView (self.mDefaultLabel).appendFlexibleSpace ()
  //---
    super.init ()
  //--- By Default, no selected object
    _ = self.mDefaultLabel.stringValue = "No Selected Object"
    _ = self.appendView (self.mDefaultInspectorView)
  //---
    self.mObserver.mEventCallBack = { [weak self] in self?.selectionDidChange () }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  deinit {
    noteObjectDeallocation (self)
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // ADD INSPECTOR
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func addObjectInspector (forEntity inEntity : EBManagedObject.Type,
                                 inspectorView inInspectorView : ALB_NSStackView) -> Self {
    self.mInspectors.append ((inEntity, inInspectorView))
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  // Graphic Controller
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  final func bind_graphic_controller (_ inController : any EBGraphicViewControllerProtocol) -> Self {
    self.mGraphicController = inController
    inController.selectedArrayDidChange_property.startsBeingObserved (by: self.mObserver)
    return self
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  private func selectionDidChange () {
    for view in self.subviews {
      self.removeView (view) // Do not use view.removeFromSuperview ()
    }
    if let selectedObjectSet = self.mGraphicController?.selectedGraphicObjectSet {
      var selectedObjectsInspectorViewSet = Set <ALB_NSStackView> ()
      var someSelectedObjectsHasNoInspector = false
      for selectedObject in selectedObjectSet.values {
        var objectHasInspector = false
        for (candidateType, candidateInspectorView) in self.mInspectors {
          if type (of: selectedObject) == candidateType {
            selectedObjectsInspectorViewSet.insert (candidateInspectorView)
            objectHasInspector = true
          }
        }
        if !objectHasInspector {
          someSelectedObjectsHasNoInspector = true
        }
      }
      if selectedObjectsInspectorViewSet.count > 1 {
        self.mDefaultLabel.stringValue = "Multiple Selection"
        _ = self.appendView (self.mDefaultInspectorView)
      }else if let view = selectedObjectsInspectorViewSet.first {
        if someSelectedObjectsHasNoInspector {
          self.mDefaultLabel.stringValue = "No Inspector"
          _ = self.appendView (self.mDefaultInspectorView)
        }else{
          _ = self.appendView (view)
        }
      }else if someSelectedObjectsHasNoInspector {
        self.mDefaultLabel.stringValue = "No Inspector"
        _ = self.appendView (self.mDefaultInspectorView)
      }else{
        self.mDefaultLabel.stringValue = "No Selected Object"
        _ = self.appendView (self.mDefaultInspectorView)
      }
    }else{
      self.mDefaultLabel.stringValue = "No Controller"
      _ = self.appendView (self.mDefaultInspectorView)
    }
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------
