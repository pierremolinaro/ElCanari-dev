//
//  prefs-get-and-store.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//--------------------------------------------------------------------------------------------------

import Foundation

//--------------------------------------------------------------------------------------------------
// ETAG
//--------------------------------------------------------------------------------------------------

private let LIBRARY_REPOSITORY_LAST_COMMIT_KEY = "library-repository-current-version"

//--------------------------------------------------------------------------------------------------

func getStoredCurrentCommit () -> Int? { // Returns nil if no current ETAG
  let value = UserDefaults ().value (forKey: LIBRARY_REPOSITORY_LAST_COMMIT_KEY)
  if let v = value as? Int {
    return v
  }else{
    return nil
  }
}

//--------------------------------------------------------------------------------------------------

func storeRepositoryCurrentCommit (_ inCommit : Int) {
  UserDefaults ().set (inCommit, forKey: LIBRARY_REPOSITORY_LAST_COMMIT_KEY)
}

//--------------------------------------------------------------------------------------------------
// SHA corresponding to current repository commit
//--------------------------------------------------------------------------------------------------

func storeRepositoryFileSHA (_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: SHA_OF_LIBRARY_REPOSITORY_FILE_KEY)
}

//--------------------------------------------------------------------------------------------------
// SHA corresponding to the current PLIST file that describes local repository image
//--------------------------------------------------------------------------------------------------

private let SHA_OF_LIBRARY_REPOSITORY_FILE_KEY = "library-repository-file-sha"

//--------------------------------------------------------------------------------------------------

func libraryDescriptionFileContents () -> [[String : Any]]? {
  var result : [[String : Any]]? = nil
  let possibleLibraryDescriptionFileSHA = UserDefaults ().string (forKey: SHA_OF_LIBRARY_REPOSITORY_FILE_KEY)
  if let libraryDescriptionFileSHA = possibleLibraryDescriptionFileSHA {
    let absoluteFilePath = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
    do{
      let fm = FileManager ()
      if let data = fm.contents(atPath: absoluteFilePath), libraryDescriptionFileSHA == sha1 (data: data) {
        do{
          if let propertyList = try PropertyListSerialization.propertyList (from: data, format: nil) as? [[String : Any]] {
            result = propertyList
          }
        }catch _ {
        }
      }
    }
  }
  return result
}

//--------------------------------------------------------------------------------------------------
