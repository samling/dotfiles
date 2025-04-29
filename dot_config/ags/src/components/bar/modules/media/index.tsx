import AstalMpris from "gi://AstalMpris?version=0.1";
import { bind, Variable } from "astal";
import { Widget, Gtk, App, Gdk } from "astal/gtk3";
import Pango from "gi://Pango";
import { Box } from "astal/gtk4/widget";
import { openMenu } from "../../utils/menu";
import { onPrimaryClick, onSecondaryClick, onMiddleClick, onScroll } from "src/lib/eventHandlers";
import { BarBoxChild } from "src/lib/types/bar";
import { generateMediaLabel } from "./helpers";
import { Astal } from "astal/gtk3";
import { activePlayer, mediaAlbum, mediaArtist, mediaTitle } from "src/globals/media";

// Simplified helper functions
const runAsyncCommand = (command: string, context?: any) => {
    if (!command) return;
    console.log(`Would run command: ${command}`);
    // In the real implementation, this would execute the command
};

const throttledScrollHandler = (interval: number) => {
    return (cmd: string, context?: any) => {
        if (cmd) runAsyncCommand(cmd, context);
    };
};

const mprisService = AstalMpris.get_default();

const truncation = Variable(true);
const truncation_size = Variable(30);
const show_label = Variable(true);
const show_active_only = Variable(false);
const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');
const format = Variable('{artist: - }{title}');

const isVis = Variable(!show_active_only);

Variable.derive([bind(show_active_only), bind(mprisService, 'players')], (showActive, players) => {
    isVis.set(!showActive || players?.length > 0);
});

const Media = (): BarBoxChild => {
    activePlayer.set(mprisService.get_players()[0]);
    const songIcon = Variable('');
    const mediaLabel = Variable.derive([
        bind(activePlayer),
        bind(truncation),
        bind(truncation_size),
        bind(show_label),
        bind(format),
        bind(mediaTitle),
        bind(mediaAlbum),
        bind(mediaArtist),
    ],
    () => {
            return generateMediaLabel(truncation_size, show_label, format, songIcon, activePlayer);
        }
    );

    const componentClassName = `media-container default`

    const component = (
        <box 
        className={componentClassName}
        onDestroy={() => {
            songIcon.drop();
            mediaLabel.drop();
        }}
        >
            <label className={'bar-button-icon media txt-icon bar'} label={bind(songIcon).as((icn) => icn || '󰝚')} />
            <label className={'bar-button-label media'} label={mediaLabel()} />
        </box>
    )

    return {
        component,
        isVis,
        boxClass: 'media',
        props: {
            setup: (self: Astal.Button): void => {
                let disconnectFunctions: (() => void)[] = [];

                Variable.derive([
                    bind(rightClick),
                    bind(middleClick),
                    bind(scrollUp),
                    bind(scrollDown),
                ],
                () => {
                    disconnectFunctions.forEach((disconnect) => disconnect());
                    disconnectFunctions = [];
                    
                    disconnectFunctions.push(
                        onPrimaryClick(self, (clicked, event) => {
                            openMenu(clicked, event, 'mediamenu');
                        })
                    );
                    
                    disconnectFunctions.push(
                        onSecondaryClick(self, (clicked, event) => {
                            runAsyncCommand(rightClick.get(), { clicked, event });
                        })
                    );
                
                    disconnectFunctions.push(
                        onMiddleClick(self, (clicked, event) => {
                            runAsyncCommand(middleClick.get(), { clicked, event });
                        })
                    );
                    
                    const scrollHandler = (dir: string) => {
                        const cmd = dir === 'up' ? scrollUp.get() : scrollDown.get();
                        if (cmd) runAsyncCommand(cmd);
                    };
                    
                    disconnectFunctions.push(
                        onScroll(self, scrollHandler, 'up', 'down')
                    );
                })
            }
        }
    }
}

export { Media };
