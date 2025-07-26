package app.freerouting.board;

import app.freerouting.geometry.planar.FloatPoint;
import app.freerouting.geometry.planar.Shape;

import java.util.Collection;
import java.util.Locale;

/** Output window for printing information about board objects. */
public interface ObjectInfoPanel {
  /** Appends p_string to the window. Returns false, if that was not possible. */
  boolean append(String p_string);

  /** Appends p_string in bold style to the window. Returns false, if that was not possible. */
  boolean append_bold(String p_string);

  /**
   * Appends p_value to the window after transforming it to the user coordinate system. Returns
   * false, if that was not possible.
   */
  boolean append(double p_value);

  /**
   * Appends p_value to the window without transforming it to the user coordinate system. Returns
   * false, if that was not possible.
   */
  boolean append_without_transforming(double p_value);

  /**
   * Appends p_point to the window after transforming to the user coordinate system. Returns false,
   * if that was not possible.
   */
  boolean append(FloatPoint p_point);

  /**
   * Appends p_shape to the window after transforming to the user coordinate system. Returns false,
   * if that was not possible.
   */
  boolean append(Shape p_shape, Locale p_locale);

  /** Begins a new line in the window. */
  boolean newline();

  /** Appends a fixed number of spaces to the window. */
  boolean indent();

  /**
   * Appends a link for creating a new PrintInfoWindow with the information of p_object to the
   * window. Returns false, if that was not possible.
   */
  boolean append(String p_link_name, String p_window_title, ObjectInfoPanel.Printable p_object);

  /**
   * Appends a link for creating a new PrintInfoWindow with the information of p_items to the
   * window. Returns false, if that was not possible.
   */
  boolean append_items(
      String p_link_name,
      String p_window_title,
      Collection<Item> p_items);

  /**
   * Appends a link for creating a new PrintInfoWindow with the information of p_objects to the
   * window. Returns false, if that was not possible.
   */
  boolean append_objects(
      String p_button_name, String p_window_title, Collection<Printable> p_objects);

  /** Functionality needed for objects to print information into an ObjectInfoWindow */
  interface Printable {
    /** Prints information about an ObjectInfoWindow.Printable object into the input window. */
    void print_info(ObjectInfoPanel p_window, Locale p_locale);
  }
}
