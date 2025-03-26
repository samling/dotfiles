import Wp from "gi://AstalWp"
import { bind, Variable } from "astal"
import { App, Gtk } from "astal/gtk3"
import AudioWindow from "./helper/AudioWindow"
import Popover from "./helper/AudioWindow"

export default function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    const visible = Variable(false);
    
    const _popover = <Popover
        onClose={() => {
            visible.set(false)
        }}
        visible={visible()}
    >
    </Popover>
    
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