import Battery from "gi://AstalBattery"
import { bind, exec, execAsync } from "astal";
import { Gtk } from "astal/gtk3"
import { uptime } from "../../../utils";

function BatteryProgress() {

    const battery = Battery.get_default();

    const labelOverlay = <label
        label={bind(battery, "percentage").as(p => `${Math.round(p*100)}%`)}
    />

    return (
        <box className="battery-progress"
        vexpand={true}
        hexpand={true}
        visible={bind(battery, "isPresent")}
        >
         <overlay
         vexpand={true}
         overlays={[labelOverlay]}
         >
            <levelbar
            hexpand={true}
            vexpand={true}
            value={bind(battery, "percentage")}
            />
         </overlay>
        </box>
    )
}


export default function Header() {

    const userName = exec("whoami");
    
    return (
        <box className="header horizontal">
            <box className="system-box"
            hexpand={true}
            >
                <box>
                    <box className={"profile-picture"}
                    css={`background-image: url("${SRC}/assets/profile.png");`}
                    />
                    <box
                    vertical={true}
                    >
                        <label className={"username"}
                        label={userName}
                        />
                        <label className="uptime"
                        hexpand={false}
                        valign={Gtk.Align.CENTER}
                        vexpand={true}
                        visible={false}
                        label={uptime().as((uptime) => `uptime: ${uptime}`)}
                        />
                    </box>
                    
                    <button className={"powerButton-CC"}
                    valign={Gtk.Align.CENTER}
                    hexpand={true}
                    halign={Gtk.Align.END}
                    onClick={() => execAsync(["adios", "--systemd"])}
                    >
                        <icon icon="system-shutdown-symbolic"/>
                    </button>
                </box>
            </box>
        </box>
    )
}