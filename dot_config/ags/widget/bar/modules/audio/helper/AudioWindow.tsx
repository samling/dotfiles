import { App, Astal, Gtk, Gdk, Widget } from "astal/gtk3"
import Wp from "gi://AstalWp"
import { bind } from "astal"
import Variable from "astal/variable"

// We don't need the window instance map since we're using App.get_window()
// If we check if the window exists before showing/hiding it

export default function AudioWindow() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    const windowName = "audio-control-window"
    let win: Widget.Window // Window instance
    
    // Create a variable to track screen width for positioning
    const screenWidth = Variable(1000)
    
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
    
    // Handle window hiding
    const hide = () => {
        if (win?.visible) {
            win.visible = false
        }
    }
    
    // Using TOP and BOTTOM anchor only, for better label wrapping
    const { TOP, RIGHT } = Astal.WindowAnchor
    
    return <window
        name={windowName}
        className="AudioWindow"
        css="background-color: transparent;"
        visible={false}
        layer={Astal.Layer.TOP}
        anchor={TOP | RIGHT}
        keymode={Astal.Keymode.EXCLUSIVE}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        setup={self => {
            win = self
            
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
        onNotifyVisible={(self) => {
            // Update screen width when window becomes visible
            if (self.visible) {
                screenWidth.set(self.get_current_monitor().workarea.width)
            }
        }}
        onKeyPressEvent={(self, event) => {
            const key = event.get_keyval()[1]
            if (key === Gdk.KEY_Escape) {
                hide()
                return true
            }
            return false
        }}
        application={App}>
        <box>
            {/* Flexible space to the left */}
            <eventbox widthRequest={screenWidth(w => w - 400)} expand onClick={hide} />
            
            {/* Content container, positioned at the right side */}
            <box hexpand={false} vertical>
                {/* Top spacing that can be clicked to close */}
                <eventbox heightRequest={10} expand onClick={hide} />
                
                {/* Audio control container */}
                <box 
                    className="audio-container"
                    css="background-color: #1e1e2e; border-radius: 12px; padding: 1em; box-shadow: 0 2px 8px rgba(0, 0, 0, 0.5); margin: 6px; font-family: 'Iosevka Term', 'Iosevka Nerd Font Propo', 'Symbols Nerd Font Mono'; color: #cdd6f4; font-size: 1.1em; font-weight: bold; min-width: 350px;">
                    <box className="audio-control-container" css="min-width: 320px;">
                        <box className="audio-control-header" css="margin-bottom: 0.5em;">
                            <button 
                                className="volume-icon-button"
                                css="background: none; border: none; padding: 0.2em; margin-right: 0.3em; border-radius: 4px;"
                                onClick={() => {
                                    speaker.mute = !speaker.mute
                                }}>
                                <icon icon={bind(speaker, "volumeIcon")} css="font-size: 1.2em;" />
                            </button>
                            <label label="Volume Control" css="font-weight: bold;" />
                        </box>
                        <box 
                            className="audio-control-content" 
                            css="display: flex; flex-direction: row; align-items: center; margin: 1em 0;">
                            <box className="AudioSlider" css="min-width: 260px; display: flex; flex-direction: row; align-items: center; flex: 1;">
                                <slider
                                    hexpand
                                    onDragged={({ value }) => speaker.volume = value}
                                    value={bind(speaker, "volume")}
                                />
                            </box>
                        </box>
                    </box>
                </box>
                
                {/* Bottom spacing */}
                <eventbox expand onClick={hide} />
            </box>
            
            {/* Right margin */}
            <eventbox widthRequest={20} expand onClick={hide} />
        </box>
    </window>
} 