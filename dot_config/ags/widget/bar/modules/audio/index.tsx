import Wp from "gi://AstalWp"
import { bind } from "astal"

export default function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    const slider = <slider
        hexpand
        onDragged={({ value }) => speaker.volume = value}
        value={bind(speaker, "volume")}
    />

    const audioSlider = <box className="AudioSlider" css="min-width: 140px" child={<icon icon={bind(speaker, "volumeIcon")} />}>
        {slider}
    </box>

    return audioSlider
}