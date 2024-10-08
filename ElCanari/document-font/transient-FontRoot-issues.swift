//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_FontRoot_issues (
       _ self_characters_issues : [any FontCharacter_issues]
) -> CanariIssueArray {
//--- START OF USER ZONE 2
        var issues = [CanariIssue] ()
        for characterIssues in self_characters_issues {
          if let s = characterIssues.issues {
            issues += s
          }
        }
        return issues.sorted { $0.representativeValue < $1.representativeValue }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
