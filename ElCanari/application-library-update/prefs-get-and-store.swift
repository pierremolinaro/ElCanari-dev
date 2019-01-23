//
//  prefs-get-and-store.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 23/01/2019.
//
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

import Foundation

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LIBRARY_REPOSITORY_TAG = "library-repository-etag"
private let LIBRARY_REPOSITORY_COMMIT_SHA = "library-repository-commit-sha"
private let LOCAL_IMAGE_FILE_SHA = "library-repository-file-sha"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRepositoryCurrentETag () -> String? { // Returns nil if no current description file
  return UserDefaults ().string (forKey: LIBRARY_REPOSITORY_TAG)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryCurrentETag (_ inETag : String) {
  UserDefaults ().set (inETag, forKey: LIBRARY_REPOSITORY_TAG)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func getRepositoryCommitSHA () -> String? { // Returns nil if no current commit
  return UserDefaults ().string (forKey: LIBRARY_REPOSITORY_COMMIT_SHA)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryCommitSHA(_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: LIBRARY_REPOSITORY_COMMIT_SHA)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func storeRepositoryFileSHA (_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: LOCAL_IMAGE_FILE_SHA)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func libraryDescriptionFileIsValid () -> Bool {
  let possibleLibraryDescriptionFileSHA = UserDefaults ().string (forKey: LOCAL_IMAGE_FILE_SHA)
  if let libraryDescriptionFileSHA = possibleLibraryDescriptionFileSHA {
    do{
      let actualSHA = try computeFileSHA (repositoryDescriptionFile)
      return actualSHA == libraryDescriptionFileSHA
    }catch _ {
    }
  }
  return false
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
