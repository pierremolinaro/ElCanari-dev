//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_AutoLayoutArtworkDocument_statusWarningCount (
       _ root_fileGenerationParameterArray_fileExtension : [any ArtworkFileGenerationParameters_fileExtension],
       _ root_fileGenerationParameterArray_hasNoData : [any ArtworkFileGenerationParameters_hasNoData]
) -> Int {
//--- START OF USER ZONE 2
        let n = root_fileGenerationParameterArray_fileExtension.count
        var warningCount = 0
        if n == 0 {
          warningCount += 1
        }
        for parameter in root_fileGenerationParameterArray_hasNoData {
          if let hasNoData = parameter.hasNoData, hasNoData {
            warningCount += 1
          }
        }
        return warningCount
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
