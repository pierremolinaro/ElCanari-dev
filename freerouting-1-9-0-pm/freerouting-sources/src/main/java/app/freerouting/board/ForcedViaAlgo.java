package app.freerouting.board;

import app.freerouting.geometry.planar.Circle;
import app.freerouting.geometry.planar.ConvexShape;
import app.freerouting.geometry.planar.FloatPoint;
import app.freerouting.geometry.planar.IntBox;
import app.freerouting.geometry.planar.IntPoint;
import app.freerouting.geometry.planar.Limits;
import app.freerouting.geometry.planar.Point;
import app.freerouting.geometry.planar.Shape;
import app.freerouting.geometry.planar.Simplex;
import app.freerouting.geometry.planar.TileShape;
import app.freerouting.geometry.planar.Vector;
import app.freerouting.library.Padstack;
import app.freerouting.rules.ViaInfo;

/** Class with static functions for checking and inserting forced vias. */
public class ForcedViaAlgo {
  /**
   * Checks, if a Via is possible at the input layer after evtl. shoving aside obstacle traces.
   * p_room_shape is used for calculating the from_side.
   */
  public static ForcedPadAlgo.CheckDrillResult check_layer(
      double p_via_radius,
      int p_cl_class,
      boolean p_attach_smd_allowed,
      TileShape p_room_shape,
      Point p_location,
      int p_layer,
      int[] p_net_no_arr,
      int p_max_recursion_depth,
      int p_max_via_recursion_depth,
      RoutingBoard p_board) {
    if (p_via_radius <= 0) {
      return ForcedPadAlgo.CheckDrillResult.DRILLABLE;
    }
    ForcedPadAlgo forced_pad_algo = new ForcedPadAlgo(p_board);
    if (!(p_location instanceof IntPoint)) {
      return ForcedPadAlgo.CheckDrillResult.NOT_DRILLABLE;
    }
    ConvexShape via_shape = new Circle((IntPoint) p_location, (int) Math.ceil(p_via_radius));

    double check_radius =
        p_via_radius
            + 0.5 * p_board.clearance_value(p_cl_class, p_cl_class, p_layer)
            + p_board.get_min_trace_half_width();

    TileShape tile_shape;
    boolean is_90_degree;
    if (p_board.rules.get_trace_angle_restriction() == AngleRestriction.NINETY_DEGREE) {
      tile_shape = via_shape.bounding_box();
      is_90_degree = true;
    } else {
      tile_shape = via_shape.bounding_octagon();
      is_90_degree = false;
    }

    CalcFromSide from_side =
        calculate_from_side(
            p_location.to_float(),
            tile_shape,
            p_room_shape.to_Simplex(),
            check_radius,
            is_90_degree);
    if (from_side == null) {
      return ForcedPadAlgo.CheckDrillResult.NOT_DRILLABLE;
    }

    return forced_pad_algo.check_forced_pad(
            tile_shape,
            from_side,
            p_layer,
            p_net_no_arr,
            p_cl_class,
            p_attach_smd_allowed,
            null,
            p_max_recursion_depth,
            p_max_via_recursion_depth,
            false,
            null);
  }

  /**
   * Checks, if a Via is possible with the input parameter after evtl. shoving aside obstacle
   * traces.
   */
  public static boolean check(
      ViaInfo p_via_info,
      Point p_location,
      int[] p_net_no_arr,
      int p_max_recursion_depth,
      int p_max_via_recursion_depth,
      RoutingBoard p_board) {
    Vector translate_vector = p_location.difference_by(Point.ZERO);
    int calc_from_side_offset = p_board.get_min_trace_half_width();
    ForcedPadAlgo forced_pad_algo = new ForcedPadAlgo(p_board);
    Padstack via_padstack = p_via_info.get_padstack();
    for (int i = via_padstack.from_layer(); i <= via_padstack.to_layer(); ++i) {
      Shape curr_pad_shape = via_padstack.get_shape(i);
      if (curr_pad_shape == null) {
        continue;
      }
      curr_pad_shape = (Shape) curr_pad_shape.translate_by(translate_vector);
      TileShape tile_shape;
      if (p_board.rules.get_trace_angle_restriction() == AngleRestriction.NINETY_DEGREE) {
        tile_shape = curr_pad_shape.bounding_box();
      } else {
        tile_shape = curr_pad_shape.bounding_octagon();
      }
      CalcFromSide from_side =
          forced_pad_algo.calc_from_side(
              tile_shape, p_location, i, calc_from_side_offset, p_via_info.get_clearance_class());
      if (forced_pad_algo.check_forced_pad(
              tile_shape,
              from_side,
              i,
              p_net_no_arr,
              p_via_info.get_clearance_class(),
              p_via_info.attach_smd_allowed(),
              null,
              p_max_recursion_depth,
              p_max_via_recursion_depth,
              false,
              null)
          == ForcedPadAlgo.CheckDrillResult.NOT_DRILLABLE) {
        p_board.set_shove_failing_layer(i);
        return false;
      }
    }
    return true;
  }

