import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import Wp from "gi://AstalWp"
import { bind } from "astal"

// We don't need the window instance map since we're using App.get_window()
// If we check if the window exists before showing/hiding it

export default function AudioWindow() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    const windowName = "audio-control-window"
    
    interface SignalConnection {
        obj: any;
        id: number;
    }
    const signals: SignalConnection[] = []
    const cleanup = () => {
        for (const signal of signals) {
            if (signal.obj && signal.id) {
                try {
                    signal.obj.disconnect(signal.id)
                } catch (e) {
                    console.log(`Error disconnecting signal: ${e}`)
                }
            }
        }
    }
    
    // Using TOP and RIGHT anchor to position the window in the top-right corner
    const { TOP, RIGHT } = Astal.WindowAnchor
    
    return <window
        name={windowName}
        className="AudioWindow"
        css="background-color: transparent;"
        visible={false}
        layer={Astal.Layer.TOP}
        anchor={TOP | RIGHT}
        marginRight={500}
        keymode={Astal.Keymode.ON_DEMAND}
        onKeyPressEvent={(_, event) => {
            const key = event.get_keyval()[1]
            if (key === Gdk.KEY_Escape) {
                App.get_window(windowName)?.hide()
                return true
            }
            return false
        }}
        setup={self => {
            // Add the window to the App
            App.add_window(self)
            
            // Set type hint to ensure it appears as a popup
            self.set_type_hint(Gdk.WindowTypeHint.POPUP_MENU)
            
            // Ensure it stays on top and has no decorations
            self.set_keep_above(true)
            self.set_decorated(false)
            
            // Set up cleanup on destroy
            const destroySignal = self.connect('destroy', cleanup)
            signals.push({ obj: self, id: destroySignal })
        }}
        application={App}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}>
        <eventbox
            className="outer-event-box"
            css="background-color: transparent;"
            onButtonPressEvent={(_, event) => {
                const buttonClicked = event.get_button()[1]
                
                if (buttonClicked === Gdk.BUTTON_PRIMARY || buttonClicked === Gdk.BUTTON_SECONDARY) {
                    App.get_window(windowName)?.hide()
                    return true
                }
                return false
            }}>
            <box 
                className="audio-container"
                css="background-color: #1e1e2e; border-radius: 12px; padding: 1em; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.5); margin: 6px; font-family: 'Iosevka Term', 'Iosevka Nerd Font Propo', 'Symbols Nerd Font Mono'; color: #cdd6f4; font-size: 1.1em; font-weight: bold;">
                <eventbox 
                    className="inner-event-box"
                    css="background-color: transparent;">
                    <box className="audio-control-container" css="min-width: 250px;">
                        <box className="audio-control-header" css="margin-bottom: 0.5em;">
                            <icon icon={bind(speaker, "volumeIcon")} css="margin-right: 0.5em; font-size: 1.2em;" />
                            <label label="Volume Control" css="font-weight: bold;" />
                        </box>
                        <box 
                            className="audio-control-content" 
                            css="display: flex; flex-direction: row; align-items: center; margin: 1em 0;">
                            <slider
                                className="audio-control-slider"
                                css="flex: 1; margin-right: 0.5em;"
                                hexpand
                                onDragged={({ value }) => speaker.volume = value}
                                value={bind(speaker, "volume")}
                            />
                            <button 
                                className="audio-mute-button"
                                css="min-width: 2em; min-height: 2em; border-radius: 50%; background-color: #45475a; transition: all 200ms ease;"
                                onClick={() => {
                                    speaker.mute = !speaker.mute
                                }}>
                                <icon icon={bind(speaker, "volumeIcon").as(icon => 
                                    icon === "audio-volume-muted-symbolic" ? 
                                    "audio-volume-high-symbolic" : 
                                    "audio-volume-muted-symbolic"
                                )} css="font-size: 1.2em;" />
                            </button>
                        </box>
                        <label label={bind(speaker, "volume").as(v => `${Math.round(v * 100)}%`)} />
                    </box>
                </eventbox>
            </box>
        </eventbox>
    </window>
} 