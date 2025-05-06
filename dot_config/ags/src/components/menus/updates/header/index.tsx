import { Gtk } from 'astal/gtk3';
import { bind } from 'astal';
import { fetchUpdateData, isChecking } from 'src/globals/updates';

export const Header = (): JSX.Element => {
    const MenuLabel = (): JSX.Element => {
        return <label className="menu-label updates" valign={Gtk.Align.CENTER} halign={Gtk.Align.START} label="Updates" />;
    };

    return (
        <box className="menu-label-container updates" halign={Gtk.Align.FILL} valign={Gtk.Align.START}>
            <MenuLabel />
            <button 
                className="menu-icon-button refresh-button" 
                valign={Gtk.Align.CENTER}
                onClicked={fetchUpdateData}
            >
                <icon 
                    className={bind(isChecking).as(checking => checking ? 'spinning-icon' : '')}
                    icon="view-refresh-symbolic"
                />
            </button>
        </box>
    );
};