  /**
   * Shoves aside traces, so that a via with the input parameters can be inserted without clearance
   * violations. If the shove failed, the database may be damaged, so that an undo becomes
   * necessary. p_trace_clearance_class_no and p_trace_pen_halfwidth_arr is provided to make space
   * for starting a trace in case the trace width is bigger than the via shape. Returns false, if
   * the forced via failed.
   */
  public static boolean insert(
      ViaInfo p_via_info,
      Point p_location,
      int[] p_net_no_arr,
      int p_trace_clearance_class_no,
      int[] p_trace_pen_halfwidth_arr,
      int p_max_recursion_depth,
      int p_max_via_recursion_depth,
      RoutingBoard p_board) {
    Vector translate_vector = p_location.difference_by(Point.ZERO);
    int calc_from_side_offset = p_board.get_min_trace_half_width();
    ForcedPadAlgo forced_pad_algo = new ForcedPadAlgo(p_board);
    Padstack via_padstack = p_via_info.get_padstack();
    for (int i = via_padstack.from_layer(); i <= via_padstack.to_layer(); ++i) {
      Shape curr_pad_shape = via_padstack.get_shape(i);
      if (curr_pad_shape == null) {
        continue;
      }
      curr_pad_shape = (Shape) curr_pad_shape.translate_by(translate_vector);
      TileShape tile_shape;
      Circle start_trace_circle;
      if (p_trace_pen_halfwidth_arr[i] > 0 && p_location instanceof IntPoint) {
        start_trace_circle = new Circle((IntPoint) p_location, p_trace_pen_halfwidth_arr[i]);
      } else {
        start_trace_circle = null;
      }
      TileShape start_trace_shape = null;
      if (p_board.rules.get_trace_angle_restriction() == AngleRestriction.NINETY_DEGREE) {
        tile_shape = curr_pad_shape.bounding_box();
        if (start_trace_circle != null) {
          start_trace_shape = start_trace_circle.bounding_box();
        }
      } else {
        tile_shape = curr_pad_shape.bounding_octagon();
        if (start_trace_circle != null) {
          start_trace_shape = start_trace_circle.bounding_octagon();
        }
      }
      CalcFromSide from_side =
          forced_pad_algo.calc_from_side(
              tile_shape, p_location, i, calc_from_side_offset, p_via_info.get_clearance_class());
      if (!forced_pad_algo.forced_pad(
          tile_shape,
          from_side,
          i,
          p_net_no_arr,
          p_via_info.get_clearance_class(),
          p_via_info.attach_smd_allowed(),
          null,
          p_max_recursion_depth,
          p_max_via_recursion_depth)) {
        p_board.set_shove_failing_layer(i);
        return false;
      }
      if (start_trace_shape != null) {
        // necessary in case start_trace_shape is bigger than tile_shape
        if (!forced_pad_algo.forced_pad(
            start_trace_shape,
            from_side,
            i,
            p_net_no_arr,
            p_trace_clearance_class_no,
            true,
            null,
            p_max_recursion_depth,
            p_max_via_recursion_depth)) {
          p_board.set_shove_failing_layer(i);
          return false;
        }
      }
    }
    p_board.insert_via(
        via_padstack,
        p_location,
        p_net_no_arr,
        p_via_info.get_clearance_class(),
        FixedState.UNFIXED,
        p_via_info.attach_smd_allowed());
    return true;
  }

  private static CalcFromSide calculate_from_side(
      FloatPoint p_via_location,
      TileShape p_via_shape,
      Simplex p_room_shape,
      double p_dist,
      boolean is_90_degree) {
    IntBox via_box = p_via_shape.bounding_box();
    for (int i = 0; i < 4; ++i) {
      FloatPoint check_point;
      double border_x;
      double border_y;
      switch (i) {
        case 0 -> {
          check_point = new FloatPoint(p_via_location.x, p_via_location.y - p_dist);
          border_x = p_via_location.x;
          border_y = via_box.ll.y;
        }
        case 1 -> {
          check_point = new FloatPoint(p_via_location.x + p_dist, p_via_location.y);
          border_x = via_box.ur.x;
          border_y = p_via_location.y;
        }
        case 2 -> {
          check_point = new FloatPoint(p_via_location.x, p_via_location.y + p_dist);
          border_x = p_via_location.x;
          border_y = via_box.ur.y;
        }
        default -> { // i == 3
          check_point = new FloatPoint(p_via_location.x - p_dist, p_via_location.y);
          border_x = via_box.ll.x;
          border_y = p_via_location.y;
        }
      }
      if (p_room_shape.contains(check_point)) {
        int from_side_no;
        if (is_90_degree) {
          from_side_no = i;
        } else {
          from_side_no = 2 * i;
        }
        FloatPoint curr_border_point = new FloatPoint(border_x, border_y);
        return new CalcFromSide(from_side_no, curr_border_point);
      }
    }
    if (is_90_degree) {
      return null;
    }
    // try the diagonal directions
    double dist = p_dist / Limits.sqrt2;
    double border_dist = via_box.max_width() / (2 * Limits.sqrt2);
    for (int i = 0; i < 4; ++i) {
      FloatPoint check_point;
      double border_x;
      double border_y;
      switch (i) {
        case 0 -> {
          check_point = new FloatPoint(p_via_location.x + dist, p_via_location.y - dist);
          border_x = p_via_location.x + border_dist;
          border_y = p_via_location.y - border_dist;
        }
        case 1 -> {
          check_point = new FloatPoint(p_via_location.x + dist, p_via_location.y + dist);
          border_x = p_via_location.x + border_dist;
          border_y = p_via_location.y + border_dist;
        }
        case 2 -> {
          check_point = new FloatPoint(p_via_location.x - dist, p_via_location.y + dist);
          border_x = p_via_location.x - border_dist;
          border_y = p_via_location.y + border_dist;
        }
        default -> { // i == 3
          check_point = new FloatPoint(p_via_location.x - dist, p_via_location.y - dist);
          border_x = p_via_location.x - border_dist;
          border_y = p_via_location.y - border_dist;
        }
      }
      if (p_room_shape.contains(check_point)) {

        int from_side_no = 2 * i + 1;
        FloatPoint curr_border_point = new FloatPoint(border_x, border_y);
        return new CalcFromSide(from_side_no, curr_border_point);
      }
    }
    return null;
  }
}
