//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutObjectInspectorView : AutoLayoutVerticalStackView {

  //····················································································································
  // Properties
  //····················································································································

  private var mNoSelectedObjectView : AutoLayoutVerticalStackView
  private var mMultipleSelectionView : AutoLayoutVerticalStackView
  private var mGraphicController : EBGraphicViewControllerProtocol? = nil
  private var mInspectors = [(EBManagedObject.Type, AutoLayoutAbstractStackView)] ()
  private var mObserver = EBOutletEvent ()

  //····················································································································
  // INIT
  //····················································································································

  override init () {
  //--- Define "No Selected Object View"
    self.mNoSelectedObjectView = AutoLayoutVerticalStackView ()
    var hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (AutoLayoutFlexibleSpace ())
    hStack.appendView (AutoLayoutStaticLabel (title: "No Selected Object", bold: false, small: false))
    hStack.appendView (AutoLayoutFlexibleSpace ())
    self.mNoSelectedObjectView.appendView (hStack)
  //--- Define "Multiple selection View"
    self.mMultipleSelectionView = AutoLayoutVerticalStackView ()
    hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (AutoLayoutFlexibleSpace ())
    hStack.appendView (AutoLayoutStaticLabel (title: "Multiple Selection", bold: false, small: false))
    hStack.appendView (AutoLayoutFlexibleSpace ())
    self.mMultipleSelectionView.appendView (hStack)
  //---
    super.init ()
  //--- By Default, no selected object
    self.appendView (self.mNoSelectedObjectView)
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
      for selectedObject in selectedObjectSet {
        for (candidateType, candidateInspectorView) in self.mInspectors {
          if type (of: selectedObject) == candidateType {
            selectedObjectsInspectorViewSet.insert (candidateInspectorView)
          }
        }
      }
      if selectedObjectsInspectorViewSet.count > 1 {
        self.appendView (self.mMultipleSelectionView)
      }else if let view = selectedObjectsInspectorViewSet.first {
        self.appendView (view)
      }else{
        self.appendView (self.mNoSelectedObjectView)
      }
    }else{
      self.appendView (self.mNoSelectedObjectView)
    }
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
