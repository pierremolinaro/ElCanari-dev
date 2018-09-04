//
//  CanariCharacterView.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 16/11/2015.
//
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   Placement
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let PLACEMENT_GRID : CGFloat = 15.0
private let GERBER_FLOW_ARROW_SIZE : CGFloat = 6.0
private let SELECTION_HOOK_SIZE : CGFloat = 8.0
private let MAX_X : Int = 24
private let MIN_Y : Int = -4
private let MAX_Y : Int = 18

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func xForX (_ inX : Int) -> CGFloat {
  return CGFloat (inX + 2) * PLACEMENT_GRID
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func yForY (_ inY : Int) -> CGFloat {
  return CGFloat (inY + 6) * PLACEMENT_GRID
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariCharacterView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariCharacterView : NSView, EBUserClassNameProtocol {
  @IBOutlet weak var mFontDocument : CanariFontDocument?
  private var mAdvanceLayer = CAShapeLayer ()
  private var mSelectionRectangleLayer = CAShapeLayer ()
  private var mSegmentLayer = CALayer ()
  private var mStrokeGerberCodeFlowLayer = CAShapeLayer ()
  private var mFillGerberCodeFlowLayer = CAShapeLayer ()
  private var mFlowIndexLayer = CAShapeLayer ()
  private var mSelectionLayer = CALayer ()

  //····················································································································

  override init(frame frameRect: NSRect) {
    super.init (frame: frameRect)
    noteObjectAllocation (self)
  }

  //····················································································································

  required init? (coder: NSCoder) {
    super.init (coder: coder)
    noteObjectAllocation (self)
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }
  
  //····················································································································
  //  First responder
  //····················································································································

  override var acceptsFirstResponder : Bool { get { return true } }

  //····················································································································
  //  Focus ring (https://developer.apple.com/library/content/qa/qa1785/_index.html)
  //····················································································································

  override var focusRingMaskBounds: NSRect { get { return self.bounds } }

  //····················································································································

  override func drawFocusRingMask () {
    #if swift(>=4)
      __NSRectFill (self.bounds)
    #else
      NSRectFill (self.bounds)
    #endif
  }

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    CATransaction.begin()
    setPasteboardPrivateObjectType ()
  //--- Draw background
    let backgroundLayer = CAShapeLayer ()
    backgroundLayer.path = CGPath (rect: self.bounds.insetBy (dx: 0.5, dy: 0.5), transform: nil)
    backgroundLayer.position = CGPoint (x:0.0, y:0.0)
    backgroundLayer.fillColor = NSColor.white.cgColor
    backgroundLayer.strokeColor = NSColor.black.cgColor
    backgroundLayer.lineWidth = 1.0
    self.layer?.addSublayer (backgroundLayer)
  //--- Add Grid
    let gridLayer = CAShapeLayer ()
    var mutablePath = CGMutablePath ()
    for y in -2 ... -1 {
      let yy = yForY (y * 2)
      mutablePath.move (to: CGPoint (x: 20.0, y: yy))
      mutablePath.addLine (to: CGPoint (x: NSMaxX (self.bounds), y: yy))
    }
    for y in 1 ... 9 {
      let yy = yForY (y * 2)
      mutablePath.move (to: CGPoint (x: 20.0, y: yy))
      mutablePath.addLine (to: CGPoint (x: NSMaxX (self.bounds), y: yy))
    }
    for x in 1 ... 12 {
      let xx = xForX (x * 2)
      mutablePath.move (to: CGPoint (x: xx, y: 0.0))
      mutablePath.addLine (to: CGPoint (x: xx, y: yForY (18) + 10.0))
    }
    gridLayer.path = mutablePath
    gridLayer.strokeColor = NSColor.lightGray.cgColor
    gridLayer.lineWidth = 1.0
    self.layer?.addSublayer (gridLayer)
  //--- Main X axis
    let mainXLayer = CAShapeLayer ()
    mutablePath = CGMutablePath ()
    mutablePath.move (to: CGPoint (x: xForX (0), y: 0.0))
    mutablePath.addLine (to: CGPoint (x: xForX (0), y: yForY (18) + 10.0))
    mainXLayer.path = mutablePath
    mainXLayer.position = CGPoint (x:0.0, y:0.0)
    mainXLayer.strokeColor = NSColor.black.cgColor
    mainXLayer.lineWidth = 1.0
    self.layer?.addSublayer (mainXLayer)
  //--- Main Y axis
    let mainYLayer = CAShapeLayer ()
    mutablePath = CGMutablePath ()
    mutablePath.move (to: CGPoint (x: 20.0, y: yForY (0)))
    mutablePath.addLine (to: CGPoint (x: NSMaxX (self.bounds), y: yForY (0)))
    mainYLayer.path = mutablePath
    mainYLayer.strokeColor = NSColor.black.cgColor
    mainYLayer.lineWidth = 1.0
    self.layer?.addSublayer (mainYLayer)
  //--- Add X axis values
    let textAttributes : [String : Any] = [
      NSFontAttributeName : NSFont.userFixedPitchFont (ofSize: 11.0)!
    ]
    for x in 0 ... 12 {
      let xx = xForX (x * 2)
      let s = "\(x*2)"
      let size = s.size (withAttributes: textAttributes)
      let tl = CATextLayer ()
      tl.frame = NSRect (x: xx - size.width * 0.5, y: yForY (18) + 10.0, width: size.width, height: size.height)
      tl.string = NSAttributedString (string: s, attributes: textAttributes)
      tl.foregroundColor = NSColor.black.cgColor
      tl.contentsScale = sw34_ScreenMain.backingScaleFactor
      tl.alignmentMode = kCAAlignmentCenter
      self.layer?.addSublayer (tl)
    }
  //--- Add Y axis values
    for y in -2 ... 9 {
      let yy = yForY (y * 2)
      let s = "\(y*2)"
      let size = s.size (withAttributes: textAttributes)
      let tl = CATextLayer ()
      tl.string = NSAttributedString (string: s, attributes: textAttributes)
      tl.frame = NSRect (x: 4.0, y: yy - size.height * 0.5, width: 14.0, height: size.height)
      tl.foregroundColor = NSColor.black.cgColor
      tl.contentsScale = sw34_ScreenMain.backingScaleFactor
      tl.alignmentMode = kCAAlignmentRight
      self.layer?.addSublayer (tl)
    }
  //--- Add segment layer
    self.layer?.addSublayer (mSegmentLayer)
  //--- Add selection rectangle layer
   mSelectionRectangleLayer.fillColor = NSColor.lightGray.withAlphaComponent (0.5).cgColor
   mSelectionRectangleLayer.strokeColor = NSColor.white.cgColor
   mSelectionRectangleLayer.lineWidth = 1.0
   self.layer?.addSublayer (mSelectionRectangleLayer)
  //--- Add advance layer
    mAdvanceLayer.fillColor = NSColor.brown.cgColor
    mAdvanceLayer.position = CGPoint (x:xForX (0), y:yForY (0))
    let s : CGFloat = 16.0
    let r = NSRect (origin: CGPoint (x: -s / 2.0, y: -s / 2.0), size: CGSize (width: s, height: s))
    mAdvanceLayer.path = CGPath (ellipseIn: r, transform: nil)
    self.layer?.addSublayer (mAdvanceLayer)
  //--- Add Gerber code flow
    mStrokeGerberCodeFlowLayer.strokeColor = NSColor.orange.cgColor
    mStrokeGerberCodeFlowLayer.fillColor = nil
    mStrokeGerberCodeFlowLayer.lineWidth = 1.0
    mStrokeGerberCodeFlowLayer.lineCap = kCALineCapRound
    self.layer?.addSublayer (mStrokeGerberCodeFlowLayer)
    mFillGerberCodeFlowLayer.strokeColor = nil
    mFillGerberCodeFlowLayer.fillColor = NSColor.orange.cgColor
    self.layer?.addSublayer (mFillGerberCodeFlowLayer)
  //---
    self.layer?.addSublayer (mFlowIndexLayer)
  //--- Add selection layer
    self.layer?.addSublayer (mSelectionLayer)
    CATransaction.commit ()
  }

  //····················································································································
  //  advance binding
  //····················································································································

  private var mAdvanceController : Controller_CanariCharacterView_advance?

  final func bind_advance (_ object:EBReadOnlyProperty_Int, file:String, line:Int) {
    mAdvanceController = Controller_CanariCharacterView_advance (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_advance () {
    mAdvanceController?.unregister ()
    mAdvanceController = nil
  }

  //····················································································································

  final func setAdvance (_ inAdvance : Int) {
    mAdvanceLayer.position = CGPoint (x:xForX (inAdvance), y:mAdvanceLayer.position.y)
  }

  //····················································································································
  //  characterSegmentList binding
  //····················································································································

  private var mCharacterCodeController : Controller_CanariCharacterView_characterGerberCode?

  final func bind_characterSegmentList (_ object:EBReadOnlyProperty_CharacterSegmentListClass, file:String, line:Int) {
    mCharacterCodeController = Controller_CanariCharacterView_characterGerberCode (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_characterSegmentList () {
    mCharacterCodeController?.unregister ()
    mCharacterCodeController = nil
  }

  //····················································································································

  final func updateSegmentDrawingsFromCharacterSegmentListController () {
    self.updateSegmentDrawings ()
  }

  //····················································································································
  //  transparency binding
  //····················································································································

  private var mTransparencyController : Controller_CanariCharacterView_transparency?

  final func bind_transparency (_ object:EBReadOnlyProperty_Double, file:String, line:Int) {
    mTransparencyController = Controller_CanariCharacterView_transparency (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_transparency () {
    mTransparencyController?.unregister ()
    mTransparencyController = nil
  }

  //····················································································································

  final func updateSegmentDrawingsFromTransparencyController () {
    self.updateSegmentDrawings ()
  }
  
  //····················································································································
  //  display flow binding
  //····················································································································

  private var mDisplayFlowController : Controller_CanariCharacterView_displayFlow?

  final func bind_displayFlow (_ object:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayFlowController = Controller_CanariCharacterView_displayFlow (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_displayFlow () {
    mDisplayFlowController?.unregister ()
    mDisplayFlowController = nil
  }

  //····················································································································

  final func updateSegmentDrawingsFromDisplayFlowController () {
    self.updateSegmentDrawings ()
  }
  
  //····················································································································
  //  display flow binding
  //····················································································································

  private var mDisplayDrawingIndexesController : Controller_CanariCharacterView_displayDrawingIndexes?

  final func bind_displayDrawingIndexes (_ object:EBReadOnlyProperty_Bool, file:String, line:Int) {
    mDisplayDrawingIndexesController = Controller_CanariCharacterView_displayDrawingIndexes (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_displayDrawingIndexes () {
    mDisplayDrawingIndexesController?.unregister ()
    mDisplayDrawingIndexesController = nil
  }

  //····················································································································

  final func updateSegmentDrawingsFromDisplayDrawingIndexesController () {
    self.updateSegmentDrawings ()
  }
  
  //····················································································································
  //  selection
  //····················································································································

  func appendSegment () {
    if let document = mFontDocument {
      let newSegment = SegmentForFontCharacter (managedObjectContext: document.managedObjectContext())
      var newSegmentEntityArray = self.segmentEntityArray ()
      newSegmentEntityArray.append (newSegment)
      mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp (newSegmentEntityArray)
      mSelection.removeAll ()
      mSelection.insert (newSegment)
    }
  }

  //····················································································································
  //  selection
  //····················································································································

  private var mSelection = Set <SegmentForFontCharacter> ()

  //····················································································································
  //  Model
  //····················································································································

  final func segmentEntityArray () -> [SegmentForFontCharacter] {
    var result = [SegmentForFontCharacter] ()
    let possibleSegments = mFontDocument?.selectedCharacter.mSelectedObject?.segments_property
    if let segments = possibleSegments {
      switch segments.prop {
        case .empty, .multiple :
          break
        case .single (let array) :
          result = array
      }
    }
    return result
  }
  
  //····················································································································
  //  Menu actions
  //····················································································································

  final override func validateMenuItem (_ menuItem: NSMenuItem) -> Bool {
    let newSegmentEntityArray = self.segmentEntityArray ()
    let action = menuItem.action
    if action == #selector (CanariCharacterView.delete(_:)) {
      return mSelection.count > 0
    }else if action == #selector (CanariCharacterView.selectAll(_:)) {
      return segmentEntityArray ().count > 0
    }else if action == #selector (CanariCharacterView.bringForward(_:)) {
      return (mSelection.count > 0) && (newSegmentEntityArray.count > 0) && !mSelection.contains (newSegmentEntityArray.last!)
    }else if action == #selector (CanariCharacterView.bringToFront(_:)) {
      return (mSelection.count > 0) && (newSegmentEntityArray.count > 0) && !mSelection.contains (newSegmentEntityArray.last!)
    }else if action == #selector (CanariCharacterView.sendBackward(_:)) {
      return (mSelection.count > 0) && (newSegmentEntityArray.count > 0) && !mSelection.contains (newSegmentEntityArray.first!)
    }else if action == #selector (CanariCharacterView.sendToBack(_:)) {
      return (mSelection.count > 0) && (newSegmentEntityArray.count > 0) && !mSelection.contains (newSegmentEntityArray.first!)
    }else if action == #selector (CanariCharacterView.copy(_:)) {
      return (mSelection.count > 0) && (newSegmentEntityArray.count > 0)
    }else if action == #selector (CanariCharacterView.cut(_:)) {
      return (mSelection.count > 0) && (newSegmentEntityArray.count > 0)
    }else if action == #selector (CanariCharacterView.paste(_:)) {
      return NSPasteboard.general ().data (forType: PRIVATE_PASTEBOARD_TYPE) != nil
    }else{
      return super.validateMenuItem (menuItem)
    }
  }

  //····················································································································
  
  @objc final func delete (_ sender : Any?) {
    deleteSelection ()
  }
  
  //····················································································································

  final override func selectAll (_ sender : Any?) {
    mSelection = Set <SegmentForFontCharacter> (segmentEntityArray ())
    updateSegmentDrawings ()
  }
  
  //····················································································································

  @objc func bringForward (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentEntityArray = self.segmentEntityArray ()
      var idx = newSegmentEntityArray.count
      for segment in self.segmentEntityArray ().reversed () {
        idx -= 1
        if mSelection.contains (segment) {
          newSegmentEntityArray.remove (at: idx)
          newSegmentEntityArray.insert (segment, at:idx + 1)
        }
      }
      mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp(newSegmentEntityArray)
      updateSegmentDrawings ()
    }
  }

  //····················································································································

  @objc func bringToFront (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentEntityArray = self.segmentEntityArray ()
      var idx = -1
      for segment in self.segmentEntityArray () {
        idx += 1
        if mSelection.contains (segment) {
          newSegmentEntityArray.remove (at: idx)
          newSegmentEntityArray.append (segment)
        }
      }
      mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp(newSegmentEntityArray)
      updateSegmentDrawings ()
    }
  }
  
  //····················································································································

  @objc func sendBackward (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentEntityArray = self.segmentEntityArray ()
      var idx = -1
      for segment in self.segmentEntityArray () {
        idx += 1
        if mSelection.contains (segment) {
          newSegmentEntityArray.remove (at: idx)
          newSegmentEntityArray.insert (segment, at:idx - 1)
        }
      }
      mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp(newSegmentEntityArray)
      updateSegmentDrawings ()
    }
  }

  //····················································································································

  @objc func sendToBack (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentEntityArray = self.segmentEntityArray ()
      var idx = newSegmentEntityArray.count
      for segment in self.segmentEntityArray ().reversed () {
        idx -= 1
        if mSelection.contains (segment) {
          newSegmentEntityArray.remove (at: idx)
          newSegmentEntityArray.insert (segment, at:0)
        }
      }
      mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp(newSegmentEntityArray)
      updateSegmentDrawings ()
    }
  }

  //····················································································································
  //  Delete Selection
  //····················································································································

  final func deleteSelection () {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var segmentEntityArray = self.segmentEntityArray ()
      for segment in mSelection {
        let possibleIdx = segmentEntityArray.index(of: segment)
        if let idx = possibleIdx {
          segmentEntityArray.remove (at: idx)
        }
      }
      mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp(segmentEntityArray)
      mSelection.removeAll ()
    }
  }
  
  //····················································································································
  //  Can move selection
  //····················································································································

  final func canMoveSelectionFrom (knob : Int, byX : Int, byY : Int) -> Bool {
    var canMove = mSelection.count > 0
    if knob == 0 {
      for object in mSelection {
        let newX = object.x1 + byX
        canMove = (newX >= 0) && (newX <= MAX_X)
        if canMove {
          let newY = object.y1 + byY
          canMove = (newY >= MIN_Y) && (newY <= MAX_Y)
        }
        if !canMove {
          break
        }
      }
    }else{
      for object in mSelection {
        let newX = object.x2 + byX
        canMove = (newX >= 0) && (newX <= MAX_X)
        if canMove {
          let newY = object.y2 + byY
          canMove = (newY >= MIN_Y) && (newY <= MAX_Y)
        }
        if !canMove {
          break
        }
      }
    }
    return canMove
  }
  
  //····················································································································

  final func canMoveSelection (byX : Int, byY : Int) -> Bool {
    return canMoveSelectionFrom (knob: 0, byX: byX, byY: byY) && canMoveSelectionFrom (knob: 1, byX: byX, byY: byY)
  }
  
  //····················································································································
  //  Move selection
  //····················································································································

  final func moveSelectionFrom (knob : Int, byX : Int, byY : Int) {
    if canMoveSelectionFrom (knob: knob, byX: byX, byY: byY) {
      if knob == 0 {
        for object in mSelection {
          object.x1 = object.x1 + byX
          object.y1 = object.y1 + byY
        }
      }else{
        for object in mSelection {
          object.x2 = object.x2 + byX
          object.y2 = object.y2 + byY
        }
      }
    }else{
      sw34_Beep ()
    }
  }
  
  //····················································································································

  final func moveSelection (byX : Int, byY : Int) {
    if canMoveSelection (byX: byX, byY: byY) {
      for object in mSelection {
        object.x1 = object.x1 + byX
        object.y1 = object.y1 + byY
        object.x2 = object.x2 + byX
        object.y2 = object.y2 + byY
      }
    }else{
      sw34_Beep ()
    }
  }
  
  //····················································································································
  //   PASTEBOARD
  //····················································································································

  private let PRIVATE_PASTEBOARD_TYPE = "AZERTY"
  
  //····················································································································

  private final func setPasteboardPrivateObjectType () {
    register (forDraggedTypes: [PRIVATE_PASTEBOARD_TYPE])
  }

  //····················································································································

  @objc func paste (_ sender : Any?) {
  //--- Get General Pasteboard
    let pb = NSPasteboard.general ()
  //--- Find a matching type name
    let possibleMatchingTypeName : String? = pb.availableType (from: [PRIVATE_PASTEBOARD_TYPE])
    if let matchingTypeName = possibleMatchingTypeName, let fontDocument = mFontDocument {
    //--- Get data from pasteboard
      let possibleArchive : Data? = pb.data (forType:matchingTypeName)
      if let archive = possibleArchive {
      //--- Unarchive to get array of archived objects
        let unarchivedObject : Any? = NSUnarchiver.unarchiveObject (with: archive)
        if let segmentListObject = unarchivedObject as? [[NSNumber]] {
          var segmentEntityArray = self.segmentEntityArray ()
          for archivedSegment : [NSNumber] in segmentListObject {
            let newSegment = SegmentForFontCharacter (managedObjectContext: fontDocument.managedObjectContext())
            newSegment.x1 = archivedSegment [0].intValue
            newSegment.y1 = archivedSegment [1].intValue
            newSegment.x2 = archivedSegment [2].intValue
            newSegment.y2 = archivedSegment [3].intValue
            segmentEntityArray.append (newSegment)
          }
          mFontDocument?.selectedCharacter.mSelectedObject?.segments_property.setProp (segmentEntityArray)
        }
      }
    }
  }

  //····················································································································

  @objc func copy (_ sender : Any?) {
  //--- Declare pasteboard types
    let pb = NSPasteboard.general ()
    pb.declareTypes ([PRIVATE_PASTEBOARD_TYPE], owner:self)
  //--- Copy private representation
    var segmentArray = [[NSNumber]] ()
    for segment in segmentEntityArray () {
      if mSelection.contains (segment) {
        let s : [NSNumber] = [
          NSNumber (value: segment.x1),
          NSNumber (value: segment.y1),
          NSNumber (value: segment.x2),
          NSNumber (value: segment.y2)
        ]
        segmentArray.append (s)
      }
    }
    let data = NSArchiver.archivedData (withRootObject: segmentArray)
    pb.setData (data, forType: PRIVATE_PASTEBOARD_TYPE)
  }

  //····················································································································

  @objc func cut (_ sender : Any?) {
    self.copy (sender)
    deleteSelection ()
  }

  //····················································································································
  //  Key down
  //····················································································································

  final override func keyDown (with event: NSEvent) {
    let shiftKeyOn = event.modifierFlags.contains (.shift)
    let amount = shiftKeyOn ? 4 : 1
    let unicodeScalars = event.charactersIgnoringModifiers!.unicodeScalars
    let unicodeChar = unicodeScalars [unicodeScalars.startIndex].value
    // Swift.print ("\(Int (unicodeChar))")
    switch Int (unicodeChar) {
    case NSUpArrowFunctionKey :
      moveSelection (byX : 0, byY: amount)
    case NSDownArrowFunctionKey :
      moveSelection (byX : 0, byY: -amount)
    case NSLeftArrowFunctionKey :
      moveSelection (byX : -amount, byY: 0)
    case NSRightArrowFunctionKey :
      moveSelection (byX : amount, byY: 0)
    case NSDeleteFunctionKey, 127 /* Back */ :
      deleteSelection ()
    default :
      super.keyDown (with: event)
    }
  }

  //····················································································································
  //  Mouse down
  //····················································································································

  private var mMouseLocation : CGPoint?

  //····················································································································

  final override func mouseDown (with mouseDownEvent: NSEvent) {
    let mouseDownLocation = self.convert (mouseDownEvent.locationInWindow, from:nil)
    mMouseLocation = mouseDownLocation
    var possibleKnobIndex : Int? = nil
  //--- First check if mouse down occurs on a knob of a selected object
    for segment in segmentEntityArray ().reversed () {
      if mSelection.contains (segment) {
        possibleKnobIndex = segment.knobIndexFor (point: mouseDownLocation)
        if possibleKnobIndex != nil {
          mSelection.removeAll ()
          mSelection.insert (segment)
          break
        }
      }
    }
    let shiftKeyOn = mouseDownEvent.modifierFlags.contains (.shift)
    let commandKeyOn = mouseDownEvent.modifierFlags.contains (.command)
  //--- Second, mouse down in segment ?
    var mouseDownInsideSegment = false
    if possibleKnobIndex == nil {
      for segment in segmentEntityArray ().reversed () {
        if segment.contains (point: mouseDownLocation) {
          if shiftKeyOn {
            mSelection.insert (segment)
          }else if commandKeyOn {
            if mSelection.contains (segment) {
              mSelection.remove (segment)
            }else{
              mSelection.insert (segment)
            }
          }else if !mSelection.contains (segment) {
            mSelection.removeAll ()
            mSelection.insert (segment)
          }
          mouseDownInsideSegment = true
          break // Exit from loop
        }
      }
      if !mouseDownInsideSegment && !shiftKeyOn {
        mSelection.removeAll ()
      }
    }
  //--- Handle mouse dragged and mouse up
    if let knobIndex = possibleKnobIndex {
      waitUntilMouseUpOnMouseDownAt (mouseDownLocation: mouseDownLocation, for: knobIndex)
    }else if mouseDownInsideSegment {
      waitUntilMouseUpOnMouseDownOnSegment (mouseDownLocation: mouseDownLocation)
    }else if shiftKeyOn {
      waitUntilMouseUpOnDraggingSelectionRectangleWithShiftKey (mouseDownLocation: mouseDownLocation)
    }else{
      waitUntilMouseUpOnDraggingSelectionRectangleNoShiftKey (mouseDownLocation: mouseDownLocation)
    }
  //--- Mouse up
    mMouseLocation = nil
    mSelectionRectangleLayer.path = nil
    updateSegmentDrawings ()
  }
  
  //····················································································································
  
  private final func waitUntilMouseUpOnMouseDownOnSegment (mouseDownLocation : CGPoint) {
    var mouseLocation = mouseDownLocation
    var loop = true
    while loop {
      updateSegmentDrawings ()
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
   //   let event : NSEvent = self.window!.nextEvent (matching: [NSLeftMouseDraggedMask, NSLeftMouseUpMask])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        let dx = Int ((mouseDraggedLocation.x - mouseLocation.x) / PLACEMENT_GRID)
        let dy = Int ((mouseDraggedLocation.y - mouseLocation.y) / PLACEMENT_GRID)
        if (dx != 0) || (dy != 0) && canMoveSelection (byX : dx, byY : dy) {
          mouseLocation.x += CGFloat (dx) * PLACEMENT_GRID
          mouseLocation.y += CGFloat (dy) * PLACEMENT_GRID
          moveSelection (byX : dx, byY : dy)
        }
        mMouseLocation = mouseLocation
      }
    }
  }
  
  //····················································································································
  
  private final func waitUntilMouseUpOnMouseDownAt (mouseDownLocation : CGPoint, for knob : Int) {
    var mouseLocation = mouseDownLocation
    var loop = true
    while loop {
      updateSegmentDrawings ()
    //--- Wait for mouse dragged or mouse up
    //  let event : NSEvent = self.window!.nextEvent (matching: [NSLeftMouseDraggedMask, NSLeftMouseUpMask])!
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        let dx = Int ((mouseDraggedLocation.x - mouseLocation.x) / PLACEMENT_GRID)
        let dy = Int ((mouseDraggedLocation.y - mouseLocation.y) / PLACEMENT_GRID)
        if (dx != 0) || (dy != 0) && canMoveSelectionFrom (knob: knob, byX: dx, byY: dy) {
          mouseLocation.x += CGFloat (dx) * PLACEMENT_GRID
          mouseLocation.y += CGFloat (dy) * PLACEMENT_GRID
          moveSelectionFrom (knob: knob, byX : dx, byY : dy)
        }
        mMouseLocation = mouseLocation
      }
    }
  }
  
  //····················································································································
  
  private final func waitUntilMouseUpOnDraggingSelectionRectangleNoShiftKey (mouseDownLocation : CGPoint) {
    var loop = true
    while loop {
      updateSegmentDrawings ()
    //--- Wait for mouse dragged or mouse up
      //  let event : NSEvent = self.window!.nextEvent (matching: [NSLeftMouseDraggedMask, NSLeftMouseUpMask])!
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        mSelection.removeAll ()
        let r = CGRect (point: mouseDownLocation, point: mouseDraggedLocation)
        mSelectionRectangleLayer.path = CGPath (rect: r, transform: nil)
        let cr = GeometricRect (cgrect: r)
        for segment in segmentEntityArray () {
          if segment.intersects (rect: cr) {
            mSelection.insert (segment)
          }
        }
      }
    }
  }
  
  //····················································································································
  
  private final func waitUntilMouseUpOnDraggingSelectionRectangleWithShiftKey (mouseDownLocation : CGPoint) {
    let selectionOnMouseDown = mSelection
    var loop = true
    while loop {
      updateSegmentDrawings ()
    //--- Wait for mouse dragged or mouse up
      //  let event : NSEvent = self.window!.nextEvent (matching: [NSLeftMouseDraggedMask, NSLeftMouseUpMask])!
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        let r = CGRect (point: mouseDownLocation, point: mouseDraggedLocation)
        mSelectionRectangleLayer.path = CGPath (rect: r, transform: nil)
        let cr = GeometricRect (cgrect: r)
        var selection = Set <SegmentForFontCharacter> ()
        for segment in segmentEntityArray () {
          if segment.intersects (rect: cr) {
            selection.insert (segment)
          }
        }
        mSelection = selection.symmetricDifference (selectionOnMouseDown)
      }
    }
  }
  
  //····················································································································
  //  Display
  //····················································································································

  private final func updateSegmentDrawings () {
    let segmentEntityArray = self.segmentEntityArray ()
  //--- Remove non existing object from selection
    mSelection.formIntersection (segmentEntityArray)
  //--- Draw segments
    let alpha = CGFloat (g_Preferences?.fontEditionTransparency ?? 1.0)
    var segmentLayers = [CALayer] ()
    for segment in segmentEntityArray {
      segmentLayers.append (segment.getDrawLayer (alpha: alpha))
    }
    mSegmentLayer.sublayers = segmentLayers
  //--- Draw display flow
    let strokePath = CGMutablePath ()
    let fillPath = CGMutablePath ()
    if g_Preferences?.showGerberDrawingFlow ?? false {
      var currentX = 0
      var currentY = 0
      strokePath.move (to: CGPoint (x: xForX (0), y: yForY (0)))
      for segment in segmentEntityArray {
        segment.buildGerberFlow (strokePath: strokePath, fillPath: fillPath, x:&currentX, y:&currentY)
      }
    }
    mStrokeGerberCodeFlowLayer.path = strokePath
    mFillGerberCodeFlowLayer.path = fillPath
  //--- Draw display flow indexes
    var indexLayers = [CALayer] ()
    if g_Preferences?.showGerberDrawingIndexes ?? false {
      var idx = 1
      for segment in segmentEntityArray {
        indexLayers.append (segment.buildGerberIndex (idx))
        idx += 1
      }
    }
    mFlowIndexLayer.sublayers = indexLayers
  //--- Draw selection hooks
    mSelectionLayer.sublayers = nil
    var selectionLayers = [CALayer] ()
    for segment in segmentEntityArray {
      if mSelection.contains (segment) {
        selectionLayers.append (segment.getSelectionLayer (mMouseLocation))
      }
    }
    mSelectionLayer.sublayers = selectionLayers
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SegmentForFontCharacter
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SegmentForFontCharacter {

  //····················································································································

  final func getDrawLayer (alpha : CGFloat) -> CALayer {
    let oblong = GeometricOblong (
      from: CGPoint (x: xForX (self.x1), y: yForY (self.y1)),
      to:   CGPoint (x: xForX (self.x2), y: yForY (self.y2)),
      height: PLACEMENT_GRID * 2.0
    )
    let shapeLayer = oblong.shape ()
    shapeLayer.strokeColor = NSColor.black.withAlphaComponent (alpha).cgColor
    return shapeLayer
  }

  //····················································································································

  final func contains (point p : CGPoint) -> Bool {
    let oblong = GeometricOblong (
      from: CGPoint (x: xForX (self.x1), y: yForY (self.y1)),
      to:   CGPoint (x: xForX (self.x2), y: yForY (self.y2)),
      height: PLACEMENT_GRID * 2.0
    )
    return oblong.contains (point: p)
  }

  //····················································································································

  final func intersects (rect r : GeometricRect) -> Bool {
    let oblong = GeometricOblong (
      from: CGPoint (x: xForX (self.x1), y: yForY (self.y1)),
      to:   CGPoint (x: xForX (self.x2), y: yForY (self.y2)),
      height: PLACEMENT_GRID * 2.0
    )
    return oblong.intersects (rect: r)
  }

  //····················································································································

  final func knobIndexFor (point p : CGPoint) -> Int? { // Return nil if point is outside a knob
    var result : Int? = nil
    do{
      let x = xForX (self.x1)
      let y = yForY (self.y1)
      let r = CGRect (x: x - SELECTION_HOOK_SIZE / 2.0, y: y - SELECTION_HOOK_SIZE / 2.0, width: SELECTION_HOOK_SIZE, height: SELECTION_HOOK_SIZE)
      if r.contains (p) {
        result = 0
      }
    }
    if result == nil {
      let x = xForX (self.x2)
      let y = yForY (self.y2)
      let r = CGRect (x: x - SELECTION_HOOK_SIZE / 2.0, y: y - SELECTION_HOOK_SIZE / 2.0, width: SELECTION_HOOK_SIZE, height: SELECTION_HOOK_SIZE)
      if r.contains (p) {
        result = 1
      }
    }
    return result
  }

  //····················································································································

  final func buildGerberIndex (_ index : Int) -> CALayer {
    let x = (xForX (self.x1) + xForX (self.x2)) / 2.0
    let y = (yForY (self.y1) + yForY (self.y2)) / 2.0
    let textAttributes : [String : Any] = [
      NSFontAttributeName : NSFont.userFixedPitchFont (ofSize: 18.0)!,
      NSForegroundColorAttributeName : NSColor.yellow
    ]
    let s = "\(index)"
    let size = s.size (withAttributes: textAttributes)
    let textLayer = CATextLayer ()
    textLayer.frame = NSRect (x: x - size.width * 0.5,
                              y: y - size.height * 0.5,
                              width: size.width,
                              height: size.height)
    textLayer.string = NSAttributedString (string: s, attributes: textAttributes)
    textLayer.alignmentMode = kCAAlignmentCenter
    textLayer.contentsScale = sw34_ScreenMain.backingScaleFactor
    return textLayer
  }

  //····················································································································
  
  final func buildGerberFlow (strokePath : CGMutablePath, fillPath : CGMutablePath, x: inout Int, y: inout Int) {
    if (self.x1 != x) || (self.y1 != y) {
      x = self.x1
      y = self.y1
      strokePath.addArrow (fillPath: fillPath, to: CGPoint (x: xForX (x), y: yForY (y)), arrowSize: GERBER_FLOW_ARROW_SIZE)
    }
    if (self.x2 != x) || (self.y2 != y) {
      x = self.x2
      y = self.y2
      strokePath.addArrow (fillPath: fillPath, to: CGPoint (x: xForX (x), y: yForY (y)), arrowSize: GERBER_FLOW_ARROW_SIZE)
    }
  }
  
  //····················································································································

  final func getSelectionLayer (_ inMouseDownLocation : CGPoint?) -> CAShapeLayer {
    var underMouse = false
    if let mouseDownLocation = inMouseDownLocation {
      underMouse = contains (point: mouseDownLocation)
    }
    let x1 = xForX (self.x1)
    let y1 = yForY (self.y1)
    let x2 = xForX (self.x2)
    let y2 = yForY (self.y2)
    let mutablePath = CGMutablePath ()
    let r1 = CGRect (x: x1 - SELECTION_HOOK_SIZE / 2.0, y: y1 - SELECTION_HOOK_SIZE / 2.0, width: SELECTION_HOOK_SIZE, height: SELECTION_HOOK_SIZE)
    mutablePath.addRect (r1, transform: CGAffineTransform.identity)
    let r2 = CGRect (x: x2 - SELECTION_HOOK_SIZE / 2.0, y: y2 - SELECTION_HOOK_SIZE / 2.0, width: SELECTION_HOOK_SIZE, height: SELECTION_HOOK_SIZE)
    mutablePath.addRect (r2, transform: CGAffineTransform.identity)
    let newLayer = CAShapeLayer ()
    newLayer.path = mutablePath
    newLayer.fillColor = underMouse ? NSColor.lightGray.cgColor : NSColor.white.cgColor
    newLayer.strokeColor = NSColor.black.cgColor
    newLayer.lineWidth = 1.0
    return newLayer
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
