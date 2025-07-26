package app.freerouting.gui;

import app.freerouting.board.ItemSelectionFilter;
import app.freerouting.boardgraphics.GraphicsContext;
import app.freerouting.datastructures.IndentFileWriter;
import app.freerouting.interactive.BoardHandling;
import app.freerouting.interactive.SnapShot;
import app.freerouting.logger.FRLogger;

import javax.swing.JFrame;
import java.awt.Color;
import java.awt.Rectangle;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;

/** Description of a text file, where the board independent interactive settings are stored. */
public class GUIDefaultsFile {
  private final BoardFrame board_frame;
  private final BoardHandling board_handling;
  /** Used, when reading a defaults file, null otherwise. */
  private final GUIDefaultsScanner scanner;
  /** Used, when writing a defaults file; null otherwise. */
  private final IndentFileWriter out_file;

  private GUIDefaultsFile(
      BoardFrame p_board_frame,
      BoardHandling p_board_handling,
      GUIDefaultsScanner p_scanner,
      IndentFileWriter p_output_file) {
    board_frame = p_board_frame;
    board_handling = p_board_handling;
    scanner = p_scanner;
    out_file = p_output_file;
  }

  /**
   * Writes the GUI setting of p_board_frame as default to p_file. Returns false, if an error
   * occurred.
   */
  public static boolean write(
      BoardFrame p_board_frame,
      BoardHandling p_board_handling,
      OutputStream p_output_stream) {
    if (p_output_stream == null) {
      return false;
    }

    IndentFileWriter output_file = new IndentFileWriter(p_output_stream);

    GUIDefaultsFile result =
        new GUIDefaultsFile(p_board_frame, p_board_handling, null, output_file);
    try {
      result.write_defaults_scope();
    } catch (IOException e) {
      FRLogger.warn("unable to write defaults file");
      return false;
    }

    try {
      output_file.close();
    } catch (IOException e) {
      FRLogger.error("unable to close defaults file", e);
      return false;
    }
    return true;
  }

  /**
   * Reads the GUI setting of p_board_frame from file. Returns false, if an error occurred while
   * reading the file.
   */
  public static boolean read(
      BoardFrame p_board_frame,
      BoardHandling p_board_handling,
      InputStream p_input_stream) {
    if (p_input_stream == null) {
      return false;
    }
    GUIDefaultsScanner scanner = new GUIDefaultsScanner(p_input_stream);
    GUIDefaultsFile new_instance =
        new GUIDefaultsFile(p_board_frame, p_board_handling, scanner, null);
    boolean result;
    try {
      result = new_instance.read_defaults_scope();
    } catch (IOException e) {
      FRLogger.error("unable to read defaults file", e);
      result = false;
    }
    return result;
  }

  /** Skips the current scope. Returns false, if no legal scope was found. */
  private static boolean skip_scope(GUIDefaultsScanner p_scanner) {
    int open_bracked_count = 1;
    while (open_bracked_count > 0) {
      Object curr_token;
      try {
        curr_token = p_scanner.next_token();
      } catch (Exception e) {
        FRLogger.error("GUIDefaultsFile.skip_scope: Error while scanning file", e);
        return false;
      }
      if (curr_token == null) {
        return false; // end of file
      }
      if (curr_token == Keyword.OPEN_BRACKET) {
        ++open_bracked_count;
      } else if (curr_token == Keyword.CLOSED_BRACKET) {
        --open_bracked_count;
      }
    }
    FRLogger.warn("GUIDefaultsFile.skip_scope: unknown scope skipped");
    return true;
  }

  private void write_defaults_scope() throws IOException {
    out_file.start_scope();
    out_file.write("gui_defaults");
    write_windows_scope();
    write_colors_scope();
    write_parameter_scope();
    out_file.end_scope();
  }

  private boolean read_defaults_scope() throws IOException {
    Object next_token = this.scanner.next_token();

    if (next_token != Keyword.OPEN_BRACKET) {
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.GUI_DEFAULTS) {
      return false;
    }

    // read the direct subscopes of the gui_defaults scope
    for (; ; ) {
      Object prev_token = next_token;
      next_token = this.scanner.next_token();
      if (next_token == null) {
        // end of file
        return true;
      }
      if (next_token == Keyword.CLOSED_BRACKET) {
        // end of scope
        break;
      }

      if (prev_token == Keyword.OPEN_BRACKET) {
        if (next_token == Keyword.COLORS) {
          if (!read_colors_scope()) {
            return false;
          }
        } else if (next_token == Keyword.WINDOWS) {
          if (!read_windows_scope()) {
            return false;
          }
        } else if (next_token == Keyword.PARAMETER) {
          if (!read_parameter_scope()) {
            return false;
          }
        } else {
          // overread all scopes except the routes scope for the time being
          skip_scope(this.scanner);
        }
      }
    }
    this.board_frame.refresh_windows();
    return true;
  }

  private boolean read_windows_scope() throws IOException {
    // read the direct subscopes of the windows scope
    Object next_token = null;
    for (; ; ) {
      Object prev_token = next_token;
      next_token = this.scanner.next_token();
      if (next_token == null) {
        // unexpected end of file
        return false;
      }
      if (next_token == Keyword.CLOSED_BRACKET) {
        // end of scope
        break;
      }

      if (prev_token == Keyword.OPEN_BRACKET) {
        if (!(next_token instanceof Keyword)) {
          FRLogger.warn("GUIDefaultsFile.windows: Keyword expected");
          return false;
        }
        if (!read_frame_scope((Keyword) next_token)) {

          return false;
        }
      }
    }
    return true;
  }

