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

private let LIBRARY_REPOSITORY_TAG_KEY = "library-repository-etag"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRepositoryCurrentETag () -> String? { // Returns nil if no current ETAG
  return UserDefaults ().string (forKey: LIBRARY_REPOSITORY_TAG_KEY)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryCurrentETag (_ inETag : String) {
  UserDefaults ().set (inETag, forKey: LIBRARY_REPOSITORY_TAG_KEY)
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
  UserDefaults ().set (nil, forKey: LIBRARY_REPOSITORY_TAG_KEY)
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

func libraryDescriptionFileIsValid () -> Bool {
  let possibleLibraryDescriptionFileSHA = UserDefaults ().string (forKey: SHA_OF_LIBRARY_REPOSITORY_FILE_KEY)
  if let libraryDescriptionFileSHA = possibleLibraryDescriptionFileSHA {
    if let actualSHA = computeFileSHA (repositoryDescriptionFile) {
      return actualSHA == libraryDescriptionFileSHA
    }else{
      return false
    }
  }
  return false
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func libraryDescriptionFileContents () -> [[String : Any]]? {
  var result : [[String : Any]]? = nil
  let possibleLibraryDescriptionFileSHA = UserDefaults ().string (forKey: SHA_OF_LIBRARY_REPOSITORY_FILE_KEY)
  if let libraryDescriptionFileSHA = possibleLibraryDescriptionFileSHA {
    let absoluteFilePath = systemLibraryPath () + "/" + repositoryDescriptionFile
    do{
      let fm = FileManager ()
      if let data = fm.contents(atPath: absoluteFilePath), libraryDescriptionFileSHA == sha1 (data) {
        do{
          if let propertyList = try PropertyListSerialization.propertyList (from: data, format: nil) as? [[String : String]] {
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
