//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutObjectInspectorView : AutoLayoutVerticalStackView {

  //····················································································································
  // Properties
  //····················································································································

  private let mDefaultInspectorView = AutoLayoutVerticalStackView ()
  private let mDefaultLabel = AutoLayoutStaticLabel (title: "", bold: true, small: true).makeWidthExpandable ().setCenterAlignment()
  private var mGraphicController : EBGraphicViewControllerProtocol? = nil
  private var mInspectors = [(EBManagedObject.Type, AutoLayoutAbstractStackView)] ()
  private let mObserver = EBOutletEvent ()

  //····················································································································
  // INIT
  //····················································································································

  override init () {
  //--- Define default View
//    let hStack = AutoLayoutHorizontalStackView ()
//    hStack.appendView (AutoLayoutFlexibleSpace ())
//    hStack.appendView (mDefaultLabel)
//    hStack.appendView (AutoLayoutFlexibleSpace ())
    self.mDefaultInspectorView.appendView (mDefaultLabel)
    self.mDefaultInspectorView.appendView (AutoLayoutFlexibleSpace ())
  //---
    super.init ()
  //--- By Default, no selected object
    self.mDefaultLabel.stringValue = "No Selected Object"
    self.appendView (self.mDefaultLabel)
  //---
    self.mObserver.mEventCallBack = { [weak self] in self?.selectionDidChange () }
  }

  //····················································································································

  required init? (coder inCoder : NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  // ADD INSPECTOR
  //····················································································································

  final func addObjectInspector (forEntity inEntity : EBManagedObject.Type,
                                 inspectorView inInspectorView : AutoLayoutAbstractStackView) -> Self {
    self.mInspectors.append ((inEntity, inInspectorView))
    return self
  }

  //····················································································································
  // Graphic Controller
  //····················································································································

  final func bind_graphic_controller (_ inController : EBGraphicViewControllerProtocol) -> Self {
    self.mGraphicController = inController
    inController.selectedArrayDidChange_property.addEBObserver (self.mObserver)
    return self
  }

  //····················································································································

  private func selectionDidChange () {
    for view in self.subviews {
      self.removeView (view) // Do not use view.removeFromSuperview ()
    }
    if let selectedObjectSet = self.mGraphicController?.selectedGraphicObjectSet {
      var selectedObjectsInspectorViewSet = Set <AutoLayoutAbstractStackView> ()
      var someSelectedObjectsHasNoInspector = false
      for selectedObject in selectedObjectSet {
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
        self.appendView (self.mDefaultLabel)
      }else if let view = selectedObjectsInspectorViewSet.first {
        if someSelectedObjectsHasNoInspector {
          self.mDefaultLabel.stringValue = "No Inspector"
          self.appendView (self.mDefaultLabel)
        }else{
          self.appendView (view)
        }
      }else if someSelectedObjectsHasNoInspector {
        self.mDefaultLabel.stringValue = "No Inspector"
        self.appendView (self.mDefaultLabel)
      }else{
        self.mDefaultLabel.stringValue = "No Selected Object"
        self.appendView (self.mDefaultLabel)
      }
    }else{
      self.mDefaultLabel.stringValue = "No Controller"
      self.appendView (self.mDefaultLabel)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
