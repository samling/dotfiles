import { Astal, Gdk, App, Gtk, Widget } from "astal/gtk3";
import { bind, Binding, timeout, Variable } from "astal";
import Wp from "gi://AstalWp";
import { hideWindow, toggleWindow } from "../utils";
import Brightness from "../lib/Brightness";

const audio = Wp.get_default()!;
const brightness = Brightness.get_default();

const shown = Variable("");
const hovering = Variable(false);
const lastChanged = Variable(-1);

const OSD_TIMEOUT = 3000;

interface OSDItemProps{
    name: string
    icon: string,
    property: Binding<number>,
    callback: (slider: Widget.Slider) => void
}

function showOSD(name: string, changed: number) {
    const window = App.get_window("osd");
    if (window === null)
        return;
    if (!window.visible)
        toggleWindow("osd");
    shown.set(name);
    timeout(OSD_TIMEOUT, () => {
        if (!hovering.get() && changed == lastChanged.get()) {
            hideWindow("osd");
        }
    })
}

function OSDItem({name, icon, property, callback}: OSDItemProps) {
    const iconName = Variable(icon);

    const setup = () => {
        property.subscribe((value) => {
            const time = Date.now();
            lastChanged.set(time);
            showOSD(name, time);
        })

        // For volume, update icon based on mute state and volume level
        if (name === "volume" && audio.defaultSpeaker) {
            audio.defaultSpeaker.connect("notify", (speaker) => {
                if (speaker.get_mute()) {
                    iconName.set("audio-volume-muted-symbolic");
                } else {
                    const vol = speaker.volume * 100;
                    if (vol > 67) {
                        iconName.set("audio-volume-high-symbolic");
                    } else if (vol > 34) {
                        iconName.set("audio-volume-medium-symbolic");
                    } else if (vol > 0) {
                        iconName.set("audio-volume-low-symbolic");
                    } else {
                        iconName.set("audio-volume-muted-symbolic");
                    }
                }
            });
        }
    }

    return (
        <box name={name} className="osd-container" 
        vertical={true} 
        setup={setup}>
            <icon className="osd-icon" icon={name === "volume" ? bind(iconName) : icon}/>
            <slider className="osd-slider"
            vertical={true}
            inverted={true}
            value={bind(property)}
            onDragged={callback}
            hexpand={true}
            drawValue={false}
            />
        </box>
    )
}

export default function OSDWindow(gdkmonitor: Gdk.Monitor) {
    return (
        <window
        name="osd"
        namespace="osd"
        anchor={Astal.WindowAnchor.RIGHT}
        visible={false}
        gdkmonitor={gdkmonitor}
        application={App}
        marginRight={25}
        >
            <revealer
            revealChild={false}
            transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
            >   
                <eventbox 
                onHover={() => hovering.set(true)}
                onHoverLost={() => {
                    hovering.set(false);
                    timeout(OSD_TIMEOUT, () => hideWindow("osd"))
                }}
                >
                    <stack shown={bind(shown)}
                    transitionType={Gtk.StackTransitionType.CROSSFADE}
                    transitionDuration={100}
                    >
                        <OSDItem name="volume" icon={"audio-volume-medium-symbolic"} 
                        property={bind(audio.defaultSpeaker, "volume")}
                        callback={({value}) => audio.defaultSpeaker.volume = value}
                        />
                        <OSDItem name="brightness" icon={"display-brightness-symbolic"} 
                        property={bind(brightness, "screen")}
                        callback={({value}) => brightness.screen = value}
                        />
                        <box name=""/>
                    </stack>
                </eventbox>
            </revealer>
        </window>
    ) as Astal.Window
}