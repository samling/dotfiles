import { Astal, Gtk, Gdk } from "astal/gtk4"
import Notifd from "gi://AstalNotifd"
import Notification from "./Notification"
import { type Subscribable } from "astal/binding"
import { Variable, bind, timeout } from "astal"

// see comment below in constructor
const TIMEOUT_DELAY = 5000

// The purpose if this class is to replace Variable<Array<Widget>>
// with a Map<number, Widget> type in order to track notification widgets
// by their id, while making it conviniently bindable as an array
class NotifiationMap implements Subscribable {
    // the underlying map to keep track of id widget pairs
    private map: Map<number, Gtk.Widget> = new Map()

    // it makes sense to use a Variable under the hood and use its
    // reactivity implementation instead of keeping track of subscribers ourselves
    private var: Variable<Array<Gtk.Widget>> = Variable([])

    // notify subscribers to rerender when state changes
    private notifiy() {
        this.var.set([...this.map.values()].reverse())
    }

    constructor() {
        const notifd = Notifd.get_default()

        /**
         * uncomment this if you want to
         * ignore timeout by senders and enforce our own timeout
         * note that if the notification has any actions
         * they might not work, since the sender already treats them as resolved
         */
        // notifd.ignoreTimeout = true

        notifd.connect("notified", (_, id) => {
            this.set(id, Notification({
                notification: notifd.get_notification(id)!,

                // once hovering over the notification is done
                // destroy the widget without calling notification.dismiss()
                // so that it acts as a "popup" and we can still display it
                // in a notification center like widget
                // but clicking on the close button will close it
                onHoverLost: () => this.delete(id),

                // notifd by default does not close notifications
                // until user input or the timeout specified by sender
                // which we set to ignore above
                setup: () => {
                    // console.log(`setup called for id: ${id}`)
                    timeout(TIMEOUT_DELAY, () => {
                        // console.log(`Timeout reached for id: ${id}`)
                        this.delete(id)
                    })
                }
            }))
        })

        // notifications can be closed by the outside before
        // any user input, which have to be handled too
        notifd.connect("resolved", (_, id) => {
            // console.log(`Notification resolved, deleting id: ${id}`)
            this.delete(id)
        })
    }

    private set(key: number, value: Gtk.Widget) {
        // console.log(`Setting notification with id: ${key}`)
        // in case of replacecment destroy previous widget
        this.map.get(key) //?.destroy()
        this.map.set(key, value)
        this.notifiy()
    }

    private delete(key: number) {
        // console.log(`Deleting notification with id: ${key}`)
        this.map.get(key) //?.destroy()
        this.map.delete(key)
        this.notifiy()
    }

    // needed by the Subscribable interface
    get() {
        return this.var.get()
    }

    // needed by the Subscribable interface
    subscribe(callback: (list: Array<Gtk.Widget>) => void) {
        return this.var.subscribe(callback)
    }
}

// Create a single instance of NotifiationMap
const notifs = new NotifiationMap()

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
    const { TOP, RIGHT } = Astal.WindowAnchor
    // Use the shared instance
    // const notifs = new NotifiationMap()

    return <window
        cssName="NotificationPopups"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT}>
        <box vertical>
            {bind(notifs)}
        </box>
    </window>
}