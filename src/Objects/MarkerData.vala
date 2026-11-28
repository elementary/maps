/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

/**
 * MarkerData represents the informations for a specific location
 *
 * It is used by {@link Maps.MarkerManager} to save, load, and represent locations on a map.
 * 
 * It can be converted from or into a {@link Json.Object} for convenience
 */
public class Maps.MarkerData : Object {

    public double latitude {get; set;}
    public double longitude {get; set;}
    public string name {get; set; default = _("New location");}
    public string comments {get; set; default = "";}

    public MarkerData (double latitude, double longitude) {
        Object (
            latitude: latitude,
            longitude: longitude
        );
    }

    public MarkerData.from_json (Json.Object node) {
        latitude = node.get_double_member ("lat");
        longitude = node.get_double_member ("long");
        name = node.get_string_member ("name");
        comments = node.get_string_member ("comments");
    }

    public Json.Object to_json () {
        var builder = new Json.Builder ();

        builder.begin_object ();
        builder.set_member_name ("lat");
        builder.add_double_value (latitude);
        builder.set_member_name ("long");
        builder.add_double_value (longitude);
        builder.set_member_name ("name");
        builder.add_string_value (name);
        builder.set_member_name ("comments");
        builder.add_string_value (comments);
        builder.end_object ();

        return builder.get_root ().get_object ();
    }
}
