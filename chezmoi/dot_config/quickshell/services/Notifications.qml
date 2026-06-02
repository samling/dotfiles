pragma Singleton
pragma ComponentBehavior: Bound

import qs.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

/**
 * Provides extra features not in Quickshell.Services.Notifications:
 *  - Persistent storage
 *  - Popup notifications, with timeout
 *  - Notification groups by app
 */
Singleton {
	id: root
    component Notif: QtObject {
        id: wrapper
        required property int notificationId // Could just be `id` but it conflicts with the default prop in QtObject
        property Notification notification
        property list<var> actions: notification?.actions.map((action) => ({
            "identifier": action.identifier,
            "text": action.text,
        })) ?? []
        property bool popup: false
        property string appIcon: notification?.appIcon ?? ""
        property string appName: notification?.appName ?? ""
        property string body: notification?.body ?? ""
        property string image: notification?.image ?? ""
        property string summary: notification?.summary ?? ""
        property double time
        property string urgency: notification?.urgency.toString() ?? "normal"
        property Timer timer
        property int popupDuration: 5000
        property double popupStartTime: 0
        property double popupRemaining: popupDuration

        // Lock mechanism: prevents destruction during animations
        property int _lockCount: 0
        property bool _pendingDiscard: false

        function lock() { _lockCount++ }
        function unlock() {
            _lockCount--
            if (_lockCount <= 0 && _pendingDiscard) {
                _lockCount = 0
                root.discardNotification(notificationId)
            }
        }

        function pausePopup() {
            if (timer && timer.running) {
                popupRemaining = Math.max(0, popupRemaining - (Date.now() - popupStartTime))
                timer.stop()
            }
        }

        function resumePopup() {
            if (timer && popup && popupRemaining > 0) {
                timer.interval = popupRemaining
                popupStartTime = Date.now()
                timer.start()
            }
        }

        onNotificationChanged: {
            if (notification === null) {
                root.discardNotification(notificationId);
            }
        }
    }

    function notifToJSON(notif) {
        return {
            "notificationId": notif.notificationId,
            "actions": notif.actions,
            "appIcon": notif.appIcon,
            "appName": notif.appName,
            "body": notif.body,
            "image": notif.image,
            "summary": notif.summary,
            "time": notif.time,
            "urgency": notif.urgency,
        }
    }
    function notifToString(notif) {
        return JSON.stringify(notifToJSON(notif), null, 2);
    }

    component NotifTimer: Timer {
        required property int notificationId
        interval: 5000
        running: true
        onTriggered: () => {
            root.timeoutNotification(notificationId);
            destroy()
        }
    }

    property bool silent: false
    property var filePath: Directories.notificationsPath
    property list<Notif> list: []
    property var popupList: list.filter((notif) => notif.popup);
    property bool popupInhibited: (GlobalStates?.sidebarRightOpen ?? false) || silent
    property var latestTimeForApp: ({})
    property var _pendingDismissNotifications: []
    readonly property int _dismissBatchSize: 25
    readonly property var log: Log.scoped("Notifications")
    readonly property var notificationConfig: Config.userConfig.notifications || ({})
    readonly property int maxHistoryCount: notificationConfig.maxHistoryCount || 100
    readonly property int maxHistoryAgeDays: notificationConfig.maxHistoryAgeDays || 14
    readonly property bool dedupeEnabled: notificationConfig.dedupe !== false
    readonly property var rules: notificationConfig.rules || []
    
    property Component notifComponent: Component {
        Notif {}
    }
    property Component notifTimerComponent: Component {
        NotifTimer {}
    }

    Timer {
        id: dismissAllTimer
        interval: 1
        repeat: true
        onTriggered: {
            const batch = root._pendingDismissNotifications.splice(0, root._dismissBatchSize)
            batch.forEach((notif) => {
                try {
                    notif.dismiss()
                } catch (e) {
                    root.log.warn("Failed to dismiss tracked notification:", e)
                }
            })
            if (root._pendingDismissNotifications.length === 0) {
                stop()
            }
        }
    }

    function stringifyList(list) {
        return JSON.stringify(list.map((notif) => notifToJSON(notif)), null, 2);
    }

    function persistList() {
        notifFileView.setText(stringifyList(root.list));
    }

    function applyRetentionLimits(list) {
        const now = Date.now()
        const maxAgeMs = maxHistoryAgeDays > 0 ? maxHistoryAgeDays * 24 * 60 * 60 * 1000 : 0
        let kept = list.filter((notif) => maxAgeMs === 0 || !notif.time || now - notif.time <= maxAgeMs)
        if (maxHistoryCount > 0 && kept.length > maxHistoryCount) {
            kept = kept.slice(kept.length - maxHistoryCount)
        }
        return kept
    }

    function notificationContentKey(notif) {
        return [notif.appName || "", notif.summary || "", notif.body || ""].join("\u001f").toLowerCase()
    }

    function textMatches(value, pattern) {
        if (!pattern) return true
        const text = (value || "").toString().toLowerCase()
        const needle = pattern.toString().toLowerCase()
        return text.indexOf(needle) !== -1
    }

    function ruleMatches(rule, notif) {
        let constrained = false
        if (rule.app || rule.appName) {
            constrained = true
            if (!textMatches(notif.appName, rule.app || rule.appName)) return false
        }
        if (rule.summary || rule.title) {
            constrained = true
            if (!textMatches(notif.summary, rule.summary || rule.title)) return false
        }
        if (rule.body) {
            constrained = true
            if (!textMatches(notif.body, rule.body)) return false
        }
        if (rule.match) {
            constrained = true
            if (!textMatches((notif.appName || "") + " " + (notif.summary || "") + " " + (notif.body || ""), rule.match)) return false
        }
        return constrained
    }

    function matchingRuleActions(notif) {
        const actions = []
        rules.forEach((rule) => {
            if (!ruleMatches(rule, notif)) return
            if (rule.action) actions.push(rule.action)
            if (rule.block) actions.push("block")
            if (rule.mute) actions.push("mute")
            if (rule.hidePopup) actions.push("hidePopup")
            if (rule.privacy) actions.push("privacy")
        })
        return actions
    }

    function hasAction(actions, action) {
        return actions.indexOf(action) !== -1
    }

    function applyPrivacy(notif) {
        notif.summary = "Notification"
        notif.body = "Hidden by privacy rule"
        notif.image = ""
        return notif
    }
    
    onListChanged: {
        // Update latest time for each app
        root.list.forEach((notif) => {
            if (!root.latestTimeForApp[notif.appName] || notif.time > root.latestTimeForApp[notif.appName]) {
                root.latestTimeForApp[notif.appName] = Math.max(root.latestTimeForApp[notif.appName] || 0, notif.time);
            }
        });
        // Remove apps that no longer have notifications
        Object.keys(root.latestTimeForApp).forEach((appName) => {
            if (!root.list.some((notif) => notif.appName === appName)) {
                delete root.latestTimeForApp[appName];
            }
        });
    }

    function appNameListForGroups(groups) {
        return Object.keys(groups).sort((a, b) => {
            // Sort by time, descending
            return groups[b].time - groups[a].time;
        });
    }

    function groupsForList(list) {
        const groups = {};
        list.forEach((notif) => {
            if (!groups[notif.appName]) {
                groups[notif.appName] = {
                    appName: notif.appName,
                    appIcon: notif.appIcon,
                    notifications: [],
                    time: 0
                };
            }
            groups[notif.appName].notifications.push(notif);
            // Always set to the latest time in the group
            groups[notif.appName].time = latestTimeForApp[notif.appName] || notif.time;
        });
        return groups;
    }

    property var groupsByAppName: groupsForList(root.list)
    property var popupGroupsByAppName: groupsForList(root.popupList)
    property var appNameList: appNameListForGroups(root.groupsByAppName)
    property var popupAppNameList: appNameListForGroups(root.popupGroupsByAppName)
    


    // Quickshell's notification IDs starts at 1 on each run, while saved notifications
    // can already contain higher IDs. This is for avoiding id collisions
    property int idOffset
    signal initDone();
    signal notify(notification: var);
    signal discard(id: int);
    signal discardAll();
    signal timeout(id: var);

	NotificationServer {
        id: notifServer
        // actionIconsSupported: true
        actionsSupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        imageSupported: true
        keepOnReload: false
        persistenceSupported: true

        onNotification: (notification) => {
            notification.tracked = true
            const incoming = {
                "appIcon": notification.appIcon ?? "",
                "appName": notification.appName ?? "",
                "body": notification.body ?? "",
                "image": notification.image ?? "",
                "summary": notification.summary ?? "",
                "time": Date.now(),
                "urgency": notification.urgency.toString() ?? "normal",
            }
            const ruleActions = matchingRuleActions(incoming)

            if (hasAction(ruleActions, "block")) {
                root.log.debug("Blocked notification", incoming.appName, incoming.summary)
                notification.dismiss()
                return
            }

            if (dedupeEnabled) {
                const incomingKey = notificationContentKey(incoming)
                const duplicateIndex = root.list.findIndex((notif) => notificationContentKey(notif) === incomingKey)
                if (duplicateIndex !== -1) {
                    root.list[duplicateIndex].time = incoming.time
                    triggerListChange()
                    persistList()
                    notification.dismiss()
                    return
                }
            }

            if (hasAction(ruleActions, "privacy")) applyPrivacy(incoming)

            const newNotifObject = notifComponent.createObject(root, {
                "notificationId": notification.id + root.idOffset,
                "notification": notification,
                "appIcon": incoming.appIcon,
                "appName": incoming.appName,
                "body": incoming.body,
                "image": incoming.image,
                "summary": incoming.summary,
                "time": incoming.time,
                "urgency": incoming.urgency,
            });
			root.list = applyRetentionLimits([...root.list, newNotifObject]);
			triggerListChange()

            // Popup
            if (!root.popupInhibited && !hasAction(ruleActions, "mute") && !hasAction(ruleActions, "hidePopup")) {
                const duration = notification.expireTimeout < 0 ? 5000 : (notification.expireTimeout || 5000);
                newNotifObject.popup = true;
                newNotifObject.popupDuration = duration;
                newNotifObject.popupRemaining = duration;
                newNotifObject.popupStartTime = Date.now();
                newNotifObject.timer = notifTimerComponent.createObject(root, {
                    "notificationId": newNotifObject.notificationId,
                    "interval": duration,
                });
            }

            root.notify(newNotifObject);
            persistList();
        }
    }

    function discardNotification(id) {
        root.log.debug("Discarding notification with ID:", id)
        const index = root.list.findIndex((notif) => notif.notificationId === id);

        // Defer if locked (e.g., mid-animation)
        if (index !== -1 && root.list[index]._lockCount > 0) {
            root.list[index]._pendingDiscard = true;
            return;
        }

        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => notif.id + root.idOffset === id);
        if (index !== -1) {
            root.list.splice(index, 1);
            notifFileView.setText(stringifyList(root.list));
            triggerListChange()
        }
        if (notifServerIndex !== -1) {
            notifServer.trackedNotifications.values[notifServerIndex].dismiss()
        }
        root.discard(id); // Emit signal
    }

    function discardAllNotifications() {
        const trackedNotifications = notifServer.trackedNotifications.values.map((notif) => notif)
        root.list = []
        triggerListChange()
        persistList();
        root._pendingDismissNotifications = trackedNotifications
        if (trackedNotifications.length > 0) {
            dismissAllTimer.restart()
        }
        root.discardAll();
    }

    function cancelTimeout(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id);
        if (root.list[index] != null)
            root.list[index].timer.stop();
    }

    function timeoutNotification(id) {
        const index = root.list.findIndex((notif) => notif.notificationId === id);
        if (root.list[index] != null)
            root.list[index].popup = false;
        root.timeout(id);
    }

    function timeoutAll() {
        root.popupList.forEach((notif) => {
            root.timeout(notif.notificationId);
        })
        root.popupList.forEach((notif) => {
            notif.popup = false;
        });
    }

    function attemptInvokeAction(id, notifIdentifier) {
        root.log.debug("Attempting to invoke action", notifIdentifier, "for notification ID", id)
        root.log.debug("idOffset", root.idOffset)
        root.log.debug("Tracked notifications", notifServer.trackedNotifications.values.map(n => ({id: n.id, offset_id: n.id + root.idOffset, actions: n.actions.map(a => a.identifier)})))
        const notifServerIndex = notifServer.trackedNotifications.values.findIndex((notif) => notif.id + root.idOffset === id);
        root.log.debug("Notification server index", notifServerIndex)
        if (notifServerIndex !== -1) {
            const notifServerNotif = notifServer.trackedNotifications.values[notifServerIndex];
            const action = notifServerNotif.actions.find((action) => action.identifier === notifIdentifier);
            root.log.debug("Action found", action)
            if (action) {
                try {
                    root.log.debug("Invoking action", action.text)
                    action.invoke();
                    root.log.debug("Action invoked successfully")
                    
                    // Add a small delay before dismissing to let the action complete
                    Qt.callLater(() => {
                        root.discardNotification(id);
                    });
                } catch (e) {
                    root.log.warn("Error invoking action", e)
                    root.discardNotification(id);
                }
            } else {
                root.log.warn("Action not found with identifier", notifIdentifier)
            }
        }
        else {
            root.log.warn("Notification not found in server", id)
        }
    }

    function triggerListChange() {
        root.list = root.list.slice(0)
    }

    function refresh() {
        notifFileView.reload()
    }

    Component.onCompleted: {
        refresh()
    }

    FileView {
        id: notifFileView
        path: Qt.resolvedUrl(filePath)
        onLoaded: {
            const fileContents = notifFileView.text()
            root.list = applyRetentionLimits(JSON.parse(fileContents).map((notif) => {
                return notifComponent.createObject(root, {
                    "notificationId": notif.notificationId,
                    "actions": [], // Notification actions are meaningless if they're not tracked by the server or the sender is dead
                    "appIcon": notif.appIcon,
                    "appName": notif.appName,
                    "body": notif.body,
                    "image": notif.image,
                    "summary": notif.summary,
                    "time": notif.time,
                    "urgency": notif.urgency,
                });
            }));
            // Find largest notificationId
            let maxId = 0
            root.list.forEach((notif) => {
                maxId = Math.max(maxId, notif.notificationId)
            })

            root.log.debug("File loaded")
            root.idOffset = maxId
            root.initDone()
        }
        onLoadFailed: (error) => {
            if(error == FileViewError.FileNotFound) {
                root.log.debug("File not found, creating new file")
                root.list = []
                notifFileView.setText(stringifyList(root.list));
            } else {
                root.log.error("Error loading file", error)
            }
        }
    }
}
