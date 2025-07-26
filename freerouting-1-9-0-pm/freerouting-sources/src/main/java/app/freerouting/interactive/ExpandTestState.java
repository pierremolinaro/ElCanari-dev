package app.freerouting.interactive;

import app.freerouting.autoroute.AutorouteControl;
import app.freerouting.autoroute.AutorouteEngine;
import app.freerouting.autoroute.CompleteFreeSpaceExpansionRoom;
import app.freerouting.autoroute.IncompleteFreeSpaceExpansionRoom;
import app.freerouting.autoroute.InsertFoundConnectionAlgo;
import app.freerouting.autoroute.LocateFoundConnectionAlgo;
import app.freerouting.autoroute.MazeSearchAlgo;
import app.freerouting.board.Connectable;
import app.freerouting.board.Item;
import app.freerouting.board.RoutingBoard;
import app.freerouting.board.TestLevel;
import app.freerouting.geometry.planar.FloatPoint;
import app.freerouting.geometry.planar.TileShape;

import java.awt.Graphics;
import java.util.Collection;
import java.util.Set;
import java.util.SortedSet;
import java.util.TreeSet;

/** State for testing the expanding algorithm of the autorouter. */
public class ExpandTestState extends InteractiveState {

  private boolean in_autoroute = false;
  private MazeSearchAlgo maze_search_algo;
  private LocateFoundConnectionAlgo autoroute_result;
  private AutorouteControl control_settings;
  private AutorouteEngine autoroute_engine;

  /** Creates a new instance of ExpandTestState */
  private ExpandTestState(
      FloatPoint p_location, InteractiveState p_return_state, BoardHandling p_board_handling) {
    super(p_return_state, p_board_handling, null);
    init(p_location);
  }

  public static ExpandTestState get_instance(
      FloatPoint p_location, InteractiveState p_return_state, BoardHandling p_board_handling) {
    return new ExpandTestState(p_location, p_return_state, p_board_handling);
  }

  @Override
  public InteractiveState key_typed(char p_key_char) {
    InteractiveState result;
    if (p_key_char == 'n') {
      if (in_autoroute) {
        if (!this.maze_search_algo.occupy_next_element()) {
          // to display the backtack rooms
          complete_autoroute();
          hdlg.screen_messages.set_status_message("expansion completed");
        }
      } else {
        boolean completing_succeeded = false;
        while (!completing_succeeded) {
          IncompleteFreeSpaceExpansionRoom next_room =
              this.autoroute_engine.get_first_incomplete_expansion_room();
          if (next_room == null) {
            hdlg.screen_messages.set_status_message("expansion completed");
            break;
          }
          completing_succeeded = complete_expansion_room(next_room);
        }
      }
      // hdlg.get_routing_board().autoroute_data().validate();
      result = this;
    } else if (p_key_char == 'a') {
      if (in_autoroute) {
        complete_autoroute();
      } else {
        IncompleteFreeSpaceExpansionRoom next_room =
            this.autoroute_engine.get_first_incomplete_expansion_room();
        while (next_room != null) {
          complete_expansion_room(next_room);
          next_room = this.autoroute_engine.get_first_incomplete_expansion_room();
        }
      }
      result = this;
      // hdlg.get_routing_board().autoroute_data().validate();
    } else if (Character.isDigit(p_key_char)) {
      // next 10^p_key_char expansions
      int d = Character.digit(p_key_char, 10);
      final int max_count = (int) Math.pow(10, d);
      if (in_autoroute) {
        for (int i = 0; i < max_count; ++i) {
          if (!this.maze_search_algo.occupy_next_element()) {
            // to display the backtack rooms
            complete_autoroute();
            hdlg.screen_messages.set_status_message("expansion completed");
            break;
          }
        }
      } else {
        int curr_count = 0;
        IncompleteFreeSpaceExpansionRoom next_room =
            this.autoroute_engine.get_first_incomplete_expansion_room();
        while (next_room != null && curr_count < max_count) {
          complete_expansion_room(next_room);
          next_room = this.autoroute_engine.get_first_incomplete_expansion_room();
          ++curr_count;
        }
      }
      result = this;
      // hdlg.get_routing_board().autoroute_data().validate();
    } else {
      autoroute_engine.clear();
      result = super.key_typed(p_key_char);
    }
    hdlg.repaint();
    return result;
  }

