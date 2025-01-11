import Cocoa

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————

struct DataScanner {
  fileprivate var mData : Data
  fileprivate var mTextView : NSTextView
  fileprivate var mReadIndex : Int = 0
  fileprivate var mReadOk : Bool = true
  fileprivate var mExpectedBytes : Array<UInt8> = []

  //····················································································································

  init (data: Data, textView : NSTextView) {
    mData = data
    mTextView = textView
  }

  //····················································································································

  func printAddress () {
    mTextView.appendMessageString (String (format:"%04X %04X:", mReadIndex >> 16, mReadIndex & 0xFFFF))
  }

  //····················································································································

  mutating func ignoreBytes (_ inLengthToIgnore : Int) {
    if mReadOk {
      mReadIndex += inLengthToIgnore ;
    }
  }

  //····················································································································
  // http://stackoverflow.com/questions/24067085/pointers-pointer-arithmetic-and-raw-data-in-swift

  mutating func testAcceptByte (_ inByte : UInt8, comment : String) -> Bool {
    var result = mReadOk
    if result {
      if mReadIndex >= mData.count {
         NSLog ("Read beyond end of data")
         mReadOk = false
       }else{
        let byte = mData [mReadIndex] // (mData.subdata (in: Range (mReadIndex, (sizeof(UInt8)))) as NSData).bytes
      //  let byte = UnsafePointer<UInt8> (byteAsData).pointee
        result = byte == inByte
        if result {
          printAddress ()
          mTextView.appendByte (inByte)
          mTextView.appendMessageString (" | \(comment)\n")
          mReadIndex += 1
          mExpectedBytes = []
        }else{
          mExpectedBytes.append (inByte)
        }
      }
    }
    return result ;
  }

  //····················································································································

  mutating func testAcceptFromByte (_ lowerBound: UInt8,
                                    upperBound: UInt8,
                                    value:inout UInt8) -> Bool {
    var result = mReadOk
    if result {
      if mReadIndex >= mData.count {
         NSLog ("Read beyond end of data")
         mReadOk = false
       }else{
       // let byteAsData = (mData.subdata (in: NSMakeRange(mReadIndex, sizeof(UInt8))) as NSData).bytes
        let byte = mData [mReadIndex] // UnsafePointer<UInt8> (byteAsData).pointee
        result = (byte >= lowerBound) && (byte <= upperBound) ;
        if (result) {
          value = byte
          mReadIndex += 1
          mExpectedBytes = []
        }else{
          for i in lowerBound ..< upperBound + 1 {
            mExpectedBytes.append (i)
          }
        }
      }
    }
    return result ;
  }

  //····················································································································

  mutating func acceptRequiredByte (_ inByte : UInt8,
                                    comment : String) {
    printAddress ()
    if mReadOk {
      if mReadIndex >= mData.count {
         NSLog ("Read beyond end of data")
         mReadOk = false
      }else{
       // let byteAsData = (mData.subdata (in: NSMakeRange(mReadIndex, sizeof(UInt8))) as NSData).bytes
        let byte = mData [mReadIndex] // UnsafePointer<UInt8> (byteAsData).pointee
        mTextView.appendMessageString (String (format:" %02X", byte))
        mTextView.appendMessageString (" | \(comment)\n")
        if (byte == inByte) {
          mReadIndex += 1
          mExpectedBytes = []
        }else{
          var message = ""
          for b in mExpectedBytes {
            message += String (format:"0x%02hhx, ", b)
            mTextView.appendMessageString (" | \(comment)\n")
          }
          mTextView.appendErrorString (String (format:"invalid current byte (0x%02X): expected bytes:%@0x%02x\n", byte, message, inByte))
          mReadOk = false
        }
      }
    }
  }

  //····················································································································

  mutating func parseByte () -> UInt8 {
    var result : UInt8 = 0
    if mReadOk {
      if mReadIndex >= mData.count {
         NSLog ("Read beyond end of data")
         mReadOk = false
       }else{
       // let byteAsData = (mData.subdata (in: NSMakeRange(mReadIndex, sizeof(UInt8))) as NSData).bytes
        result = mData [mReadIndex] // UnsafePointer<UInt8> (byteAsData).pointee
//        result = UnsafePointer<UInt8> (byteAsData).pointee
        mReadIndex += 1
      }
    }
    return result
  }

  //····················································································································

  mutating func parseAutosizedUnsignedInteger (_ comment : String) -> UInt {
    printAddress ()
    var result : UInt = 0
    var shift : UInt = 0
    var loop = true
    while loop && mReadOk {
      if mReadIndex >= mData.count {
         NSLog ("Read beyond end of data")
         mReadOk = false
      }else{
       // let byteAsData = (mData.subdata (in: NSMakeRange(mReadIndex, sizeof(UInt8))) as NSData).bytes
        let byte = mData [mReadIndex] // UnsafePointer<UInt8> (byteAsData).pointee
        mTextView.appendByte (byte)
        let w : UInt = UInt (byte) & 0x7F
        result |= (w << shift)
        shift += 7
        loop = (byte & 0x80) != 0
        mReadIndex += 1
      }
    }
    mTextView.appendMessageString (" | \(comment) (\(result))\n")
    return result ;
  }

  //····················································································································

  mutating func parseAutosizedData (_ lengthComment : String, dataComment:String) -> Data {
    var result = Data ()
    if mReadOk {
      let dataLength : Int = Int (parseAutosizedUnsignedInteger (lengthComment))
      if (mReadIndex + dataLength) >= mData.count {
        NSLog ("Read beyond end of data")
        mReadOk = false
      }else{
        printAddress ()
        result = mData.subdata (in: mReadIndex ..< mReadIndex + dataLength) // mData.subdata (in: NSMakeRange (mReadIndex, dataLength))
        mTextView.appendMessageString (" ... | \(dataComment) (\(dataLength) bytes)\n")
        mReadIndex += dataLength
      }
    }
    return result ;
  }

  //····················································································································

  mutating func parseAutosizedString (_ comment : String) -> String {
    printAddress ()
    var result : String = ""
    var ptr = (mData as NSData).bytes.bindMemory(to: UInt8.self, capacity: mData.count)
    ptr += mReadIndex
    var stringLength = 0
    var loop = true
    while loop && mReadOk {
      if (mReadIndex + stringLength) >= mData.count {
         mTextView.appendErrorString ("Read beyond end of data")
         mReadOk = false
      }else{
        mTextView.appendByte (ptr.pointee)
        loop = ptr.pointee != 0
        ptr += 1
        stringLength += 1
      }
    }
    if (mReadOk) {
      let d = mData.subdata (in: mReadIndex ..< mReadIndex + stringLength - 1) // mData.subdata (in: NSMakeRange (mReadIndex, stringLength-1))
      result = String (data:d, encoding: .utf8)!
      mReadIndex += stringLength
      mTextView.appendMessageString (" | \"" + result + "\": \(comment)\n")
    }
    return result
  }

  //····················································································································

  func ok () -> Bool {
    return mReadOk
  }

  //····················································································································

}

//——————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
