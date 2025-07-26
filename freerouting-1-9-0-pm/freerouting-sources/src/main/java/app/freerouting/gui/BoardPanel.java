package app.freerouting.gui;

import app.freerouting.geometry.planar.FloatPoint;
import app.freerouting.interactive.ActivityReplayFileScope;
import app.freerouting.interactive.BoardHandling;
import app.freerouting.interactive.ScreenMessages;
import app.freerouting.logger.FRLogger;

import java.awt.AWTException;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Robot;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;
import java.awt.geom.Point2D;
import java.util.Locale;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.JViewport;
import javax.swing.event.TableModelEvent;
import javax.swing.event.TableModelListener;

/** Panel containing the graphical representation of a routing board. */
public class BoardPanel extends JPanel {

  private static final double c_zoom_factor = 2.0;
  public final ScreenMessages screen_messages;
  public final BoardFrame board_frame;
  private final JScrollPane scroll_pane;
  public JPopupMenu popup_menu_insert_cancel;
  public PopupMenuCopy popup_menu_copy;
  public PopupMenuMove popup_menu_move;
  public JPopupMenu popup_menu_corneritem_construction;
  public JPopupMenu popup_menu_main;
  public PopupMenuDynamicRoute popup_menu_dynamic_route;
  public PopupMenuStitchRoute popup_menu_stitch_route;
  public JPopupMenu popup_menu_select;
  BoardHandling board_handling;
  Point2D right_button_click_location;
  private Robot robot;
  private Point middle_drag_position;
  /**
   * Defines the appearance of the custom custom_cursor in the board panel. Null, if the standard
   * custom_cursor is used.
   */
  private Cursor custom_cursor;

  /** Creates a new BoardPanel in an Application */
  public BoardPanel(
      ScreenMessages p_screen_messages,
      BoardFrame p_board_frame,
      Locale p_locale,
      boolean p_save_intermediate_stages,
      float p_optimization_improvement_threshold) {
    screen_messages = p_screen_messages;
    try {
      // used to be able to change the location of the mouse pointer
      robot = new Robot();
    } catch (AWTException e) {
      FRLogger.warn("unable to create robot");
    }
    board_frame = p_board_frame;
    this.scroll_pane = board_frame.scroll_pane;
    default_init(p_locale, p_save_intermediate_stages, p_optimization_improvement_threshold);
  }

  private void default_init(
      Locale p_locale,
      boolean p_save_intermediate_stages,
      float p_optimization_improvement_threshold) {
    setLayout(new BorderLayout());

    setBackground(new Color(0, 0, 0));
    setMaximumSize(new Dimension(30000, 20000));
    setMinimumSize(new Dimension(90, 60));
    setPreferredSize(new Dimension(1200, 900));
    addMouseMotionListener(
        new MouseMotionAdapter() {
          @Override
          public void mouseDragged(MouseEvent evt) {
            mouse_dragged_action(evt);
          }

          @Override
          public void mouseMoved(MouseEvent evt) {
            mouse_moved_action(evt);
          }
        });
    addKeyListener(
        new KeyAdapter() {
          @Override
          public void keyTyped(KeyEvent evt) {
            board_handling.key_typed_action(evt.getKeyChar());
          }
        });
    addMouseListener(
        new MouseAdapter() {
          @Override
          public void mouseClicked(MouseEvent evt) {
            mouse_clicked_action(evt);
          }

          @Override
          public void mousePressed(MouseEvent evt) {
            mouse_pressed_action(evt);
          }

          @Override
          public void mouseReleased(MouseEvent evt) {
            board_handling.button_released();
            middle_drag_position = null;
          }
        });
    addMouseWheelListener(
        evt -> board_handling.mouse_wheel_moved(evt.getWheelRotation()));
    board_handling =
        new BoardHandling(
            this, p_locale, p_save_intermediate_stages, p_optimization_improvement_threshold);
    setAutoscrolls(true);
    this.setCursor(new java.awt.Cursor(java.awt.Cursor.CROSSHAIR_CURSOR));
  }

