### Local Development

#### Satisfying dependencies

* Create an example project somewhere: `ags init --gtk 3 -d some/directory`
* Copy the generated `@girs` folder to this folder
* Run `npm install` in this folder

### Running

* `hyprctl dispatch exec 'ags run'`
    * If running within uwsm, `uwsm app -- ags run`

### Inspiration

This is the third iteration of my bar. It draws _heavily_ from [HyprPanel](https://github.com/Jas-SinghFSU/HyprPanel), an extensive and extremely well-designed bar and panel that already implements the majority of modules I wanted for my own. Primarily the goal has been to better understand, piece by piece, how HyprPanel works to inform my own future modules. I've plucked a great many pieces from HyprPanel, with the primary changes being:

* No settings menu; I will eventually implement a config file of my own, but I prefer something copmletely declarative (I know HyprPanel settings can be exported, just a personal choice)
* New/modified modules (e.g. Tailscale, dashboard buttons, etc.)
* My own styles


That said, the majority of this bar's code comes directly from HyprPanel, so they deserve many, many thanks.

Many more thanks go to the following projects from which I've borrowed code, ideas, or both:

* [shadey56/saturn](https://github.com/shadeyg56/saturn)
* [Jas-SinghFSU/HyprPanel](https://github.com/Jas-SinghFSU/HyprPanel)
* [linuxmobile/astal-bar](https://github.com/linuxmobile/astal-bar)
* [rice-cracker-dev/mht-shell](https://github.com/rice-cracker-dev/mht-shell)
* [gitmeED331/agsv2](https://github.com/gitmeED331/agsv2)
* [qxb3/conf](https://github.com/qxb3/conf)