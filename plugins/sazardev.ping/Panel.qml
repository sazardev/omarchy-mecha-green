import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

// Standalone NET widget. The richer graph lives in sazardev.mecha-hud.
BarWidget {
  id: root
  moduleName: "sazardev.ping"

  readonly property string configuredHost: String(setting("pingHost", "1.1.1.1"))
  readonly property int intervalSec: Math.max(2, Number(setting("pingIntervalSec", 5)))
  readonly property string shortHost: configuredHost.length > 18 ? configuredHost.substring(0, 18) + "…" : configuredHost

  function refresh() { ping.runPing() }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  PingService {
    id: ping
    host: root.configuredHost
    intervalSec: root.intervalSec
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: ping.ok ? "NET " + Math.round(ping.latency) : "NET --"
    active: !ping.ok || ping.latency >= 100
    activeColor: Color.urgent
    foreground: ping.ok ? (ping.latency < 40 ? Color.accent : Color.foreground) : Color.urgent
    tooltipText: (ping.ok ? "NET " + Math.round(ping.latency) + " ms" : "NET no reply")
      + (ping.average >= 0 ? "  ·  avg " + Math.round(ping.average) + " ms" : "")
      + "  ·  loss " + Math.round(ping.packetLoss) + "%"
      + "  ·  " + root.shortHost
      + "  ·  left-click ping test"
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) {
        ping.runPing()
        return
      }
      if (root.bar) root.bar.run("omarchy-launch-floating-terminal-with-presentation ping -c 4 " + Util.shellQuote(ping.safeHost))
    }
  }
}
