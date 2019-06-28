//
//  main.swift
//  keyed-archiver
//
//  Created by Pierre Molinaro on 26/02/2019.
//  Copyright © 2019 Pierre Molinaro. All rights reserved.
//

import Cocoa

let color = NSColor.red

let archive = NSArchiver.archivedData (withRootObject: color)
print ("archive: \(archive.count) bytes")

let keyedArchive = NSKeyedArchiver.archivedData (withRootObject: color)
print ("keyed archive: \(keyedArchive.count) bytes")

let mutableData = NSMutableData ()
let keyedArchiver0 = NSKeyedArchiver (forWritingWith: mutableData)
keyedArchiver0.encode (color, forKey: NSKeyedArchiveRootObjectKey)
keyedArchiver0.finishEncoding ()
print ("keyed archive 2: \(mutableData.length) bytes")

let keyedArchiver = NSKeyedArchiver ()
keyedArchiver.encode (color, forKey: NSKeyedArchiveRootObjectKey)
keyedArchiver.finishEncoding ()
let keyedArchive2 = keyedArchiver.encodedData
print ("keyed archive 2: \(keyedArchive2.count) bytes")

let keyedArchive3 = try? NSKeyedArchiver.archivedData (withRootObject: color, requiringSecureCoding: false)
print ("keyed archive 3: \(keyedArchive3!.count) bytes")

let keyedArchive4 = try? NSKeyedArchiver.archivedData (withRootObject: color, requiringSecureCoding: true)
print ("keyed archive 4: \(keyedArchive4!.count) bytes, identical to 3: \(keyedArchive3! == keyedArchive4!)")

let home = NSHomeDirectory ()
try? keyedArchive2.write(to: URL (fileURLWithPath: home + "/Desktop/keyedArchive.plist"))