  void create_popup_menus() {
    popup_menu_main = new PopupMenuMain(this.board_frame);
    popup_menu_dynamic_route = new PopupMenuDynamicRoute(this.board_frame);
    popup_menu_stitch_route = new PopupMenuStitchRoute(this.board_frame);
    popup_menu_corneritem_construction = new PopupMenuCornerItemConstruction(this.board_frame);
    popup_menu_select = new PopupMenuSelectedItems(this.board_frame);
    popup_menu_insert_cancel = new PopupMenuInsertCancel(this.board_frame);
    popup_menu_copy = new PopupMenuCopy(this.board_frame);
    popup_menu_move = new PopupMenuMove(this.board_frame);
  }

  public void zoom_with_mouse_wheel(Point2D p_point, int p_wheel_rotation) {
    if (this.middle_drag_position != null || p_wheel_rotation == 0) {
      return; // scrolling with the middle mouse button in progress
    }
    double zoom_factor = 1 - 0.1 * p_wheel_rotation;
    zoom_factor = Math.max(zoom_factor, 0.5);
    zoom(zoom_factor, p_point);
  }

  private void mouse_pressed_action(MouseEvent evt) {
    if (evt.getButton() == 1) {
      board_handling.mouse_pressed(evt.getPoint());
    } else if (evt.getButton() == 2 && middle_drag_position == null) {
      middle_drag_position = new Point(evt.getPoint());
    }
  }

  private void mouse_dragged_action(MouseEvent evt) {
    if (middle_drag_position != null) {
      scroll_middle_mouse(evt);
    } else {
      board_handling.mouse_dragged(evt.getPoint());
      scroll_near_border(evt);
    }
  }

  private void mouse_moved_action(MouseEvent p_evt) {
    this.requestFocusInWindow(); // to enable keyboard aliases
    if (board_handling != null) {
      board_handling.mouse_moved(p_evt.getPoint());
    }
    if (this.custom_cursor != null) {
      this.custom_cursor.set_location(p_evt.getPoint());
      this.repaint();
    }
  }

  private void mouse_clicked_action(MouseEvent evt) {
    if (evt.getButton() == 1) {
      board_handling.left_button_clicked(evt.getPoint());
    } else if (evt.getButton() == 3) {
      JPopupMenu curr_menu = board_handling.get_current_popup_menu();
      if (curr_menu != null) {
        int curr_x = evt.getX();
        int curr_y = evt.getY();
        if (curr_menu == popup_menu_dynamic_route && false) {
          int dx = curr_menu.getWidth();
          if (dx <= 0) {
            // force the width to be calculated
            curr_menu.show(this, curr_x, curr_y);
            dx = curr_menu.getWidth();
          }
          curr_x -= dx;
        }
        curr_menu.show(this, curr_x, curr_y);
      }
      right_button_click_location = evt.getPoint();
    }
  }

  /** overwrites the paintComponent method to draw the routing board */
  @Override
  public void paintComponent(Graphics p_g) {
    super.paintComponent(p_g);
    if (board_handling != null) {
      board_handling.draw(p_g);
    }
    if (this.custom_cursor != null) {
      this.custom_cursor.draw(p_g);
    }
  }

  /** Returns the position of the viewport */
  public Point get_viewport_position() {
    JViewport viewport = scroll_pane.getViewport();
    return viewport.getViewPosition();
  }

  /** Sets the position of the viewport */
  void set_viewport_position(Point p_position) {
    JViewport viewport = scroll_pane.getViewport();
    viewport.setViewPosition(p_position);
  }

  /** zooms in at p_position */
  public void zoom_in(Point2D p_position) {
    zoom(c_zoom_factor, p_position);
  }

  /** zooms out at p_position */
  public void zoom_out(Point2D p_position) {
    double zoom_factor = 1 / c_zoom_factor;
    zoom(zoom_factor, p_position);
  }

