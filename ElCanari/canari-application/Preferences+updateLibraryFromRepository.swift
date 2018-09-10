
import Cocoa
import SystemConfiguration

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

private let SLOW_DOWNLOAD = false // When active, downloading is slowed down with sleep (1)

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let parallelDownloadCount = 4

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let repositoryDescriptionFile = "repository-description.plist"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

// https://stackoverflow.com/questions/13276195/mac-osx-how-can-i-grab-proxy-configuration-using-cocoa-or-even-pure-c-function

fileprivate func proxy () -> [String] {
  var proxyOption = [String] ()
  if let proxies : NSDictionary = SCDynamicStoreCopyProxies (nil) {
    // NSLog ("\(proxies)")
    let possibleHTTPSProxy = proxies ["HTTPSProxy"]
    let possibleHTTPSEnable = proxies ["HTTPSEnable"]
    let possibleHTTPSPort = proxies ["HTTPSPort"]
    if let HTTPSEnable : Int = possibleHTTPSEnable as? Int, HTTPSEnable == 1, let HTTPSProxy = possibleHTTPSProxy {
      var proxySetting : String = "\(HTTPSProxy)"
      if let HTTPSPort = possibleHTTPSPort {
        proxySetting += ":" + "\(HTTPSPort)"
      }
      // Swift.print ("proxy \(proxySetting)")
      proxyOption = ["--proxy", proxySetting]
    }
  }
  return proxyOption
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   LIBRARY UPDATE ENTRY POINT
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

func performLibraryUpdate (_ inWindow : EBWindow?, _ inLogTextView : NSTextView) {
//--- Disable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = false
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = false
//-------- Cleat log window
  inLogTextView.clear ()
//-------- Show "Check for update" window
  inWindow?.makeKeyAndOrderFront (nil)
//-------- ① We start by checking if a repository did change using etag
  inLogTextView.appendMessageString ("Phase 1: repository did change?\n", color: NSColor.purple)
  var possibleAlert : NSAlert? = nil
  if let etag = getRepositoryCurrentETag (), let sha = getRepositoryCommitSHA () {
    inLogTextView.appendSuccessString ("  Current Etag: \(etag)\n")
    inLogTextView.appendSuccessString ("  Current commit SHA: \(sha)\n")
    queryServerLastCommitUsingEtag (etag, inLogTextView, &possibleAlert)
  }else{
    inLogTextView.appendWarningString ("  No current Etag and/or no current commit SHA\n")
    queryServerLastCommitWithNoEtag (inLogTextView, &possibleAlert)
  }
//-------- ② Repository ETAG and commit SHA have been successfully retrieve,
//            now read of download the file list corresponding to this commit
  inLogTextView.appendMessageString ("Phase 2: get repository file list\n", color: NSColor.purple)
  var repositoryFileDictionary = [String : CanariLibraryFileDescriptor] ()
  if possibleAlert == nil {
    readOrDownloadLibraryFileDictionary (&repositoryFileDictionary, inLogTextView, &possibleAlert)
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
    buildLibraryOperations (libraryFileDictionary, &libraryOperations, inLogTextView)
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
        completionHandler: { (response : Int) in window.orderOut (nil) }
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
//--- Enable update buttons
  g_Preferences?.mCheckForLibraryUpdatesButton?.isEnabled = true
  g_Preferences?.mUpDateLibraryMenuItemInCanariMenu?.isEnabled = true
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitUsingEtag (_ etag : String,
                                             _ inLogTextView : NSTextView,
                                             _ ioPossibleAlert : inout NSAlert?) {
  let command = [
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "-H", "If-None-Match:\"\(etag)\"",
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ] + proxy ()
  inLogTextView.appendMessageString ("  Command: \(command)\n")
  let response = runShellCommandAndGetDataOutput (command)
  inLogTextView.appendMessageString ("  Result code: \(response)\n")
  switch response {
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
      let c0 = response.components (separatedBy: "Status: ")
      let c1 = c0 [1].components (separatedBy: " ")
      //print ("C1 \(c1 [0])")
      if let status = Int (c1 [0]) {
        inLogTextView.appendMessageString ("  HTTP Status: \(status)\n", color: NSColor.black)
        if status == 304 { // Status 304 --> not modified, use current repository description file
          inLogTextView.appendMessageString ("  HTTP Status means 'no repository change, use current description file'\n", color: NSColor.black)
        }else if status == 200 { // Status 200 --> Ok, modified
          inLogTextView.appendMessageString ("  HTTP Status means 'repository did change'\n", color: NSColor.black)
          storeRepositoryETagAndLastCommitSHA (withResponse: response, inLogTextView, &ioPossibleAlert)
        }
      }else{
        inLogTextView.appendErrorString ("  Cannot extract HTTP status from downloaded data\n")
      }
    }
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func queryServerLastCommitWithNoEtag (_ inLogTextView : NSTextView, _ ioPossibleAlert : inout NSAlert?) {
  let command = [
    "/usr/bin/curl",
    "-s", // Silent mode, do not show download progress
    "-i", // Add response header in output
    "-L", // Follow
    "https://api.github.com/repos/pierremolinaro/ElCanari-Library/branches"
  ] + proxy ()
  inLogTextView.appendMessageString ("  Command: \(command)\n")
  let response = runShellCommandAndGetDataOutput (command)
  inLogTextView.appendMessageString ("  Result code: \(response)\n")
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
  if components.count == 2 {
    let jsonData = components [1].data (using: .utf8)!
    do{
    //--- Get commit sha
      let jsonArray = try JSONSerialization.jsonObject (with: jsonData) as! NSArray
      let jsonDictionary = jsonArray [0] as! NSDictionary
      let commitDict = jsonDictionary ["commit"]  as! NSDictionary
      let commitSHA = commitDict ["sha"]  as! String
      inLogTextView.appendSuccessString ("  Commit SHA: \(commitSHA) has been stored in preferences\n")
      storeRepositoryCommitSHA (commitSHA)
    //--- Get ETag
      let c1 = components [0].components (separatedBy:"ETag: \"")
      let c2 = c1 [1].components (separatedBy:"\"")
      let etag = c2 [0]
      storeRepositoryCurrentETag (etag)
      inLogTextView.appendSuccessString ("  Etag: \(etag) has been stored in preferences\n")
    }catch let error {
      inLogTextView.appendErrorString ("  Error parsing JSON: \(error)\n")
      ioPossibleAlert = NSAlert (error: error)
    }
  }else{
    inLogTextView.appendErrorString ("  Invalid HTTP result, has \(components.count) components instead of 2\n")
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func readOrDownloadLibraryFileDictionary (
        _ ioLibraryFileDictionary : inout [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView,
        _ ioPossibleAlert : inout NSAlert?) {
  if libraryDescriptionFileIsValid () {
    inLogTextView.appendMessageString ("  Local repository image file is valid\n")
    let f = systemLibraryPath () + "/" + repositoryDescriptionFile
    inLogTextView.appendMessageString ("  Local repository image file is \(f)\n")
    let data = try! Data (contentsOf: URL (fileURLWithPath: f))
    let propertyList = try! PropertyListSerialization.propertyList (from: data, format: nil) as! [[String : String]]
    for entry in propertyList {
      let filePath = entry ["path"]!
      let descriptor = CanariLibraryFileDescriptor (
        relativePath: filePath,
        repositorySHA: entry ["sha"]!,
        sizeInRepository: Int (entry ["size"]!)!,
        localSHA: ""
      )
      ioLibraryFileDictionary [filePath] = descriptor
    }
  }else if let repositoryCommitSHA = getRepositoryCommitSHA () {
    inLogTextView.appendWarningString ("  Local repository image file is not valid: get it from repository\n")
    let command = [
      "/usr/bin/curl",
      "-s", // Silent mode, do not show download progress
      "-L", // Follow redirections
      "https://api.github.com/repos/pierremolinaro/ElCanari-Library/git/trees/\(repositoryCommitSHA)?recursive=1"
    ] + proxy ()
    inLogTextView.appendMessageString ("  Command: \(command)\n")
    let response = runShellCommandAndGetDataOutput (command)
    inLogTextView.appendMessageString ("  Result code: \(response)\n")
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
        if let fileDescriptionArray = treeEntry as? [[String : Any]] {
          for fileDescriptionDictionay in fileDescriptionArray {
            let filePath = fileDescriptionDictionay ["path"] as! String
            let ext = filePath.pathExtension
            if (ext == "ElCanariFont") || (ext == "ElCanariArtwork") {
              let descriptor = CanariLibraryFileDescriptor (
                relativePath: filePath,
                repositorySHA: "?", // fileDescriptionDictionay ["sha"] as! String,
                sizeInRepository: fileDescriptionDictionay ["size"] as! Int,
                localSHA: "?"
              )
              ioLibraryFileDictionary [filePath] = descriptor
            }
          }
        }else{
          print ("Entry is not an [[String : String]] object: \(String (describing: treeEntry))")
        }
      }catch let error {
        ioPossibleAlert = NSAlert (error: error)
      }
    }
  }else{
    inLogTextView.appendErrorString ("  Repository commit SHA does not exist in preferences\n")
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
        _ inLogTextView : NSTextView) {
  inLogTextView.appendMessageString ("  Library File Dictionary has \(inLibraryFileDictionary.count) entries\n")
  for descriptor in inLibraryFileDictionary.values {
    // inLogTextView.appendMessageString ("    \(descriptor.mRelativePath): \(descriptor.mRepositorySHA) \(descriptor.mLocalSHA)\n")
    if descriptor.mRepositorySHA == "" {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: 0,
        operation: .delete,
        logTextView: inLogTextView
      )
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != "") && (descriptor.mLocalSHA == "?") {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: descriptor.mSizeInRepository,
        operation: .download,
        logTextView: inLogTextView
      )
      outLibraryOperations.append (element)
    }else if (descriptor.mRepositorySHA != descriptor.mLocalSHA) {
      let element = LibraryOperationElement (
        relativePath: descriptor.mRelativePath,
        sizeInRepository: descriptor.mSizeInRepository,
        operation: .update,
        logTextView: inLogTextView
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

enum LibraryOperation {
  case download
  case update
  case delete
  case deleteRegistered
  case downloadError (Int32)
  case downloading (Int)
  case downloaded (Data)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class LibraryOperationElement : EBObject {

  //····················································································································
  //   Properties
  //····················································································································

  let mRelativePath : String
  let mSizeInRepository : Int
  let mLogTextView : NSTextView

  var mOperation : LibraryOperation {
    willSet {
      self.willChangeValue (forKey: "actionName")
    }
    didSet {
      self.didChangeValue (forKey: "actionName")
    }
  }

  //····················································································································

  init (relativePath inRelativePath : String,
        sizeInRepository inSizeInRepository : Int,
        operation inOperation : LibraryOperation,
        logTextView inLogTextView: NSTextView) {
    mRelativePath = inRelativePath
    mOperation = inOperation
    mSizeInRepository = inSizeInRepository
    mLogTextView = inLogTextView
    super.init ()
  }


  //····················································································································
  // Values for progress indicator
  //····················································································································

  var maxIndicatorValue : Double { return Double (self.mSizeInRepository + 10_000) }

  var currentIndicatorValue : Double {
    switch self.mOperation {
    case .download, .update, .delete, .downloadError :
      return 0.0
    case .downloading (let progress) :
      return Double (progress) * self.maxIndicatorValue / 100.0
    case .downloaded (_), .deleteRegistered :
      return self.maxIndicatorValue
    }
  }

  //····················································································································
  // Dynamic properties for Cocoa bindings
  //····················································································································

  @objc dynamic var relativePath : String { return self.mRelativePath }

  @objc dynamic var actionName : String {
    switch self.mOperation {
    case .download :
      return "Download (\(mSizeInRepository) bytes)"
    case .update :
      return "Update (\(mSizeInRepository) bytes)"
    case .delete :
      return "Delete"
    case .deleteRegistered :
      return "Delete registered"
    case .downloadError (let errorCode) :
      return "Error \(errorCode)"
    case .downloaded (_) :
      return "Downloaded"
    case .downloading (let progress) :
      return "Downloading… (\(progress)%)"
    }
  }

  //····················································································································

  func beginAction (_ inController : CanariLibraryUpdateController) {
    if inController.shouldCancel {
      inController.elementActionDidEnd (self, 0)
    }else{
      switch mOperation {
      case .download, .update :
        let repositoryCommitSHA = getRepositoryCommitSHA ()!
        self.mOperation = .downloading (0)
        let task = Process ()
        let concurrentQueue = DispatchQueue (label: "Queue \(relativePath)", attributes: .concurrent)
        concurrentQueue.async {
        //--- Define task
          task.launchPath = "/usr/bin/curl"
          task.arguments = [
            "-s", // Silent mode, do not show download progress
            "-L", // Follow redirections
            "https://raw.githubusercontent.com/pierremolinaro/ElCanari-Library/\(repositoryCommitSHA)/\(self.mRelativePath)",
          ] + proxy ()
          let pipe = Pipe ()
          task.standardOutput = pipe
          task.standardError = pipe
          let fileHandle = pipe.fileHandleForReading
        //--- Launch
          task.launch ()
          var data = Data ()
          var hasData = true
        //--- Loop until all data is got, or download is cancelled
          while hasData && !inController.shouldCancel {
            let newData = fileHandle.availableData
            hasData = newData.count > 0
            data.append (newData)
            DispatchQueue.main.async {
              self.mOperation = .downloading (data.count * 100 / self.mSizeInRepository)
              inController.updateProgressIndicator ()
            }
            if SLOW_DOWNLOAD {
              sleep (1)
            }
          }
          if inController.shouldCancel {
            task.terminate ()
          }
        //--- Task completed
          task.waitUntilExit ()
          fileHandle.closeFile ()
          let status = task.terminationStatus
          if inController.shouldCancel || (status != 0) {
            self.mOperation = .downloadError (status)
          }else{
            self.mOperation = .downloaded (data)
          }
          DispatchQueue.main.async { inController.elementActionDidEnd (self, status) }
        }
      case .delete :
        self.mOperation = .deleteRegistered
        inController.elementActionDidEnd (self, 0)
      case .downloadError, .downloaded, .downloading, .deleteRegistered :
        inController.elementActionDidEnd (self, 0)
      }
    }
  }

  //····················································································································

  func commit () throws {
    switch self.mOperation {
    case .download, .update, .downloadError, .downloading, .delete :
      ()
    case .deleteRegistered :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
      try fm.removeItem (atPath: fullFilePath)
    case .downloaded (let data) :
      let fullFilePath = systemLibraryPath() + "/" + self.mRelativePath
      let fm = FileManager ()
    //--- Create directory
      let destinationDirectory = fullFilePath.deletingLastPathComponent
      if !fm.fileExists(atPath: destinationDirectory) { // If directory does not exist, creta it
        DispatchQueue.main.async {
          self.mLogTextView.appendMessageString ("  Create directory '\(destinationDirectory)'")
        }
        try fm.createDirectory (atPath:destinationDirectory, withIntermediateDirectories:true, attributes:nil)
      }else if fm.fileExists (atPath: fullFilePath) { // If file exists, delete it
        try fm.removeItem (atPath:fullFilePath)
      }
    //--- Write file
      try data.write(to: URL (fileURLWithPath: fullFilePath))
    }
  }

  //····················································································································
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private var gCanariLibraryUpdateController = CanariLibraryUpdateController ()

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

class CanariLibraryUpdateController : EBObject {

  let mArrayController = NSArrayController ()

  var mCurrentActionArray : [LibraryOperationElement]
  var mCurrentParallelActionCount = 0
  var mNextActionIndex = 0 // Index of mActionArray

  let mActionArray : [LibraryOperationElement]
  let mRepositoryFileDictionary : [String : CanariLibraryFileDescriptor]
  let mLogTextView : NSTextView

  var logTextView : NSTextView { return self.mLogTextView }

  //····················································································································
  //   Init
  //····················································································································

  init (_ inActionArray : [LibraryOperationElement],
        _ inRepositoryFileDictionary : [String : CanariLibraryFileDescriptor],
        _ inLogTextView : NSTextView) {
    mCurrentActionArray = inActionArray
    mActionArray = inActionArray
    mRepositoryFileDictionary = inRepositoryFileDictionary
    mLogTextView = inLogTextView
    super.init ()
  }

  //····················································································································

  override init () {
    mCurrentActionArray = []
    mActionArray = []
    mRepositoryFileDictionary = [:]
    mLogTextView = NSTextView ()
    super.init ()
  }
  
  //····················································································································
  //   Handling error or cancel
  //····················································································································

  private var mErrorCode : Int32 = 0 // No error

  //····················································································································

  var shouldCancel : Bool { return mErrorCode != 0 }

  //····················································································································

  func cancel () {
    self.mErrorCode = -1
  }

  //····················································································································
  //  Cocoa bindings
  //····················································································································

  func bind () {
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn (withIdentifier: "name")?.bind (
        "value",
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.relativePath",
        options:nil
      )
      tableView.tableColumn (withIdentifier: "action")?.bind (
        "value",
        to:self.mArrayController,
        withKeyPath:"arrangedObjects.actionName",
        options:nil
      )
      self.mArrayController.content = self.mCurrentActionArray
    }
  }
  
  //····················································································································

  func unbind () { //--- Remove bindings
    if let tableView = g_Preferences?.mTableViewInLibraryUpdateWindow {
      tableView.tableColumn(withIdentifier: "name")?.unbind ("value")
      tableView.tableColumn(withIdentifier: "action")?.unbind ("value")
      mArrayController.content = nil
    }
  }

  //····················································································································
  //   launchElementDownload
  //····················································································································

  fileprivate func launchElementDownload () {
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }
  }

  //····················································································································
  //   elementActionDidEnd
  //····················································································································

  fileprivate func elementActionDidEnd (_ inElement : LibraryOperationElement, _ inErrorCode : Int32) {
    if (self.mErrorCode == 0) && (inErrorCode != 0) {
       mErrorCode = inErrorCode
    }
  //--- Decrement parallel action count
    self.mCurrentParallelActionCount -= 1
  //--- Remove corresponding entry in table view
    if let idx = self.mCurrentActionArray.index (of: inElement) {
      self.mCurrentActionArray.remove (at: idx)
      self.mArrayController.content = self.mCurrentActionArray
    }
  //--- Update progress indicator
    self.updateProgressIndicator ()
  //--- Update remaining operation count
    if self.mCurrentActionArray.count == 0 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "Commiting changes…"
    }else if self.mCurrentActionArray.count == 1 {
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "1 element to update"
   }else{
      g_Preferences?.mInformativeTextInLibraryUpdateWindow?.stringValue = "\(self.mCurrentActionArray.count) elements to update"
    }
  //--- Launch next action, if any
    if self.mNextActionIndex < self.mActionArray.count {
      self.mNextActionIndex += 1
      self.mCurrentParallelActionCount += 1
      self.mActionArray [self.mNextActionIndex - 1].beginAction (self)
    }else if self.mCurrentParallelActionCount == 0 { // Last download did end
      DispatchQueue.main.async { commitAllActions (self.mActionArray, self.mRepositoryFileDictionary, self.mLogTextView) }
    }
  }

  //····················································································································

  fileprivate func updateProgressIndicator () {
    var progressCurrentValue = 0.0
    for action in self.mActionArray {
      progressCurrentValue += action.currentIndicatorValue
    }
    g_Preferences?.mProgressIndicatorInLibraryUpdateWindow?.doubleValue = progressCurrentValue
  }

  //····················································································································

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

private func commitAllActions (_ inActionArray : [LibraryOperationElement],
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
          completionHandler: { (response : Int) in window.orderOut (nil) ; enableItemsAfterCompletion () }
        )
      }catch let error {
        let alert = NSAlert ()
        alert.messageText = "Cannot commit changes"
        alert.addButton (withTitle: "Ok")
        alert.informativeText = "A file system operation returns \(error) error"
        alert.beginSheetModal (
          for: window,
          completionHandler: { (response : Int) in window.orderOut (nil) ; enableItemsAfterCompletion () }
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
//  Computing SHA1 of Data
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func sha1 (_ inData : Data) -> String {
  let transform = SecDigestTransformCreate (kSecDigestSHA1, 0, nil)
  SecTransformSetAttribute (transform, kSecTransformInputAttributeName, inData as CFTypeRef, nil)
  let shaValue = SecTransformExecute (transform, nil) as! Data
  var s = ""
  for byte in shaValue {
    s += "\(String (byte, radix:16, uppercase: false))"
  }
  return s
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Computing SHA1 of a library file
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func computeFileSHA (_ filePath : String) throws -> String {
  let absoluteFilePath = systemLibraryPath () + "/" + filePath
  let data = try Data (contentsOf: URL (fileURLWithPath: absoluteFilePath))
  return sha1 (data)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//   runShellCommandAndGetDataOutput
//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private enum ShellCommandStatus {
  case ok (Data)
  case error (Int32)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func runShellCommandAndGetDataOutput (_ command : [String]) -> ShellCommandStatus {
//--- Separate command and arguments
  let cmd = command [0]
  let args = [String] (command.dropFirst ())
//--- Define task
  let task = Process ()
  task.launchPath = cmd
  task.arguments = args
  let pipe = Pipe ()
  task.standardOutput = pipe
  task.standardError = pipe
  let fileHandle = pipe.fileHandleForReading
//--- Launch
  task.launch ()
  var data = Data ()
  var hasData = true
  while hasData {
    let newData = fileHandle.availableData
    // print ("  \(newData.count)")
    hasData = newData.count > 0
    data.append (newData)
  }
  task.waitUntilExit ()
//--- Task completed
  fileHandle.closeFile ()
  let status = task.terminationStatus
  if status != 0 {
    return .error (status)
  }else{
    return .ok (data)
  }
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private let LIBRARY_REPOSITORY_TAG = "library-repository-etag"
private let LIBRARY_REPOSITORY_COMMIT_SHA = "library-repository-commit-sha"
private let LOCAL_IMAGE_FILE_SHA = "library-repository-file-sha"

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCurrentETag () -> String? { // Returns nil if no current description file
  return UserDefaults ().string (forKey: LIBRARY_REPOSITORY_TAG)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryCurrentETag (_ inETag : String) {
  UserDefaults ().set (inETag, forKey: LIBRARY_REPOSITORY_TAG)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func getRepositoryCommitSHA () -> String? { // Returns nil if no current commit
  return UserDefaults ().string (forKey: LIBRARY_REPOSITORY_COMMIT_SHA)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryCommitSHA(_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: LIBRARY_REPOSITORY_COMMIT_SHA)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func storeRepositoryFileSHA(_ inSHA : String) {
  UserDefaults ().set (inSHA, forKey: LOCAL_IMAGE_FILE_SHA)
}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

private func libraryDescriptionFileIsValid () -> Bool {
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
