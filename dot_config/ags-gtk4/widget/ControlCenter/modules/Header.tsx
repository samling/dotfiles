import Battery from "gi://AstalBattery"
import { bind, exec, execAsync } from "astal";
import { Gtk } from "astal/gtk4"
import { uptime } from "../../../utils";

function BatteryProgress() {

    const battery = Battery.get_default();

    const labelOverlay = <label
        label={bind(battery, "percentage").as(p => `${Math.round(p*100)}%`)}
    />

    return (
        <box cssClasses={["battery-progress"]}
        vexpand={true}
        hexpand={true}
        visible={bind(battery, "isPresent")}
        >
         <overlay
         vexpand={true}
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
        <box cssClasses={["header", "horizontal"]}>
            <box cssClasses={["system-box"]}
            hexpand={true}
            >
                <box>
                    <box cssClasses={["profile-picture"]}
                    // css={`background-image: url("${SRC}/assets/profile.png");`}
                    />
                    <box
                    vertical={true}
                    >
                        <label cssClasses={["username"]}
                        label={userName}
                        />
                        <label cssClasses={["uptime"]}
                        hexpand={false}
                        valign={Gtk.Align.CENTER}
                        vexpand={true}
                        visible={false}
                        label={uptime().as((uptime) => `uptime: ${uptime}`)}
                        />
                    </box>
                    
                    <button cssClasses={["powerButton-CC"]}
                    valign={Gtk.Align.CENTER}
                    hexpand={true}
                    halign={Gtk.Align.END}
                    onClicked={() => execAsync(["wlogout"]).catch(error => 
                        console.log(`Failed to execute wlogout: ${error.message}`)
                    )}
                    >
                        <image iconName="system-shutdown-symbolic"/>
                    </button>
                </box>
            </box>
        </box>
    )
}