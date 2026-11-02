/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * Marker is a subclass of {@link Shumate.Marker} built from a {@link Maps.MarkerData}
 *
 * It displays a pointer on the map which when clicked shows a popover presenting the MarkerData informations.
 *
 * It is created by {@link Maps.MarkerManager} from the content of a {@link Maps.Storage}
 */
public class Maps.Marker : Shumate.Marker {

    public signal void changed ();
    public signal void deletion_requested (Shumate.Marker marker);

    private Gtk.Popover popover;
    private Gtk.Entry entry_name;
    private Granite.HyperTextView textview_comments;

    public string loc_name {
        owned get {
            return entry_name.text.dup ();
        }
        set {
            entry_name.text = value;
            changed ();
        }
    }

    public string loc_comments {
        owned get {
            return textview_comments.buffer.text.dup ();
        }
        set {
            textview_comments.buffer.text = value;
            changed ();
        }
    }

    public Marker (MarkerData markerdata) {
        Object (
            latitude: markerdata.latitude,
            longitude: markerdata.longitude,
            loc_name: markerdata.name,
            loc_comments: markerdata.comments
        );
    }

    construct {
        var box = new Granite.Box (Gtk.Orientation.VERTICAL, Granite.Box.Spacing.SINGLE) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10,
            width_request = 210
        };

        entry_name = new Gtk.Entry () {
            show_emoji_icon = true
        };

        var box_name = new Granite.Box (VERTICAL, NONE);
        box_name.append (new Granite.HeaderLabel (_("Location name")));
        box_name.append (entry_name);

        textview_comments = new Granite.HyperTextView () {
            accepts_tab = false,
            wrap_mode = WORD_CHAR,
            top_margin = 3,
            right_margin = 3,
            bottom_margin = 3,
            left_margin = 3,
        };

        var scrolled_comments = new Gtk.ScrolledWindow () {
            child = textview_comments,
            hscrollbar_policy = NEVER
        };

        var frame_comments = new Gtk.Frame (null) {
            child = scrolled_comments,
            height_request = 110,
            hexpand = true,
            vexpand = true
        };

        var box_comments = new Granite.Box (VERTICAL, NONE);
        box_comments.append (new Granite.HeaderLabel (_("Comments")));
        box_comments.append (frame_comments);

        var delete_button = new Gtk.Button.from_icon_name ("user-trash-symbolic") {
            tooltip_text = _("Delete this location"),
        };
        delete_button.add_css_class (Granite.CssClass.DESTRUCTIVE);

        var box_toolbar = new Granite.Box (HORIZONTAL, HALF) {
            halign = Gtk.Align.START,
        };
        box_toolbar.append (delete_button);

        box.append (box_name);
        box.append (box_comments);
        box.append (box_toolbar);

        popover = new Gtk.Popover () {
            child = box
        };

        var image = new Gtk.Image.from_icon_name ("pointer") {
            icon_size = Gtk.IconSize.LARGE
        };

        var menubutton = new Gtk.MenuButton () {
            popover = popover,
            child = image,
            has_frame = false,
        };

        popover.position = Gtk.PositionType.TOP;
        child = menubutton;
        textview_comments.grab_focus ();

        bind_property ("loc-name",
            menubutton, "tooltip-text",
            GLib.BindingFlags.DEFAULT | GLib.BindingFlags.SYNC_CREATE
        );

        entry_name.changed.connect (on_changed);
        textview_comments.buffer.changed.connect (on_changed);
        delete_button.clicked.connect (delete_marker);
        popover.show.connect (on_show);
    }

    public void delete_marker () {
        popover.popdown ();
        deletion_requested (this);
    }

    public void popup () {
        popover.popup ();
    }

    // We use a dedicated handler as there may be a lot of markers
    // To avoid the infamous vala lambda leak bug
    public void on_changed () {
        changed ();
    }

    private void on_show () {
        // Prevent entry_name from stealing the show by selecting its content
        entry_name.select_region (-1, -1);
        textview_comments.grab_focus ();
    }

    public void grab_entry () {
        entry_name.grab_focus ();
    }

    public MarkerData to_markerdata () {
        return new MarkerData (latitude, longitude) {
            name = loc_name,
            comments = loc_comments
        };
    }
}
