/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * SearchResultMarker is a subclass of {@link Shumate.Marker} built from a {@link Geocode.Location}
 *
 * It displays a pointer on the map which when clicked shows a popover offering the user to create a new pin for this location
 *
 * It is created by {@link Maps.Map_Widget} when user selects a result of a search
 */
public class Maps.SearchResultMarker : Shumate.Marker {

    public signal void create_pin (MarkerData markerdata);

    private Granite.HeaderLabel headerlabel;
    private Gtk.Popover popover;

    public string loc_name {
        get {
            return headerlabel.label;
        }
        set {
            headerlabel.label = value;
        }
    }

    public string loc_address {
        get {
            return headerlabel.secondary_text;
        }
        set {
            headerlabel.secondary_text = value;
        }
    }

    public SearchResultMarker (Geocode.Place place) {
        Object (
            latitude: place.location.latitude,
            longitude: place.location.longitude
        );
    }

    construct {
        var box = new Granite.Box (VERTICAL, HALF) {
            margin_top = 10,
            margin_bottom = 10,
            margin_start = 10,
            margin_end = 10,
            width_request = 90
        };

        headerlabel = new Granite.HeaderLabel ("");
        var button = new Gtk.Button.with_label (_("Create new pin"));

        box.append (headerlabel);
        box.append (button);

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
            tooltip_text = loc_name
        };

        popover.position = Gtk.PositionType.TOP;
        child = menubutton;

        button.clicked.connect (on_button_click);
    }

    private void on_button_click () {
        popover.popdown ();
        var new_marker_data = new MarkerData (latitude, longitude) {
            name = loc_name,
            comments = loc_address
        };
        create_pin (new_marker_data);
    }
}
