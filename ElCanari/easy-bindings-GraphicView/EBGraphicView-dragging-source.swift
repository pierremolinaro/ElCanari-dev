//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import AppKit

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

extension EBGraphicView : NSDraggingSource {

  //····················································································································

  final func draggingSession (_ session: NSDraggingSession,
                              sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
    return .generic
  }

  //····················································································································

  final func ebStartDragging (with inEvent : NSEvent, dragType : NSPasteboard.PasteboardType) {
  //--- Find object under mouse
    let mouseDownLocation = self.convert (inEvent.locationInWindow, from:nil)
    let (possibleObjectIndex, _) = self.indexOfFrontObject (at: mouseDownLocation)
    if let objectIndex = possibleObjectIndex {
    //--- Build dragged object set
      var draggedObjectSet = EBReferenceSet <EBGraphicManagedObject> ()
      let objectArray = self.mViewController?.graphicObjectArray ?? []
      let selectedObjectSet = self.mViewController?.selectedGraphicObjectSet ?? EBReferenceSet <EBGraphicManagedObject> ()
      if selectedObjectSet.contains (objectArray [objectIndex]) { // Clic on a selected object: drag selection
        draggedObjectSet = selectedObjectSet
      }else{ // Object is not selected: drag only this object
        draggedObjectSet.insert (objectArray [objectIndex])
      }
    //--- Start dragging
      if draggedObjectSet.count > 0 {
        self.performStartDragging (draggedObjectSet: draggedObjectSet, event: inEvent, dragType: dragType)
      }
    }
  }

  //····················································································································

  final fileprivate func performStartDragging (draggedObjectSet : EBReferenceSet <EBGraphicManagedObject>,
                                               event inEvent : NSEvent,
                                               dragType : NSPasteboard.PasteboardType) {
  //--- Build dragging item
    let pasteboardItem = NSPasteboardItem ()
    let draggingItem = NSDraggingItem (pasteboardWriter: pasteboardItem)
  //--- Buils image and data
    let objectArray = self.mViewController?.graphicObjectArray ?? []
    var displayShape = EBShape ()
    var objectDictionaryArray = [[String : Any]] ()
    var objectAdditionalDictionaryArray = [[String : Any]] ()
    for object in objectArray {
      if draggedObjectSet.contains (object), let objectShape = object.objectDisplay {
        displayShape.add (objectShape)
        var dict = [String : Any] ()
        object.savePropertiesIntoDictionary (&dict)
        objectDictionaryArray.append (dict)
        var additionalDict = [String : Any] ()
        object.saveIntoAdditionalDictionary (&additionalDict)
        objectAdditionalDictionaryArray.append (additionalDict)
      }
    }
  //--- Associated data
    let mouseDownCocoaLocation = self.convert (inEvent.locationInWindow, from:nil)
    let mouseDownCanariLocation = mouseDownCocoaLocation.canariPointAligned (onCanariGrid: SYMBOL_GRID_IN_CANARI_UNIT)
    let dataDictionary : [String : Any] = [
      OBJECT_DICTIONARY_KEY : objectDictionaryArray,
      OBJECT_ADDITIONAL_DICTIONARY_KEY : objectAdditionalDictionaryArray,
      X_KEY : mouseDownCanariLocation.x,
      Y_KEY : mouseDownCanariLocation.y
    ]
    pasteboardItem.setPropertyList (dataDictionary, forType: dragType)
  //--- Transform image by scaling and translating
    let hasHorizontalFlip : CGFloat = self.horizontalFlip ? -1.0 : 1.0
    let hasVerticalFlip   : CGFloat = self.verticalFlip   ? -1.0 : 1.0
    var transform = AffineTransform ()
    transform.scale (x: self.actualScale * hasHorizontalFlip, y: self.actualScale * hasVerticalFlip)
    transform.translate (x: -displayShape.boundingBox.minX, y: -displayShape.boundingBox.minY)
    let finalShape = displayShape.transformed (by: transform)
  //--- Build image
    let rect = finalShape.boundingBox
    let image = buildPDFimage (frame: rect, shape: finalShape)
  //--- Move image rect origin to mouse click location
    let draggingFrame = NSRect (
      x: displayShape.boundingBox.minX,
      y: displayShape.boundingBox.minY,
      width: rect.size.width,
      height: rect.size.height
    )
  //--- Set dragged image
    draggingItem.setDraggingFrame (draggingFrame, contents: image)
  //--- Begin dragging
    self.beginDraggingSession (with: [draggingItem], event: inEvent, source: self)
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————