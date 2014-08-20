/*
 * Copyright (C) Elemetnary Tweak Developers, 2014
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

struct TerminalTheme
{
        public TerminalTheme (string _name, string _cursor, string fg, string bg, string _palette)
        {
                name = _name;
                cursor = _cursor;
                foreground = fg;
                background = bg;
                palette = _palette;
        }
        string name;
        string cursor;
        string foreground;
        string background;
        string palette;
}

const TerminalTheme[] DEFAULT_THEMES = {
        {
                "Default",
                "#FFFFFF",
                "#f2f2f2",
                "#101010",
                "#303030:#e1321a:#6ab017:#ffc005:#004f9e:#ec0048:#2aa7e7:#f2f2f2:#5d5d5d:#ff361e:#7bc91f:#ffd00a:#0071ff:#ff1d62:#4bb8fd:#a020f0"
        },
        {
                "Chalk",
                "#d0d0d0",
                "#d0d0d0",
                "#151515",
                "#151515:#fb9fb1:#acc267:#ddb26f:#6fc2ef:#e1a3ee:#12cfc0:#d0d0d0:#505050:#eda987:#202020:#303030:#b0b0b0:#e0e0e0:#deaf8f:#f5f5f5"
        },
        {
                "Monokai",
                "#f8f8f2",
                "#f8f8f2",
                "#272822",
                "#272822:#f92672:#a6e22e:#f4bf75:#66d9ef:#ae81ff:#a1efe4:#f8f8f2:#75715e:#fd971f:#383830:#49483e:#a59f85:#f5f4f1:#cc6633:#f9f8f5"
        },
        {
                "Solarized",
                "#93a1a1",
                "#93a1a1",
                "#002b36",
                "#002b36:#dc322f:#859900:#b58900:#268bd2:#6c71c4:#2aa198:#93a1a1:#657b83:#cb4b16:#073642:#586e75:#839496:#eee8d5:#d33682:#fdf6e3"
        },
        {
                "Zenburn",
                "#8f8faf",
                "#dcdcdc",
                "#1f1f1f",
                "#3f3f3f:#e8e893:#9e9ece:#f0f0df:#8c8cd0:#c0c0be:#dfdfaf:#efefef:#3f3f3f:#e8e893:#9e9ece:#f0f0df:#8c8cd0:#c0c0be:#dfdfaf:#efefef"
        }
};

public class TerminalGrid : Gtk.Grid
{
        public TerminalGrid ()
        {
                column_spacing = 12;
                row_spacing = 6;
                margin_top = 24;
                column_homogeneous = true;

//                var settings = new Settings ("org.pantheon.terminal.settings");

                // scrollback
                var limit_scrollback = new Gtk.Switch ();
                limit_scrollback.halign = Gtk.Align.START;
                limit_scrollback.active = TerminalSettings.get_default ().scrollback_lines >= 0;
                var scrollback = new Gtk.SpinButton.with_range (0, 99999999999, 100);
                scrollback.width_request = 160;
                scrollback.halign = Gtk.Align.START;
                scrollback.value = limit_scrollback.active ? TerminalSettings.get_default ().scrollback_lines : 0;
                scrollback.sensitive = limit_scrollback.active;
                limit_scrollback.notify["active"].connect (() => {
                        TerminalSettings.get_default ().scrollback_lines = limit_scrollback.active ? (int)scrollback.value : -1;
                        scrollback.sensitive = limit_scrollback.active;
                });
                scrollback.changed.connect (() => {
                        if (limit_scrollback.active)
                                TerminalSettings.get_default ().scrollback_lines = (int)scrollback.value;
                });


                // custom font
                var custom_font = new Gtk.Switch ();
                custom_font.halign = Gtk.Align.START;
                custom_font.active = TerminalSettings.get_default ().font != "";
                var font = new Gtk.FontButton ();
                font.set_font (TerminalSettings.get_default ().font == "" ?
                        InterfaceSettings.get_default ().monospace_font_name :
                        TerminalSettings.get_default ().font );
                font.sensitive = custom_font.active;
                font.width_request = 160;
                font.halign = Gtk.Align.START;
                font.font_set.connect (() => {
                        TerminalSettings.get_default ().font = font.get_font_desc ().to_string ();
                });
                custom_font.notify["active"].connect (() => {
                        TerminalSettings.get_default ().font = custom_font.active ? font.get_font_desc ().to_string () : "";
                        font.sensitive = custom_font.active;
                });

                var opacity = new Gtk.SpinButton.with_range ( 0, 100, 1);
                var opacity_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                opacity.width_request = 160;
                opacity.halign = Gtk.Align.START;
                opacity.set_value (TerminalSettings.get_default ().opacity);
                opacity.value_changed.connect (() => {
                        TerminalSettings.get_default ().opacity = (int)opacity.get_value ();
                });

              var opacity_default = new Gtk.ToolButton.from_stock (Gtk.Stock.REVERT_TO_SAVED);

              opacity_default.clicked.connect (() => {
              TerminalSettings.get_default ().schema.reset ("opacity");
              opacity.set_value (TerminalSettings.get_default ().opacity);
              });

              opacity_default.halign = Gtk.Align.START;

              opacity_box.pack_start (opacity, false);
              opacity_box.pack_start (opacity_default, false);

                var themes = new Gtk.ComboBoxText ();
                var themes_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
                themes.width_request = 160;
                themes.halign = Gtk.Align.START;
                TerminalTheme[] custom_themes = {};
                var active = -1;
                int i = 0;
                for (; i < DEFAULT_THEMES.length; i++) {
                        var theme = DEFAULT_THEMES[i];
                        if (theme.palette == TerminalSettings.get_default ().palette)
                                active = i;
                        themes.append (i.to_string (), theme.name);
                }

              var themes_default = new Gtk.ToolButton.from_stock (Gtk.Stock.REVERT_TO_SAVED);

              themes_default.clicked.connect (() => {
              TerminalSettings.get_default ().schema.reset ("palette");
              TerminalSettings.get_default ().schema.reset ("background");
              TerminalSettings.get_default ().schema.reset ("foreground");
              TerminalSettings.get_default ().schema.reset ("cursor-color");
              themes.active = 0;
              });

              themes_default.halign = Gtk.Align.START;

              themes_box.pack_start (themes, false);
              themes_box.pack_start (themes_default, false);

                /* FIXME we may want to be a bit more generous here and use an existing parser
                 * get the custom themes together from ~/.local/share/pantheon-terminal/themes, if it exists
                 * the name of the file is used as name for the theme, the file has to look like this:
                 * (no empty line on top or things will break)
                 * cursor-color
                 * foreground-color
                 * background-color
                 * palette1:palette2:palette3:...:pallete16
                 */
                var custom_themes_file = File.new_for_path (Environment.get_user_data_dir () + "/pantheon-terminal/themes");
                if (custom_themes_file.query_exists ()) {
                        try {
                                var it = custom_themes_file.enumerate_children (FileAttribute.STANDARD_NAME, 0, null);
                                FileInfo info;
                                while ((info = it.next_file ()) != null) {
                                        string data;
                                        FileUtils.get_contents (custom_themes_file.get_path () + "/" + info.get_name (), out data);
                                        var parts = data.split ("\n");
                                        custom_themes += TerminalTheme (info.get_name (), parts[0], parts[1], parts[2], parts[3]);
                                        i++;
                                        themes.append (i.to_string (), info.get_name ());
                                }
                        } catch (Error e) { warning (e.message); }
                }

                themes.append ("-1", _("Custom"));
                themes.active_id = active.to_string ();
                themes.changed.connect (() => {
                        TerminalTheme theme;
                        var index = int.parse (themes.active_id);
                        if (index == -1)
                                return;

                        if (index < DEFAULT_THEMES.length)
                                theme = DEFAULT_THEMES[index];
                        else
                                theme = custom_themes[index - DEFAULT_THEMES.length - 1];

                        TerminalSettings.get_default ().cursor_color = theme.cursor;
                        TerminalSettings.get_default ().foreground = theme.foreground;
                        TerminalSettings.get_default ().background = theme.background;
                        TerminalSettings.get_default ().palette = theme.palette;
                });

                attach (new LLabel.right (_("Limit Scrollback Lines:")), 0, 0, 1, 1);
                attach (limit_scrollback, 1, 0, 1, 1);
                attach (scrollback, 1, 1, 1, 1);

                attach (new LLabel.right (_("Custom Font:")), 0, 2, 1, 1);
                attach (custom_font, 1, 2, 1, 1);
                attach (font, 1, 3, 1, 1);

                attach (new LLabel.right (_("Opacity:")), 0, 4, 1, 1);
                attach (opacity_box, 1, 4, 1, 1);

                attach (new LLabel.right (_("Theme:")), 0, 5, 1, 1);
                attach (themes_box, 1, 5, 1, 1);
        }
}