  private void write_windows_scope() throws IOException {
    out_file.start_scope();
    out_file.write("windows");
    write_frame_scope(this.board_frame, "board_frame");
    write_frame_scope(this.board_frame.color_manager, "color_manager");
    write_frame_scope(this.board_frame.layer_visibility_window, "layer_visibility");
    write_frame_scope(this.board_frame.object_visibility_window, "object_visibility");
    write_frame_scope(this.board_frame.display_misc_window, "display_miscellaneous");
    write_frame_scope(this.board_frame.snapshot_window, "snapshots");
    write_frame_scope(this.board_frame.select_parameter_window, "select_parameter");
    write_frame_scope(this.board_frame.route_parameter_window, "route_parameter");
    write_frame_scope(this.board_frame.route_parameter_window.manual_rule_window, "manual_rules");
    write_frame_scope(this.board_frame.route_parameter_window.detail_window, "route_details");
    write_frame_scope(this.board_frame.move_parameter_window, "move_parameter");
    write_frame_scope(this.board_frame.clearance_matrix_window, "clearance_matrix");
    write_frame_scope(this.board_frame.via_window, "via_rules");
    write_frame_scope(this.board_frame.edit_vias_window, "edit_vias");
    write_frame_scope(this.board_frame.edit_net_rules_window, "edit_net_rules");
    write_frame_scope(this.board_frame.assign_net_classes_window, "assign_net_rules");
    write_frame_scope(this.board_frame.padstacks_window, "padstack_info");
    write_frame_scope(this.board_frame.packages_window, "package_info");
    write_frame_scope(this.board_frame.components_window, "component_info");
    write_frame_scope(this.board_frame.net_info_window, "net_info");
    write_frame_scope(this.board_frame.incompletes_window, "incompletes_info");
    write_frame_scope(this.board_frame.clearance_violations_window, "violations_info");
    out_file.end_scope();
  }

