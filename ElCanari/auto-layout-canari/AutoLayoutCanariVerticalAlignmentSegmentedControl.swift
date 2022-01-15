//
//  AutoLayoutCanariVerticalAlignmentSegmentedControl.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 15/01/2022.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariVerticalAlignmentSegmentedControl : AutoLayoutBase_NSSegmentedControl {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (equalWidth: true, size: inSize)

    self.segmentDistribution = .fillEqually

    self.target = self
    self.action = #selector (Self.selectedSegmentDidChange (_:))

    self.addSegment (withImageNamed: "alignmentBottom")
    self.addSegment (withImageNamed: "alignmentBaseline")
    self.addSegment (withImageNamed: "alignmentMiddle")
    self.addSegment (withImageNamed: "alignmentTop")
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

  //····················································································································

//  override func ebCleanUp () {
//    self.mAlignmentController?.unregister ()
//    self.mAlignmentController = nil
//    super.ebCleanUp ()
//  }

  //····················································································································
  // ADD PAGE
  //····················································································································

  final func addSegment (withImageNamed inImageName : String) {
    let idx = self.segmentCount
    self.segmentCount += 1
    if let image = NSImage (named: inImageName) {
      self.setImage (image, forSegment: idx)
      self.setImageScaling (.scaleProportionallyUpOrDown, forSegment: idx)
      self.setLabel ("", forSegment: idx)
    }else{
      self.setLabel ("?", forSegment: idx)
    }
  }

  //····················································································································
  // SELECTED TAB DID CHANGE
  //····················································································································

  @objc func selectedSegmentDidChange (_ inSender : Any?) {
    _ = self.mObject?.setFrom (rawValue: self.selectedSegment)
  }

  //····················································································································
  //  $alignment binding
  //····················································································································

  private var mAlignmentController : EBObservablePropertyController? = nil
  private var mObject : EBReadWriteObservableEnumProtocol? = nil

  //····················································································································

  final func bind_alignment (_ inObject : EBReadWriteEnumProperty <BoardTextVerticalAlignment>) -> Self {
    self.mObject = inObject
    self.mAlignmentController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func update (from inObject : EBReadWriteEnumProperty <BoardTextVerticalAlignment>) {
    self.selectedSegment = inObject.rawValue () ?? 0
    self.selectedSegmentDidChange (nil)
  }


  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
