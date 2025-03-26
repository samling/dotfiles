import { App, Astal, Gtk, Gdk, Widget } from "astal/gtk3"
import Wp from "gi://AstalWp"
import { bind } from "astal"
import Variable from "astal/variable"

type PopoverProps = Pick<
    Widget.WindowProps,
    | "name"
    | "namespace"
    | "className"
    | "visible"
    | "child"
    | "marginBottom"
    | "marginTop"
    | "marginLeft"
    | "marginRight"
    | "halign"
    | "valign"
> & {
    onClose?(self: Widget.Window): void
}

export default function Popover({
    child,
    marginBottom,
    marginTop,
    marginLeft,
    marginRight,
    halign = Gtk.Align.CENTER,
    valign = Gtk.Align.CENTER,
    onClose,
    ...props
}: PopoverProps) {
    const speaker = Wp.get_default()?.audio.defaultSpeaker!
    const windowName = "audio-control-window"
    const { TOP, RIGHT, BOTTOM, LEFT } = Astal.WindowAnchor
    
    return <window
        {...props}
        name={windowName}
        className="AudioWindow"
        css="background-color: transparent;"
        keymode={Astal.Keymode.EXCLUSIVE}
        anchor={TOP | RIGHT | BOTTOM | LEFT}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        onNotifyVisible={(self) => {
            if (!self.visible) {
                onClose?.(self)
            }
        }}
        onButtonPressEvent={(self, event) => {
            const [, _x, _y] = event.get_coords()
            const { x, y, width, height } = self
                .get_child()!
                .get_allocation()

            const xOut = _x < x || _x > x + width
            const yOut = _y < y || _y > y + height

            // clicked outside
            if (xOut || yOut) {
                self.visible = false
            }
        }}
        onKeyPressEvent={(self, event: Gdk.Event) => {
            if (event.get_keyval()[1] === Gdk.KEY_Escape) {
                self.visible = false
            }
        }}>
        <box
            halign={Gtk.Align.END}
            valign={Gtk.Align.START}
            marginBottom={marginBottom}
            marginTop={marginTop}
            marginLeft={marginLeft}
            marginRight={marginRight}
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
    </window>
} 