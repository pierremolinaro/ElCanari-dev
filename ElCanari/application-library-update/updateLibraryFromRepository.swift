
import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
//---------------- ① Pour savoir si le repository a changé, on appelle :
//        curl -s -i -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// La réponse est :
//  ·······
//   Status: 200 OK
//  ·······
//   ETag: "22fc6b218e31128b7f802057f883393b"
//  ·······
//  [
//    {
//      "name": "master",
//      "commit": {
//        "sha": "20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//        "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/commits/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f"
//      }
//    }
//  ]
// Trois infos intéressantes dans la réponse :
//   - Status --> 200 : la requête s'est correctement déroulée
//   - commit / sha --> 20adfd48680e893e29a2e6bb94ebbbe88bb83e8f : valeur caractérisant le commit, utilisé dans les étapes suivantes
//   - Etag --> 22fc6b218e31128b7f802057f883393b : cette valeur permet d'interroger le serveur en lui indiquant 
// d'envoyer une réponse 304 si le repository n'a pas changé :
//        curl -s -i -L -H 'If-None-Match:"22fc6b218e31128b7f802057f883393b"' https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches
// On obtient alors la réponse suivante (sans donnée JSON)
//  ·······
//   Status: 304 Not Modified
//  ·······
// Si le contenu a changé, on obtient une réponse 200 comme précédemment, avec à la fin les données JSON.


//---------------- ② Pour obtenir la liste des fichiers du repository, on appelle :
// curl -s -L https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f?recursive=1
// La réponse est :
//{
//  "sha": "20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//  "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/20adfd48680e893e29a2e6bb94ebbbe88bb83e8f",
//  "tree": [
//  ·······
//    {
//      "path": "artworks",
//      "mode": "040000",
//      "type": "tree",
//      "sha": "aef45cfbb8a896426e0c49eda7ced76b5ce340c9",
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/aef45cfbb8a896426e0c49eda7ced76b5ce340c9"
//    },
//    {
//      "path": "artworks/electro_dragon.ElCanariArtwork",
//      "mode": "100644",
//      "type": "blob",
//      "sha": "e089e1c10538d15cda9de3e8a74b3bfd5ee1100a",
//      "size": 5850,
//      "url": "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/blobs/e089e1c10538d15cda9de3e8a74b3bfd5ee1100a"
//    },
//  ·······
// Le champ "tree" est un tableau, un élément par fichier ou répertoire. Pour chaque fichier "size" contient sa taille ;
// Attention "sha" n'est pas le SHA du fichier, mais de son blob.

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

let repositoryDescriptionFile = "repository-description.plist"
let CURL = "/usr/bin/curl"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdateOperation (_ inWindow : EBWindow?, _ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("Start library update operation\n", color: NSColor.blue)
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- Show "Check for update" window
  inWindow?.makeKeyAndOrderFront (nil)
//-------- ⓪ Get system proxy
  inLogTextView.appendMessageString ("Phase 0: Get proxy (if any)\n", color: NSColor.purple)
  let proxy = getSystemProxy (inLogTextView)
//-------- ① We start by checking if a repository did change using etag
  inLogTextView.appendMessageString ("Phase 1: repository did change?\n", color: NSColor.purple)
  var possibleAlert : NSAlert? = nil
  var needsToDownloadRepositoryFileList = true
  if let etag = getRepositoryCurrentETag (), let sha = getRepositoryCommitSHA () {
    inLogTextView.appendSuccessString ("  Current Etag: \(etag)\n")
    inLogTextView.appendSuccessString ("  Current commit SHA: \(sha)\n")
    queryServerLastCommitUsingEtag (etag, inLogTextView, proxy, &needsToDownloadRepositoryFileList, &possibleAlert)
  }else{
    inLogTextView.appendWarningString ("  No current Etag and/or no current commit SHA\n")
    queryServerLastCommitWithNoEtag (inLogTextView, proxy, &possibleAlert)
    needsToDownloadRepositoryFileList = true
  }
//-------- ② Repository ETAG and commit SHA have been successfully retrieve,
//            now read of download the file list corresponding to this commit
  inLogTextView.appendMessageString ("Phase 2: get repository file list\n", color: NSColor.purple)
  var repositoryFileDictionary = [String : CanariLibraryFileDescriptor] ()
  if possibleAlert == nil {
    readOrDownloadLibraryFileDictionary (&repositoryFileDictionary, inLogTextView, proxy, needsToDownloadRepositoryFileList, &possibleAlert)
  }else{
    inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
  }
//-------- ③ Repository has been successfully interrogated, then enumerate local system library
  inLogTextView.appendMessageString ("Phase 3: enumerate local system library\n", color: NSColor.purple)
  var libraryFileDictionary = repositoryFileDictionary
  if possibleAlert == nil {
    appendLocalFilesToLibraryFileDictionary (&libraryFileDictionary, inLogTextView, &possibleAlert)
  }else{
    inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
  }
//-------- ④ Build library operations
  inLogTextView.appendMessageString ("Phase 4: build operation list\n", color: NSColor.purple)
  var libraryOperations = [LibraryOperationElement] ()
  if possibleAlert == nil {
    buildLibraryOperations (libraryFileDictionary, &libraryOperations, inLogTextView, proxy)
  }else{
    inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
  }
//-------- ⑤ Order out "Check for update" window
  inLogTextView.appendMessageString ("Phase 5: library is up to date ?\n", color: NSColor.purple)
  let ok = possibleAlert == nil
  if let window = inWindow {
    if (possibleAlert == nil) && (libraryOperations.count == 0) {
      inLogTextView.appendSuccessString ("  The library is up to date\n")
      possibleAlert = NSAlert ()
      possibleAlert?.messageText = "The library is up to date"
      possibleAlert?.addButton (withTitle: "Ok")
    }
    if let alert = possibleAlert {
      alert.beginSheetModal (
        for: window,
        completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) }
      )
    }else{
      window.orderOut (nil)
    }
  }
