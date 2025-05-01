import { Gtk } from 'astal/gtk3';

export const Header = ({ type, label }: HeaderProps): JSX.Element => {
    return (
        <box className={`menu-label-container ${type}`} halign={Gtk.Align.FILL} hexpand vexpand vertical>
            <label className={`menu-label screencapture ${type}`} halign={Gtk.Align.FILL} hexpand label={label}/>
        </box>
    );
};

interface HeaderProps {
    type: 'screenshot' | 'recording';
    label: string;
}
