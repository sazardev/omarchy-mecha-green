import QtQuick
import Quickshell
import Quickshell.Io

// Small ICMP latency sampler for the standalone NET widget.
Item {
  id: root

  property string host: "1.1.1.1"
  property int intervalSec: 5
  property real latency: -1
  property bool ok: false
  property int sent: 0
  property int lost: 0
  property var history: []
  property string lastUpdate: "--:--:--"
  property bool done: false

  readonly property string safeHost: {
    var value = String(host || "").trim()
    if (!value || value.charAt(0) === "-") return "1.1.1.1"
    return value.replace(/[^A-Za-z0-9.:_-]/g, "")
  }

  readonly property real packetLoss: sent > 0 ? (lost * 100 / sent) : 0
  readonly property real average: {
    var sum = 0
    var count = 0
    for (var i = 0; i < history.length; i++) {
      if (history[i] >= 0) { sum += history[i]; count++ }
    }
    return count > 0 ? sum / count : -1
  }

  function runPing() {
    if (pingProc.running) return
    done = false
    pingProc.command = ["ping", "-n", "-c", "1", "-W", "2", safeHost]
    pingProc.running = true
  }

  function handle(raw) {
    if (done) return
    done = true
    var text = String(raw || "")
    var match = text.match(/time[=<]([0-9.]+)\s*ms/)
    sent += 1
    var value = match ? Number(match[1]) : -1
    if (value >= 0) {
      latency = value
      ok = true
    } else {
      latency = -1
      ok = false
      lost += 1
    }
    history = history.concat([value]).slice(-60)
    lastUpdate = Qt.formatTime(new Date(), "HH:mm:ss")
  }

  onHostChanged: {
    sent = 0
    lost = 0
    history = []
    latency = -1
    ok = false
    runPing()
  }

  Process {
    id: pingProc
    running: false
    command: []
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handle(text)
    }
    onExited: function(exitCode) {
      if (!root.done) root.handle("")
    }
  }

  Timer {
    interval: root.intervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runPing()
  }
}