  /** zooms to frame */
  public void zoom_frame(Point2D p_position1, Point2D p_position2) {
    double width_of_zoom_frame = Math.abs(p_position1.getX() - p_position2.getX());
    double height_of_zoom_frame = Math.abs(p_position1.getY() - p_position2.getY());

    double center_x = Math.min(p_position1.getX(), p_position2.getX()) + (width_of_zoom_frame / 2);
    double center_y = Math.min(p_position1.getY(), p_position2.getY()) + (height_of_zoom_frame / 2);

    Point2D center_point = new Point2D.Double(center_x, center_y);

    Rectangle display_rect = get_viewport_bounds();

    double width_factor = display_rect.getWidth() / width_of_zoom_frame;
    double height_factor = display_rect.getHeight() / height_of_zoom_frame;

    Point2D changed_location =
        zoom(Math.min(width_factor, height_factor), center_point);
    set_viewport_center(changed_location);
  }

  public void center_display(Point2D p_new_center) {
    Point delta = set_viewport_center(p_new_center);
    Point2D new_center = get_viewport_center();
    Point new_mouse_location =
        new Point(
            (int) (new_center.getX() - delta.getX()), (int) (new_center.getY() - delta.getY()));
    move_mouse(new_mouse_location);
    repaint();
    this.board_handling.activityReplayFile.start_scope(ActivityReplayFileScope.CENTER_DISPLAY);
    FloatPoint curr_corner =
        new FloatPoint(p_new_center.getX(), p_new_center.getY());
    this.board_handling.activityReplayFile.add_corner(curr_corner);
  }

  public Point2D get_viewport_center() {
    Point pos = get_viewport_position();
    Rectangle display_rect = get_viewport_bounds();
    return new Point2D.Double(
        pos.getX() + display_rect.getCenterX(), pos.getY() + display_rect.getCenterY());
  }

  /** zooms the content of the board by p_factor Returns the change of the cursor location */
  public Point2D zoom(double p_factor, Point2D p_location) {
    final int max_panel_size = 10000000;
    Dimension old_size = this.getSize();
    Point2D old_center = get_viewport_center();

    if (p_factor > 1 && Math.max(old_size.getWidth(), old_size.getHeight()) >= max_panel_size) {
      return p_location; // to prevent an sun.dc.pr.PRException, which I do not know, how to handle;
                         // maybe a bug in Java.
    }
    int new_width = (int) Math.round(p_factor * old_size.getWidth());
    int new_height = (int) Math.round(p_factor * old_size.getHeight());
    Dimension new_size = new Dimension(new_width, new_height);
    board_handling.graphics_context.change_panel_size(new_size);
    setPreferredSize(new_size);
    setSize(new_size);
    revalidate();

    Point2D new_cursor =
        new Point2D.Double(
            p_location.getX() * p_factor, p_location.getY() * p_factor);
    double dx = new_cursor.getX() - p_location.getX();
    double dy = new_cursor.getY() - p_location.getY();
    Point2D new_center =
        new Point2D.Double(old_center.getX() + dx, old_center.getY() + dy);
    Point2D adjustment_vector = set_viewport_center(new_center);
    repaint();
    Point2D adjusted_new_cursor =
        new Point2D.Double(
            new_cursor.getX() + adjustment_vector.getX() + 0.5,
            new_cursor.getY() + adjustment_vector.getY() + 0.5);
    return adjusted_new_cursor;
  }

  /** Returns the viewport bounds of the scroll pane */
  Rectangle get_viewport_bounds() {
    return scroll_pane.getViewportBorderBounds();
  }

