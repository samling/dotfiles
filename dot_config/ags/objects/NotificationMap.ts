import { Astal, Gtk, Gdk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import { Notification }from "../widget/Notification"
import { type Subscribable } from "astal/binding"
import { Variable, bind, timeout } from "astal"

// see comment below in constructor
const TIMEOUT_DELAY = 5000

type NotificationMapOpts = {
    timeout: number,
    dismissOnTimeout?: boolean,
    limit?: number,
    persist?: boolean
}

const notifd = Notifd.get_default()

// The purpose if this class is to replace Variable<Array<Widget>>
// with a Map<number, Widget> type in order to track notification widgets
// by their id, while making it conviniently bindable as an array
export default class NotificationMap implements Subscribable {

    private limit: number | undefined = undefined;
    private timeout: number = 0;
    private dismissOnTimeout: boolean | undefined = undefined;
    

    // the underlying map to keep track of id widget pairs
    private map: Map<number, Gtk.Widget> = new Map()

    // it makes sense to use a Variable under the hood and use its
    // reactivity implementation instead of keeping track of subscribers ourselves
    private var: Variable<Array<Gtk.Widget>> = Variable([])

    // notify subscribers to rerender when state changes
    private notifiy() {
        this.var.set([...this.map.values()].reverse())
    }

    constructor(options: NotificationMapOpts = {timeout: 0, dismissOnTimeout: false, persist: false}) {

        /**
         * uncomment this if you want to
         * ignore timeout by senders and enforce our own timeout
         * note that if the notification has any actions
         * they might not work, since the sender already treats them as resolved
         */
        // notifd.ignoreTimeout = true

        this.limit = options.limit;
        this.timeout = options.timeout;
        this.dismissOnTimeout = options.dismissOnTimeout;

        if (options.persist)
            notifd.get_notifications().forEach((notif) => {
                this.create(notif.id)
            })
        

        notifd.connect("notified", (_, id) => {
            if (notifd.get_dont_disturb()) {
                return;
            }

            this.create(id);
        })

        // notifications can be closed by the outside before
        // any user input, which have to be handled too
        notifd.connect("resolved", (_, id) => {
            this.delete(id)
        })
    }

    private set(key: number, value: Gtk.Widget) {
        if (this.limit != undefined && this.map.size === this.limit) {
            const first = Array.from(this.map.keys())[0]
            this.delete(first)
        }
        // in case of replacecment destroy previous widget
        this.map.get(key)?.destroy()
        this.map.set(key, value)
        this.notifiy()
    }

    private create(id: number) {
        if (notifd.get_dont_disturb()) {
            return;
        }

        this.set(id, Notification({
            notification: notifd.get_notification(id)!,
            setup: () => timeout(this.timeout, () => {
                if (this.timeout != 0) {
                    if (this.dismissOnTimeout) {
                        notifd.get_notification(id).dismiss()
                    }
                    this.delete(id)
                }
            })
        }))
    }

    private delete(key: number) {
        this.map.get(key)?.destroy()
        this.map.delete(key)
        this.notifiy()
    }

    public disposeAll() {
        this.map.forEach((_, id) => {
            notifd.get_notification(id).dismiss()
        })
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