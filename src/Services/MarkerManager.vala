/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * MarkerManager manages locations on a {@link Shumate.MarkerLayer}
 *  
 * It loads {@link Maps.MarkerData} from {@link Maps.Storage}, from which it creates {@link Maps.Marker} widgets and adds them to the layer
 *
 */
public class Maps.MarkerManager : Object {

    private static uint debounce_timer_id;

    public signal void pin_created (Marker marker);

    private Storage storage;
    private unowned Shumate.MarkerLayer markerlayer;

    public MarkerManager (Shumate.MarkerLayer markerlayer) {
        this.markerlayer = markerlayer;
    }

    construct {
        storage = new Storage ();
    }

    public async void populate_layer () {
        var markerdata_array = storage.load ();

        foreach (var markerdata_note in markerdata_array.get_elements ()) {
            var markerdata = new MarkerData.from_json (markerdata_note.get_object ());
            add_marker (markerdata);
        }

        // Only care about new pins after loading everything
        pin_created.connect (on_pin_created);
    }

    public void add_marker (MarkerData markerdata) {
        var marker = new Marker (markerdata);
        markerlayer.add_marker (marker);

        marker.changed.connect (save_debounce);
        marker.deletion_requested.connect (remove_marker);

        pin_created (marker);
    }

    public void remove_marker (Shumate.Marker marker) {
        markerlayer.remove_marker (marker);
        save_debounce ();
    }

    public void save_debounce () {
        if (debounce_timer_id != 0) {
            GLib.Source.remove (debounce_timer_id);
        }

        debounce_timer_id = Timeout.add (750, debounce_handler);
    }

    public bool debounce_handler () {
        debounce_timer_id = 0;
        immediately_save ();
        return GLib.Source.REMOVE;
    }

    public void immediately_save () {
        debug ("Saving");
        var json_array = new Json.Array ();

        foreach (var marker in markerlayer.get_markers ()) {
            var markerdata = ((Maps.Marker)marker).to_markerdata ();
            json_array.add_object_element (markerdata.to_json ());
        }

        storage.save (json_array);
    }

    private void on_pin_created (Marker marker) {
        marker.popup ();
        marker.grab_entry ();
        save_debounce ();
    }

    ~MarkerManager () {
        immediately_save ();
    }
}
