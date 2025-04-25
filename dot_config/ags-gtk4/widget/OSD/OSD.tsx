import { App, Astal, Gdk, Gtk } from "astal/gtk4";
import { bind, Variable } from "astal";
import { timeout } from "astal/time";
import Wp from "gi://AstalWp";
import Brightness from "./brightness";

function OsdOverlay({ visible }: { visible: Variable<Boolean> }) {
    const brightness = Brightness.get_default();
    const speaker = Wp.get_default()!.get_default_speaker();

    const iconName = Variable("");
    const value = Variable(0);

    let count = 0;
    function show(v: number, icon: string) {
        visible.set(true);
        value.set(v * 0.85 + 0.15);
        iconName.set(icon);
        count++;
        timeout(2000, () => {
            count--;
            if (count === 0) visible.set(false);
        });
    }

    return (
        <revealer
            setup={() => {
                brightness.connect("notify::screen", () => {
                    show(brightness.screen, "display-brightness-symbolic");
                });

                if (speaker) {
                    speaker.connect("notify::volume", () => {
                        show(speaker.volume, "audio-speakers-symbolic");
                    });
                }
            }}
            revealChild={bind(visible).as(Boolean)}
            transitionType={Gtk.RevealerTransitionType.CROSSFADE}
        >
            <box cssClasses={["OSD"]}>
                <levelbar widthRequest={100} value={value()}>
                    <image
                        iconName={iconName()}
                        halign={Gtk.Align.START}
                        valign={Gtk.Align.CENTER}
                    />
                </levelbar>
            </box>
        </revealer>
    );
}

export default function OSD(gdkmonitor: Gdk.Monitor) {
    const visible = Variable(false);

    return (
        <window
            visible={bind(visible)}
            name={"OSD"}
            gdkmonitor={gdkmonitor}
            layer={Astal.Layer.OVERLAY}
            anchor={Astal.WindowAnchor.BOTTOM}
            exclusivity={Astal.Exclusivity.IGNORE}
            application={App}
            cssClasses={["OSD"]}
        >
            <OsdOverlay visible={visible} />
        </window>
    ) as Astal.Window;
}