package app.freerouting.designforms.specctra;

import app.freerouting.board.Item;
import app.freerouting.library.Padstack;
import app.freerouting.logger.FRLogger;

import java.io.IOException;
import java.util.Collection;
import java.util.Iterator;
import java.util.LinkedList;

/** Class for reading and writing package scopes from dsn-files. */
public class Package {

  public final String name;
  /** List of objects of type PinInfo. */
  public final PinInfo[] pin_info_arr;
  /** The outline of the package. */
  public final Collection<Shape> outline;
  /** Collection of keepoouts belonging to this package */
  public final Collection<Shape.ReadAreaScopeResult> keepouts;
  /** Collection of via keepoouts belonging to this package */
  public final Collection<Shape.ReadAreaScopeResult> via_keepouts;
  /** Collection of place keepoouts belonging to this package */
  public final Collection<Shape.ReadAreaScopeResult> place_keepouts;
  /** If false, the package is placed on the back side of the board */
  public final boolean is_front;

  /** Creates a new instance of Package */
  public Package(
      String p_name,
      PinInfo[] p_pin_info_arr,
      Collection<Shape> p_outline,
      Collection<Shape.ReadAreaScopeResult> p_keepouts,
      Collection<Shape.ReadAreaScopeResult> p_via_keepouts,
      Collection<Shape.ReadAreaScopeResult> p_place_keepouts,
      boolean p_is_front) {
    name = p_name;
    pin_info_arr = p_pin_info_arr;
    outline = p_outline;
    keepouts = p_keepouts;
    via_keepouts = p_via_keepouts;
    place_keepouts = p_place_keepouts;
    is_front = p_is_front;
  }

  public static Package read_scope(IJFlexScanner p_scanner, LayerStructure p_layer_structure) {
    try {
      boolean is_front = true;
      Collection<Shape> outline = new LinkedList<>();
      Collection<Shape.ReadAreaScopeResult> keepouts = new LinkedList<>();
      Collection<Shape.ReadAreaScopeResult> via_keepouts =
          new LinkedList<>();
      Collection<Shape.ReadAreaScopeResult> place_keepouts =
          new LinkedList<>();
      Object next_token = p_scanner.next_token();
      if (!(next_token instanceof String)) {
        FRLogger.warn("Package.read_scope: String expected at '" + p_scanner.get_scope_identifier() + "'");
        return null;
      }
      String package_name = (String) next_token;
      p_scanner.set_scope_identifier(package_name);
      Collection<PinInfo> pin_info_list = new LinkedList<>();
      for (; ; ) {
        Object prev_token = next_token;
        next_token = p_scanner.next_token();

        if (next_token == null) {
          FRLogger.warn("Package.read_scope: unexpected end of file at '" + p_scanner.get_scope_identifier() + "'");
          return null;
        }
        if (next_token == Keyword.CLOSED_BRACKET) {
          // end of scope
          break;
        }
        if (prev_token == Keyword.OPEN_BRACKET) {
          if (next_token == Keyword.PIN) {
            PinInfo next_pin = read_pin_info(p_scanner);
            if (next_pin == null) {
              return null;
            }
            pin_info_list.add(next_pin);
          } else if (next_token == Keyword.SIDE) {
            is_front = read_placement_side(p_scanner);
          } else if (next_token == Keyword.OUTLINE) {
            Shape curr_shape = Shape.read_scope(p_scanner, p_layer_structure);
            if (curr_shape != null) {
              outline.add(curr_shape);
            }
            // overread closing bracket
            next_token = p_scanner.next_token();
            if (next_token != Keyword.CLOSED_BRACKET) {
              FRLogger.warn("Package.read_scope: closed bracket expected at '" + p_scanner.get_scope_identifier() + "'");
              return null;
            }
          } else if (next_token == Keyword.KEEPOUT) {
            Shape.ReadAreaScopeResult keepout_area =
                Shape.read_area_scope(p_scanner, p_layer_structure, false);
            if (keepout_area != null) {
              keepouts.add(keepout_area);
            } else {
              FRLogger.error("Package.read_scope: could not read keepout area of package '"+package_name+"'", null);
            }
          } else if (next_token == Keyword.VIA_KEEPOUT) {
            Shape.ReadAreaScopeResult keepout_area =
                Shape.read_area_scope(p_scanner, p_layer_structure, false);
            if (keepout_area != null) {
              via_keepouts.add(keepout_area);
            }
          } else if (next_token == Keyword.PLACE_KEEPOUT) {
            Shape.ReadAreaScopeResult keepout_area =
                Shape.read_area_scope(p_scanner, p_layer_structure, false);
            if (keepout_area != null) {
              place_keepouts.add(keepout_area);
            }
          } else {
            ScopeKeyword.skip_scope(p_scanner);
          }
        }
      }
      PinInfo[] pin_info_arr = new PinInfo[pin_info_list.size()];
      Iterator<PinInfo> it = pin_info_list.iterator();
      for (int i = 0; i < pin_info_arr.length; ++i) {
        pin_info_arr[i] = it.next();
      }
      return new Package(
          package_name, pin_info_arr, outline, keepouts, via_keepouts, place_keepouts, is_front);
    } catch (IOException e) {
      FRLogger.error("Package.read_scope: IO error scanning file", e);
      return null;
    }
  }

