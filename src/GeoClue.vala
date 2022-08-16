/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: Copyright 2014-2015 Atlas Developers, 2018-2022 Ryo Nakano
 *
 * Inspired from https://gitlab.gnome.org/GNOME/gnome-clocks/blob/master/src/geocoding.vala
 */

public class Atlas.GeoClue : Object {
    private GClue.Simple? simple;

    public GeoClue () {
    }

    public async GClue.Location? get_current_location () {
        if (simple == null) {
            try {
                simple = yield new GClue.Simple (Build.PROJECT_NAME, GClue.AccuracyLevel.EXACT, null);
            } catch (Error e) {
                warning ("Failed to connect to GeoClue2 service: %s", e.message);
                return null;
            }
        }

        return simple.get_location ();
    }
}
