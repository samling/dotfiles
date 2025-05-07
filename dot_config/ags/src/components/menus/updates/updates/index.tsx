import { App, Gtk } from "astal/gtk3";
import { bind, execAsync, Variable } from 'astal';
import { runAsyncCommand } from 'src/components/bar/utils/helpers.js';

// Import the shared state
import { sharedUpdateData } from 'src/globals/updates';

export const Updates = (): JSX.Element => {
    // Render function can use sharedUpdateData directly
    const renderUpdates = (data: { count: string, details: string, formattedDetails: string }) => {
        const hasUpdates = parseInt(data.count, 10) > 0;
        
        return (
            <box className="updates-container" halign={Gtk.Align.FILL} hexpand vertical>
                <box className="updates-count-row" halign={Gtk.Align.FILL} hexpand>
                    <label 
                        className="updates-label" 
                        label="Available Updates" 
                        halign={Gtk.Align.START} 
                        hexpand 
                    />
                    <label 
                        className={`updates-count ${hasUpdates ? 'has-updates' : ''}`}
                        label={data.count} 
                        halign={Gtk.Align.END} 
                    />
                </box>
                
                {hasUpdates ? (
                    <box className="updates-details" halign={Gtk.Align.FILL} hexpand vertical>
                        {data.formattedDetails && (
                            <label 
                                    className="updates-tooltip monospace" 
                                    label={data.formattedDetails} 
                                    wrap={false} 
                                    xalign={0} 
                                    halign={Gtk.Align.FILL} 
                                    hexpand 
                                    selectable={true}
                                />
                        )}
                        
                        <box className="updates-actions" halign={Gtk.Align.FILL} hexpand spacing={8}>
                            <button 
                                className="update-button" 
                                onClicked={() => {
                                    App.get_window('updatesmenu')?.set_visible(false);
                                    runAsyncCommand("wezterm --config 'exit_behavior=\"Hold\"' -e --class=wezterm-yay-update yay -Syu", { clicked: null, event: null })
                                }}
                            >
                                <label label="Update System" />
                            </button>
                        </box>
                    </box>
                ) : (
                    <box className="system-up-to-date" halign={Gtk.Align.FILL} hexpand>
                        <label 
                            className="up-to-date-label" 
                            label="System is up to date" 
                            halign={Gtk.Align.CENTER} 
                            hexpand 
                        />
                    </box>
                )}
            </box>
        );
    };

    return (
        <box 
            className={bind(sharedUpdateData).as(data =>
                `menu-items-section updates ${data.count !== '0' ? 'has-updates' : 'has-no-updates'}`
            )}
            halign={Gtk.Align.FILL} 
            hexpand 
        >
            <scrollable 
                className="menu-scroller updates"
                vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
                hscrollbarPolicy={Gtk.PolicyType.NEVER}
                hexpand
                vexpand
            >
                <box 
                    className="menu-content updates" 
                    vertical
                    halign={Gtk.Align.FILL}
                    hexpand
                >
                    {bind(sharedUpdateData).as(renderUpdates)}
                </box>
            </scrollable>
        </box>
    );
};