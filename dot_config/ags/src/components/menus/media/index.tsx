import AstalMpris from "gi://AstalMpris?version=0.1";
import { bind } from "astal";
import { Gtk } from "astal/gtk3";
import Pango from "gi://Pango";
import DropdownMenu from "../shared/dropdown";
const media = AstalMpris.get_default();

function TrackInfo({ player }: { player: AstalMpris.Player }) {
    return (
        <box className="track-info" vertical>
            <label className="track-name"
                justify={Gtk.Justification.LEFT}
                xalign={0}
                ellipsize={Pango.EllipsizeMode.END}
                label={bind(player, "title").as(title => title?.length > 0 ? title : "Unknown title")}
            />
            <label className="artist-name"
                justify={Gtk.Justification.LEFT}
                xalign={0}
                label={bind(player, "artist").as(artist => artist?.length > 0 ? artist : "Unknown artist")}
            />
        </box>
    );
}

function MediaControls({ player }: { player: AstalMpris.Player }) {
    return (
        <box className="media-controls" hexpand halign={Gtk.Align.CENTER}>
            <button className="previous-button" onClick={() => player.previous()}>
                <icon icon="media-skip-backward-symbolic" />
            </button>
            <button className="play-button" onClick={() => player.play_pause()}>
                <icon icon={bind(player, "playbackStatus").as(status => 
                    status === AstalMpris.PlaybackStatus.PLAYING
                    ? "media-playback-pause-symbolic"
                    : "media-playback-start-symbolic"
                )} />
            </button>
            <button className="next-button" onClick={() => player.next()}>
                <icon icon="media-skip-forward-symbolic" />
            </button>
        </box>
    );
}

export default (): JSX.Element => {
    const mediaContent = bind(media, "players").as(players => {
        const player = players.find(p => p.get_entry() === "spotify") ?? players[0];
        
        if (!player) {
            return <label>No media player detected</label>;
        }

        return (
            <box className="media-box" vertical>
                <TrackInfo player={player} />
                <MediaControls player={player} />
            </box>
        );
    });

    return (
        <DropdownMenu
            name="mediamenu"
        >
            {mediaContent}
        </DropdownMenu>
    );
}
