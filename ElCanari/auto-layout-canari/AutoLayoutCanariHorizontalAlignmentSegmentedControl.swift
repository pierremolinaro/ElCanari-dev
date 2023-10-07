//
//  AutoLayoutCanariHorizontalAlignmentSegmentedControl.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 19/06/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class AutoLayoutCanariHorizontalAlignmentSegmentedControl : AutoLayoutBase_NSSegmentedControl {

  //····················································································································

  init (size inSize : EBControlSize) {
    super.init (equalWidth: true, size: inSize)

    self.segmentDistribution = .fillEqually

    self.target = self
    self.action = #selector (Self.selectedSegmentDidChange (_:))

    self.addSegment (withImageNamed: "alignmentLeft")
    self.addSegment (withImageNamed: "alignmentCenter")
    self.addSegment (withImageNamed: "alignmentRight")
  }

  //····················································································································

  required init?(coder inCoder: NSCoder) {
    fatalError ("init(coder:) has not been implemented")
  }

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
  private var mObject : EBEnumReadWriteObservableProtocol? = nil

  //····················································································································

  final func bind_alignment (_ inObject : EBEnumReadWriteProperty <HorizontalAlignment>) -> Self {
    self.mObject = inObject
    self.mAlignmentController = EBObservablePropertyController (
      observedObjects: [inObject],
      callBack: { [weak self] in self?.update (from: inObject) }
    )
    return self
  }

  //····················································································································

  fileprivate func update (from inObject : EBEnumReadWriteProperty <HorizontalAlignment>) {
    if let rawValue = inObject.rawValue () {
      self.selectedSegment = rawValue
      self.selectedSegmentDidChange (nil)
    }
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
