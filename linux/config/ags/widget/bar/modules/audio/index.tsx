import Wp from "gi://AstalWp"
import { bind } from "astal"

export default function AudioSlider() {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!

    return <box className="AudioSlider" css="min-width: 140px">
        <icon icon={bind(speaker, "volumeIcon")} />
        <slider
            hexpand
            onDragged={({ value }) => speaker.volume = value}
            value={bind(speaker, "volume")}
        />
    </box>
}