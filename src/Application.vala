/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2025 elementary, Inc. (https://elementary.io)
 *                         2018-2025 Ryo Nakano <ryonakaknock3@gmail.com>
 *                         2014-2015 Atlas Developers
 */

public class Maps.Application : Adw.Application {
    public static Settings settings { get; private set; }

    private const ActionEntry[] ACTION_ENTRIES = {
        { "quit", on_quit_activate },
    };
    private MainWindow main_window;

    public Application () {
        Object (
            application_id: "io.elementary.maps",
            flags: ApplicationFlags.HANDLES_OPEN
        );
    }

    static construct {
        settings = new Settings ("io.elementary.maps");
    }

    private void setup_style () {
        var style_action = new SimpleAction.stateful (
            "color-scheme", VariantType.STRING, new Variant.string (Define.ColorScheme.DEFAULT)
        );
        style_action.bind_property (
            "state",
            style_manager, "color-scheme",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE,
            (binding, state_scheme, ref adw_scheme) => {
                Variant? state_scheme_dup = state_scheme.dup_variant ();
                if (state_scheme_dup == null) {
                    warning ("Failed to Variant.dup_variant");
                    return false;
                }

                adw_scheme = Util.to_adw_scheme ((string) state_scheme_dup);
                return true;
            },
            (binding, adw_scheme, ref state_scheme) => {
                string str_scheme = Util.to_str_scheme ((Adw.ColorScheme) adw_scheme);
                state_scheme = new Variant.string (str_scheme);
                return true;
            }
        );
        settings.bind_with_mapping (
            "color-scheme",
            style_manager, "color-scheme", SettingsBindFlags.DEFAULT,
            (adw_scheme, gschema_scheme, user_data) => {
                adw_scheme = Util.to_adw_scheme ((string) gschema_scheme);
                return true;
            },
            (adw_scheme, expected_type, user_data) => {
                string str_scheme = Util.to_str_scheme ((Adw.ColorScheme) adw_scheme);
                Variant gschema_scheme = new Variant.string (str_scheme);
                return gschema_scheme;
            },
            null, null
        );
        add_action (style_action);
    }

    protected override void open (File[] files, string hint) {
        activate ();

        var file = files[0];
        if (file == null || !file.has_uri_scheme ("geo")) {
            critical ("no geo uri scheme");
            return;
        }

        ((MainWindow) active_window).go_to_uri (file.get_uri ());
    }

    protected override void startup () {
        /*
         * Granite.init() calls Gdk.DisplayManager.get() internally without
         * initializing Gtk, which is illegal and causes an intentional
         * crash since Gtk 4.17. So, initialize Gtk explicitly here as a
         * workaround.
         * TODO: Remove this when https://github.com/elementary/granite/pull/893 is released
         */
        Gtk.init ();
        // Apply elementary stylesheet instead of default Adwaita stylesheet
        Granite.init ();

        base.startup ();

        Intl.setlocale (LocaleCategory.ALL, "");
        Intl.bindtextdomain (Config.GETTEXT_PACKAGE, Config.LOCALEDIR);
        Intl.bind_textdomain_codeset (Config.GETTEXT_PACKAGE, "UTF-8");
        Intl.textdomain (Config.GETTEXT_PACKAGE);

        setup_style ();

        add_action_entries (ACTION_ENTRIES, this);
        set_accels_for_action ("app.quit", { "<Control>q" });
        set_accels_for_action ("win.search", { "<Control>f" });
    }

    protected override void activate () {
        if (get_windows () != null) {
            main_window.present ();
            return;
        }

        main_window = new MainWindow ();
        main_window.set_application (this);
        // The main_window seems to need showing before restoring its size in Gtk4
        main_window.present ();

        settings.bind ("window-height", main_window, "default-height", SettingsBindFlags.DEFAULT);
        settings.bind ("window-width", main_window, "default-width", SettingsBindFlags.DEFAULT);

        /*
         * Binding of main_window maximization with "SettingsBindFlags.DEFAULT" results the main_window getting bigger and bigger on open.
         * So we use the prepared binding only for setting
         */
        if (settings.get_boolean ("maximized")) {
            main_window.maximize ();
        }

        settings.bind ("maximized", main_window, "maximized", SettingsBindFlags.SET);
    }

    private void on_quit_activate () {
        if (main_window != null) {
            main_window.prep_destroy ();
            // Prevent quit() for now for pre-destruction process
            return;
        }

        quit ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }
}
