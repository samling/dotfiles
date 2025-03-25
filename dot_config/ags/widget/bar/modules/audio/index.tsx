import Wp from "gi://AstalWp"
import { bind, Variable } from "astal"
import { App, Gtk, Gdk } from "astal/gtk3"
import AudioWindow from "../../../audio/AudioWindow"

// Keep track of if the audio window has been initialized
const initialized = new Variable(false)

export default function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    
    // Create the audio window if it doesn't already exist
    const ensureAudioWindow = () => {
        if (initialized.get()) return
        AudioWindow()
        initialized.set(true)
    }
    
    // Create the audio window when the component is initialized
    const setup = (widget: Gtk.Widget) => {
        ensureAudioWindow()
    }
    
    // Show just the icon button that triggers the floating window
    return <button
        className="AudioIcon"
        tooltipText="Audio Settings"
        setup={setup}
        onClick={() => {
            // Ensure the audio window is created
            ensureAudioWindow()
            
            // Toggle the window visibility
            const audioWindow = App.get_window("audio-control-window")
            if (audioWindow) {
                // Toggle visibility
                const isVisible = audioWindow.get_visible()
                audioWindow.set_visible(!isVisible)
            }
        }}>
        <icon icon={bind(speaker, "volumeIcon")} />
    </button>
}