import { Astal, Gtk, Gdk, Widget } from "astal/gtk3"

export type PopoverProps = Pick<
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
    const { TOP, RIGHT, BOTTOM, LEFT } = Astal.WindowAnchor
    
    return <window
        {...props}
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
        {child}
    </window>
} 