  private boolean read_frame_scope(Keyword p_frame) throws IOException {
    boolean is_visible;
    Object next_token = this.scanner.next_token();
    if (next_token == Keyword.VISIBLE) {
      is_visible = true;
    } else if (next_token == Keyword.NOT_VISIBLE) {
      is_visible = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_frame_scope: visible or not_visible expected");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.OPEN_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_frame_scope: open_bracket expected");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.BOUNDS) {
      FRLogger.warn("GUIDefaultsFile.read_frame_scope: bounds expected");
      return false;
    }
    Rectangle bounds = read_rectangle();
    if (bounds == null) {
      return false;
    }
    for (int i = 0; i < 2; ++i) {
      next_token = this.scanner.next_token();
      if (next_token != Keyword.CLOSED_BRACKET) {
        FRLogger.warn("GUIDefaultsFile.read_frame_scope: closing bracket expected");
        return false;
      }
    }
    JFrame curr_frame;
    switch (p_frame) {
      case BOARD_FRAME           -> curr_frame = this.board_frame;
      case COLOR_MANAGER         -> curr_frame = this.board_frame.color_manager;
      case OBJECT_VISIBILITY     -> curr_frame = this.board_frame.object_visibility_window;
      case LAYER_VISIBILITY      -> curr_frame = this.board_frame.layer_visibility_window;
      case DISPLAY_MISCELLANEOUS -> curr_frame = this.board_frame.display_misc_window;
      case SNAPSHOTS             -> curr_frame = this.board_frame.snapshot_window;
      case SELECT_PARAMETER      -> curr_frame = this.board_frame.select_parameter_window;
      case ROUTE_PARAMETER       -> curr_frame = this.board_frame.route_parameter_window;
      case MANUAL_RULES          -> curr_frame = this.board_frame.route_parameter_window.manual_rule_window;
      case ROUTE_DETAILS         -> curr_frame = this.board_frame.route_parameter_window.detail_window;
      case MOVE_PARAMETER        -> curr_frame = this.board_frame.move_parameter_window;
      case CLEARANCE_MATRIX      -> curr_frame = this.board_frame.clearance_matrix_window;
      case VIA_RULES             -> curr_frame = this.board_frame.via_window;
      case EDIT_VIAS             -> curr_frame = this.board_frame.edit_vias_window;
      case EDIT_NET_RULES        -> curr_frame = this.board_frame.edit_net_rules_window;
      case ASSIGN_NET_RULES      -> curr_frame = this.board_frame.assign_net_classes_window;
      case PADSTACK_INFO         -> curr_frame = this.board_frame.padstacks_window;
      case PACKAGE_INFO          -> curr_frame = this.board_frame.packages_window;
      case COMPONENT_INFO        -> curr_frame = this.board_frame.components_window;
      case NET_INFO              -> curr_frame = this.board_frame.net_info_window;
      case INCOMPLETES_INFO      -> curr_frame = this.board_frame.incompletes_window;
      case VIOLATIONS_INFO       -> curr_frame = this.board_frame.clearance_violations_window;
      default -> {
        FRLogger.warn("GUIDefaultsFile.read_frame_scope: unknown frame");
        return false;
      }
    }
    curr_frame.setVisible(is_visible);
    if (p_frame == Keyword.BOARD_FRAME) {
      curr_frame.setBounds(bounds);
    } else {
      // Set only the location.
      // Do not change the size of the frame because it depends on the layer count.
      curr_frame.setLocation(bounds.getLocation());
    }
    return true;
  }

  private Rectangle read_rectangle() throws IOException {
    int[] coor = new int[4];
    for (int i = 0; i < 4; ++i) {
      Object next_token = this.scanner.next_token();
      if (!(next_token instanceof Integer)) {
        FRLogger.warn("GUIDefaultsFile.read_rectangle: Integer expected");
        return null;
      }
      coor[i] = (Integer) next_token;
    }
    return new Rectangle(coor[0], coor[1], coor[2], coor[3]);
  }

  private void write_frame_scope(JFrame p_frame, String p_frame_name)
      throws IOException {
    out_file.start_scope();
    out_file.write(p_frame_name);
    out_file.new_line();
    if (p_frame.isVisible()) {
      out_file.write("visible");
    } else {
      out_file.write("not_visible");
    }
    write_bounds(p_frame.getBounds());
    out_file.end_scope();
  }

  private void write_bounds(Rectangle p_bounds) throws IOException {
    out_file.start_scope();
    out_file.write("bounds");
    out_file.new_line();
    int x = (int) p_bounds.getX();
    out_file.write(String.valueOf(x));
    int y = (int) p_bounds.getY();
    out_file.write(" ");
    out_file.write(String.valueOf(y));
    int width = (int) p_bounds.getWidth();
    out_file.write(" ");
    out_file.write(String.valueOf(width));
    int height = (int) p_bounds.getHeight();
    out_file.write(" ");
    out_file.write(String.valueOf(height));
    out_file.end_scope();
  }

  private boolean read_colors_scope() throws IOException {
    // read the direct subscopes of the colors scope
    Object next_token = null;
    for (; ; ) {
      Object prev_token = next_token;
      next_token = this.scanner.next_token();
      if (next_token == null) {
        // unexpected end of file
        return false;
      }
      if (next_token == Keyword.CLOSED_BRACKET) {
        // end of scope
        break;
      }

      if (prev_token == Keyword.OPEN_BRACKET) {

        if (next_token == Keyword.BACKGROUND) {
          if (!read_background_color()) {
            return false;
          }
        } else if (next_token == Keyword.CONDUCTION) {
          if (!read_conduction_colors()) {
            return false;
          }
        } else if (next_token == Keyword.HILIGHT) {
          if (!read_hilight_color()) {
            return false;
          }
        } else if (next_token == Keyword.INCOMPLETES) {
          if (!read_incompletes_color()) {
            return false;
          }
        } else if (next_token == Keyword.KEEPOUT) {
          if (!read_keepout_colors()) {
            return false;
          }
        } else if (next_token == Keyword.OUTLINE) {
          if (!read_outline_color()) {
            return false;
          }
        } else if (next_token == Keyword.COMPONENT_FRONT) {
          if (!read_component_color(true)) {
            return false;
          }
        } else if (next_token == Keyword.COMPONENT_BACK) {
          if (!read_component_color(false)) {
            return false;
          }
        } else if (next_token == Keyword.LENGTH_MATCHING) {
          if (!read_length_matching_color()) {
            return false;
          }
        } else if (next_token == Keyword.PINS) {
          if (!read_pin_colors()) {
            return false;
          }
        } else if (next_token == Keyword.TRACES) {
          if (!read_trace_colors(false)) {
            return false;
          }
        } else if (next_token == Keyword.FIXED_TRACES) {
          if (!read_trace_colors(true)) {
            return false;
          }
        } else if (next_token == Keyword.VIA_KEEPOUT) {
          if (!read_via_keepout_colors()) {
            return false;
          }
        } else if (next_token == Keyword.VIAS) {
          if (!read_via_colors(false)) {
            return false;
          }
        } else if (next_token == Keyword.FIXED_VIAS) {
          if (!read_via_colors(true)) {
            return false;
          }
        } else if (next_token == Keyword.VIOLATIONS) {
          if (!read_violations_color()) {
            return false;
          }
        } else {
          // skip unknown scope
          skip_scope(this.scanner);
        }
      }
    }
    return true;
  }

  private boolean read_trace_colors(boolean p_fixed) throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_trace_color_intensity(intensity);
    Color[] curr_colors = read_color_array();
    if (curr_colors.length < 1) {
      return false;
    }
    this.board_handling.graphics_context.item_color_table.set_trace_colors(curr_colors, p_fixed);
    return true;
  }

  private boolean read_via_colors(boolean p_fixed) throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_via_color_intensity(intensity);
    Color[] curr_colors = read_color_array();
    if (curr_colors.length < 1) {
      return false;
    }
    this.board_handling.graphics_context.item_color_table.set_via_colors(curr_colors, p_fixed);
    return true;
  }

  private boolean read_pin_colors() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_pin_color_intensity(intensity);
    Color[] curr_colors = read_color_array();
    if (curr_colors.length < 1) {
      return false;
    }
    this.board_handling.graphics_context.item_color_table.set_pin_colors(curr_colors);
    return true;
  }

  private boolean read_conduction_colors() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_conduction_color_intensity(intensity);
    Color[] curr_colors = read_color_array();
    if (curr_colors.length < 1) {
      return false;
    }
    this.board_handling.graphics_context.item_color_table.set_conduction_colors(curr_colors);
    return true;
  }

  private boolean read_keepout_colors() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_obstacle_color_intensity(intensity);
    Color[] curr_colors = read_color_array();
    if (curr_colors.length < 1) {
      return false;
    }
    this.board_handling.graphics_context.item_color_table.set_keepout_colors(curr_colors);
    return true;
  }

  private boolean read_via_keepout_colors() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_via_obstacle_color_intensity(intensity);
    Color[] curr_colors = read_color_array();
    if (curr_colors.length < 1) {
      return false;
    }
    this.board_handling.graphics_context.item_color_table.set_via_keepout_colors(curr_colors);
    return true;
  }

  private boolean read_background_color() throws IOException {
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_background_color(curr_color);
    this.board_frame.set_board_background(curr_color);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_background_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private boolean read_hilight_color() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_hilight_color_intensity(intensity);
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_hilight_color(curr_color);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_higlight_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private boolean read_incompletes_color() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_incomplete_color_intensity(intensity);
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_incomplete_color(curr_color);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_incompletes_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private boolean read_length_matching_color() throws IOException {
    double intensity = read_color_intensity();
    if (intensity < 0) {
      return false;
    }
    this.board_handling.graphics_context.set_length_matching_area_color_intensity(intensity);
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_length_matching_area_color(
        curr_color);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_length_matching_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private boolean read_violations_color() throws IOException {
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_violations_color(curr_color);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_violations_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private boolean read_outline_color() throws IOException {
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_outline_color(curr_color);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_outline_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private boolean read_component_color(boolean p_front) throws IOException {
    Color curr_color = read_color();
    if (curr_color == null) {
      return false;
    }
    this.board_handling.graphics_context.other_color_table.set_component_color(curr_color, p_front);
    Object next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_component_color: closing bracket expected");
      return false;
    }
    return true;
  }

  private double read_color_intensity() throws IOException {
    double result;
    Object next_token = this.scanner.next_token();
    if (next_token instanceof Double) {
      result = (Double) next_token;
    } else if (next_token instanceof Integer) {
      result = (Integer) next_token;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_color_intensity: Number expected");
      result = -1;
    }
    return result;
  }

  /** reads a java.awt.Color from the defaults file. Returns null, if no valid color was found. */
  private Color read_color() throws IOException {
    int[] rgb_color_arr = new int[3];
    for (int i = 0; i < 3; ++i) {
      Object next_token = this.scanner.next_token();
      if (!(next_token instanceof Integer)) {
        if (next_token != Keyword.CLOSED_BRACKET) {
          FRLogger.warn("GUIDefaultsFile.read_color: closing bracket expected");
        }
        return null;
      }
      rgb_color_arr[i] = (Integer) next_token;
    }
    return new Color(rgb_color_arr[0], rgb_color_arr[1], rgb_color_arr[2]);
  }

  /**
   * reads an array java.awt.Color from the defaults file. Returns null, if no valid colors were
   * found.
   */
  private Color[] read_color_array() throws IOException {
    Collection<Color> color_list = new LinkedList<>();
    for (; ; ) {
      Color curr_color = read_color();
      if (curr_color == null) {
        break;
      }
      color_list.add(curr_color);
    }
    Color[] result = new Color[color_list.size()];
    Iterator<Color> it = color_list.iterator();
    for (int i = 0; i < result.length; ++i) {
      result[i] = it.next();
    }
    return result;
  }

  private void write_colors_scope() throws IOException {
    GraphicsContext graphics_context =
        this.board_handling.graphics_context;
    out_file.start_scope();
    out_file.write("colors");
    out_file.start_scope();
    out_file.write("background");
    write_color_scope(graphics_context.get_background_color());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("hilight");
    write_color_intensity(graphics_context.get_hilight_color_intensity());
    write_color_scope(graphics_context.get_hilight_color());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("incompletes");
    write_color_intensity(graphics_context.get_incomplete_color_intensity());
    write_color_scope(graphics_context.get_incomplete_color());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("outline");
    write_color_scope(graphics_context.get_outline_color());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("component_front");
    write_color_scope(graphics_context.get_component_color(true));
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("component_back");
    write_color_scope(graphics_context.get_component_color(false));
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("violations");
    write_color_scope(graphics_context.get_violations_color());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("length_matching");
    write_color_intensity(graphics_context.get_length_matching_area_color_intensity());
    write_color_scope(graphics_context.get_length_matching_area_color());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("traces");
    write_color_intensity(graphics_context.get_trace_color_intensity());
    write_color(graphics_context.get_trace_colors(false));
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("fixed_traces");
    write_color_intensity(graphics_context.get_trace_color_intensity());
    write_color(graphics_context.get_trace_colors(true));
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("vias");
    write_color_intensity(graphics_context.get_via_color_intensity());
    write_color(graphics_context.get_via_colors(false));
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("fixed_vias");
    write_color_intensity(graphics_context.get_via_color_intensity());
    write_color(graphics_context.get_via_colors(true));
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("pins");
    write_color_intensity(graphics_context.get_pin_color_intensity());
    write_color(graphics_context.get_pin_colors());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("conduction");
    write_color_intensity(graphics_context.get_conduction_color_intensity());
    write_color(graphics_context.get_conduction_colors());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("keepout");
    write_color_intensity(graphics_context.get_obstacle_color_intensity());
    write_color(graphics_context.get_obstacle_colors());
    out_file.end_scope();
    out_file.start_scope();
    out_file.write("via_keepout");
    write_color_intensity(graphics_context.get_via_obstacle_color_intensity());
    write_color(graphics_context.get_via_obstacle_colors());
    out_file.end_scope();
    out_file.end_scope();
  }

  private void write_color_intensity(double p_value) throws IOException {
    out_file.write(" ");
    float value = (float) p_value;
    out_file.write(String.valueOf(value));
  }

  private void write_color_scope(Color p_color) throws IOException {
    out_file.new_line();
    int red = p_color.getRed();
    out_file.write(String.valueOf(red));
    out_file.write(" ");
    int green = p_color.getGreen();
    out_file.write(String.valueOf(green));
    out_file.write(" ");
    int blue = p_color.getBlue();
    out_file.write(String.valueOf(blue));
  }

  private void write_color(Color[] p_colors) throws IOException {
    for (int i = 0; i < p_colors.length; ++i) {
      write_color_scope(p_colors[i]);
    }
  }

  private boolean read_parameter_scope() throws IOException {
    // read the subscopes of the parameter scope
    Object next_token = null;
    for (; ; ) {
      Object prev_token = next_token;
      next_token = this.scanner.next_token();
      if (next_token == null) {
        // unexpected end of file
        return false;
      }
      if (next_token == Keyword.CLOSED_BRACKET) {
        // end of scope
        break;
      }

      if (prev_token == Keyword.OPEN_BRACKET) {

        if (next_token == Keyword.SELECTION_LAYERS) {
          if (!read_selection_layer_scope()) {
            return false;
          }
        } else if (next_token == Keyword.VIA_SNAP_TO_SMD_CENTER) {
          if (!read_via_snap_to_smd_center_scope()) {
            return false;
          }
        } else if (next_token == Keyword.SHOVE_ENABLED) {
          if (!read_shove_enabled_scope()) {
            return false;
          }
        } else if (next_token == Keyword.DRAG_COMPONENTS_ENABLED) {
          if (!read_drag_components_enabled_scope()) {
            return false;
          }
        } else if (next_token == Keyword.ROUTE_MODE) {
          if (!read_route_mode_scope()) {
            return false;
          }
        } else if (next_token == Keyword.PULL_TIGHT_REGION) {
          if (!read_pull_tight_region_scope()) {
            return false;
          }
        } else if (next_token == Keyword.PULL_TIGHT_ACCURACY) {
          if (!read_pull_tight_accuracy_scope()) {
            return false;
          }
        } else if (next_token == Keyword.IGNORE_CONDUCTION_AREAS) {
          if (!read_ignore_conduction_scope()) {
            return false;
          }
        } else if (next_token == Keyword.AUTOMATIC_LAYER_DIMMING) {
          if (!read_automatic_layer_dimming_scope()) {
            return false;
          }
        } else if (next_token == Keyword.CLEARANCE_COMPENSATION) {
          if (!read_clearance_compensation_scope()) {
            return false;
          }
        } else if (next_token == Keyword.HILIGHT_ROUTING_OBSTACLE) {
          if (!read_hilight_routing_obstacle_scope()) {
            return false;
          }
        } else if (next_token == Keyword.SELECTABLE_ITEMS) {
          if (!read_selectable_item_scope()) {
            return false;
          }
        } else if (next_token == Keyword.DESELECTED_SNAPSHOT_ATTRIBUTES) {
          if (!read_deselected_snapshot_attributes()) {
            return false;
          }
        } else {
          // skip unknown scope
          skip_scope(this.scanner);
        }
      }
    }
    return true;
  }

  private void write_parameter_scope() throws IOException {
    out_file.start_scope();
    out_file.write("parameter");
    write_selection_layer_scope();
    write_selectable_item_scope();
    write_via_snap_to_smd_center_scope();
    write_route_mode_scope();
    write_shove_enabled_scope();
    write_drag_components_enabled_scope();
    write_hilight_routing_obstacle_scope();
    write_pull_tight_region_scope();
    write_pull_tight_accuracy_scope();
    write_clearance_compensation_scope();
    write_ignore_conduction_scope();
    write_automatic_layer_dimming_scope();
    write_deselected_snapshot_attributes();
    out_file.end_scope();
  }

  private boolean read_selection_layer_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean select_on_all_layers;
    if (next_token == Keyword.ALL_VISIBLE) {
      select_on_all_layers = true;
    } else if (next_token == Keyword.CURRENT_ONLY) {
      select_on_all_layers = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_selection_layer_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_selection_layer_scop: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_select_on_all_visible_layers(select_on_all_layers);
    return true;
  }

  private boolean read_shove_enabled_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean shove_enabled;
    if (next_token == Keyword.ON) {
      shove_enabled = true;
    } else if (next_token == Keyword.OFF) {
      shove_enabled = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_shove_enabled_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_shove_enabled_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_push_enabled(shove_enabled);
    return true;
  }

  private boolean read_drag_components_enabled_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean drag_components_enabled;
    if (next_token == Keyword.ON) {
      drag_components_enabled = true;
    } else if (next_token == Keyword.OFF) {
      drag_components_enabled = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_drag_components_enabled_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_drag_components_enabled_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_drag_components_enabled(drag_components_enabled);
    return true;
  }

  private boolean read_ignore_conduction_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean ignore_conduction;
    if (next_token == Keyword.ON) {
      ignore_conduction = true;
    } else if (next_token == Keyword.OFF) {
      ignore_conduction = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_ignore_conduction_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_ignore_conduction_scope: closing bracket expected");
      return false;
    }
    this.board_handling.set_ignore_conduction(ignore_conduction);
    return true;
  }

  private void write_shove_enabled_scope() throws IOException {
    out_file.start_scope();
    out_file.write("shove_enabled ");
    out_file.new_line();
    if (this.board_handling.settings.get_push_enabled()) {
      out_file.write("on");
    } else {
      out_file.write("off");
    }
    out_file.end_scope();
  }

  private void write_drag_components_enabled_scope() throws IOException {
    out_file.start_scope();
    out_file.write("drag_components_enabled ");
    out_file.new_line();
    if (this.board_handling.settings.get_drag_components_enabled()) {
      out_file.write("on");
    } else {
      out_file.write("off");
    }
    out_file.end_scope();
  }

  private void write_ignore_conduction_scope() throws IOException {
    out_file.start_scope();
    out_file.write("ignore_conduction_areas ");
    out_file.new_line();
    if (this.board_handling.get_routing_board().rules.get_ignore_conduction()) {
      out_file.write("on");
    } else {
      out_file.write("off");
    }
    out_file.end_scope();
  }

  private void write_selection_layer_scope() throws IOException {
    out_file.start_scope();
    out_file.write("selection_layers ");
    out_file.new_line();
    if (this.board_handling.settings.get_select_on_all_visible_layers()) {
      out_file.write("all_visible");
    } else {
      out_file.write("current_only");
    }
    out_file.end_scope();
  }

  private boolean read_route_mode_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean is_stitch_mode;
    if (next_token == Keyword.STITCHING) {
      is_stitch_mode = true;
    } else if (next_token == Keyword.DYNAMIC) {
      is_stitch_mode = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_route_mode_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_selection_layer_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_stitch_route(is_stitch_mode);
    return true;
  }

  private void write_route_mode_scope() throws IOException {
    out_file.start_scope();
    out_file.write("route_mode ");
    out_file.new_line();
    if (this.board_handling.settings.get_is_stitch_route()) {
      out_file.write("stitching");
    } else {
      out_file.write("dynamic");
    }
    out_file.end_scope();
  }

  private boolean read_pull_tight_region_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    if (!(next_token instanceof Integer)) {
      FRLogger.warn("GUIDefaultsFile.read_pull_tight_region_scope: Integer expected");
      return false;
    }
    int pull_tight_region = (Integer) next_token;
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_pull_tight_region_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_current_pull_tight_region_width(pull_tight_region);
    return true;
  }

  private void write_pull_tight_region_scope() throws IOException {
    out_file.start_scope();
    out_file.write("pull_tight_region ");
    out_file.new_line();
    int pull_tight_region = this.board_handling.settings.get_trace_pull_tight_region_width();
    out_file.write(String.valueOf(pull_tight_region));
    out_file.end_scope();
  }

  private boolean read_pull_tight_accuracy_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    if (!(next_token instanceof Integer)) {
      FRLogger.warn("GUIDefaultsFile.read_pull_tight_accuracy_scope: Integer expected");
      return false;
    }
    int pull_tight_accuracy = (Integer) next_token;
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_pull_tight_accuracy_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_current_pull_tight_accuracy(pull_tight_accuracy);
    return true;
  }

  private void write_pull_tight_accuracy_scope() throws IOException {
    out_file.start_scope();
    out_file.write("pull_tight_accuracy ");
    out_file.new_line();
    int pull_tight_accuracy = this.board_handling.settings.get_trace_pull_tight_accuracy();
    out_file.write(String.valueOf(pull_tight_accuracy));
    out_file.end_scope();
  }

  private boolean read_automatic_layer_dimming_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    double intensity;
    if (next_token instanceof Double) {
      intensity = (Double) next_token;
    } else if (next_token instanceof Integer) {
      intensity = (Integer) next_token;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_automatic_layer_dimming_scope: Integer expected");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_automatic_layer_dimming_scope: closing bracket expected");
      return false;
    }
    this.board_handling.graphics_context.set_auto_layer_dim_factor(intensity);
    return true;
  }

  private void write_automatic_layer_dimming_scope() throws IOException {
    out_file.start_scope();
    out_file.write("automatic_layer_dimming ");
    out_file.new_line();
    float layer_dimming = (float) this.board_handling.graphics_context.get_auto_layer_dim_factor();
    out_file.write(String.valueOf(layer_dimming));
    out_file.end_scope();
  }

  private boolean read_hilight_routing_obstacle_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean hilight_obstacle;
    if (next_token == Keyword.ON) {
      hilight_obstacle = true;
    } else if (next_token == Keyword.OFF) {
      hilight_obstacle = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_hilight_routing_obstacle_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn(
          "GUIDefaultsFile.read_hilight_routing_obstacle_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_hilight_routing_obstacle(hilight_obstacle);
    return true;
  }

  private void write_hilight_routing_obstacle_scope() throws IOException {
    out_file.start_scope();
    out_file.write("hilight_routing_obstacle ");
    out_file.new_line();
    if (this.board_handling.settings.get_hilight_routing_obstacle()) {
      out_file.write("on");
    } else {
      out_file.write("off");
    }
    out_file.end_scope();
  }

  private boolean read_clearance_compensation_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean clearance_compensation;
    if (next_token == Keyword.ON) {
      clearance_compensation = true;
    } else if (next_token == Keyword.OFF) {
      clearance_compensation = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_clearance_compensation_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_clearance_compensation_scope: closing bracket expected");
      return false;
    }
    this.board_handling.set_clearance_compensation(clearance_compensation);
    return true;
  }

  private void write_clearance_compensation_scope() throws IOException {
    out_file.start_scope();
    out_file.write("clearance_compensation ");
    out_file.new_line();
    if (this.board_handling
        .get_routing_board()
        .search_tree_manager
        .is_clearance_compensation_used()) {
      out_file.write("on");
    } else {
      out_file.write("off");
    }
    out_file.end_scope();
  }

  private boolean read_via_snap_to_smd_center_scope() throws IOException {
    Object next_token = this.scanner.next_token();
    boolean snap;
    if (next_token == Keyword.ON) {
      snap = true;
    } else if (next_token == Keyword.OFF) {
      snap = false;
    } else {
      FRLogger.warn("GUIDefaultsFile.read_via_snap_to_smd_center_scope: unexpected token");
      return false;
    }
    next_token = this.scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("GUIDefaultsFile.read_via_snap_to_smd_center_scope: closing bracket expected");
      return false;
    }
    this.board_handling.settings.set_via_snap_to_smd_center(snap);
    return true;
  }

  private void write_via_snap_to_smd_center_scope() throws IOException {
    out_file.start_scope();
    out_file.write("via_snap_to_smd_center ");
    out_file.new_line();
    if (this.board_handling.settings.get_via_snap_to_smd_center()) {
      out_file.write("on");
    } else {
      out_file.write("off");
    }
    out_file.end_scope();
  }

  private boolean read_selectable_item_scope() throws IOException {
    ItemSelectionFilter item_selection_filter =
        this.board_handling.settings.get_item_selection_filter();
    item_selection_filter.deselect_all();
    for (; ; ) {
      Object next_token = this.scanner.next_token();
      if (next_token == Keyword.CLOSED_BRACKET) {
        break;
      }
      if (next_token == Keyword.TRACES) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.TRACES, true);
      } else if (next_token == Keyword.VIAS) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.VIAS, true);
      } else if (next_token == Keyword.PINS) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.PINS, true);
      } else if (next_token == Keyword.CONDUCTION) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.CONDUCTION, true);
      } else if (next_token == Keyword.KEEPOUT) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.KEEPOUT, true);
      } else if (next_token == Keyword.VIA_KEEPOUT) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.VIA_KEEPOUT, true);
      } else if (next_token == Keyword.FIXED) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.FIXED, true);
      } else if (next_token == Keyword.UNFIXED) {
        item_selection_filter.set_selected(ItemSelectionFilter.SelectableChoices.UNFIXED, true);
      } else {
        FRLogger.warn("GUIDefaultsFile.read_selectable_item_scope: unexpected token");
        return false;
      }
    }
    return true;
  }

  private void write_selectable_item_scope() throws IOException {
    out_file.start_scope();
    out_file.write("selectable_items ");
    out_file.new_line();
    ItemSelectionFilter item_selection_filter =
        this.board_handling.settings.get_item_selection_filter();
    ItemSelectionFilter.SelectableChoices[] selectable_choices =
        ItemSelectionFilter.SelectableChoices.values();
    for (int i = 0; i < selectable_choices.length; ++i) {
      if (item_selection_filter.is_selected(selectable_choices[i])) {
        out_file.write(selectable_choices[i].toString());
        out_file.write(" ");
      }
    }
    out_file.end_scope();
  }

  private void write_deselected_snapshot_attributes() throws IOException {
    SnapShot.Attributes attributes =
        this.board_handling.settings.get_snapshot_attributes();
    out_file.start_scope();
    out_file.write("deselected_snapshot_attributes ");
    if (!attributes.object_colors) {
      out_file.new_line();
      out_file.write("object_colors ");
    }
    if (!attributes.object_visibility) {
      out_file.new_line();
      out_file.write("object_visibility ");
    }
    if (!attributes.layer_visibility) {
      out_file.new_line();
      out_file.write("layer_visibility ");
    }
    if (!attributes.display_region) {
      out_file.new_line();
      out_file.write("display_region ");
    }
    if (!attributes.interactive_state) {
      out_file.new_line();
      out_file.write("interactive_state ");
    }
    if (!attributes.selection_layers) {
      out_file.new_line();
      out_file.write("selection_layers ");
    }
    if (!attributes.selectable_items) {
      out_file.new_line();
      out_file.write("selectable_items ");
    }
    if (!attributes.current_layer) {
      out_file.new_line();
      out_file.write("current_layer ");
    }
    if (!attributes.rule_selection) {
      out_file.new_line();
      out_file.write("rule_selection ");
    }
    if (!attributes.manual_rule_settings) {
      out_file.new_line();
      out_file.write("manual_rule_settings ");
    }
    if (!attributes.push_and_shove_enabled) {
      out_file.new_line();
      out_file.write("push_and_shove_enabled ");
    }
    if (!attributes.drag_components_enabled) {
      out_file.new_line();
      out_file.write("drag_components_enabled ");
    }
    if (!attributes.pull_tight_region) {
      out_file.new_line();
      out_file.write("pull_tight_region ");
    }
    if (!attributes.component_grid) {
      out_file.new_line();
      out_file.write("component_grid ");
    }
    out_file.end_scope();
  }

  private boolean read_deselected_snapshot_attributes() throws IOException {
    SnapShot.Attributes attributes =
        this.board_handling.settings.get_snapshot_attributes();
    for (; ; ) {
      Object next_token = this.scanner.next_token();
      if (next_token == Keyword.CLOSED_BRACKET) {
        break;
      }
      if (next_token == Keyword.OBJECT_COLORS) {
        attributes.object_colors = false;
      } else if (next_token == Keyword.OBJECT_VISIBILITY) {
        attributes.object_visibility = false;
      } else if (next_token == Keyword.LAYER_VISIBILITY) {
        attributes.layer_visibility = false;
      } else if (next_token == Keyword.DISPLAY_REGION) {
        attributes.display_region = false;
      } else if (next_token == Keyword.INTERACTIVE_STATE) {
        attributes.interactive_state = false;
      } else if (next_token == Keyword.SELECTION_LAYERS) {
        attributes.selection_layers = false;
      } else if (next_token == Keyword.SELECTABLE_ITEMS) {
        attributes.selectable_items = false;
      } else if (next_token == Keyword.CURRENT_LAYER) {
        attributes.current_layer = false;
      } else if (next_token == Keyword.RULE_SELECTION) {
        attributes.rule_selection = false;
      } else if (next_token == Keyword.MANUAL_RULE_SETTINGS) {
        attributes.manual_rule_settings = false;
      } else if (next_token == Keyword.PUSH_AND_SHOVE_ENABLED) {
        attributes.push_and_shove_enabled = false;
      } else if (next_token == Keyword.DRAG_COMPONENTS_ENABLED) {
        attributes.drag_components_enabled = false;
      } else if (next_token == Keyword.PULL_TIGHT_REGION) {
        attributes.pull_tight_region = false;
      } else if (next_token == Keyword.COMPONENT_GRID) {
        attributes.component_grid = false;
      } else {
        FRLogger.warn("GUIDefaultsFile.read_deselected_snapshot_attributes: unexpected token");
        return false;
      }
    }
    return true;
  }
  /** Keywords in the gui defaults file. */
  enum Keyword {
    ALL_VISIBLE,
    ASSIGN_NET_RULES,
    AUTOMATIC_LAYER_DIMMING,
    BACKGROUND,
    BOARD_FRAME,
    BOUNDS,
    CLEARANCE_COMPENSATION,
    CLEARANCE_MATRIX,
    CLOSED_BRACKET,
    COLOR_MANAGER,
    COLORS,
    COMPONENT_BACK,
    COMPONENT_FRONT,
    COMPONENT_GRID,
    COMPONENT_INFO,
    CONDUCTION,
    CURRENT_LAYER,
    CURRENT_ONLY,
    DESELECTED_SNAPSHOT_ATTRIBUTES,
    DISPLAY_MISCELLANEOUS,
    DISPLAY_REGION,
    DRAG_COMPONENTS_ENABLED,
    DYNAMIC,
    EDIT_VIAS,
    EDIT_NET_RULES,
    FIXED,
    FIXED_TRACES,
    FIXED_VIAS,
    FORTYFIVE_DEGREE,
    GUI_DEFAULTS,
    HILIGHT,
    HILIGHT_ROUTING_OBSTACLE,
    IGNORE_CONDUCTION_AREAS,
    INCOMPLETES,
    INCOMPLETES_INFO,
    INTERACTIVE_STATE,
    KEEPOUT,
    LAYER_VISIBILITY,
    LENGTH_MATCHING,
    MANUAL_RULES,
    MANUAL_RULE_SETTINGS,
    MOVE_PARAMETER,
    NET_INFO,
    NINETY_DEGREE,
    NONE,
    NOT_VISIBLE,
    OBJECT_COLORS,
    OBJECT_VISIBILITY,
    OPEN_BRACKET,
    OFF,
    ON,
    OUTLINE,
    PARAMETER,
    PACKAGE_INFO,
    PADSTACK_INFO,
    PINS,
    PULL_TIGHT_ACCURACY,
    PULL_TIGHT_REGION,
    PUSH_AND_SHOVE_ENABLED,
    ROUTE_DETAILS,
    ROUTE_MODE,
    ROUTE_PARAMETER,
    RULE_SELECTION,
    SELECT_PARAMETER,
    SELECTABLE_ITEMS,
    SELECTION_LAYERS,
    SNAPSHOTS,
    SHOVE_ENABLED,
    STITCHING,
    TRACES,
    UNFIXED,
    VIA_KEEPOUT,
    VISIBLE,
    VIA_RULES,
    VIA_SNAP_TO_SMD_CENTER,
    VIAS,
    VIOLATIONS,
    VIOLATIONS_INFO,
    WINDOWS
  }
}
