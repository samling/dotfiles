import { App } from 'astal/gtk3';
import { Gio } from 'astal/file';
import { GLib } from 'astal/gobject';

declare global {
    const CONFIG_DIR: string;
    const CONFIG_FILE: string;
    const TMP: string;
    const USER: string;
    const SRC_DIR: string;
}

export function ensureDirectory(path: string): void {
    if (!GLib.file_test(path, GLib.FileTest.EXISTS)) {
        Gio.File.new_for_path(path).make_directory_with_parents(null);
    }
}

const dataDir = typeof DATADIR !== 'undefined' ? DATADIR : SRC;

Object.assign(globalThis, {
    CONFIG_DIR: `${GLib.get_user_config_dir()}/ags`,
    CONFIG_FILE: `${GLib.get_user_config_dir()}/ags/config.json`,
    TMP: `${GLib.get_tmp_dir()}/ags`,
    USER: GLib.get_user_name(),
    SRC_DIR: dataDir,
});