  /**
   * Sets the viewport center to p_point. Adjust the result, if p_point is near the border of the
   * viewport. Returns the adjustment vector
   */
  Point set_viewport_center(Point2D p_point) {
    Rectangle display_rect = get_viewport_bounds();
    double x_corner = p_point.getX() - display_rect.getWidth() / 2;
    double y_corner = p_point.getY() - display_rect.getHeight() / 2;
    Dimension panel_size = getSize();
    double adjusted_x_corner = Math.min(x_corner, panel_size.getWidth());
    adjusted_x_corner = Math.max(x_corner, 0);
    double adjusted_y_corner = Math.min(y_corner, panel_size.getHeight());
    adjusted_y_corner = Math.max(y_corner, 0);
    Point new_position =
        new Point((int) adjusted_x_corner, (int) adjusted_y_corner);
    set_viewport_position(new_position);
    Point adjustment_vector =
        new Point(
            (int) (adjusted_x_corner - x_corner), (int) (adjusted_y_corner - y_corner));
    return adjustment_vector;
  }

  /** Selects the p_signal_layer_no-th layer in the select_parameter_window. */
  public void set_selected_signal_layer(int p_signal_layer_no) {
    if (this.board_frame.select_parameter_window != null) {
      this.board_frame.select_parameter_window.select(p_signal_layer_no);
      this.popup_menu_dynamic_route.disable_layer_item(p_signal_layer_no);
      this.popup_menu_stitch_route.disable_layer_item(p_signal_layer_no);
      this.popup_menu_copy.disable_layer_item(p_signal_layer_no);
    }
  }

  void init_colors() {
    board_handling.graphics_context.item_color_table.addTableModelListener(
        new ColorTableListener());
    board_handling.graphics_context.other_color_table.addTableModelListener(
        new ColorTableListener());
    setBackground(board_handling.graphics_context.get_background_color());
  }

  private void scroll_near_border(MouseEvent p_evt) {
    final int border_dist = 50;
    Rectangle r =
        new Rectangle(
            p_evt.getX() - border_dist,
            p_evt.getY() - border_dist,
            2 * border_dist,
            2 * border_dist);
    ((JPanel) p_evt.getSource()).scrollRectToVisible(r);
  }

  private void scroll_middle_mouse(MouseEvent p_evt) {
    double delta_x = middle_drag_position.x - p_evt.getX();
    double delta_y = middle_drag_position.y - p_evt.getY();

    Point view_position = get_viewport_position();

    double x = (view_position.x + delta_x);
    double y = (view_position.y + delta_y);

    Dimension panel_size = this.getSize();
    x = Math.min(x, panel_size.getWidth() - this.get_viewport_bounds().getWidth());
    y = Math.min(y, panel_size.getHeight() - this.get_viewport_bounds().getHeight());

    x = Math.max(x, 0);
    y = Math.max(y, 0);

    Point p = new Point((int) x, (int) y);
    set_viewport_position(p);
  }

  public void move_mouse(Point2D p_location) {
    if (robot == null) {
      return;
    }
    Point absolute_panel_location = board_frame.absolute_panel_location();
    Point view_position = get_viewport_position();
    int x =
        (int) Math.round(absolute_panel_location.getX() - view_position.getX() + p_location.getX())
            + 1;
    int y =
        (int)
            Math.round(
                absolute_panel_location.getY() - view_position.getY() + p_location.getY() + 1);
    robot.mouseMove(x, y);
  }

  /**
   * If p_value is true, the custom crosshair cursor will be used in display. Otherwise, the standard
   * Cursor will be used. Using the custom cursor may slow down the display performance a lot.
   */
  public void set_custom_crosshair_cursor(boolean p_value) {
    if (p_value) {
      this.custom_cursor = Cursor.get_45_degree_cross_hair_cursor();
    } else {
      this.custom_cursor = null;
    }
    board_frame.refresh_windows();
    repaint();
  }

  /**
   * If the result is true, the custom crosshair cursor will be used in display. Otherwise, the
   * standard Cursor will be used. Using the custom cursor may slow down the display performance a
   * lot.
   */
  public boolean is_custom_cross_hair_cursor() {
    return this.custom_cursor != null;
  }

  private class ColorTableListener implements TableModelListener {
    @Override
    public void tableChanged(TableModelEvent p_event) {
      // redisplay board because some colors have changed.
      setBackground(board_handling.graphics_context.get_background_color());
      repaint();
    }
  }
}
