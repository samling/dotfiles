import { Gtk } from "astal/gtk4";
import { GLib } from "astal";
import Pango from "gi://Pango";
import AstalNotifd from "gi://AstalNotifd";

const time = (time: number, format = "%H:%M") =>
  GLib.DateTime.new_from_unix_local(time).format(format);

const isIcon = (icon: string) => {
  const iconTheme = new Gtk.IconTheme();
  return iconTheme.has_icon(icon);
};

const fileExists = (path: string) => GLib.file_test(path, GLib.FileTest.EXISTS);

const urgency = (n: AstalNotifd.Notification) => {
  const { LOW, NORMAL, CRITICAL } = AstalNotifd.Urgency;

  switch (n.urgency) {
    case LOW:
      return "low";
    case CRITICAL:
      return "critical";
    case NORMAL:
    default:
      return "normal";
  }
};

// Escape special characters for GTK markup
const escapeMarkup = (text: string) => {
  if (!text) return "";
  return text
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
};

export default function Notification({
  n,
  showActions = true,
  showProgressBar = false,
}: {
  n: AstalNotifd.Notification;
  showActions?: boolean;
  showProgressBar?: boolean;
}) {
  // Main notification structure
  return (
    <box
      name={n.id.toString()}
      cssClasses={["notification-container", urgency(n)]}
      hexpand={false}
      vexpand={false}
    >
      <box vertical>
        {/* Header with app icon, name, time and close button */}
        <box cssClasses={["notif-header"]}>
          {(n.appIcon || n.desktopEntry) && (
            <image
              cssClasses={["app-icon"]}
              visible={!!(n.appIcon || n.desktopEntry)}
              iconName={n.appIcon || n.desktopEntry}
            />
          )}
          <label
            cssClasses={["app-name"]}
            halign={Gtk.Align.START}
            label={n.appName || "Unknown"}
          />
          <label
            cssClasses={["time"]}
            hexpand
            halign={Gtk.Align.END}
            label={time(n.time)!}
          />
          <button cssClasses={["notif-close"]} onClicked={() => n.dismiss()}>
            <image iconName={"window-close-symbolic"} />
          </button>
        </box>
        
        <Gtk.Separator visible orientation={Gtk.Orientation.HORIZONTAL} />
        
        {/* Content area with image and text */}
        <box cssClasses={["notif-main"]} spacing={10}>
          {n.image && fileExists(n.image) && (
            <box valign={Gtk.Align.START} cssClasses={["notif-img"]}>
              <image 
                file={n.image} 
                overflow={Gtk.Overflow.HIDDEN}
                hexpand={true}
                vexpand={true}
                halign={Gtk.Align.FILL}
                valign={Gtk.Align.FILL}
              />
            </box>
          )}
          {n.image && isIcon(n.image) && (
            <box cssClasses={["notif-img"]} valign={Gtk.Align.START}>
              <image
                iconName={n.image}
                iconSize={Gtk.IconSize.LARGE}
                hexpand={true}
                vexpand={true}
                halign={Gtk.Align.FILL}
                valign={Gtk.Align.FILL}
              />
            </box>
          )}
          <box hexpand vertical>
            <label
              ellipsize={Pango.EllipsizeMode.END}
              maxWidthChars={30}
              cssClasses={["notif-summary"]}
              halign={Gtk.Align.START}
              xalign={0}
              label={n.summary}
            />
            {n.body && (
              <label
                cssClasses={["notif-body"]}
                maxWidthChars={30}
                wrap
                halign={Gtk.Align.START}
                xalign={0}
                useMarkup
                label={escapeMarkup(n.body)}
              />
            )}
          </box>
        </box>
        
        {/* Action buttons */}
        {showActions && n.get_actions().length > 0 && (
          <box cssClasses={["notif-actions"]} spacing={6}>
            {n.get_actions().map(({ label, id }) => (
              <button cssClasses={["notif-action"]} hexpand onClicked={() => n.invoke(id)}>
                <label label={label} halign={Gtk.Align.CENTER} hexpand />
              </button>
            ))}
          </box>
        )}
        
        {/* Progress bar */}
        {showProgressBar && (
          <box cssClasses={["notification-progress-bar"]}>
            <box setup={(widget) => {
              // Create a progress bar
              const progressBar = new Gtk.ProgressBar();
              progressBar.set_fraction(1.0);
              progressBar.set_hexpand(true);
              progressBar.set_valign(Gtk.Align.CENTER);
              
              // Add it to the box
              widget.append(progressBar);
              
              // Direct animation setup on the widget
              let fraction = 1.0;
              
              // Set up animation timeout
              const timeout = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
                fraction -= 0.01;
                if (fraction <= 0) {
                  progressBar.set_fraction(0);
                  return false; // Stop animation
                } else {
                  progressBar.set_fraction(fraction);
                  return true; // Continue animation
                }
              });
              
              // Cleanup on widget destruction
              widget.connect('destroy', () => {
                if (timeout) {
                  GLib.source_remove(timeout);
                }
              });
            }}/>
          </box>
        )}
      </box>
    </box>
  );
}