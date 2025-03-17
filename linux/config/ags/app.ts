#!/usr/bin/env -S ags run
import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/bar/Bar"
import Picker from "./widget/picker/Picker"

App.start({
    css: style,
    // instanceName: "js",
    requestHandler(request, res) {
        print(request)
        res("ok")
    },
    main: () => {
        const monitors = App.get_monitors()
        const bar = monitors.map(Bar)
        const picker = monitors.map(Picker)
        return [...bar, ...picker]
    }
})
