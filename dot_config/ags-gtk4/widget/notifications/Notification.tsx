import { GLib } from "astal"
import { Gtk, Astal } from "astal/gtk4"
import Pango from "gi://Pango?version=1.0"
import Gdk from "gi://Gdk?version=4.0"
import Notifd from "gi://AstalNotifd"

const isIcon = (icon: string) => {
    const display = Gdk.Display.get_default();
    if (!display) return false;
    return !!Gtk.IconTheme.get_for_display(display).has_icon(icon)
}

const fileExists = (path: string) =>
    GLib.file_test(path, GLib.FileTest.EXISTS)

const time = (time: number, format = "%H:%M") => GLib.DateTime
    .new_from_unix_local(time)
    .format(format)!

const urgency = (n: Notifd.Notification) => {
    const { LOW, NORMAL, CRITICAL } = Notifd.Urgency
    // match operator when?
    switch (n.urgency) {
        case LOW: return "low"
        case CRITICAL: return "critical"
        case NORMAL:
        default: return "normal"
    }
}

type Props = {
    setup?(self: Gtk.Box): void
    onHoverLost?(self: Gtk.Box): void
    notification: Notifd.Notification
}

export default function Notification(props: Props) {
    const { notification: n, onHoverLost, setup } = props
    const { START, CENTER, END } = Gtk.Align

    // Define common icon size
    const iconSize = 16; // Adjust as needed

    return <Gtk.Box
        cssName={`Notification ${urgency(n)}`}
        // @ts-expect-error setup is a custom prop handled by astal/ags
        setup={setup}
    >
        <Gtk.Box orientation={Gtk.Orientation.VERTICAL}>
            <Gtk.Box cssName="header">
                {(n.appIcon || n.desktopEntry) ? <Gtk.Image
                    cssName="app-icon"
                    iconName={n.appIcon || n.desktopEntry || undefined}
                    pixelSize={iconSize}
                /> : null}
                <Gtk.Label
                    cssName="app-name"
                    halign={START}
                    ellipsize={Pango.EllipsizeMode.END}
                    label={n.appName || "Unknown"}
                />
                <Gtk.Label
                    cssName="time"
                    hexpand
                    halign={END}
                    label={time(n.time)}
                />
                {/* @ts-expect-error setup is a custom prop for post-creation config */}
                <Gtk.Button setup={(self: Gtk.Button) => self.connect("clicked", () => n.dismiss())}>
                    <Gtk.Image iconName="window-close-symbolic" pixelSize={iconSize} />
                </Gtk.Button>
            </Gtk.Box>
            <Gtk.Separator />
            <Gtk.Box cssName="content">
                {n.image && fileExists(n.image) ? <Gtk.Box
                    valign={START}
                    cssName="image"
                    // @ts-expect-error setup is a custom prop
                    setup={(self: Gtk.Box) => {
                        const cssProvider = Gtk.CssProvider.new();
                        const cssData = `box { background-image: url('${n.image}'); }`;
                        cssProvider.load_from_data(cssData, cssData.length);
                        self.get_style_context().add_provider(cssProvider, Gtk.STYLE_PROVIDER_PRIORITY_USER);
                    }}
                /> : null}
                {n.image && isIcon(n.image) ? <Gtk.Box
                    hexpand={false}
                    valign={START}
                    cssName="icon-image">
                    <Gtk.Image iconName={n.image} hexpand halign={CENTER} valign={CENTER} pixelSize={32} />
                </Gtk.Box> : null}
                <Gtk.Box orientation={Gtk.Orientation.VERTICAL}>
                    <Gtk.Label
                        cssName="summary"
                        halign={START}
                        xalign={0}
                        label={n.summary}
                        ellipsize={Pango.EllipsizeMode.END}
                    />
                    {n.body ? <Gtk.Label
                        cssName="body"
                        wrap
                        useMarkup
                        halign={START}
                        xalign={0}
                        justify={Gtk.Justification.FILL}
                        label={n.body}
                    /> : null}
                </Gtk.Box>
            </Gtk.Box>
            {n.get_actions().length > 0 ? <Gtk.Box cssName="actions" spacing={8}>
                {n.get_actions().map(({ label, id }) => {
                    // Create button programmatically
                    const button = new Gtk.Button({ hexpand: true });
                    const buttonLabel = new Gtk.Label({ label: label, halign: CENTER, hexpand: true });
                    button.set_child(buttonLabel);
                    button.connect("clicked", () => n.invoke(id));
                    return button; // Return the configured widget instance
                })}
            </Gtk.Box> : null}
        </Gtk.Box>
    </Gtk.Box>
}