package app.freerouting.interactive;

import app.freerouting.board.AngleRestriction;
import app.freerouting.board.FixedState;
import app.freerouting.board.RoutingBoard;
import app.freerouting.geometry.planar.FloatPoint;
import app.freerouting.geometry.planar.IntPoint;
import app.freerouting.geometry.planar.Line;
import app.freerouting.geometry.planar.Side;
import app.freerouting.geometry.planar.TileShape;
import app.freerouting.rules.BoardRules;

import java.util.Arrays;
import java.util.Iterator;
import java.util.LinkedList;

/** Class for interactive construction of a tile shaped obstacle */
public class TileConstructionState extends CornerItemConstructionState {
  /** Creates a new instance of TileConstructionState */
  private TileConstructionState(
      FloatPoint p_location,
      InteractiveState p_parent_state,
      BoardHandling p_board_handling,
      ActivityReplayFile p_activityReplayFile) {
    super(p_parent_state, p_board_handling, p_activityReplayFile);
    if (this.activityReplayFile != null) {
      activityReplayFile.start_scope(ActivityReplayFileScope.CREATING_TILE);
    }
    this.add_corner(p_location);
  }

  /**
   * Returns a new instance of this class If p_logfile != null; the creation of this item is stored
   * in a logfile
   */
  public static TileConstructionState get_instance(
      FloatPoint p_location,
      InteractiveState p_parent_state,
      BoardHandling p_board_handling,
      ActivityReplayFile p_activityReplayFile) {
    return new TileConstructionState(
        p_location, p_parent_state, p_board_handling, p_activityReplayFile);
  }

  /** adds a corner to the tile under construction */
  @Override
  public InteractiveState left_button_clicked(FloatPoint p_location) {
    super.left_button_clicked(p_location);
    remove_concave_corners();
    hdlg.repaint();
    return this;
  }

  @Override
  public InteractiveState process_logfile_point(FloatPoint p_point) {
    return left_button_clicked(p_point);
  }

  @Override
  public InteractiveState complete() {
    remove_concave_corners_at_close();
    int corner_count = corner_list.size();
    boolean construction_succeeded = corner_count > 2;
    if (construction_succeeded) {
      // create the edgelines of the new tile
      Line[] edge_lines = new Line[corner_count];
      Iterator<IntPoint> it = corner_list.iterator();
      IntPoint first_corner = it.next();
      IntPoint prev_corner = first_corner;
      for (int i = 0; i < corner_count - 1; ++i) {
        IntPoint next_corner = it.next();
        edge_lines[i] = new Line(prev_corner, next_corner);
        prev_corner = next_corner;
      }
      edge_lines[corner_count - 1] = new Line(prev_corner, first_corner);
      TileShape obstacle_shape = TileShape.get_instance(edge_lines);
      RoutingBoard board = hdlg.get_routing_board();
      int layer = hdlg.settings.layer;
      int cl_class = BoardRules.clearance_class_none();

      construction_succeeded = board.check_shape(obstacle_shape, layer, new int[0], cl_class);
      if (construction_succeeded) {
        // insert the new shape as keepout
        this.observers_activated = !hdlg.get_routing_board().observers_active();
        if (this.observers_activated) {
          hdlg.get_routing_board().start_notify_observers();
        }
        board.generate_snapshot();
        board.insert_obstacle(obstacle_shape, layer, cl_class, FixedState.UNFIXED);
        if (this.observers_activated) {
          hdlg.get_routing_board().end_notify_observers();
          this.observers_activated = false;
        }
      }
    }
    if (construction_succeeded) {
      hdlg.screen_messages.set_status_message(resources.getString("keepout_successful_completed"));
    } else {
      hdlg.screen_messages.set_status_message(
          resources.getString("keepout_cancelled_because_of_overlaps"));
    }
    if (activityReplayFile != null) {
      activityReplayFile.start_scope(ActivityReplayFileScope.COMPLETE_SCOPE);
    }
    return this.return_state;
  }

  /** skips concave corners at the end of the corner_list. */
  private void remove_concave_corners() {
    IntPoint[] corner_arr = new IntPoint[corner_list.size()];
    Iterator<IntPoint> it = corner_list.iterator();
    for (int i = 0; i < corner_arr.length; ++i) {
      corner_arr[i] = it.next();
    }

    int new_length = corner_arr.length;
    if (new_length < 3) {
      return;
    }
    IntPoint last_corner = corner_arr[new_length - 1];
    IntPoint curr_corner = corner_arr[new_length - 2];
    while (new_length > 2) {
      IntPoint prev_corner = corner_arr[new_length - 3];
      Side last_corner_side = last_corner.side_of(prev_corner, curr_corner);
      if (last_corner_side == Side.ON_THE_LEFT) {
        // side is ok, nothing to skip
        break;
      }
      if (this.hdlg.get_routing_board().rules.get_trace_angle_restriction()
          != AngleRestriction.FORTYFIVE_DEGREE) {
        // skip concave corner
        corner_arr[new_length - 2] = last_corner;
      }
      --new_length;
      // In 45 degree case just skip last corner as nothing like the following
      // calculation for the 90 degree case to keep
      // the angle restrictions is implemented.
      if (this.hdlg.get_routing_board().rules.get_trace_angle_restriction()
          == AngleRestriction.NINETY_DEGREE) {
        // prevent generating a non orthogonal line by changing the previous corner
        IntPoint prev_prev_corner = null;
        if (new_length >= 3) {
          prev_prev_corner = corner_arr[new_length - 3];
        }
        if (prev_prev_corner != null && prev_prev_corner.x == prev_corner.x) {
          corner_arr[new_length - 2] = new IntPoint(prev_corner.x, last_corner.y);
        } else {
          corner_arr[new_length - 2] = new IntPoint(last_corner.x, prev_corner.y);
        }
      }
      curr_corner = prev_corner;
    }
    if (new_length < corner_arr.length) {
      // something skipped, update corner_list
      corner_list =
          new LinkedList<>(Arrays.asList(corner_arr).subList(0, new_length));
    }
  }
  /**
   * removes as many corners at the end of the corner list, so that closing the polygon will not
   * create a concave corner
   */
  private void remove_concave_corners_at_close() {
    add_corner_for_snap_angle();
    if (corner_list.size() < 4) {
      return;
    }
    IntPoint[] corner_arr = new IntPoint[corner_list.size()];
    Iterator<IntPoint> it = corner_list.iterator();
    for (int i = 0; i < corner_arr.length; ++i) {
      corner_arr[i] = it.next();
    }
    int new_length = corner_arr.length;

    IntPoint first_corner = corner_arr[0];
    IntPoint second_corner = corner_arr[1];
    while (new_length > 3) {
      IntPoint last_corner = corner_arr[new_length - 1];
      if (last_corner.side_of(second_corner, first_corner) != Side.ON_THE_LEFT) {
        break;
      }
      --new_length;
    }

    if (new_length != corner_arr.length) {
      // recalculate the corner_list
      corner_list = new LinkedList<>(Arrays.asList(corner_arr).subList(0, new_length));
      add_corner_for_snap_angle();
    }
  }

  @Override
  public void display_default_message() {
    hdlg.screen_messages.set_status_message(resources.getString("creatig_tile"));
  }
}
