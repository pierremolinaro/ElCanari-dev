//
//  EBManagedDocument.swift
//  ElCanari-Debug-temporary
//
//  Created by Pierre Molinaro on 09/02/2021.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBManagedDocument : NSDocument, EBUserClassNameProtocol {

  //····················································································································
  //   Properties
  //····················································································································

  internal final var mRootObject : EBManagedObject?
  fileprivate final var mUndoManager = EBUndoManager ()

  //····················································································································
  //    init
  //····················································································································

  override init () {
    super.init ()
    noteObjectAllocation (self)
    self.undoManager = self.mUndoManager
    self.mUndoManager.disableUndoRegistration ()
    self.mRootObject = newInstanceOfEntityNamed (self.mUndoManager, rootEntityClassName ())!
    self.mUndoManager.enableUndoRegistration ()
  }

  //····················································································································

  deinit {
    noteObjectDeallocation (self)
  }

  //····················································································································
  //    ebUndoManager
  //····················································································································

  final var ebUndoManager : EBUndoManager {
    return self.mUndoManager
  }

  //····················································································································
  //    rootEntityClassName
  //····················································································································

  func rootEntityClassName () -> String {
    return ""
  }

  //····················································································································
  // Providing the drag image, called by a source drag table view (CanariDragSourceTableView)
  //····················································································································

  func dragImageForRowsXib (source inSourceTableView : CanariDragSourceTableView,
                            with dragRows: IndexSet,
                            tableColumns: [NSTableColumn],
                            event dragEvent: NSEvent,
                            offset dragImageOffset: NSPointPointer) -> NSImage {
    return NSImage (named: NSImage.Name ("exclamation"))!
  }

  //····················································································································

  func dragImageForRows (source inSourceTableView : AutoLayoutElCanariDragSourceTableView,
                         with dragRows: IndexSet,
                         tableColumns: [NSTableColumn],
                         event dragEvent: NSEvent,
                         offset dragImageOffset: NSPointPointer) -> NSImage {
    return NSImage (named: NSImage.Name ("exclamation"))!
  }

  //····················································································································
  //   Drag destination
  //····················································································································
  //The six NSDraggingDestination methods are invoked in a distinct order:
  //
  // ① As the image is dragged into the destination’s boundaries, the destination is sent a draggingEntered: message.
  //       The method should return a value that indicates which dragging operation the destination will perform.
  // ② While the image remains within the destination, a series of draggingUpdated: messages are sent.
  //       The method should return a value that indicates which dragging operation the destination will perform.
  // ③ If the image is dragged out of the destination, draggingExited: is sent and the sequence of
  //       NSDraggingDestination messages stops. If it re-enters, the sequence begins again (with a new
  //       draggingEntered: message).
  // ④ When the image is released, it either slides back to its source (and breaks the sequence) or a
  //       prepareForDragOperation: message is sent to the destination, depending on the value returned by the most
  //       recent invocation of draggingEntered: or draggingUpdated:.
  // ⑤  If the prepareForDragOperation: message returned YES, a performDragOperation: message is sent.
  // ⑥  Finally, if performDragOperation: returned YES, concludeDragOperation: is sent.
  //
  //····················································································································

  func draggingEntered (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    // NSLog ("draggingEntered")
    return .copy
  }

  //····················································································································

  func draggingUpdated (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> NSDragOperation {
    // NSLog ("draggingUpdated")
    return .copy
  }

  //····················································································································

  func draggingExited (_ sender: NSDraggingInfo?, _ destinationScrollView : NSScrollView) {
    // NSLog ("draggingExited")
  }

  //····················································································································

  func prepareForDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    // NSLog ("prepareForDragOperation")
    return true
  }

  //····················································································································

  func performDragOperation (_ sender: NSDraggingInfo, _ destinationScrollView : NSScrollView) -> Bool {
    // NSLog ("performDragOperation")
    return false
  }

  //····················································································································

  func concludeDragOperation (_ inSender: NSDraggingInfo?, _ destinationScrollView : NSScrollView) {
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  EBSignatureObserverEvent
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

final class EBSignatureObserverEvent : EBTransientProperty_UInt32, EBSignatureObserverProtocol {

  //····················································································································

  private weak var mRootObject : EBSignatureObserverProtocol? // SOULD BE WEAK

  //····················································································································

  override init () {
    super.init ()
    self.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        return .single (unwSelf.signature ())
      }else{
        return .empty
      }
    }
  }

  //····················································································································

  final func setRootObject (_ rootObject : EBSignatureObserverProtocol) {
    self.mRootObject = rootObject
  }

  //····················································································································

  func signature () -> UInt32 {
    if let rootObject = self.mRootObject {
      return rootObject.signature ()
    }else{
      return 0
    }
  }

  //····················································································································

  func clearSignatureCache () {
    self.observedObjectDidChange ()
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