  public static void write_scope(
      WriteScopeParameter p_par, app.freerouting.library.Package p_package)
      throws IOException {
    p_par.file.start_scope();
    p_par.file.write("image ");
    p_par.identifier_type.write(p_package.name, p_par.file);
    // write the placement side of the package
    p_par.file.new_line();
    p_par.file.write("(side ");
    if (p_package.is_front) {
      p_par.file.write("front)");
    } else {
      p_par.file.write("back)");
    }
    // write the pins of the package
    for (int i = 0; i < p_package.pin_count(); ++i) {
      app.freerouting.library.Package.Pin curr_pin = p_package.get_pin(i);
      p_par.file.new_line();
      p_par.file.write("(pin ");
      Padstack curr_padstack =
          p_par.board.library.padstacks.get(curr_pin.padstack_no);
      p_par.identifier_type.write(curr_padstack.name, p_par.file);
      p_par.file.write(" ");
      p_par.identifier_type.write(curr_pin.name, p_par.file);
      double[] rel_coor = p_par.coordinate_transform.board_to_dsn(curr_pin.relative_location);
      for (int j = 0; j < rel_coor.length; ++j) {
        p_par.file.write(" ");
        p_par.file.write(String.valueOf(rel_coor[j]));
      }
      int rotation = (int) Math.round(curr_pin.rotation_in_degree);
      if (rotation != 0) {
        p_par.file.write("(rotate ");
        p_par.file.write(String.valueOf(rotation));
        p_par.file.write(")");
      }
      p_par.file.write(")");
    }
    // write the keepouts belonging to  the package.
    for (int i = 0; i < p_package.keepout_arr.length; ++i) {
      write_package_keepout(p_package.keepout_arr[i], p_par, false);
    }
    for (int i = 0; i < p_package.via_keepout_arr.length; ++i) {
      write_package_keepout(p_package.via_keepout_arr[i], p_par, true);
    }
    // write the package outline.
    for (int i = 0; i < p_package.outline.length; ++i) {
      p_par.file.start_scope();
      p_par.file.write("outline");
      Shape curr_outline =
          p_par.coordinate_transform.board_to_dsn_rel(p_package.outline[i], Layer.SIGNAL);
      curr_outline.write_scope(p_par.file, p_par.identifier_type);
      p_par.file.end_scope();
    }
    p_par.file.end_scope();
  }

  private static void write_package_keepout(
      app.freerouting.library.Package.Keepout p_keepout,
      WriteScopeParameter p_par,
      boolean p_is_via_keepout)
      throws IOException {
    Layer keepout_layer;
    if (p_keepout.layer >= 0) {
      app.freerouting.board.Layer board_layer = p_par.board.layer_structure.arr[p_keepout.layer];
      keepout_layer = new Layer(board_layer.name, p_keepout.layer, board_layer.is_signal);
    } else {
      keepout_layer = Layer.SIGNAL;
    }
    app.freerouting.geometry.planar.Shape boundary_shape;
    app.freerouting.geometry.planar.Shape[] holes;
    if (p_keepout.area instanceof app.freerouting.geometry.planar.Shape) {
      boundary_shape = (app.freerouting.geometry.planar.Shape) p_keepout.area;
      holes = new app.freerouting.geometry.planar.Shape[0];
    } else {
      boundary_shape = p_keepout.area.get_border();
      holes = p_keepout.area.get_holes();
    }
    p_par.file.start_scope();
    if (p_is_via_keepout) {
      p_par.file.write("via_keepout");
    } else {
      p_par.file.write("keepout");
    }
    Shape dsn_shape = p_par.coordinate_transform.board_to_dsn(boundary_shape, keepout_layer);
    if (dsn_shape != null) {
      dsn_shape.write_scope(p_par.file, p_par.identifier_type);
    }
    for (int j = 0; j < holes.length; ++j) {
      Shape dsn_hole = p_par.coordinate_transform.board_to_dsn(holes[j], keepout_layer);
      dsn_hole.write_hole_scope(p_par.file, p_par.identifier_type);
    }
    p_par.file.end_scope();
  }

