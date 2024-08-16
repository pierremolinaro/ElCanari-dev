//
//  compression.swift
//  ElCanari
//
//  Created by Pierre Molinaro on 31/05/2024.
//
//--------------------------------------------------------------------------------------------------

import Foundation
import Compression

//--------------------------------------------------------------------------------------------------

func compressedData (_ inData : Data,
                     using inAlgorithm : compression_algorithm) -> Data {
  var sourceBuffer : [UInt8] = [UInt8] (inData)
  let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate (capacity: sourceBuffer.count)
  defer {
    destinationBuffer.deallocate ()
  }
  let compressedSize = compression_encode_buffer (
    destinationBuffer,
    sourceBuffer.count,
    &sourceBuffer,
    sourceBuffer.count,
    nil,
    inAlgorithm
  )
  let compressedData = Data (bytes: destinationBuffer, count: compressedSize)
  return compressedData
}

//--------------------------------------------------------------------------------------------------

func uncompressedData (_ inCompressedData : Data,
                       using inAlgorithm : compression_algorithm,
                       initialExpansionFactor inFactor : Int) -> Data {
  var sourceBuffer : [UInt8] = [UInt8] (inCompressedData)
  var expansionFactor = inFactor
  var uncompressedData = Data ()
  var loop = true
  while loop {
    let destinationBufferSize = sourceBuffer.count * expansionFactor
    let destinationBuffer = UnsafeMutablePointer <UInt8>.allocate (capacity: destinationBufferSize)
    defer {
      destinationBuffer.deallocate ()
    }
    let uncompressedSize = compression_decode_buffer (
      destinationBuffer,
      destinationBufferSize,
      &sourceBuffer,
      sourceBuffer.count,
      nil,
      inAlgorithm
    )
    if (uncompressedSize > 0) && (uncompressedSize < destinationBufferSize) {
      uncompressedData = Data (bytes: destinationBuffer, count: uncompressedSize)
      loop = false
    }else{  // Means overflow, destination buffer too small
      expansionFactor *= 2
      loop = expansionFactor < 100
    }
  }
  return uncompressedData
}

//--------------------------------------------------------------------------------------------------
