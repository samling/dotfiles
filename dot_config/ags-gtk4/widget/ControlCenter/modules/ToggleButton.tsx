import { bind, timeout, Variable } from "astal";
import { Gtk, Widget, Astal, Gdk } from "astal/gtk4";
import Binding from "astal/binding";
import { controlCenterStackWidget } from "../ControlCenter";

interface SimpleToggleProps {
    child?: Gtk.Widget,
    toggle: () => void,
    condition: Binding<boolean>,
}

interface ArrowButtonProps {
    name: string
    icon: Gtk.Widget,
    label: Gtk.Widget,
    activate: () => void,
    deactivate: () => void,
    activateOnArrow?: boolean,
    condition: Binding<boolean>
}

interface MenuProps {
    name: string,
    title: string,
    child?: Gtk.Widget | Binding<Gtk.Widget>
}

const opened = Variable("");

export function Arrow(name: string, activate: () => void) {
    let deg = 0;
    let iconOpened = false;

    const iconSetup = (icon: Gtk.Image) => {
        opened.subscribe((opened) => {
            if (opened === name && !iconOpened || opened !== name && iconOpened) {
                const step = opened === name ? 10 : -10;
                iconOpened = !iconOpened;
                for (let i = 0; i < 9; ++i) {
                    timeout(15 * i, () => {
                        deg += step;
                        icon.cssClasses.push(`rotate(${deg}deg)`);
                    ;});
                }
            }
        })
    }

    
    return (
        <button
        onClicked={() => {
            opened.set(opened.get() === name ? "" : name)
            activate();
        }}
        >
            <image iconName="pan-end-symbolic"
            setup={iconSetup}
            />
        </button>
    )
}

export function ArrowToggleButton({
    name,
    icon,
    label,
    activate,
    deactivate,
    activateOnArrow = true,
    condition
}: ArrowButtonProps) {

    return (
        <box cssClasses={bind(condition).as((c) => c ? ["toggle-button", "active"] : ["toggle-button"])}> 
            <button
            onPrimaryClick={() => {
                controlCenterStackWidget.set(name)
            }}
            onSecondaryClick={() => {
                if (condition.get()) {
                    deactivate();
                    if (opened.get() === name)
                        opened.set("");
                } else {
                    activate();
                }
            }}
            >
                <box cssClasses={["label-box-horizontal"]}
                hexpand={true}
                >
                    {icon}
                    {label}
                </box>
            </button>
        </box>
    )
}

export function Menu({name, title, child}: MenuProps) {
    return (
        <box name={name} vertical={true} cssClasses={["menu"]}>
                <button
                onClicked={() => controlCenterStackWidget.set("controlcenter")}
                halign={Gtk.Align.START}
                cssClasses={["menu-back"]}
                >
                    <image iconName="go-previous-symbolic"/>
                </button>
                <label cssClasses={["menu-title"]} label={title}
                halign={Gtk.Align.START}
                />
                <Gtk.ScrolledWindow vexpand={true}>
                    {child}
                </Gtk.ScrolledWindow>
        </box>
    )
}



export function SimpleToggleButton({
    child,
    toggle,
    condition,
}: SimpleToggleProps) {


    return (
        <button cssClasses={bind(condition).as((c) => c ? ["simple-toggle", "active"] : ["simple-toggle"])}
        onClick={toggle}
        valign={Gtk.Align.CENTER}
        halign={Gtk.Align.CENTER}
        >
            {child}
        </button>
    )
}