  /** Reads the information of a single pin in a package. */
  private static PinInfo read_pin_info(IJFlexScanner p_scanner) {
    try {
      // Read the padstack name.
      p_scanner.yybegin(SpecctraDsnFileReader.NAME);
      Object next_token = p_scanner.next_token();
      if (!(next_token instanceof String) && !(next_token instanceof Integer)) {
        FRLogger.warn("Package.read_pin_info: String or Integer expected at '" + p_scanner.get_scope_identifier() + "'");
        return null;
      }
      String padstack_name = next_token.toString();
      double rotation = 0;

      p_scanner.yybegin(
          SpecctraDsnFileReader.NAME); // to be able to handle pin names starting with a digit.
      next_token = p_scanner.next_token();
      if (next_token == Keyword.OPEN_BRACKET) {
        // read the padstack rotation
        next_token = p_scanner.next_token();
        if (next_token == Keyword.ROTATE) {
          rotation = read_rotation(p_scanner);
        } else {
          ScopeKeyword.skip_scope(p_scanner);
        }
        p_scanner.yybegin(SpecctraDsnFileReader.NAME);
        next_token = p_scanner.next_token();
      }
      // Read the pin name.
      if (!(next_token instanceof String) && !(next_token instanceof Integer)) {
        FRLogger.warn("Package.read_pin_info: String or Integer expected at '" + p_scanner.get_scope_identifier() + "'");
        return null;
      }
      String pin_name = next_token.toString();

      double[] pin_coor = new double[2];
      for (int i = 0; i < 2; ++i) {
        next_token = p_scanner.next_token();
        if (next_token instanceof Double) {
          pin_coor[i] = (Double) next_token;
        } else if (next_token instanceof Integer) {
          pin_coor[i] = (Integer) next_token;
        } else {
          FRLogger.warn("Package.read_pin_info: number expected at '" + p_scanner.get_scope_identifier() + "'");
          return null;
        }
      }
      // Handle scopes at the end of the pin scope.
      for (; ; ) {
        Object prev_token = next_token;
        next_token = p_scanner.next_token();

        if (next_token == null) {
          FRLogger.warn("Package.read_pin_info: unexpected end of file at '" + p_scanner.get_scope_identifier() + "'");
          return null;
        }
        if (next_token == Keyword.CLOSED_BRACKET) {
          // end of scope
          break;
        }
        if (prev_token == Keyword.OPEN_BRACKET) {
          if (next_token == Keyword.ROTATE) {
            rotation = read_rotation(p_scanner);
          } else {
            ScopeKeyword.skip_scope(p_scanner);
          }
        }
      }
      return new PinInfo(padstack_name, pin_name, pin_coor, rotation);
    } catch (IOException e) {
      FRLogger.error("Package.read_pin_info: IO error while scanning file", e);
      return null;
    }
  }

  private static double read_rotation(IJFlexScanner p_scanner) {
    double result = 0;

    try {
      String next_string = p_scanner.next_string();
      result = Double.parseDouble(next_string);

      // Overread The closing bracket.
      Object next_token = p_scanner.next_token();
      if (next_token != Keyword.CLOSED_BRACKET) {
        FRLogger.warn("Package.read_rotation: closing bracket expected at '" + p_scanner.get_scope_identifier() + "'");
      }
    } catch (IOException e) {
      FRLogger.error("Package.read_rotation: IO error while scanning file", e);
    }

    return result;
  }

  /** Writes the placements of p_package to a Specctra dsn-file. */
  public static void write_placement_scope(
      WriteScopeParameter p_par, app.freerouting.library.Package p_package)
      throws IOException {
    Collection<Item> board_items = p_par.board.get_items();
    boolean component_found = false;
    for (int i = 1; i <= p_par.board.components.count(); ++i) {
      app.freerouting.board.Component curr_component = p_par.board.components.get(i);
      if (curr_component.get_package() == p_package) {
        // check, if not all items of the component are deleted
        boolean undeleted_item_found = false;
        for (Item curr_item : board_items) {
          if (curr_item.get_component_no() == curr_component.no) {
            undeleted_item_found = true;
            break;
          }
        }
        if (undeleted_item_found || !curr_component.is_placed()) {
          if (!component_found) {
            // write the scope header
            p_par.file.start_scope();
            p_par.file.write("component ");
            p_par.identifier_type.write(p_package.name, p_par.file);
            component_found = true;
          }
          Component.write_scope(p_par, curr_component);
        }
      }
    }
    if (component_found) {
      p_par.file.end_scope();
    }
  }

  private static boolean read_placement_side(IJFlexScanner p_scanner) throws IOException {
    Object next_token = p_scanner.next_token();
    boolean result = (next_token != Keyword.BACK);

    next_token = p_scanner.next_token();
    if (next_token != Keyword.CLOSED_BRACKET) {
      FRLogger.warn("Package.read_placement_side: closing bracket expected at '" + p_scanner.get_scope_identifier() + "'");
    }
    return result;
  }

  /** Describes the Iinformation of a pin in a package. */
  public static class PinInfo {
    /** Phe name of the pastack of this pin. */
    public final String padstack_name;
    /** Phe name of this pin. */
    public final String pin_name;
    /** The x- and y-coordinates relative to the package location. */
    public final double[] rel_coor;
    /** The rotation of the pin relative to the package. */
    public final double rotation;
    PinInfo(String p_padstack_name, String p_pin_name, double[] p_rel_coor, double p_rotation) {
      padstack_name = p_padstack_name;
      pin_name = p_pin_name;
      rel_coor = p_rel_coor;
      rotation = p_rotation;
    }
  }
}
