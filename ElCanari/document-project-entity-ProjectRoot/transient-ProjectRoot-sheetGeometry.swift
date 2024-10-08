//--------------------------------------------------------------------------------------------------
//  THIS FILE IS REGENERATED BY EASY BINDINGS, ONLY MODIFY IT WITHIN USER ZONES
//--------------------------------------------------------------------------------------------------

import AppKit

//--------------------------------------------------------------------------------------------------

//--- START OF USER ZONE 1


//--- END OF USER ZONE 1

//--------------------------------------------------------------------------------------------------

@MainActor func transient_ProjectRoot_sheetGeometry (
       _ self_mSchematicSheetOrientation : SchematicSheetOrientation,
       _ self_mSchematicCustomWidth : Int,           
       _ self_mSchematicCustomHeight : Int
) -> SchematicSheetGeometry {
//--- START OF USER ZONE 2
  let A4MinSize = cocoaToCanariUnit (PAPER_A4_MIN_SIZE_COCOA_UNIT)
  let A4MaxSize = cocoaToCanariUnit (PAPER_A4_MAX_SIZE_COCOA_UNIT)
  let leftMargin = cocoaToCanariUnit (PAPER_LEFT_MARGIN_COCOA_UNIT)
  let rightMargin = cocoaToCanariUnit (PAPER_RIGHT_MARGIN_COCOA_UNIT)
  let topMargin = cocoaToCanariUnit (PAPER_TOP_MARGIN_COCOA_UNIT)
  let bottomMargin = cocoaToCanariUnit (PAPER_BOTTOM_MARGIN_COCOA_UNIT)
  switch self_mSchematicSheetOrientation {
  case .a4Horizontal :
    let width = A4MaxSize - leftMargin - rightMargin - cocoaToCanariUnit (2.0)
    let height = A4MinSize - topMargin - bottomMargin - cocoaToCanariUnit (2.0)
    return SchematicSheetGeometry (
      size: CanariSize (width: width, height: height),
      horizontalDivisions: (10 * A4MaxSize) / A4MinSize,
      verticalDivisions: 10
    )
  case .a4Vertical :
    let width = A4MinSize - leftMargin - rightMargin - cocoaToCanariUnit (2.0)
    let height = A4MaxSize - topMargin - bottomMargin - cocoaToCanariUnit (2.0)
    return SchematicSheetGeometry (
      size: CanariSize (width: width, height: height),
      horizontalDivisions: 10,
      verticalDivisions: (10 * A4MaxSize) / A4MinSize
    )
  case .custom :
    let width = self_mSchematicCustomWidth
    let height = self_mSchematicCustomHeight
    let m = max (width, height)
    return SchematicSheetGeometry (
      size: CanariSize (width: width, height: height),
      horizontalDivisions: (10 * width) / m,
      verticalDivisions: (10 * height) / m
    )
  }
//--- END OF USER ZONE 2
}

//--------------------------------------------------------------------------------------------------
