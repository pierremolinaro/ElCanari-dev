//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func transient_AutoLayoutArtworkDocument_segmentedControlDataIssueImage (
       _ root_fileGenerationParameterArray_fileExtension : [ArtworkFileGenerationParameters_fileExtension],
       _ root_fileGenerationParameterArray_name : [ArtworkFileGenerationParameters_name],
       _ root_hasDataWarning : Bool,                                     
       _ root_emptyDrillFileExtension : Bool
) -> NSImage {
//--- START OF USER ZONE 2
  var hasError = root_emptyDrillFileExtension
  var idx = 0
  while !hasError && (idx < root_fileGenerationParameterArray_fileExtension.count) {
    if root_fileGenerationParameterArray_fileExtension [idx].fileExtension.isEmpty {
      hasError = true
    }
    idx += 1
  }
  idx = 0
  while !hasError && (idx < root_fileGenerationParameterArray_name.count) {
    if root_fileGenerationParameterArray_name [idx].name.isEmpty {
      hasError = true
    }
    idx += 1
  }
  return hasError
   ? NSImage.statusError
   : (root_hasDataWarning ? NSImage.statusWarning : NSImage (size: NSSize ()))
//--- END OF USER ZONE 2
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————