import Wp from "gi://AstalWp"
import { bind } from "astal"
import { App, Gtk } from "astal/gtk3"
import AudioWindow from "../../../audio/AudioWindow"

export default function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    
    // Create the audio window when the component is initialized
    const setup = (widget: Gtk.Widget) => {
        return AudioWindow()
    }
    
    // Show just the icon button that triggers the floating window
    return <button
        className="AudioIcon"
        tooltipText="Audio Settings"
        setup={setup}
        onClick={() => {
            const audioWindow = App.get_window("audio-control-window")
            if (audioWindow) {
                const isVisible = audioWindow.get_visible()
                audioWindow.set_visible(!isVisible)
            }
        }}>
        <icon icon={bind(speaker, "volumeIcon")} />
    </button>
}