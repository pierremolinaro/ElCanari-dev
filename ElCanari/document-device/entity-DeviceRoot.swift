//--------------------------------------------------------------------------------------------------
//  THIS FILE IS GENERATED BY EASY BINDINGS, DO NOT MODIFY IT
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------
//    Entity: DeviceRoot
//--------------------------------------------------------------------------------------------------

final class DeviceRoot : EBManagedObject
    {

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mSelectedPageIndex
  //------------------------------------------------------------------------------------------------

  final let mSelectedPageIndex_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mSelectedSymbolInspectorIndex
  //------------------------------------------------------------------------------------------------

  final let mSelectedSymbolInspectorIndex_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mSelectedPackageInspectorIndex
  //------------------------------------------------------------------------------------------------

  final let mSelectedPackageInspectorIndex_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mTitle
  //------------------------------------------------------------------------------------------------

  final let mTitle_property : EBStoredProperty_String

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mCategory
  //------------------------------------------------------------------------------------------------

  final let mCategory_property : EBStoredProperty_String

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mImageData
  //------------------------------------------------------------------------------------------------

  final let mImageData_property : EBStoredProperty_Data

  //------------------------------------------------------------------------------------------------

  final var mImageData : Data {
    get { return self.mImageData_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mPrefix
  //------------------------------------------------------------------------------------------------

  final let mPrefix_property : EBStoredProperty_String

  //------------------------------------------------------------------------------------------------

  final var mPrefix : String {
    get { return self.mPrefix_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mComments
  //------------------------------------------------------------------------------------------------

  final let mComments_property : EBStoredProperty_String

  //------------------------------------------------------------------------------------------------

  final var mComments : String {
    get { return self.mComments_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mPackageDisplayZoom
  //------------------------------------------------------------------------------------------------

  final let mPackageDisplayZoom_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mPackageDisplayHorizontalFlip
  //------------------------------------------------------------------------------------------------

  final let mPackageDisplayHorizontalFlip_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mPackageDisplayVerticalFlip
  //------------------------------------------------------------------------------------------------

  final let mPackageDisplayVerticalFlip_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mShowPackages
  //------------------------------------------------------------------------------------------------

  final let mShowPackages_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mShowPackagePadNumbers
  //------------------------------------------------------------------------------------------------

  final let mShowPackagePadNumbers_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mShowPackageFrontPads
  //------------------------------------------------------------------------------------------------

  final let mShowPackageFrontPads_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mShowPackageBackPads
  //------------------------------------------------------------------------------------------------

  final let mShowPackageBackPads_property : EBStoredProperty_Bool

  //------------------------------------------------------------------------------------------------
  //   Atomic property: mSymbolDisplayZoom
  //------------------------------------------------------------------------------------------------

  final let mSymbolDisplayZoom_property : EBStoredProperty_Int

  //------------------------------------------------------------------------------------------------
  //   To many property: mDocs
  //------------------------------------------------------------------------------------------------

  final let mDocs_property = StoredArrayOf_DeviceDocumentation (usedForSignature: true, key: "mDocs")

  //------------------------------------------------------------------------------------------------
  //   To many property: mSymbolInstances
  //------------------------------------------------------------------------------------------------

  final let mSymbolInstances_property = StoredArrayOf_SymbolInstanceInDevice (usedForSignature: true, key: "mSymbolInstances")

  //------------------------------------------------------------------------------------------------

  final var mSymbolInstances : EBReferenceArray <SymbolInstanceInDevice> {
    get { return self.mSymbolInstances_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   To many property: mPackages
  //------------------------------------------------------------------------------------------------

  final let mPackages_property = StoredArrayOf_PackageInDevice (usedForSignature: true, key: "mPackages")

  //------------------------------------------------------------------------------------------------

  final var mPackages : EBReferenceArray <PackageInDevice> {
    get { return self.mPackages_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   To many property: mSymbolTypes
  //------------------------------------------------------------------------------------------------

  final let mSymbolTypes_property = StoredArrayOf_SymbolTypeInDevice (usedForSignature: true, key: "mSymbolTypes")

  //------------------------------------------------------------------------------------------------

  final var mSymbolTypes : EBReferenceArray <SymbolTypeInDevice> {
    get { return self.mSymbolTypes_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   To many property: mPadProxies
  //------------------------------------------------------------------------------------------------

  final let mPadProxies_property = StoredArrayOf_PadProxyInDevice (usedForSignature: true, key: "mPadProxies")

  //------------------------------------------------------------------------------------------------

  final var mPadProxies : EBReferenceArray <PadProxyInDevice> {
    get { return self.mPadProxies_property.propval }
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: imageIsValid
  //------------------------------------------------------------------------------------------------

  final let imageIsValid_property = EBTransientProperty <Bool> ()

  //------------------------------------------------------------------------------------------------

  final var imageIsValid : Bool? {
    return self.imageIsValid_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: unconnectedPins
  //------------------------------------------------------------------------------------------------

  final let unconnectedPins_property = EBTransientProperty <UnconnectedSymbolPinsInDevice> ()

  //------------------------------------------------------------------------------------------------

  final var unconnectedPins : UnconnectedSymbolPinsInDevice? {
    return self.unconnectedPins_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: inconsistentPackagePadNameSetsMessage
  //------------------------------------------------------------------------------------------------

  final let inconsistentPackagePadNameSetsMessage_property = EBTransientProperty <String> ()

  //------------------------------------------------------------------------------------------------

  final var inconsistentPackagePadNameSetsMessage : String? {
    return self.inconsistentPackagePadNameSetsMessage_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: inconsistentSymbolNameSetMessage
  //------------------------------------------------------------------------------------------------

  final let inconsistentSymbolNameSetMessage_property = EBTransientProperty <String> ()

  //------------------------------------------------------------------------------------------------

  final var inconsistentSymbolNameSetMessage : String? {
    return self.inconsistentSymbolNameSetMessage_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: packagePadNameSetsAreConsistent
  //------------------------------------------------------------------------------------------------

  final let packagePadNameSetsAreConsistent_property = EBTransientProperty <Bool> ()

  //------------------------------------------------------------------------------------------------

  final var packagePadNameSetsAreConsistent : Bool? {
    return self.packagePadNameSetsAreConsistent_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: symbolNameAreConsistent
  //------------------------------------------------------------------------------------------------

  final let symbolNameAreConsistent_property = EBTransientProperty <Bool> ()

  //------------------------------------------------------------------------------------------------

  final var symbolNameAreConsistent : Bool? {
    return self.symbolNameAreConsistent_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: symbolTypeNames
  //------------------------------------------------------------------------------------------------

  final let symbolTypeNames_property = EBTransientProperty <StringArray> ()

  //------------------------------------------------------------------------------------------------

  final var symbolTypeNames : StringArray? {
    return self.symbolTypeNames_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: embeddedLibraryAttentionImage
  //------------------------------------------------------------------------------------------------

  final let embeddedLibraryAttentionImage_property = EBTransientProperty <NSImage> ()

  //------------------------------------------------------------------------------------------------

  final var embeddedLibraryAttentionImage : NSImage? {
    return self.embeddedLibraryAttentionImage_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: unconnectedPads
  //------------------------------------------------------------------------------------------------

  final let unconnectedPads_property = EBTransientProperty <StringArray> ()

  //------------------------------------------------------------------------------------------------

  final var unconnectedPads : StringArray? {
    return self.unconnectedPads_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: assignedPadProxies
  //------------------------------------------------------------------------------------------------

  final let assignedPadProxies_property = EBTransientProperty <AssignedPadProxiesInDevice> ()

  //------------------------------------------------------------------------------------------------

  final var assignedPadProxies : AssignedPadProxiesInDevice? {
    return self.assignedPadProxies_property.optionalValue
  }

  //------------------------------------------------------------------------------------------------
  //   Transient property: issues
  //------------------------------------------------------------------------------------------------

  final let issues_property = EBTransientProperty <CanariIssueArray> ()

  //------------------------------------------------------------------------------------------------

  final var issues : CanariIssueArray? {
    return self.issues_property.optionalValue
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    init
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  required init (_ inUndoManager : UndoManager?) {
    self.mSelectedPageIndex_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "mSelectedPageIndex")
    self.mSelectedSymbolInspectorIndex_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "mSelectedSymbolInspectorIndex")
    self.mSelectedPackageInspectorIndex_property = EBStoredProperty_Int (defaultValue: 0, undoManager: inUndoManager, key: "mSelectedPackageInspectorIndex")
    self.mTitle_property = EBStoredProperty_String (defaultValue: "", undoManager: inUndoManager, key: "mTitle")
    self.mCategory_property = EBStoredProperty_String (defaultValue: "", undoManager: inUndoManager, key: "mCategory")
    self.mImageData_property = EBStoredProperty_Data (defaultValue: Data (), undoManager: inUndoManager, key: "mImageData")
    self.mPrefix_property = EBStoredProperty_String (defaultValue: "", undoManager: inUndoManager, key: "mPrefix")
    self.mComments_property = EBStoredProperty_String (defaultValue: "", undoManager: inUndoManager, key: "mComments")
    self.mPackageDisplayZoom_property = EBStoredProperty_Int (defaultValue: 400, undoManager: inUndoManager, key: "mPackageDisplayZoom")
    self.mPackageDisplayHorizontalFlip_property = EBStoredProperty_Bool (defaultValue: false, undoManager: inUndoManager, key: "mPackageDisplayHorizontalFlip")
    self.mPackageDisplayVerticalFlip_property = EBStoredProperty_Bool (defaultValue: false, undoManager: inUndoManager, key: "mPackageDisplayVerticalFlip")
    self.mShowPackages_property = EBStoredProperty_Bool (defaultValue: true, undoManager: inUndoManager, key: "mShowPackages")
    self.mShowPackagePadNumbers_property = EBStoredProperty_Bool (defaultValue: true, undoManager: inUndoManager, key: "mShowPackagePadNumbers")
    self.mShowPackageFrontPads_property = EBStoredProperty_Bool (defaultValue: true, undoManager: inUndoManager, key: "mShowPackageFrontPads")
    self.mShowPackageBackPads_property = EBStoredProperty_Bool (defaultValue: true, undoManager: inUndoManager, key: "mShowPackageBackPads")
    self.mSymbolDisplayZoom_property = EBStoredProperty_Int (defaultValue: 400, undoManager: inUndoManager, key: "mSymbolDisplayZoom")
    super.init (inUndoManager)
    self.accumulateProperty (self.mSelectedPageIndex_property)
    self.accumulateProperty (self.mSelectedSymbolInspectorIndex_property)
    self.accumulateProperty (self.mSelectedPackageInspectorIndex_property)
    self.accumulateProperty (self.mTitle_property)
    self.accumulateProperty (self.mCategory_property)
    self.accumulateProperty (self.mImageData_property)
    self.accumulateProperty (self.mPrefix_property)
    self.accumulateProperty (self.mComments_property)
    self.accumulateProperty (self.mPackageDisplayZoom_property)
    self.accumulateProperty (self.mPackageDisplayHorizontalFlip_property)
    self.accumulateProperty (self.mPackageDisplayVerticalFlip_property)
    self.accumulateProperty (self.mShowPackages_property)
    self.accumulateProperty (self.mShowPackagePadNumbers_property)
    self.accumulateProperty (self.mShowPackageFrontPads_property)
    self.accumulateProperty (self.mShowPackageBackPads_property)
    self.accumulateProperty (self.mSymbolDisplayZoom_property)
  //--- To many property: mDocs (no option)
    self.mDocs_property.undoManager = inUndoManager
    self.accumulateProperty (self.mDocs_property)
  //--- To many property: mSymbolInstances (has opposite relationship)
    self.mSymbolInstances_property.undoManager = inUndoManager
    self.mSymbolInstances_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mDeviceRoot_property.setProp (me) } },
      resetter: { inObject in inObject.mDeviceRoot_property.setProp (nil) }
    )
    self.accumulateProperty (self.mSymbolInstances_property)
  //--- To many property: mPackages (has opposite relationship)
    self.mPackages_property.undoManager = inUndoManager
    self.mPackages_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mRoot_property.setProp (me) } },
      resetter: { inObject in inObject.mRoot_property.setProp (nil) }
    )
    self.accumulateProperty (self.mPackages_property)
  //--- To many property: mSymbolTypes (no option)
    self.mSymbolTypes_property.undoManager = inUndoManager
    self.accumulateProperty (self.mSymbolTypes_property)
  //--- To many property: mPadProxies (no option)
    self.mPadProxies_property.undoManager = inUndoManager
    self.accumulateProperty (self.mPadProxies_property)
  //--- Atomic property: imageIsValid
    self.imageIsValid_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mImageData_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_DeviceRoot_imageIsValid (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mImageData_property.startsBeingObserved (by: self.imageIsValid_property)
  //--- Atomic property: unconnectedPins
    self.unconnectedPins_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mSymbolInstances_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_DeviceRoot_unconnectedPins (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mSymbolInstances_property.toMany_unconnectedPins_StartsBeingObserved (by: self.unconnectedPins_property)
  //--- Atomic property: inconsistentPackagePadNameSetsMessage
    self.inconsistentPackagePadNameSetsMessage_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mPackages_property.selection
        let s1 = unwSelf.mPackages_property.selection
        switch (s0, s1) {
        case (.single (let v0),
              .single (let v1)) :
          return .single (transient_DeviceRoot_inconsistentPackagePadNameSetsMessage (v0, v1))
        case (.multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mPackages_property.toMany_padNameSet_StartsBeingObserved (by: self.inconsistentPackagePadNameSetsMessage_property)
    self.mPackages_property.toMany_mName_StartsBeingObserved (by: self.inconsistentPackagePadNameSetsMessage_property)
  //--- Atomic property: inconsistentSymbolNameSetMessage
    self.inconsistentSymbolNameSetMessage_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mSymbolInstances_property.selection
        let s1 = unwSelf.mSymbolInstances_property.selection
        switch (s0, s1) {
        case (.single (let v0),
              .single (let v1)) :
          return .single (transient_DeviceRoot_inconsistentSymbolNameSetMessage (v0, v1))
        case (.multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mSymbolInstances_property.toMany_symbolQualifiedName_StartsBeingObserved (by: self.inconsistentSymbolNameSetMessage_property)
    self.mSymbolInstances_property.toMany_pinSymbolQualifiedNames_StartsBeingObserved (by: self.inconsistentSymbolNameSetMessage_property)
  //--- Atomic property: packagePadNameSetsAreConsistent
    self.packagePadNameSetsAreConsistent_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mPackages_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_DeviceRoot_packagePadNameSetsAreConsistent (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mPackages_property.toMany_padNameSet_StartsBeingObserved (by: self.packagePadNameSetsAreConsistent_property)
  //--- Atomic property: symbolNameAreConsistent
    self.symbolNameAreConsistent_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.inconsistentSymbolNameSetMessage_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_DeviceRoot_symbolNameAreConsistent (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.inconsistentSymbolNameSetMessage_property.startsBeingObserved (by: self.symbolNameAreConsistent_property)
  //--- Atomic property: symbolTypeNames
    self.symbolTypeNames_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mSymbolTypes_property.selection
        switch (s0) {
        case (.single (let v0)) :
          return .single (transient_DeviceRoot_symbolTypeNames (v0))
        case (.multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mSymbolTypes_property.toMany_mTypeName_StartsBeingObserved (by: self.symbolTypeNames_property)
  //--- Atomic property: embeddedLibraryAttentionImage
    self.embeddedLibraryAttentionImage_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mPackages_property.selection
        let s1 = unwSelf.mSymbolTypes_property.selection
        switch (s0, s1) {
        case (.single (let v0),
              .single (let v1)) :
          return .single (transient_DeviceRoot_embeddedLibraryAttentionImage (v0, v1))
        case (.multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mPackages_property.toMany_mFileSystemStatusRequiresAttentionForPackageInDevice_StartsBeingObserved (by: self.embeddedLibraryAttentionImage_property)
    self.mSymbolTypes_property.toMany_mFileSystemStatusRequiresAttentionForSymbolTypeInDevice_StartsBeingObserved (by: self.embeddedLibraryAttentionImage_property)
  //--- Atomic property: unconnectedPads
    self.unconnectedPads_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mPadProxies_property.selection
        let s1 = unwSelf.mPadProxies_property.selection
        switch (s0, s1) {
        case (.single (let v0),
              .single (let v1)) :
          return .single (transient_DeviceRoot_unconnectedPads (v0, v1))
        case (.multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mPadProxies_property.toMany_mPadName_StartsBeingObserved (by: self.unconnectedPads_property)
    self.mPadProxies_property.toMany_isConnected_StartsBeingObserved (by: self.unconnectedPads_property)
  //--- Atomic property: assignedPadProxies
    self.assignedPadProxies_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mPadProxies_property.selection
        let s1 = unwSelf.mPadProxies_property.selection
        let s2 = unwSelf.mPadProxies_property.selection
        let s3 = unwSelf.mPadProxies_property.selection
        switch (s0, s1, s2, s3) {
        case (.single (let v0),
              .single (let v1),
              .single (let v2),
              .single (let v3)) :
          return .single (transient_DeviceRoot_assignedPadProxies (v0, v1, v2, v3))
        case (.multiple,
              .multiple,
              .multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mPadProxies_property.toMany_mPadName_StartsBeingObserved (by: self.assignedPadProxies_property)
    self.mPadProxies_property.toMany_symbolName_StartsBeingObserved (by: self.assignedPadProxies_property)
    self.mPadProxies_property.toMany_mPinInstanceName_StartsBeingObserved (by: self.assignedPadProxies_property)
    self.mPadProxies_property.toMany_isConnected_StartsBeingObserved (by: self.assignedPadProxies_property)
  //--- Atomic property: issues
    self.issues_property.mReadModelFunction = { [weak self] in
      if let unwSelf = self {
        let s0 = unwSelf.mTitle_property.selection
        let s1 = unwSelf.mPrefix_property.selection
        let s2 = unwSelf.inconsistentPackagePadNameSetsMessage_property.selection
        let s3 = unwSelf.inconsistentSymbolNameSetMessage_property.selection
        let s4 = unwSelf.unconnectedPins_property.selection
        let s5 = unwSelf.unconnectedPads_property.selection
        let s6 = unwSelf.mPackages_property.selection
        let s7 = unwSelf.mPackages_property.selection
        let s8 = unwSelf.mSymbolTypes_property.selection
        let s9 = unwSelf.mSymbolTypes_property.selection
        let s10 = unwSelf.mSymbolTypes_property.selection
        switch (s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10) {
        case (.single (let v0),
              .single (let v1),
              .single (let v2),
              .single (let v3),
              .single (let v4),
              .single (let v5),
              .single (let v6),
              .single (let v7),
              .single (let v8),
              .single (let v9),
              .single (let v10)) :
          return .single (transient_DeviceRoot_issues (v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10))
        case (.multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple,
              .multiple) :
          return .multiple
        default :
          return .empty
        }
      }else{
        return .empty
      }
    }
    self.mTitle_property.startsBeingObserved (by: self.issues_property)
    self.mPrefix_property.startsBeingObserved (by: self.issues_property)
    self.inconsistentPackagePadNameSetsMessage_property.startsBeingObserved (by: self.issues_property)
    self.inconsistentSymbolNameSetMessage_property.startsBeingObserved (by: self.issues_property)
    self.unconnectedPins_property.startsBeingObserved (by: self.issues_property)
    self.unconnectedPads_property.startsBeingObserved (by: self.issues_property)
    self.mPackages_property.toMany_mVersion_StartsBeingObserved (by: self.issues_property)
    self.mPackages_property.toMany_mName_StartsBeingObserved (by: self.issues_property)
    self.mSymbolTypes_property.toMany_mVersion_StartsBeingObserved (by: self.issues_property)
    self.mSymbolTypes_property.toMany_mTypeName_StartsBeingObserved (by: self.issues_property)
    self.mSymbolTypes_property.toMany_instanceCount_StartsBeingObserved (by: self.issues_property)
  //--- Install undoers and opposite setter for relationships
    self.mSymbolInstances_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mDeviceRoot_property.setProp (me) } },
      resetter: { inObject in inObject.mDeviceRoot_property.setProp (nil) }
    )
    self.mPackages_property.setOppositeRelationShipFunctions (
      setter: { [weak self] inObject in if let me = self { inObject.mRoot_property.setProp (me) } },
      resetter: { inObject in inObject.mRoot_property.setProp (nil) }
    )
  //--- Register properties for handling signature
    self.mCategory_property.setSignatureObserver (observer: self)
    self.mComments_property.setSignatureObserver (observer: self)
    self.mDocs_property.setSignatureObserver (observer: self)
    self.mImageData_property.setSignatureObserver (observer: self)
    self.mPackages_property.setSignatureObserver (observer: self)
    self.mPadProxies_property.setSignatureObserver (observer: self)
    self.mPrefix_property.setSignatureObserver (observer: self)
    self.mSymbolInstances_property.setSignatureObserver (observer: self)
    self.mSymbolTypes_property.setSignatureObserver (observer: self)
    self.mTitle_property.setSignatureObserver (observer: self)
  //--- Extern delegates
   }
  
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //    Extern delegates
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -


  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  //   computeSignature
  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  override func computeSignature () -> UInt32 {
    var crc = super.computeSignature ()
    crc.accumulate (u32: self.mCategory_property.signature ())
    crc.accumulate (u32: self.mComments_property.signature ())
    crc.accumulate (u32: self.mDocs_property.signature ())
    crc.accumulate (u32: self.mImageData_property.signature ())
    crc.accumulate (u32: self.mPackages_property.signature ())
    crc.accumulate (u32: self.mPadProxies_property.signature ())
    crc.accumulate (u32: self.mPrefix_property.signature ())
    crc.accumulate (u32: self.mSymbolInstances_property.signature ())
    crc.accumulate (u32: self.mSymbolTypes_property.signature ())
    crc.accumulate (u32: self.mTitle_property.signature ())
    return crc
  }

  // - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

}

//--------------------------------------------------------------------------------------------------

