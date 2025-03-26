import Wp from "gi://AstalWp"
import { bind, Variable } from "astal"
import { App, Gtk } from "astal/gtk3"
import Popover from "../../../../shared/popover/popover"

export default function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    const visible = Variable(false);
    const windowName = "audio-control-window"
    
    const _popover = <Popover
        name={windowName}
        className="AudioWindow"
        onClose={() => {
            visible.set(false)
        }}
        visible={visible()}
        child={
            <box
                halign={Gtk.Align.END}
                valign={Gtk.Align.START}
                onButtonPressEvent={() => true}
            >
            <box className="audio-container">
                <box className="audio-control-content">
                    <button 
                        className="volume-icon-button"
                        onClick={() => {
                            speaker.mute = !speaker.mute
                        }}>
                        <icon icon={bind(speaker, "volumeIcon")} css="font-size: 1.2em;" />
                    </button>
                    
                    <slider
                        className="AudioSlider"
                        hexpand
                        onDragged={({ value }) => speaker.volume = value}
                        value={bind(speaker, "volume")}
                    />
                </box>
                </box>
            </box>
        }
    />
    
    // Show just the icon button that triggers the floating window
    return <button
        className="AudioIcon"
        tooltipText="Audio Settings"
        onClicked={() => {
            visible.set(!visible.get())
        }}>
        <icon icon={bind(speaker, "volumeIcon")} />
    </button>
}