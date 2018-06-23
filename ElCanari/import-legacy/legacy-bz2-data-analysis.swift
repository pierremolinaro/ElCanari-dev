//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//  Created by Pierre Molinaro on 08/07/2015.
//  Copyright © 2015 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————


import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func analyzeLegacyUncompressedData (_ uncompressedData : Data, objectArray : inout [NSMutableDictionary]) {
  var dataScanner = EBDataScanner (data:uncompressedData)
  var entityLegacyDescriptionArray = [EBEntityLegacyDescription] ()
  analyzeEntities (&dataScanner, entities:&entityLegacyDescriptionArray)
  loadWithDataScanner (&dataScanner, entities:&entityLegacyDescriptionArray, objectArray:&objectArray)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ANALYZE ENTITIES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private class EBEntityLegacyDescription {
  let mEntityName : String
  let mSuperEntityIndex : UInt?
  let mEntityPropertyNameArray : [String]
  let mEntityRelationshipNameArray : [String]
  
  init (entityName : String,
        superEntityIndex : UInt?,
        entityPropertyNameArray : [String],
        entityRelationshipArray : [String]) {
    mEntityName = entityName
    mEntityPropertyNameArray = entityPropertyNameArray
    mEntityRelationshipNameArray = entityRelationshipArray
    mSuperEntityIndex = superEntityIndex
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func analyzeEntities (_ dataScanner : inout EBDataScanner,
                              entities : inout [EBEntityLegacyDescription]) {
//--- Get entity count
  let entityCount : UInt = dataScanner.parseAutosizedUnsignedInteger ()
  for _ : UInt in 0 ..< entityCount {
  //--- 'Start of Entity' mark
    dataScanner.acceptRequired (byte: 0xBA)
  //--- Entity Name
    let entityName = dataScanner.parseAutosizedString ()
  //--- Super entity
    let superEntityIndex : UInt?
    if dataScanner.testAccept (byte: 0xFE) {
      superEntityIndex = dataScanner.parseAutosizedUnsignedInteger ()
    }else{ // No super entity
      superEntityIndex = nil
      dataScanner.acceptRequired (byte: 0xFF)
    }
  //--- Parse attributes and relationship definitions
    var entityPropertyNameArray = [String] ()
    var entityRelationshipNameArray = [String] ()
    var loop = true
    while loop && dataScanner.ok () {
      if dataScanner.testAccept (byte: 0x01) { // "NSInteger16AttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x02) { //  comment:"NSInteger32AttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x03) { // comment:"NSInteger64AttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x04) { // comment:"NSDecimalAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
       }else if dataScanner.testAccept (byte: 0x05) { // comment:"NSDoubleAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x06) { // comment:"NSFloatAttributeType or NSDoubleAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x07) { // comment:"NSStringAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x08) { // comment:"NSBooleanAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x09) { // comment:"NSDateAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x0A) { // comment:"NSBinaryDataAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAccept (byte: 0x0B) { // comment:"To-one relationship Mark") {
        /* const NSUInteger relationshipEntityIndex = */ _ = dataScanner.parseAutosizedUnsignedInteger ()
        let relationshipName = dataScanner.parseAutosizedString ()
        entityRelationshipNameArray.append (relationshipName)
      }else if dataScanner.testAccept (byte: 0x0C) { // comment:"To-many relationship Mark") {
        /* const NSUInteger relationshipEntityIndex = */ _ = dataScanner.parseAutosizedUnsignedInteger ()
        let relationshipName = dataScanner.parseAutosizedString ()
        entityRelationshipNameArray.append (relationshipName)
      }else if dataScanner.testAccept (byte: 0x0D) { // comment:"NSTransformableAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ()
        entityPropertyNameArray.append (attributeName)
      }else{
        entityPropertyNameArray.append ("")
        entityRelationshipNameArray.append ("")
        dataScanner.acceptRequired (byte: 0x00)
        loop = false
        let entityDescription = EBEntityLegacyDescription (
          entityName: entityName,
          superEntityIndex: superEntityIndex,
          entityPropertyNameArray: entityPropertyNameArray,
          entityRelationshipArray: entityRelationshipNameArray
        )
        entities.append (entityDescription)
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ANALYZE VALUES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func loadWithDataScanner (_ dataScanner : inout EBDataScanner,
                                  entities : inout [EBEntityLegacyDescription],
                                  objectArray : inout [NSMutableDictionary]) {
//------------------------ 'Object count' mark
  dataScanner.acceptRequired (byte: 0x02) // comment:"Object count Mark")
//------------------------ Get object count 
  let objectCount = dataScanner.parseAutosizedUnsignedInteger ()
//------------------------ Parse object attributes
  for i in 0 ..< objectCount {
    scanObjectIndex (
      i,
      dataScanner : &dataScanner,
      entities:&entities,
      objectArray:&objectArray
    )
  }
//------------------------ Parse object relation
  for i in 0 ..< objectCount {
    scanRelationshipForObjectIndex (
      i,
      dataScanner : &dataScanner,
      entities:&entities,
      objectArray:&objectArray
    )
  }
//------------------------ 'End of file' mark
  dataScanner.acceptRequired (byte: 0x05)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func scanObjectIndex (_ inObjectIndex : UInt,
                              dataScanner : inout EBDataScanner,
                              entities : inout [EBEntityLegacyDescription],
                              objectArray : inout [NSMutableDictionary]) {
//--- 'start of object attribute' mark
  dataScanner.acceptRequired (byte: 0x03) // comment:"Start of values Mark")
//--- Entity index
  let entityIndex : Int = Int (dataScanner.parseAutosizedUnsignedInteger ())
//--- Create new object
  let entityName = entities [entityIndex].mEntityName
  let objectValues = NSMutableDictionary ()
  objectValues.setValue(entityName, forKey:kEntityKey)
//--- Entity attribute name list, ordered by name
  let sortedPropertyNames = entities [entityIndex].mEntityPropertyNameArray
//--- Parse attributes and relationship values
  var propertyIndex = 0
  var loop = true
  while loop {
    let key = sortedPropertyNames [propertyIndex]
    propertyIndex += 1
    if dataScanner.testAccept (byte: 0xFF) { // nil
 
    }else if dataScanner.testAccept (byte: 0xFE) { //, comment:"Unsigned Integer Mark for '\(key)'") { // positive signed integer
      let value = dataScanner.parseAutosizedUnsignedInteger ()
      objectValues.setValue (NSNumber (value: value), forKey:key)
    }else if dataScanner.testAccept (byte: 0xFD) { // comment:"Negative Integer Mark for '\(key)'") { // negative signed integer
      let value = Int (dataScanner.parseAutosizedUnsignedInteger ())
      objectValues.setValue (NSNumber (value: -value), forKey:key)
    }else if dataScanner.testAccept (byte: 0x09) { // comment:"String Mark for '\(key)'") { // String
      let s : String = dataScanner.parseAutosizedString ()
      objectValues.setValue (s, forKey:key)
    }else if dataScanner.testAccept (byte: 0x0A) { // comment:"Boolean NO for '\(key)'") { // False
      objectValues.setValue (NSNumber (value: false), forKey:key)
    }else if dataScanner.testAccept (byte: 0x0B) { // comment:"Boolean YES for '\(key)'") { // True
      objectValues.setValue (NSNumber (value: true), forKey:key)
    }else if dataScanner.testAccept (byte: 0x0C) { // comment:"Float Mark for '\(key)'") { // Float
      let data = dataScanner.parseAutosizedData ()
      let floatNumber = NSUnarchiver.unarchiveObject (with: data as Data)
      objectValues.setValue (floatNumber, forKey:key)
    }else if dataScanner.testAccept (byte: 0x0D) { // comment:"Double Mark for '\(key)'") { // Double
      let data = dataScanner.parseAutosizedData ()
      let doubleNumber = NSUnarchiver.unarchiveObject (with: data as Data)
      objectValues.setValue (doubleNumber, forKey:key)
    }else if dataScanner.testAccept (byte: 0x0E) { // comment:"Date Mark for '\(key)'") { // Date
      let data = dataScanner.parseAutosizedData ()
      let date = NSUnarchiver.unarchiveObject (with: data as Data)
      objectValues.setValue (date, forKey:key)
    }else if dataScanner.testAccept (byte: 0x0F) { // comment:"Binary Data Mark for '\(key)'") { // Binary Data
      let data = dataScanner.parseAutosizedData ()
      objectValues.setValue (data, forKey:key)
    }else if dataScanner.testAccept (byte: 0x10) { // comment:"Decimal Mark for '\(key)'") { // Decimal
      let data = dataScanner.parseAutosizedData ()
      let decimalNumber = NSUnarchiver.unarchiveObject (with: data as Data)
      objectValues.setValue (decimalNumber, forKey:key)
//    }else if dataScanner.testAccept (byte: 0x11) { // comment:"Transformable Attribute Mark for '\(key)'") { // Decimal
//      dataScanner.parseAutosizedData ("Value as binary data (length)", dataComment:"Value as binary data")
    }else{
      dataScanner.acceptRequired (byte: 0x00) // comment:"End of #\(inObjectIndex) Object Attribute Values\n")
      objectArray.append (objectValues)
      loop = false
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func scanRelationshipForObjectIndex (_ inObjectIndex : UInt,
                                             dataScanner : inout EBDataScanner,
                                             entities : inout [EBEntityLegacyDescription],
                                             objectArray : inout [NSMutableDictionary]) {
//--- 'start of object relationship' mark
  dataScanner.acceptRequired (byte: 0x04) // comment:"Start of #\(inObjectIndex) Object Relationships");
//--- Entity Index
  let entityIndex = Int (dataScanner.parseAutosizedUnsignedInteger ())
//--- Build attribute array
  let sortedRelationshipDescriptionArray = entities [entityIndex].mEntityRelationshipNameArray
//--- Parse relationship values
  var relationshipIndex = 0
  var loop = true
  let objectValues = objectArray [Int (inObjectIndex)]
  while loop {
    let key = sortedRelationshipDescriptionArray [relationshipIndex]
    relationshipIndex += 1
    if dataScanner.testAccept (byte: 0xFF) { // comment:"'\(key)' -> nil") { // nil
    }else if dataScanner.testAccept (byte: 0x01) { // comment:"'\(key)' -> To one value") {
      let destinationObjectIndex = dataScanner.parseAutosizedUnsignedInteger ()
      objectValues.setValue (NSNumber (value: destinationObjectIndex), forKey:key)
    }else if dataScanner.testAccept (byte: 0x02) { // comment:"'\(key)' -> To Many value") {
      let objectCount = dataScanner.parseAutosizedUnsignedInteger ()
      let objectArray = NSMutableArray ()
      for _ in 0 ..< objectCount {
        let destinationObjectIndex = dataScanner.parseAutosizedUnsignedInteger ()
        objectArray.add (NSNumber (value: destinationObjectIndex))
      }
      objectValues.setValue (objectArray, forKey:key)
    }else{
      dataScanner.acceptRequired (byte: 0x00) // comment:"End of #\(inObjectIndex) Object Relationships\n")
      loop = false
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