  @Override
  public InteractiveState left_button_clicked(FloatPoint p_location) {
    return cancel();
  }

  @Override
  public InteractiveState cancel() {
    autoroute_engine.clear();
    return this.return_state;
  }

  @Override
  public InteractiveState complete() {
    return cancel();
  }

  @Override
  public void draw(Graphics p_graphics) {
    autoroute_engine.draw(p_graphics, hdlg.graphics_context, 0.1);
    if (this.autoroute_result != null) {
      this.autoroute_result.draw(p_graphics, hdlg.graphics_context);
    }
  }

  private void init(FloatPoint p_location) {
    // look if an autoroute can be started at the input location
    RoutingBoard board = hdlg.get_routing_board();
    int layer = hdlg.settings.layer;
    Collection<Item> found_items = board.pick_items(p_location.round(), layer, null);
    Item route_item = null;
    int route_net_no = 0;
    for (Item curr_ob : found_items) {
      if (curr_ob instanceof Connectable) {
        Item curr_item = curr_ob;
        if (curr_item.net_count() == 1 && curr_item.get_net_no(0) > 0) {
          route_item = curr_item;
          route_net_no = curr_item.get_net_no(0);
          break;
        }
      }
    }
    this.control_settings =
        new AutorouteControl(hdlg.get_routing_board(), route_net_no, hdlg.settings);
    // this.control_settings.ripup_allowed = true;
    // this.control_settings.is_fanout = true;
    this.control_settings.ripup_pass_no = hdlg.settings.autoroute_settings.get_start_pass_no();
    this.control_settings.ripup_costs =
        this.control_settings.ripup_pass_no
            * hdlg.settings.autoroute_settings.get_start_ripup_costs();
    this.control_settings.vias_allowed = false;
    this.autoroute_engine =
        new AutorouteEngine(board, this.control_settings.trace_clearance_class_no, false);
    this.autoroute_engine.init_connection(route_net_no, null, null);
    if (route_item == null) {
      // create an expansion room in the empty space
      TileShape contained_shape = TileShape.get_instance(p_location.round());
      IncompleteFreeSpaceExpansionRoom expansion_room =
          autoroute_engine.add_incomplete_expansion_room(null, layer, contained_shape);
      hdlg.screen_messages.set_status_message("expansion test started");
      complete_expansion_room(expansion_room);
      return;
    }
    Set<Item> route_start_set = route_item.get_connected_set(route_net_no);
    Set<Item> route_dest_set = route_item.get_unconnected_set(route_net_no);
    if (!route_dest_set.isEmpty()) {
      hdlg.screen_messages.set_status_message("app.freerouting.autoroute test started");
      this.maze_search_algo =
          MazeSearchAlgo.get_instance(
              route_start_set, route_dest_set, autoroute_engine, control_settings);
      this.in_autoroute = (this.maze_search_algo != null);
    }
  }

  private void complete_autoroute() {
    MazeSearchAlgo.Result search_result = this.maze_search_algo.find_connection();
    if (search_result != null) {
      SortedSet<Item> ripped_item_list = new TreeSet<>();
      this.autoroute_result =
          LocateFoundConnectionAlgo.get_instance(
              search_result,
              control_settings,
              this.autoroute_engine.autoroute_search_tree,
              hdlg.get_routing_board().rules.get_trace_angle_restriction(),
              ripped_item_list,
              TestLevel.ALL_DEBUGGING_OUTPUT);
      hdlg.get_routing_board().generate_snapshot();
      SortedSet<Item> ripped_connections = new TreeSet<>();
      for (Item curr_ripped_item : ripped_item_list) {
        ripped_connections.addAll(
            curr_ripped_item.get_connection_items(Item.StopConnectionOption.VIA));
      }
      hdlg.get_routing_board().remove_items(ripped_connections, false);
      InsertFoundConnectionAlgo.get_instance(
          autoroute_result, hdlg.get_routing_board(), control_settings);
    }
  }

  /** Returns true, if the completion succeeded. */
  private boolean complete_expansion_room(IncompleteFreeSpaceExpansionRoom p_incomplete_room) {
    Collection<CompleteFreeSpaceExpansionRoom> completed_rooms =
        autoroute_engine.complete_expansion_room(p_incomplete_room);
    return (!completed_rooms.isEmpty());
  }
}
