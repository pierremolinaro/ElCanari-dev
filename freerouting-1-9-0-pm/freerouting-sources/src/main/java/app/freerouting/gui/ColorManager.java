package app.freerouting.gui;

import app.freerouting.boardgraphics.GraphicsContext;
import app.freerouting.management.FRAnalytics;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Component;
import java.awt.Dimension;
import java.awt.Insets;
import java.awt.event.ActionListener;
import java.util.Locale;
import java.util.ResourceBundle;
import javax.swing.BorderFactory;
import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JColorChooser;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.border.Border;
import javax.swing.table.TableCellRenderer;

/** Window for changing the colors of board objects. */
public class ColorManager extends BoardSavableSubWindow {

  private final JTable layers_color_table;
  private final JTable general_color_table;

  /** Creates a new instance of ColorManager */
  public ColorManager(BoardFrame p_board_frame) {
    GraphicsContext graphics_context = p_board_frame.board_panel.board_handling.graphics_context;
    ResourceBundle resources =
        ResourceBundle.getBundle(
            "app.freerouting.gui.Default", p_board_frame.get_locale());
    this.setTitle(resources.getString("color_manager"));
    final JPanel panel = new JPanel();
    final int textfield_height = 20;
    final int table_width = 1100;
    final int item_color_table_height =
        graphics_context.item_color_table.getRowCount() * textfield_height;

    panel.setPreferredSize(new Dimension(10 + table_width, 90 + item_color_table_height));

    layers_color_table = new JTable(graphics_context.item_color_table);
    layers_color_table.setPreferredScrollableViewportSize(new Dimension(table_width, item_color_table_height));
    JScrollPane item_scroll_pane = init_color_table(layers_color_table, p_board_frame.get_locale());
    panel.add(item_scroll_pane, BorderLayout.NORTH);

    general_color_table = new JTable(graphics_context.other_color_table);
    general_color_table.setPreferredScrollableViewportSize(new Dimension(table_width, textfield_height));
    JScrollPane other_scroll_pane = init_color_table(general_color_table, p_board_frame.get_locale());
    panel.add(other_scroll_pane, BorderLayout.SOUTH);
    getContentPane().add(panel, BorderLayout.CENTER);
    p_board_frame.set_context_sensitive_help(this, "WindowDisplay_Colors");
    this.pack();
    this.setResizable(false);
  }

  /** Initializes p_color_table and return the created scroll_pane of the color table. */
  private static JScrollPane init_color_table(JTable p_color_table, Locale p_locale) {
    // Create the scroll pane and add the table to it.
    JScrollPane scroll_pane = new JScrollPane(p_color_table);
    // Set up renderer and editor for the Color columns.
    p_color_table.setDefaultRenderer(Color.class, new ColorRenderer(true));

    setUpColorEditor(p_color_table, p_locale);
    return scroll_pane;
  }

  // Set up the editor for the Color cells.
  private static void setUpColorEditor(JTable p_table, Locale p_locale) {
    // First, set up the color_editor_button that brings up the dialog.
    final JButton color_editor_button =
        new JButton("") {
          @Override
          public void setText(String s) {
            // Button never shows text -- only color.
          }
        };
    color_editor_button.setBackground(Color.white);
    color_editor_button.setBorderPainted(false);
    color_editor_button.setMargin(new Insets(0, 0, 0, 0));

    // Now create an editor to encapsulate the color_editor_button, and
    // set it up as the editor for all Color cells.
    final ColorEditor colorEditor = new ColorEditor(color_editor_button);
    p_table.setDefaultEditor(Color.class, colorEditor);

    // Set up the dialog that the color_editor_button brings up.
    final JColorChooser colorChooser = new JColorChooser();
    ActionListener okListener =
        e -> colorEditor.currentColor = colorChooser.getColor();
    ResourceBundle resources =
        ResourceBundle.getBundle("app.freerouting.gui.Default", p_locale);
    final JDialog dialog = JColorChooser.createDialog(color_editor_button, resources.getString("pick_a_color"), true, colorChooser, okListener, null);

    // Here's the code that brings up the dialog.
    color_editor_button.addActionListener(
        e -> {
          color_editor_button.setBackground(colorEditor.currentColor);
          colorChooser.setColor(colorEditor.currentColor);
          // Without the following line, the dialog comes up
          // in the middle of the screen.
          // dialog.setLocationRelativeTo(color_editor_button);
          dialog.setVisible(true);
        });
    color_editor_button.addActionListener(evt -> FRAnalytics.buttonClicked("color_editor_button", color_editor_button.getText()));
  }

  /** Reassigns the table model variables because they may have changed in p_graphics_context. */
  public void set_table_models(GraphicsContext p_graphics_context) {
    this.layers_color_table.setModel(p_graphics_context.item_color_table);
    this.general_color_table.setModel(p_graphics_context.other_color_table);
  }

  private static class ColorRenderer extends JLabel implements TableCellRenderer {
    Border unselectedBorder;
    Border selectedBorder;
    boolean isBordered;

    public ColorRenderer(boolean p_is_bordered) {
      super();
      this.isBordered = p_is_bordered;
      setOpaque(true); // MUST do this for background to show up.
    }

    @Override
    public Component getTableCellRendererComponent(
        JTable p_table,
        Object p_color,
        boolean p_is_selected,
        boolean p_has_focus,
        int p_row,
        int p_column) {
      setBackground((Color) p_color);
      if (isBordered) {
        if (p_is_selected) {
          if (selectedBorder == null) {
            selectedBorder =
                BorderFactory.createMatteBorder(2, 5, 2, 5, p_table.getSelectionBackground());
          }
          setBorder(selectedBorder);
        } else {
          if (unselectedBorder == null) {
            unselectedBorder = BorderFactory.createMatteBorder(2, 5, 2, 5, p_table.getBackground());
          }
          setBorder(unselectedBorder);
        }
      }
      return this;
    }
  }

  /**
   * The editor button that brings up the dialog. We extend DefaultCellEditor for convenience, even
   * though it mean we have to create a dummy check box. Another approach would be to copy the
   * implementation of TableCellEditor methods from the source code for DefaultCellEditor.
   */
  private static class ColorEditor extends DefaultCellEditor {
    Color currentColor;

    public ColorEditor(JButton b) {
      super(new JCheckBox()); // Unfortunately, the constructor
      // expects a checkbox, combo-box, or text field.
      editorComponent = b;
      setClickCountToStart(1); // This is usually 1 or 2.

      // Must do this so that editing stops when appropriate.
      b.addActionListener(e -> fireEditingStopped());
    }

    @Override
    protected void fireEditingStopped() {
      super.fireEditingStopped();
    }

    @Override
    public Object getCellEditorValue() {
      return currentColor;
    }

    @Override
    public Component getTableCellEditorComponent(
        JTable table, Object value, boolean isSelected, int row, int column) {
      ((JButton) editorComponent).setText(value.toString());
      currentColor = (Color) value;
      return editorComponent;
    }
  }
}
