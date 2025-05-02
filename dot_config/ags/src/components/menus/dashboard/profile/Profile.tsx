import { bind, GLib, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { normalizePath, isAnImage } from 'src/lib/utils.js';

const image = Variable<string>('~/.face.icon');
const name = Variable<'system' | string>('system');

const ProfilePicture = (): JSX.Element => {
    return (
        <box
            className={'profile-picture'}
            halign={Gtk.Align.CENTER}
            css={bind(image).as((img) => {
                if (isAnImage(img)) {
                    return `background-image: url("${normalizePath(img)}")`;
                }

                return `background-image: url("${SRC_DIR}/assets/hyprpanel.png")`;
            })}
        />
    );
};

const ProfileName = (): JSX.Element => {
    return (
        <label
            className={'profile-name'}
            halign={Gtk.Align.CENTER}
            label={bind(name).as((profileName) => {
                if (profileName === 'system') {
                    const username = GLib.get_user_name();
                    return username;
                }
                return profileName;
            })}
        />
    );
};

export const UserProfile = (): JSX.Element => {
    return (
        <box className={'profile-picture-container dashboard-card'} hexpand vertical>
            <ProfilePicture />
            <ProfileName />
        </box>
    );
};
