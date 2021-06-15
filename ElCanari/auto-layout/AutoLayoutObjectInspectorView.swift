//----------------------------------------------------------------------------------------------------------------------

import Cocoa

//----------------------------------------------------------------------------------------------------------------------

final class AutoLayoutObjectInspectorView : AutoLayoutVerticalStackView {

  //····················································································································
  // Properties
  //····················································································································

  private var mNoSelectedObjectView : AutoLayoutVerticalStackView
  private var mGraphicController : EBGraphicViewControllerProtocol? = nil
  
  //····················································································································
  // INIT
  //····················································································································

  override init () {
  //--- Define "No Selected Object View"
    self.mNoSelectedObjectView = AutoLayoutVerticalStackView ()
    let hStack = AutoLayoutHorizontalStackView ()
    hStack.appendView (AutoLayoutFlexibleSpace ())
    hStack.appendView (AutoLayoutStaticLabel (title: "No Selected Object", bold: false, small: false))
    hStack.appendView (AutoLayoutFlexibleSpace ())
    self.mNoSelectedObjectView.appendView (hStack)
  //---
    super.init ()
  //--- By Default, no selected object
    self.appendView (self.mNoSelectedObjectView)
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

  final func addObjectInspector (forEntity inEntity : String, pageView inPageView : AutoLayoutAbstractStackView) -> Self {
//    self.segmentCount += 1
//    self.setLabel (inTitle, forSegment: self.segmentCount - 1)
//    self.mPages.append (inPageView)
//    self.frame.size = self.intrinsicContentSize
    return self
  }

  //····················································································································
  // Graphic Controller
  //····················································································································

  final func bind_graphic_controller (_ inController : EBGraphicViewControllerProtocol) -> Self {
    self.mGraphicController = inController
    return self
  }

  //····················································································································

}

//----------------------------------------------------------------------------------------------------------------------
