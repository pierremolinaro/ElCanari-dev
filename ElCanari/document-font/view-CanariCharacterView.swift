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

private let PLACEMENT_GRID : CGFloat = 11.0
private let GERBER_FLOW_ARROW_SIZE : CGFloat = 6.0
private let SELECTION_KNOB_SIZE : CGFloat = 8.0
private let MAX_X : Int = 24
private let MIN_Y : Int = -8
private let MAX_Y : Int = 18

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func xForX (_ inX : Int) -> CGFloat {
  return CGFloat (inX + 2) * PLACEMENT_GRID
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func yForY (_ inY : Int) -> CGFloat {
  return CGFloat (inY + 9) * PLACEMENT_GRID
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func knobRect (_ inX : Int, _ inY : Int) -> NSRect {
  let x = xForX (inX)
  let y = yForY (inY)
  return NSRect (x: x - SELECTION_KNOB_SIZE / 2.0, y: y - SELECTION_KNOB_SIZE / 2.0, width: SELECTION_KNOB_SIZE, height: SELECTION_KNOB_SIZE)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   CanariCharacterView
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariCharacterView : NSView, EBUserClassNameProtocol {
  @IBOutlet weak var mFontDocument : CanariFontDocument?

  private var mSelectionRectangle : NSRect? = nil

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
    NSRectFill (self.bounds)
  }

  //····················································································································
  //  awakeFromNib
  //····················································································································

  final override func awakeFromNib () {
    setPasteboardPrivateObjectType ()
  }

  //····················································································································
  //  drawRect
  //····················································································································

  override func draw (_ inDirtyRect: NSRect) {
  //--- Background
    NSColor.white.setFill ()
    NSRectFill (inDirtyRect)
  //--- Border
    let r = self.bounds.insetBy (dx: 0.5, dy: 0.5)
    var bp = NSBezierPath (rect: r)
    bp.lineWidth = 1.0
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Draw grid
    bp = NSBezierPath ()
    for y in -4 ... -1 {
      let yy = yForY (y * 2)
      bp.move (to: CGPoint (x: 20.0, y: yy))
      bp.line (to: CGPoint (x: NSMaxX (self.bounds), y: yy))
    }
    for y in 1 ... 12 {
      let yy = yForY (y * 2)
      bp.move (to: CGPoint (x: 20.0, y: yy))
      bp.line (to: CGPoint (x: NSMaxX (self.bounds), y: yy))
    }
    for x in 1 ... 16 {
      let xx = xForX (x * 2)
      bp.move (to: CGPoint (x: xx, y: 0.0))
      bp.line (to: CGPoint (x: xx, y: yForY (24) + 10.0))
    }
    bp.lineWidth = 1.0
    NSColor.lightGray.setStroke ()
    bp.stroke ()
  //--- Main X and Y axis
    bp = NSBezierPath ()
    bp.move (to: CGPoint (x: xForX (0), y: 0.0))
    bp.line (to: CGPoint (x: xForX (0), y: yForY (24) + 10.0))
    bp.move (to: CGPoint (x: 20.0, y: yForY (0)))
    bp.line (to: CGPoint (x: NSMaxX (self.bounds), y: yForY (0)))
    bp.lineWidth = 1.0
    NSColor.black.setStroke ()
    bp.stroke ()
  //--- Add X axis values
    let textAttributes : [String : Any] = [
      NSFontAttributeName : NSFont.userFixedPitchFont (ofSize: 11.0)!
    ]
    for x in 0 ... 16 {
      let xx = xForX (x * 2)
      let s = "\(x*2)"
      let size = s.size (withAttributes: textAttributes)
      s.draw (at: NSPoint (x: xx - size.width * 0.5, y: yForY (24) + 10.0), withAttributes: textAttributes)
    }
  //--- Add Y axis values
    for y in -4 ... 12 {
      let yy = yForY (y * 2)
      let s = "\(y*2)"
      let size = s.size (withAttributes: textAttributes)
      s.draw (at: NSPoint (x: 18.0 - size.width, y: yy - size.height * 0.5), withAttributes: textAttributes)
    }
  //--- Selection rectangle
    if let selectionRectangle = mSelectionRectangle {
      bp = NSBezierPath (rect: selectionRectangle)
      NSColor.gray.withAlphaComponent (0.1).setFill ()
      bp.fill ()
      bp.lineWidth = 1.0
      NSColor.black.setStroke ()
      bp.stroke ()

    }
  //--- Character segments
    bp = NSBezierPath ()
    for segment in self.mSegmentList {
      bp.move (to: CGPoint (x: xForX (segment.x1), y: yForY (segment.y1)))
      bp.line (to: CGPoint (x: xForX (segment.x2), y: yForY (segment.y2)))
    }
    bp.lineWidth = PLACEMENT_GRID * 2.0
    bp.lineCapStyle = .roundLineCapStyle
    NSColor.black.withAlphaComponent (self.mSegmentTransparency).setStroke ()
    bp.stroke ()
  //--- Character advancement
    let advanceRect = NSRect (
      origin: CGPoint (x:xForX (self.mAdvancement) - PLACEMENT_GRID / 2.0, y: yForY (0) - PLACEMENT_GRID / 2.0),
      size: CGSize (width: PLACEMENT_GRID, height: PLACEMENT_GRID)
    )
    bp = NSBezierPath (ovalIn: advanceRect)
    NSColor.brown.setFill ()
    bp.fill ()
  //--- Draw display flow
    if mDisplaySegmentFlow {
      let strokePath = NSBezierPath ()
      let fillPath = NSBezierPath ()
      var currentX = 0
      var currentY = 0
      strokePath.move (to: CGPoint (x: xForX (0), y: yForY (0)))
      for segment in self.mSegmentList {
        if (segment.x1 != currentX) || (segment.y1 != currentY) {
          currentX = segment.x1
          currentY = segment.y1
          strokePath.addArrow (fillPath: fillPath, to: NSPoint (x: xForX (currentX), y: yForY (currentY)), arrowSize: GERBER_FLOW_ARROW_SIZE)
        }
        if (segment.x2 != currentX) || (segment.y2 != currentY) {
          currentX = segment.x2
          currentY = segment.y2
          strokePath.addArrow (fillPath: fillPath, to: NSPoint (x: xForX (currentX), y: yForY (currentY)), arrowSize: GERBER_FLOW_ARROW_SIZE)
        }
      }
      NSColor.orange.setFill ()
      NSColor.orange.setStroke ()
      strokePath.lineWidth = 1.0
      strokePath.lineCapStyle = .roundLineCapStyle
      strokePath.stroke ()
      fillPath.fill ()
    }
  //--- Draw index flow
    if mDrawGerberFlowIndex {
      var idx = 1
      for segment in self.mSegmentList {
        let x = (xForX (segment.x1) + xForX (segment.x2)) / 2.0
        let y = (yForY (segment.y1) + yForY (segment.y2)) / 2.0
        let textAttributes : [String : Any] = [
          NSFontAttributeName : NSFont.userFixedPitchFont (ofSize: 18.0)!,
          NSForegroundColorAttributeName : NSColor.yellow
        ]
        let s = "\(idx)"
        let size = s.size (withAttributes: textAttributes)
        s.draw (at: NSPoint (x: x - size.width * 0.5, y: y - size.height * 0.5), withAttributes: textAttributes)
        idx += 1
      }
    }
  //--- Draw selection knobs
    NSColor.white.setFill ()
    NSColor.black.setStroke ()
    for segment in self.mSelection {
      let bp1 = NSBezierPath (rect:knobRect (segment.x1, segment.y1))
      bp1.fill ()
      bp1.lineWidth = 1.0
      bp1.stroke ()
      let bp2 = NSBezierPath (rect:knobRect (segment.x2, segment.y2))
      bp2.fill ()
      bp2.lineWidth = 1.0
      bp2.stroke ()
    }
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

  fileprivate var mAdvancement = 0

  //····················································································································

  final func setAdvance (_ inAdvance : Int) {
    mAdvancement = inAdvance
    self.needsDisplay = true
  }

  //····················································································································
  //  characterSegmentList binding
  //····················································································································

  private var mCharacterSegmentListController : Controller_CanariCharacterView_characterGerberCode?

  final func bind_characterSegmentList (_ object:EBReadOnlyProperty_CharacterSegmentListClass, file:String, line:Int) {
    mCharacterSegmentListController = Controller_CanariCharacterView_characterGerberCode (object:object, outlet:self)
  }

  //····················································································································

  final func unbind_characterSegmentList () {
    mCharacterSegmentListController?.unregister ()
    mCharacterSegmentListController = nil
  }

  //····················································································································

  final func updateSegmentDrawingsFromCharacterSegmentListController (_ inSegments : CharacterSegmentListClass) {
    self.mSegmentList = inSegments.code
    let oldSelection = self.mSelection
    self.mSelection = Set ()
    for oldSegment in oldSelection {
      for newSegment in self.mSegmentList {
        if (oldSegment.x1 == newSegment.x1) && (oldSegment.y1 == newSegment.y1)
        && (oldSegment.x2 == newSegment.x2) && (oldSegment.y2 == newSegment.y2) {
          self.mSelection.insert (newSegment)
          break
        }
      }
    }
    self.needsDisplay = true
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

  fileprivate var mSegmentTransparency : CGFloat = 0.5

  //····················································································································

  final func updateSegmentDrawingsFromTransparencyController (_ inSegmentTransparency : CGFloat) {
    self.mSegmentTransparency = inSegmentTransparency
    self.needsDisplay = true
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

  fileprivate var mDisplaySegmentFlow = true

  //····················································································································

  final func updateSegmentDrawingsFromDisplayFlowController (_ inDisplaySegmentFlow : Bool) {
    self.mDisplaySegmentFlow = inDisplaySegmentFlow
    self.needsDisplay = true
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

  fileprivate var mDrawGerberFlowIndex = true

  //····················································································································

  final func updateSegmentDrawingsFromDisplayDrawingIndexesController (_ inDrawGerberFlowIndex : Bool) {
    self.mDrawGerberFlowIndex = inDrawGerberFlowIndex
    self.needsDisplay = true
  }
  
  //····················································································································
  //  selection
  //····················································································································

  func appendSegment () {
    var newSegmentArray = self.mSegmentList
    let newSegment = SegmentForFontCharacterClass (x1: 2, y1: 1, x2: 9, y2: 8)
    newSegmentArray.append (newSegment)
    mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
  }

  //····················································································································
  //  selection
  //····················································································································

  private var mSelection = Set <SegmentForFontCharacterClass> ()

  //····················································································································
  //  Model
  //····················································································································

  fileprivate var mSegmentList = [SegmentForFontCharacterClass] ()

  //····················································································································
  //  Menu actions
  //····················································································································

  final override func validateMenuItem (_ menuItem: NSMenuItem) -> Bool {
    let action = menuItem.action
    if action == #selector (CanariCharacterView.delete(_:)) {
      return mSelection.count > 0
    }else if action == #selector (CanariCharacterView.selectAll(_:)) {
      return self.mSegmentList.count > 0
    }else if action == #selector (CanariCharacterView.bringForward(_:)) {
      return (mSelection.count > 0) && (self.mSegmentList.count > 0) && !mSelection.contains (self.mSegmentList.last!)
    }else if action == #selector (CanariCharacterView.bringToFront(_:)) {
      return (mSelection.count > 0) && (self.mSegmentList.count > 0) && !mSelection.contains (self.mSegmentList.last!)
    }else if action == #selector (CanariCharacterView.sendBackward(_:)) {
      return (mSelection.count > 0) && (self.mSegmentList.count > 0) && !mSelection.contains (self.mSegmentList.first!)
    }else if action == #selector (CanariCharacterView.sendToBack(_:)) {
      return (mSelection.count > 0) && (self.mSegmentList.count > 0) && !mSelection.contains (self.mSegmentList.first!)
    }else if action == #selector (CanariCharacterView.copy(_:)) {
      return (mSelection.count > 0) && (self.mSegmentList.count > 0)
    }else if action == #selector (CanariCharacterView.cut(_:)) {
      return (mSelection.count > 0) && (self.mSegmentList.count > 0)
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
    mSelection = Set (self.mSegmentList)
    self.needsDisplay = true
  }
  
  //····················································································································

  @objc func bringForward (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = newSegmentArray.count
      for segment in self.mSegmentList.reversed () {
        idx -= 1
        if mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.insert (segment, at:idx + 1)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································

  @objc func bringToFront (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = -1
      for segment in self.mSegmentList {
        idx += 1
        if mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.append (segment)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }
  
  //····················································································································

  @objc func sendBackward (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = -1
      for segment in self.mSegmentList {
        idx += 1
        if mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.insert (segment, at:idx - 1)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································

  @objc func sendToBack (_ sender : Any?) {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      var idx = newSegmentArray.count
      for segment in self.mSegmentList.reversed () {
        idx -= 1
        if mSelection.contains (segment) {
          newSegmentArray.remove (at: idx)
          newSegmentArray.insert (segment, at:0)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }
  }

  //····················································································································
  //  Delete Selection
  //····················································································································

  final func deleteSelection () {
    if mSelection.count == 0 {
      sw34_Beep ()
    }else{
      var newSegmentArray = self.mSegmentList
      for segment in mSelection {
        let possibleIdx = self.mSegmentList.index(of: segment)
        if let idx = possibleIdx {
          newSegmentArray.remove (at: idx)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
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
      var newSegmentArray = [SegmentForFontCharacterClass] ()
      let oldSelection = self.mSelection
      self.mSelection = Set ()
      for segment in self.mSegmentList {
        if oldSelection.contains (segment) {
          var x1 = segment.x1
          var y1 = segment.y1
          var x2 = segment.x2
          var y2 = segment.y2
          if knob == 0 {
            x1 += byX
            y1 += byY
          }else{
            x2 += byX
            y2 += byY
          }
          let newSegment = SegmentForFontCharacterClass (x1: x1, y1: y1, x2: x2, y2: y2)
          newSegmentArray.append (newSegment)
          self.mSelection.insert (newSegment)
        }else{
          newSegmentArray.append (segment)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
    }else{
      sw34_Beep ()
    }
  }
  
  //····················································································································

  final func moveSelection (byX : Int, byY : Int) {
    if canMoveSelection (byX: byX, byY: byY) {
      var newSegmentArray = [SegmentForFontCharacterClass] ()
      let oldSelection = self.mSelection
      self.mSelection = Set ()
      for segment in self.mSegmentList {
        if oldSelection.contains (segment) {
          let newSegment = SegmentForFontCharacterClass (
            x1: segment.x1 + byX,
            y1: segment.y1 + byY,
            x2: segment.x2 + byX,
            y2: segment.y2 + byY
          )
          newSegmentArray.append (newSegment)
          self.mSelection.insert (newSegment)
        }else{
          newSegmentArray.append (segment)
        }
      }
      mFontDocument?.defineSegmentsForCurrentCharacter (newSegmentArray)
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
//  //--- Get General Pasteboard
//    let pb = NSPasteboard.general ()
//  //--- Find a matching type name
//    let possibleMatchingTypeName : String? = pb.availableType (from: [PRIVATE_PASTEBOARD_TYPE])
//    if let matchingTypeName = possibleMatchingTypeName, let fontDocument = mFontDocument {
//    //--- Get data from pasteboard
//      let possibleArchive : Data? = pb.data (forType:matchingTypeName)
//      if let archive = possibleArchive {
//      //--- Unarchive to get array of archived objects
//        let unarchivedObject : Any? = NSUnarchiver.unarchiveObject (with: archive)
//        if let segmentListObject = unarchivedObject as? [[NSNumber]] {
//          var segmentEntityArray = self.segmentEntityArray ()
//          for archivedSegment : [NSNumber] in segmentListObject {
//            let newSegment = SegmentForFontCharacter (managedObjectContext: fontDocument.managedObjectContext())
//            newSegment.x1 = archivedSegment [0].intValue
//            newSegment.y1 = archivedSegment [1].intValue
//            newSegment.x2 = archivedSegment [2].intValue
//            newSegment.y2 = archivedSegment [3].intValue
//            segmentEntityArray.append (newSegment)
//          }
////          mFontDocument?.mCharacterSelection.mSelectedObject?.segments_property.setProp (segmentEntityArray)
//        }
//      }
//    }
  }

  //····················································································································

  @objc func copy (_ sender : Any?) {
//  //--- Declare pasteboard types
//    let pb = NSPasteboard.general ()
//    pb.declareTypes ([PRIVATE_PASTEBOARD_TYPE], owner:self)
//  //--- Copy private representation
//    var segmentArray = [[NSNumber]] ()
//    for segment in segmentEntityArray () {
//      if mSelection.contains (segment) {
//        let s : [NSNumber] = [
//          NSNumber (value: segment.x1),
//          NSNumber (value: segment.y1),
//          NSNumber (value: segment.x2),
//          NSNumber (value: segment.y2)
//        ]
//        segmentArray.append (s)
//      }
//    }
//    let data = NSArchiver.archivedData (withRootObject: segmentArray)
//    pb.setData (data, forType: PRIVATE_PASTEBOARD_TYPE)
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
    for segment in self.mSegmentList.reversed () {
      if self.mSelection.contains (segment) {
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
      for segment in self.mSegmentList.reversed () {
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
    mSelectionRectangle = nil
    self.needsDisplay = true
  }
  
  //····················································································································
  
  private final func waitUntilMouseUpOnMouseDownOnSegment (mouseDownLocation : CGPoint) {
    var mouseLocation = mouseDownLocation
    var loop = true
    while loop {
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
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
    //--- Wait for mouse dragged or mouse up
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
      self.display ()
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged // NSLeftMouseDragged
      if loop { // NSLeftMouseDragged
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        mSelection.removeAll ()
        let r = CGRect (point: mouseDownLocation, point: mouseDraggedLocation)
        mSelectionRectangle = r
        let cr = GeometricRect (cgrect: r)
        for segment in self.mSegmentList {
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
      self.display ()
    //--- Wait for mouse dragged or mouse up
      let event : NSEvent = self.window!.nextEvent (matching: [.leftMouseDragged, .leftMouseUp])!
      loop = event.type == .leftMouseDragged
      if loop {
        let mouseDraggedLocation = convert (event.locationInWindow, from:nil)
        let r = CGRect (point: mouseDownLocation, point: mouseDraggedLocation)
        mSelectionRectangle = r
        let cr = GeometricRect (cgrect: r)
        var selection = Set <SegmentForFontCharacterClass> ()
        for segment in self.mSegmentList {
          if segment.intersects (rect: cr) {
            selection.insert (segment)
          }
        }
        mSelection = selection.symmetricDifference (selectionOnMouseDown)
      }
    }
  }
  
  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   EXTENSION SegmentForFontCharacter
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension SegmentForFontCharacterClass {

  //····················································································································

  final func knobIndexFor (point p : CGPoint) -> Int? { // Return nil if point is outside a knob
    var result : Int? = nil
    do{
      let r = knobRect (self.x1, self.y1)
      if r.contains (p) {
        result = 0
      }
    }
    if result == nil {
      let r = knobRect (self.x2, self.y2)
      if r.contains (p) {
        result = 1
      }
    }
    return result
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

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
