//
//  legacy-bz2-data-analysis.swift
//  eb-document-analyzer
//
//  Created by Pierre Molinaro on 08/07/2015.
//  Copyright © 2015 Pierre Molinaro. All rights reserved.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func analyzeLegacyBZ2Data (_ data : Data, textView:NSTextView) {
  textView.appendMessageString ("------------------------------ Uncompressed data format\n")
  let uncompressedData = bz2DecompressedData (data)
  textView.appendMessageString ("Uncompressed data: \(uncompressedData.count) bytes\n")
//--- Analyze uncompressed data
  var dataScanner = DataScanner (data:uncompressedData, textView:textView)
  textView.appendMessageString ("--- Entities\n")
  var entityLegacyDescriptionArray = [EBEntityLegacyDescription] ()
  analyzeEntities (&dataScanner, textView:textView, entities:&entityLegacyDescriptionArray)
  textView.appendMessageString ("--- Values\n")
  var objectArray = [NSMutableDictionary] ()
  loadWithDataScanner (&dataScanner, textView:textView, entities:&entityLegacyDescriptionArray, objectArray:&objectArray)
  textView.appendMessageString ("--- Resulting dictionary array\n")
  textView.appendMessageString (String (format:"%@\n", objectArray))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    ANALYZE ENTITIES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class EBEntityLegacyDescription {
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

private func analyzeEntities (_ dataScanner : inout DataScanner,
                              textView:NSTextView,
                              entities : inout [EBEntityLegacyDescription]) {
//--- Get entity count
  let entityCount : UInt = dataScanner.parseAutosizedUnsignedInteger ("Entity Count")
  for i : UInt in 0 ..< entityCount {
    textView.appendMessageString ("\n")
  //--- 'Start of Entity' mark
    dataScanner.acceptRequiredByte (0xBA, comment: "Start of Entity")
  //--- Entity Name
    let entityName = dataScanner.parseAutosizedString ("Entity Name")
  //--- Super entity
    let superEntityIndex : UInt?
    if dataScanner.testAcceptByte (0xFE, comment : "Super Entity Mark") {
      superEntityIndex = dataScanner.parseAutosizedUnsignedInteger ("Super Entity Index")
   //   loadedSuperEntity = [mLoadedEntityArray objectAtIndex:superEntityIndex] ;
    }else{ // No super entity
      superEntityIndex = nil
      dataScanner.acceptRequiredByte (0xFF, comment:"No Super Entity Mark")
    }
  //--- Parse attributes and relationship definitions
    var entityPropertyNameArray = [String] ()
    var entityRelationshipNameArray = [String] ()
    var loop = true
    while loop && dataScanner.ok () {
      if dataScanner.testAcceptByte (0x01, comment:"NSInteger16AttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x02, comment:"NSInteger32AttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x03, comment:"NSInteger64AttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x04, comment:"NSDecimalAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
       }else if dataScanner.testAcceptByte (0x05, comment:"NSDoubleAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x06, comment:"NSFloatAttributeType or NSDoubleAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x07, comment:"NSStringAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x08, comment:"NSBooleanAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x09, comment:"NSDateAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x0A, comment:"NSBinaryDataAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else if dataScanner.testAcceptByte (0x0B, comment:"To-one relationship Mark") {
        /* const NSUInteger relationshipEntityIndex = */ _ = dataScanner.parseAutosizedUnsignedInteger ("Destination Entity Index")
        let relationshipName = dataScanner.parseAutosizedString ("Relationship Name")
        entityRelationshipNameArray.append (relationshipName)
      }else if dataScanner.testAcceptByte (0x0C, comment:"To-many relationship Mark") {
        /* const NSUInteger relationshipEntityIndex = */ _ = dataScanner.parseAutosizedUnsignedInteger ("Destination Entity Index")
        let relationshipName = dataScanner.parseAutosizedString ("Relationship Name")
        entityRelationshipNameArray.append (relationshipName)
      }else if dataScanner.testAcceptByte (0x0D, comment:"NSTransformableAttributeType Mark") {
        let attributeName = dataScanner.parseAutosizedString ("Attribute Name")
        entityPropertyNameArray.append (attributeName)
      }else{
        entityPropertyNameArray.append ("")
        entityRelationshipNameArray.append ("")
        dataScanner.acceptRequiredByte (0x00, comment:"End of #\(i) Entity Mark")
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

private func loadWithDataScanner (_ dataScanner : inout DataScanner,
                                  textView:NSTextView,
                                  entities : inout [EBEntityLegacyDescription],
                                  objectArray : inout [NSMutableDictionary]) {
//------------------------ 'Object count' mark
  dataScanner.acceptRequiredByte (0x02, comment:"Object count Mark")
//------------------------ Get object count 
  let objectCount = dataScanner.parseAutosizedUnsignedInteger ("Object count")
//------------------------ Parse object attributes
  for i in 0 ..< objectCount {
    scanObjectIndex (
      i,
      dataScanner : &dataScanner,
      textView:textView,
      entities:&entities,
      objectArray:&objectArray
    )
  }
//------------------------ Parse object relation
  for i in 0 ..< objectCount {
    scanRelationshipForObjectIndex (
      i,
      dataScanner : &dataScanner,
      textView:textView,
      entities:&entities,
      objectArray:&objectArray
    )
  }
//------------------------ 'End of file' mark
  dataScanner.acceptRequiredByte (0x05, comment:"End of Objects Mark")
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func scanObjectIndex (_ inObjectIndex : UInt,
                              dataScanner : inout DataScanner,
                              textView:NSTextView,
                              entities : inout [EBEntityLegacyDescription],
                              objectArray : inout [NSMutableDictionary]) {
  textView.appendMessageString ("Value of object #\(inObjectIndex)\n")
//--- 'start of object attribute' mark
  dataScanner.acceptRequiredByte (0x03, comment:"Start of values Mark")
//--- Entity index
  let entityIndex : Int = Int (dataScanner.parseAutosizedUnsignedInteger ("Entity Index"))
//--- Create new object
  let entityName = entities [entityIndex].mEntityName
  textView.appendMessageString ("      --> entity Name: '\(entityName)'\n")
//--- Entity attribute name list, ordered by name
  let sortedPropertyNames = entities [entityIndex].mEntityPropertyNameArray
//--- Parse attributes and relationship values
  var propertyIndex = 0
  var loop = true
  let objectValues = NSMutableDictionary ()
  while loop {
    let key = sortedPropertyNames [propertyIndex]
    propertyIndex += 1
    if dataScanner.testAcceptByte (0xFF, comment:"No value for '\(key)'") { // nil
 
    }else if dataScanner.testAcceptByte (0xFE, comment:"Unsigned Integer Mark for '\(key)'") { // positive signed integer
      let value = dataScanner.parseAutosizedUnsignedInteger ("Value")
      objectValues.setValue (NSNumber (value: value as UInt), forKey:key)
    }else if dataScanner.testAcceptByte (0xFD, comment:"Negative Integer Mark for '\(key)'") { // negative signed integer
      let value = Int (dataScanner.parseAutosizedUnsignedInteger ("Value to Negate"))
      objectValues.setValue (NSNumber (value: -value as Int), forKey:key)
    }else if dataScanner.testAcceptByte (0x09, comment:"String Mark for '\(key)'") { // String
      let s : String = dataScanner.parseAutosizedString ("Value")
      objectValues.setValue (s, forKey:key)
    }else if dataScanner.testAcceptByte (0x0A, comment:"Boolean NO for '\(key)'") { // False
      objectValues.setValue (NSNumber (value: false as Bool), forKey:key)
    }else if dataScanner.testAcceptByte (0x0B, comment:"Boolean YES for '\(key)'") { // True
      objectValues.setValue (NSNumber (value: true as Bool), forKey:key)
    }else if dataScanner.testAcceptByte (0x0C, comment:"Float Mark for '\(key)'") { // Float
      let data = dataScanner.parseAutosizedData ("Float value (length)", dataComment:"Float value")
      let floatNumber = NSUnarchiver.unarchiveObject (with: data)
      objectValues.setValue (floatNumber, forKey:key)
    }else if dataScanner.testAcceptByte (0x0D, comment:"Double Mark for '\(key)'") { // Double
      let data = dataScanner.parseAutosizedData ("Double Value (length)", dataComment:"Double Value")
      let doubleNumber = NSUnarchiver.unarchiveObject (with: data)
      objectValues.setValue (doubleNumber, forKey:key)
    }else if dataScanner.testAcceptByte (0x0E, comment:"Date Mark for '\(key)'") { // Date
      let data = dataScanner.parseAutosizedData ("Date value (length)", dataComment:"Date value")
      let date = NSUnarchiver.unarchiveObject (with: data)
      objectValues.setValue (date, forKey:key)
    }else if dataScanner.testAcceptByte (0x0F, comment:"Binary Data Mark for '\(key)'") { // Binary Data
      let data = dataScanner.parseAutosizedData ("Data Value (length)", dataComment:"Data Value")
      objectValues.setValue (data, forKey:key)
    }else if dataScanner.testAcceptByte (0x10, comment:"Decimal Mark for '\(key)'") { // Decimal
      let data = dataScanner.parseAutosizedData ("Decimal Value (length)", dataComment:"Decimal Value")
      let decimalNumber = NSUnarchiver.unarchiveObject (with: data)
      objectValues.setValue (decimalNumber, forKey:key)
//    }else if dataScanner.testAcceptByte (0x11, comment:"Transformable Attribute Mark for '\(key)'") { // Decimal
//      dataScanner.parseAutosizedData ("Value as binary data (length)", dataComment:"Value as binary data")
    }else{
      dataScanner.acceptRequiredByte (0x00, comment:"End of #\(inObjectIndex) Object Attribute Values\n")
      objectArray.append (objectValues)
      loop = false
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func scanRelationshipForObjectIndex (_ inObjectIndex : UInt,
                                             dataScanner : inout DataScanner,
                                             textView:NSTextView,
                                             entities : inout [EBEntityLegacyDescription],
                                             objectArray : inout [NSMutableDictionary]) {
//--- 'start of object relationship' mark
  dataScanner.acceptRequiredByte (0x04, comment:"Start of #\(inObjectIndex) Object Relationships");
//--- Entity Index
  let entityIndex = Int (dataScanner.parseAutosizedUnsignedInteger ("Entity Index"))
//--- Build attribute array
  let sortedRelationshipDescriptionArray = entities [entityIndex].mEntityRelationshipNameArray
//--- Parse relationship values
  var relationshipIndex = 0
  var loop = true
  let objectValues = objectArray [Int (inObjectIndex)]
  while loop {
    let key = sortedRelationshipDescriptionArray [relationshipIndex]
    relationshipIndex += 1
    if dataScanner.testAcceptByte (0xFF, comment:"'\(key)' -> nil") { // nil
    }else if dataScanner.testAcceptByte (0x01, comment:"'\(key)' -> To one value") {
      let destinationObjectIndex = dataScanner.parseAutosizedUnsignedInteger ("Destination object index")
      objectValues.setValue (NSNumber (value: destinationObjectIndex as UInt), forKey:key)
    }else if dataScanner.testAcceptByte (0x02, comment:"'\(key)' -> To Many value") {
      let objectCount = dataScanner.parseAutosizedUnsignedInteger ("Destination object count")
      let objectArray = NSMutableArray ()
      for _ in 0 ..< objectCount {
        let destinationObjectIndex = dataScanner.parseAutosizedUnsignedInteger ("Object index")
        objectArray.add (NSNumber (value: destinationObjectIndex as UInt))
      }
      objectValues.setValue (objectArray, forKey:key)
    }else{
      dataScanner.acceptRequiredByte (0x00, comment:"End of #\(inObjectIndex) Object Relationships\n")
      loop = false
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