//-------- ⑥ If ok and there are update operations, perform library update
  if ok && (libraryOperations.count != 0) {
    inLogTextView.appendMessageString ("  Display Update Dialog\n", color: NSColor.purple)
    performLibraryOperations (libraryOperations, repositoryFileDictionary, inLogTextView)
  }else{
    if !ok {
      inLogTextView.appendWarningString ("  Not realized, due to previous errors\n")
    }
    enableItemsAfterCompletion ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func enableItemsAfterCompletion () {
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitUsingEtag (_ etag : String,
                                             _ inLogTextView : NSTextView,
                                             _ inProxy : [String],
                                             _ outNeedsToDownloadRepositoryFileList : inout Bool,
                                             _ ioPossibleAlert : inout NSAlert?) {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "-H", "If-None-Match:\"\(etag)\"",
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ] + inProxy
  let responseCode = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  switch responseCode {
  case .error (let errorCode) :
    inLogTextView.appendErrorString ("  Result code means 'Cannot connect to the server'\n")
    ioPossibleAlert = NSAlert ()
    ioPossibleAlert?.messageText = "Cannot connect to the server"
    ioPossibleAlert?.addButton (withTitle: "Ok")
    ioPossibleAlert?.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    inLogTextView.appendSuccessString ("  Result code means 'Ok'\n")
    if let response = String (data: responseData, encoding: .utf8) {
      // Swift.print ("\(response)")
      let c0 = response.components (separatedBy: "Status: ")
      let c1 = c0 [1].components (separatedBy: " ")
      //print ("C1 \(c1 [0])")
      if let status = Int (c1 [0]) {
        inLogTextView.appendMessageString ("  HTTP Status: \(status)\n", color: NSColor.black)
        if status == 304 { // Status 304 --> not modified, use current repository description file
          inLogTextView.appendMessageString ("  HTTP Status means 'no repository change, use current description file'\n", color: NSColor.black)
          outNeedsToDownloadRepositoryFileList = false
        }else if status == 200 { // Status 200 --> Ok, modified
          inLogTextView.appendMessageString ("  HTTP Status means 'repository did change'\n", color: NSColor.black)
          storeRepositoryETagAndLastCommitSHA (withResponse: response, inLogTextView, &ioPossibleAlert)
          outNeedsToDownloadRepositoryFileList = true
        }
      }else{
        inLogTextView.appendErrorString ("  Cannot extract HTTP status from downloaded data\n")
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitWithNoEtag (_ inLogTextView : NSTextView,
                                              _ inProxy : [String],
                                              _ ioPossibleAlert : inout NSAlert?) {
  let arguments = [
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ] + inProxy
  let response = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
  switch response {
  case .error (let errorCode) :
    inLogTextView.appendErrorString ("  Result code means 'Cannot connect to the server'\n")
    let alert = NSAlert ()
    alert.messageText = "Cannot connect to the server"
    alert.addButton (withTitle: "Ok")
    alert.informativeText = (errorCode == 6)
      ? "No network connection"
      : "Server connection error"
  case .ok (let responseData) :
    inLogTextView.appendSuccessString ("  Result code means 'Ok'\n")
    if let response = String (data: responseData, encoding: .utf8) {
      storeRepositoryETagAndLastCommitSHA (withResponse: response, inLogTextView, &ioPossibleAlert)
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryETagAndLastCommitSHA (withResponse inResponse : String,
                                                  _ inLogTextView : NSTextView,
                                                  _ ioPossibleAlert : inout NSAlert?) {
  let components = inResponse.components (separatedBy:"\r\n\r\n")
  if components.count >= 2 {
    let jsonData = components [components.count - 1].data (using: .utf8)!
    do{
      inLogTextView.appendErrorString ("  HTTP result, has \(components.count) lines\n")
    //--- Get commit sha
      let jsonArray = try JSONSerialization.jsonObject (with: jsonData) as! NSArray
      let jsonDictionary = jsonArray [0] as! NSDictionary
      let commitDict = jsonDictionary ["commit"]  as! NSDictionary
      let commitSHA = commitDict ["sha"]  as! String
      inLogTextView.appendSuccessString ("  Commit SHA: \(commitSHA) has been stored in preferences\n")
      storeRepositoryCommitSHA (commitSHA)
    //--- Get ETag
      let c1 = components [components.count - 2].components (separatedBy:"ETag: \"")
      let c2 = c1 [1].components (separatedBy:"\"")
      let etag = c2 [0]
      storeRepositoryCurrentETag (etag)
      inLogTextView.appendSuccessString ("  Etag: \(etag) has been stored in preferences\n")
    }catch let error {
      inLogTextView.appendErrorString ("  Error parsing JSON: \(error)\n")
      ioPossibleAlert = NSAlert (error: error)
    }
  }else{
    inLogTextView.appendErrorString ("  Invalid HTTP result, has \(components.count) line (should be ≥ 2)\n")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func readOrDownloadLibraryFileDictionary (
        _ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView,
        _ inProxy : [String],
        _ inNeedsToDownloadRepositoryFileList : Bool,
        _ ioPossibleAlert : inout NSAlert?) {
//--- Download library description file ?
  let fm = FileManager ()
  inLogTextView.appendWarningString ("  Needs to download description file: \(inNeedsToDownloadRepositoryFileList)\n")
  inLogTextView.appendWarningString ("  Local description file is valid: \(libraryDescriptionFileIsValid ())\n")
  if inNeedsToDownloadRepositoryFileList || !libraryDescriptionFileIsValid () {
    if let repositoryCommitSHA = getRepositoryCommitSHA () {
      inLogTextView.appendWarningString ("  Local repository image file is not valid: get it from repository\n")
      let arguments = [
        "-s", // Silent mode, do not show download progress
        "-L", // Follow redirections
        "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/\(repositoryCommitSHA)?recursive=1"
      ] + inProxy
      let response = runShellCommandAndGetDataOutput (CURL, arguments, inLogTextView)
      switch response {
      case .error (let errorCode) :
        if errorCode != 6 { // Error #6 is 'no network connection'
          ioPossibleAlert = NSAlert ()
          ioPossibleAlert?.messageText = "Cannot connect to the server"
          ioPossibleAlert?.addButton (withTitle: "Ok")
          ioPossibleAlert?.informativeText = "Error code: \(errorCode)"
        }
      case .ok (let responseData) :
        do{
          let jsonObject = try JSONSerialization.jsonObject (with: responseData) as! NSDictionary
          let treeEntry = get (jsonObject, "tree", #line)
          let extensions = Set <String> (["ElCanariFont", "ElCanariArtwork", "ElCanariSymbol", "ElCanariPackage", "ElCanariDevice"])
          if let fileDescriptionArray = treeEntry as? [[String : Any]] {
            for fileDescriptionDictionay in fileDescriptionArray {
              let filePath = fileDescriptionDictionay ["path"] as! String
             // let ext = filePath.pathExtension
              if extensions.contains (filePath.pathExtension) {
                var localSHA = ""
                if fm.fileExists (atPath: filePath) {
                  let fileData = try! Data (contentsOf: URL (fileURLWithPath: filePath))
                  localSHA = sha1 (fileData)
                }
                let descriptor = CanariLibraryFileDescriptor (
                  relativePath: filePath,
                  repositorySHA: "?",
                  sizeInRepository: fileDescriptionDictionay ["size"] as! Int,
                  localSHA: localSHA
                )
                ioLibraryFileDictionary [filePath] = descriptor
              }
            }
          }else{
            inLogTextView.appendErrorString ("  Entry is not an [[String : String]] object: \(String (describing: treeEntry))\n")
          }
        }catch let error {
          ioPossibleAlert = NSAlert (error: error)
        }
      }
    }else{
      inLogTextView.appendErrorString ("  Repository commit SHA does not exist in preferences\n")
      let alert = NSAlert ()
      alert.messageText = "Internal error"
      alert.addButton (withTitle: "Ok")
      alert.informativeText = "Repository commit SHA does not exist in preferences."
      ioPossibleAlert = alert
    }
  }
//--- Now, use local library description file to get repository SHA
  if (ioPossibleAlert == nil) && libraryDescriptionFileIsValid () {
    let f = systemLibraryPath () + "/" + repositoryDescriptionFile
    let data = try! Data (contentsOf: URL (fileURLWithPath: f))
    let propertyList = try! PropertyListSerialization.propertyList (from: data, format: nil) as! [[String : String]]
    for entry in propertyList {
      let filePath = entry ["path"]!
      let repositorySHA = entry ["sha"]!
      if let descriptor = ioLibraryFileDictionary [filePath] {
        let newDescriptor = CanariLibraryFileDescriptor (
          relativePath: filePath,
          repositorySHA: repositorySHA,
          sizeInRepository: descriptor.mSizeInRepository,
          localSHA: descriptor.mLocalSHA
        )
        ioLibraryFileDictionary [filePath] = newDescriptor
      }else{
        let fullFilePath = systemLibraryPath () + "/" + filePath
        var localSHA = ""
        if fm.fileExists (atPath: fullFilePath) {
          let fileData = try! Data (contentsOf: URL (fileURLWithPath: fullFilePath))
          localSHA = sha1 (fileData)
        }
        let newDescriptor = CanariLibraryFileDescriptor (
          relativePath: filePath,
          repositorySHA: repositorySHA,
          sizeInRepository: Int (entry ["size"]!)!,
          localSHA: localSHA
        )
        ioLibraryFileDictionary [filePath] = newDescriptor
      }
    }
  }
//--- Print ?
  inLogTextView.appendMessageString ("  Repository contents (repositorySHA:size:path):\n")
  for (path, value) in ioLibraryFileDictionary {
    inLogTextView.appendMessageString ("    (\(value.mRepositorySHA):\(value.mSizeInRepository):\(path))\n")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func appendLocalFilesToLibraryFileDictionary (
        _ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView,
        _ ioPossibleAlert : inout NSAlert?) {
  do{
    inLogTextView.appendMessageString ("  System Library path is \(systemLibraryPath ())\n")
    let fm = FileManager ()
    if fm.fileExists (atPath: systemLibraryPath ()) {
      let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
      for filePath in currentLibraryContents {
      //--- Eliminate ".DS_store" and description plist file
        var enter = (filePath.lastPathComponent != ".DS_Store") && (filePath != repositoryDescriptionFile)
      //--- Eliminate directories
        if enter {
          let fullPath = systemLibraryPath () + "/" + filePath
          var isDirectory : ObjCBool = false
          _ = fm.fileExists (atPath:fullPath, isDirectory: &isDirectory)
          enter = !isDirectory.boolValue
        }
        if enter {
          if let descriptor = ioLibraryFileDictionary [filePath] {
            let localSHA = try computeFileSHA (filePath)
            let newDescriptor = CanariLibraryFileDescriptor (
              relativePath: descriptor.mRelativePath,
              repositorySHA: descriptor.mRepositorySHA,
              sizeInRepository: descriptor.mSizeInRepository,
              localSHA: localSHA
            )
            ioLibraryFileDictionary [filePath] = newDescriptor
          }else{
            let descriptor = CanariLibraryFileDescriptor (
              relativePath: filePath,
              repositorySHA: "",
              sizeInRepository: 0,
              localSHA: "?"
            )
            ioLibraryFileDictionary [filePath] = descriptor
          }
        }
      }
      inLogTextView.appendMessageString ("  System Library directory contents:\n")
      inLogTextView.appendMessageString ("    local SHA:repository SHA:SHA:repository size:file path\n")
      for descriptor in ioLibraryFileDictionary.values {
        inLogTextView.appendMessageString ("    \(descriptor.mLocalSHA):\(descriptor.mRepositorySHA):\(descriptor.mSizeInRepository):\(descriptor.mRelativePath)\n")
      }
    }else{
      inLogTextView.appendWarningString ("  System Library directory does not exist\n")
    }
  }catch let error {
    inLogTextView.appendErrorString ("  Switch exception \(error)\n")
    ioPossibleAlert = NSAlert (error: error)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func buildLibraryOperations (
        _ inLibraryFileDictionary : [String : CanariLibraryFileDescriptor],
        _ outLibraryOperations : inout [LibraryOperationElement],
        _ inLogTextView : NSTextView,
        _ inProxy : [String]) {
  inLogTextView.appendMessageString ("  Library File Dictionary has \(inLibraryFileDictionary.count) entries\n")
  for descriptor in inLibraryFileDictionary.values {
    // inLogTextView.appendMessageString ("    \(descriptor.mRelativePath): \(descriptor.mRepositorySHA) \(descriptor.mLocalSHA)\n")
    if descriptor.mRepositorySHA == "" {
     inLogTextView.appendMessageString ("    Delete \(descriptor.mRelativePath)\n")
     let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: 0,
        operation: .delete,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "?") {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: descriptor.mSizeInRepository,
        operation: .download,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: descriptor.mSizeInRepository,
        operation: .update,
        logTextView: inLogTextView,
        proxy: inProxy
      )
      outLibraryOperations.append (element)
    }
  }
  if outLibraryOperations.count == 0 {
    inLogTextView.appendMessageString ("  No operation\n")
  }else{
    inLogTextView.appendMessageString ("  Library operations (operation:file path:size in repository)\n")
    for op in outLibraryOperations {
      inLogTextView.appendMessageString ("    \(op.mOperation):\(op.mRelativePath):\(op.mSizeInRepository)\n")
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = CanariLibraryUpdateController ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func performLibraryOperations (
   _ inLibraryOperations : [LibraryOperationElement],
   _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
   _ inLogTextView : NSTextView) {
//--- Perform library update in main thread
  DispatchQueue.main.async  {
  //--- Configure informative text in library update window
    if inLibraryOperations.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(inLibraryOperations.count) elements to update"
    }
    var progressMaxValue = 0.0
    for action in inLibraryOperations {
      progressMaxValue += action.maxIndicatorValue
    }
  //--- Configure progress indicator in library update window
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.minValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.maxValue = progressMaxValue
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = 0.0
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.isIndeterminate = false
  //--- Configure table view in library update window
    gCanariLibraryUpdateController = CanariLibraryUpdateController (inLibraryOperations, inRepositoryFileDictionary, inLogTextView)
    gCanariLibraryUpdateController.bind ()
  //--- Show library update window
    g_Preferences?.mLibraryUpdateWindow?.makeKeyAndOrderFront (nil)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func startLibraryUpdate () {
//--- Launch parallel downloads
  for _ in 1...parallelDownloadCount {
    gCanariLibraryUpdateController.launchElementDownload ()
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func cancelLibraryUpdate () {
//--- Cancel current downloadings
  gCanariLibraryUpdateController.cancel ()
  startLibraryUpdate ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   C O M M I T    U P D A T E S   I N   F I L E    S Y S T E M
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func commitAllActions (_ inActionArray : [LibraryOperationElement],
                       _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
                       _ inLogTextView : NSTextView) {
//--- Update UI
  gCanariLibraryUpdateController.unbind ()
  let logTextView = gCanariLibraryUpdateController.logTextView
  gCanariLibraryUpdateController = CanariLibraryUpdateController ()
//--- Commit change only if all actions has been successdully completed
  var repositoryFileDictionary = inRepositoryFileDictionary
  var performCommit = true
  for action in inActionArray {
    switch action.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      performCommit = false
    case .deleteRegistered :
      ()
    case .downloaded (let data) :
      var descriptor = repositoryFileDictionary [action.mRelativePath]!
      descriptor.mRepositorySHA = sha1 (data)
      repositoryFileDictionary [action.mRelativePath] = descriptor
    }
  }
//--- Perform commit
  if !performCommit {
    g_Preferences?.mLibraryUpdateWindow?.orderOut (nil)
    enableItemsAfterCompletion ()
  }else{
    if let window = g_Preferences?.mLibraryUpdateWindow {
      do{
        for action in inActionArray {
          try action.commit ()
        }
      //--- Delete orphean directories
        try deleteOrphanDirectories (logTextView)
      //--- Write library description plist file
        try writeLibraryDescriptionPlistFile (repositoryFileDictionary, inLogTextView)
      //--- Completed!
        let alert = NSAlert ()
        alert.messageText = "Update completed, the library is up to date"
        alert.addButton (withTitle: "Ok")
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }catch let error {
        let alert = NSAlert ()
        alert.messageText = "Cannot commit changes"
        alert.addButton (withTitle: "Ok")
        alert.informativeText = "A file system operation returns \(error) error"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : NSApplication.ModalResponse) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//    deleteOrphanDirectories
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func deleteOrphanDirectories (_ inLogTextView : NSTextView) throws {
  let fm = FileManager ()
  let currentLibraryContents = try fm.subpathsOfDirectory (atPath: systemLibraryPath ())
  var directoryArray = [String] ()
  for relativePath in currentLibraryContents {
    let fullPath = systemLibraryPath () + "/" + relativePath
    var isDirectory : ObjCBool = false
    fm.fileExists (atPath: fullPath, isDirectory: &isDirectory)
    if (isDirectory.boolValue) {
      directoryArray.append (fullPath)
    }
  }
  directoryArray.sort ()
  var i=directoryArray.count-1
  while i>=0 {
    let fullPath = directoryArray [i]
    var currentDirectoryContents = try fm.contentsOfDirectory (atPath: fullPath)
  //--- Remove .DS_Store files
    var j=0
    while j<currentDirectoryContents.count {
      let s = currentDirectoryContents [j]
      if s == ".DS_Store" {
        currentDirectoryContents.remove (at: j)
        j -= 1
      }
      j += 1
    }
    if (currentDirectoryContents.count == 0) {
      inLogTextView.appendMessageString ("  Delete orphean directory at '\(fullPath)\n")
      try fm.removeItem (atPath: fullPath)
    }
    i -= 1
  }
  enableItemsAfterCompletion ()
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func writeLibraryDescriptionPlistFile (
        _ inRepositoryFileDictionary: [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView) throws {
  inLogTextView.appendMessageString ("  Write Library Description Plist File (repositorySHA:size:path)\n")
  for (path, value) in inRepositoryFileDictionary {
    inLogTextView.appendMessageString ("    \(value.mRepositorySHA):\(value.mSizeInRepository):\(path)\n")
  }
//--- Write plist file
  var dictionaryArray = [[String : String]] ()
  for descriptor in inRepositoryFileDictionary.values {
    var dictionary = [String : String] ()
    dictionary ["path"] = descriptor.mRelativePath
    dictionary ["size"] = "\(descriptor.mSizeInRepository)"
    dictionary ["sha"] = descriptor.mRepositorySHA
    dictionaryArray.append (dictionary)
  }
  let data : Data = try PropertyListSerialization.data (fromPropertyList: dictionaryArray, format: .binary, options: 0)
  let f = systemLibraryPath () + "/" + repositoryDescriptionFile
  try data.write (to: URL (fileURLWithPath: f))
  storeRepositoryFileSHA (sha1 (data))
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct CanariLibraryFileDescriptor {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  var mRepositorySHA : String
  let mSizeInRepository : Int
  let mLocalSHA : String

  //····················································································································

  init (relativePath inRelativePath : String,
        repositorySHA inRepositorySHA : String,
        sizeInRepository inSizeInRepository : Int,
        localSHA inLocalSHA : String) {
    mRelativePath = inRelativePath
    mRepositorySHA = inRepositorySHA
    mLocalSHA = inLocalSHA
    mSizeInRepository = inSizeInRepository
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   get fromDictionary
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func get (_ inObject: Any?, _ key : String, _ line : Int) -> Any? {
  if let dictionary = inObject as? NSDictionary {
    if let r = dictionary [key] {
      return r
    }else{
      print ("line \(line) : no \(key) key in dictionary")
      return nil
    }
  }else{
    print ("line \(line) : object is not a dictionary")
    return nil
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
