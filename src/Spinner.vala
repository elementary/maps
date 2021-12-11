/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2021 Ryo Nakano <ryonakaknock3@gmail.com>
 */

public class Spinner : Gtk.Spinner {
    public Spinner () {
        Object (
            no_show_all: true
        );
    }

    public new void activate (string reason) {
        tooltip_text = reason;
        show ();
        start ();
    }

    public void deactivate () {
        hide ();
        stop ();
    }
}
