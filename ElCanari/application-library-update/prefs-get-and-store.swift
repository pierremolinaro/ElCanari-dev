//
//  prefs-get-and-store.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ETAG
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let REPOSITORY_CONTENTS_FOR_COMMIT_KEY = "repository-contents-for-commit"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRepositoryContentsForCommitCache () -> (String, [[String : Any]])? {
  if let dict = UserDefaults ().value (forKey: REPOSITORY_CONTENTS_FOR_COMMIT_KEY) as? [String : Any],
     let sha = dict ["sha"] as? String,
     let array = dict ["data"] as? [[String : Any]] {
    return (sha, array)
  }else{
    return nil
  }
}
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryContentsForCommitCache (_ inCommitSHA : String, _ inArray : [[String : Any]]) {
  let dict : [String : Any] = [
    "sha" : inCommitSHA,
    "data" : inArray
  ]
  UserDefaults ().set (dict, forKey: REPOSITORY_CONTENTS_FOR_COMMIT_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ETAG
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LIBRARY_REPOSITORY_LAST_COMMIT_KEY = "library-repository-current-version"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getStoredCurrentCommit () -> Int? { // Returns nil if no current ETAG
  let value = UserDefaults ().value (forKey: LIBRARY_REPOSITORY_LAST_COMMIT_KEY)
  if let v = value as? Int {
    return v
  }else{
    return nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryCurrentCommit (_ inCommit : Int) {
  UserDefaults ().set (inCommit, forKey: LIBRARY_REPOSITORY_LAST_COMMIT_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// SHA corresponding to current repository commit
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LIBRARY_REPOSITORY_COMMIT_SHA_KEY = "library-repository-commit-sha"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRepositoryCommitSHA () -> String? { // Returns nil if no current commit
  return UserDefaults ().string (forKey: LIBRARY_REPOSITORY_COMMIT_SHA_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryCommitSHA (_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: LIBRARY_REPOSITORY_COMMIT_SHA_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryCommitSHA_removeETAG (_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: LIBRARY_REPOSITORY_COMMIT_SHA_KEY)
//  UserDefaults ().set (nil, forKey: LIBRARY_REPOSITORY_TAG_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryFileSHA (_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: SHA_OF_LIBRARY_REPOSITORY_FILE_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// SHA corresponding to the current PLIST file that describes local repository image
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let SHA_OF_LIBRARY_REPOSITORY_FILE_KEY = "library-repository-file-sha"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func libraryDescriptionFileContents () -> [[String : Any]]? {
  var result : [[String : Any]]? = nil
  let possibleLibraryDescriptionFileSHA = UserDefaults ().string (forKey: SHA_OF_LIBRARY_REPOSITORY_FILE_KEY)
  if let libraryDescriptionFileSHA = possibleLibraryDescriptionFileSHA {
    let absoluteFilePath = systemLibraryPath () + "/" + REPOSITORY_DESCRIPTION_PLIST_FILE_NAME
    do{
      let fm = FileManager ()
      if let data = fm.contents(atPath: absoluteFilePath), libraryDescriptionFileSHA == sha1 (data) {
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

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
