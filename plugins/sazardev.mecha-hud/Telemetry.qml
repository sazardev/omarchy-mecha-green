import QtQuick
import Quickshell
import Quickshell.Io

// Shared telemetry for the Mecha HUD bar widget.
// Commands are fixed apart from the ping host, which is passed as an argv
// element rather than interpolated into a shell string.
Item {
  id: root

  property string pingHost: "1.1.1.1"
  property int pingIntervalSec: 5
  property int cpuIntervalSec: 2
  property int memIntervalSec: 5
  property int powerIntervalSec: 15
  property int gatewayIntervalSec: 60

  readonly property int maxSamples: 60
  readonly property string safeHost: {
    var value = String(pingHost || "").trim()
    if (!value || value.charAt(0) === "-") return "1.1.1.1"
    return value.replace(/[^A-Za-z0-9.:_-]/g, "")
  }

  property real latency: -1
  property bool pingOk: false
  property int sent: 0
  property int lost: 0
  property var latencyHistory: []
  readonly property real packetLoss: sent > 0 ? (lost * 100 / sent) : 0

  property real cpu: 0
  property var cpuHistory: []
  property var lastCpu: null

  property real ramTotal: 0
  property real ramUsed: 0
  readonly property real ramUsage: ramTotal > 0 ? (ramUsed / ramTotal * 100) : 0

  property bool hasBattery: false
  property int batteryLevel: 100
  property string batteryStatus: ""
  property bool charging: false

  property string gateway: ""
  property int uptimeSec: 0
  property string lastUpdate: "--:--:--"

  readonly property string threatLabel: cpu < 25 ? "LOW" : cpu < 50 ? "GUARDED" : cpu < 75 ? "ELEVATED" : "SEVERE"
  readonly property string ammoLabel: ramUsage < 60 ? "READY" : ramUsage < 85 ? "LOW" : "CRITICAL"

  function pushSample(list, value) {
    return list.concat([value]).slice(-maxSamples)
  }

  function reset() {
    sent = 0
    lost = 0
    latency = -1
    pingOk = false
    latencyHistory = []
    cpuHistory = []
    lastCpu = null
  }

  function refreshAll() {
    runPing()
    runCpu()
    runMem()
    runPower()
    runUptime()
    runGateway()
  }

  function runPing() {
    if (pingProc.running) return
    pingDone = false
    pingProc.command = ["ping", "-n", "-c", "1", "-W", "2", safeHost]
    pingProc.running = true
  }

  property bool pingDone: false

  function handlePing(raw) {
    if (pingDone) return
    pingDone = true
    var text = String(raw || "")
    var match = text.match(/time[=<]([0-9.]+)\s*ms/)
    sent += 1
    if (match) {
      latency = Number(match[1])
      pingOk = true
      latencyHistory = pushSample(latencyHistory, latency)
    } else {
      latency = -1
      pingOk = false
      lost += 1
      latencyHistory = pushSample(latencyHistory, -1)
    }
    lastUpdate = Qt.formatTime(new Date(), "HH:mm:ss")
  }

  function runCpu() {
    if (cpuProc.running) return
    cpuProc.running = true
  }

  function handleCpu(raw) {
    var fields = String(raw || "").trim().split(/\s+/)
    if (fields.length < 5) return
    var values = []
    for (var i = 1; i < fields.length; i++) values.push(Number(fields[i]) || 0)
    var idle = values[3] + (values[4] || 0)
    var total = 0
    for (var j = 0; j < values.length; j++) total += values[j]
    if (lastCpu && total > lastCpu.total) {
      var totalDelta = total - lastCpu.total
      var idleDelta = idle - lastCpu.idle
      var usage = Math.round(Math.max(0, Math.min(100, (1 - idleDelta / totalDelta) * 100)))
      cpu = usage
      cpuHistory = pushSample(cpuHistory, usage)
    }
    lastCpu = { total: total, idle: idle }
  }

  function runMem() {
    if (memProc.running) return
    memProc.running = true
  }

  function handleMem(raw) {
    var parts = String(raw || "").trim().split(/\s+/)
    if (parts.length < 2) return
    var totalKb = Number(parts[0])
    var availKb = Number(parts[1])
    if (!totalKb || !availKb) return
    ramTotal = totalKb / 1048576
    ramUsed = (totalKb - availKb) / 1048576
  }

  function runPower() {
    if (powerProc.running) return
    powerProc.running = true
  }

  function handlePower(raw) {
    var line = String(raw || "").trim()
    if (!line) {
      hasBattery = false
      batteryLevel = 100
      batteryStatus = "AC"
      charging = true
      return
    }
    var parts = line.split("|")
    hasBattery = true
    batteryLevel = Math.max(0, Math.min(100, parseInt(parts[0]) || 0))
    batteryStatus = parts[1] || ""
    charging = /Charging|Full/.test(batteryStatus)
  }

  function runUptime() {
    if (uptimeProc.running) return
    uptimeProc.running = true
  }

  function handleUptime(raw) {
    var value = String(raw || "").trim().split(/\s+/)[0]
    uptimeSec = parseInt(value) || 0
  }

  function runGateway() {
    if (gatewayProc.running) return
    gatewayProc.running = true
  }

  function handleGateway(raw) {
    gateway = String(raw || "").trim()
  }

  function formatUptime(seconds) {
    var days = Math.floor(seconds / 86400)
    var hours = Math.floor((seconds % 86400) / 3600)
    var mins = Math.floor((seconds % 3600) / 60)
    return (days > 0 ? days + "d " : "") + (hours < 10 ? "0" : "") + hours + ":" + (mins < 10 ? "0" : "") + mins
  }

  Process {
    id: pingProc
    running: false
    command: []
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handlePing(text)
    }
    onExited: function(exitCode) {
      if (!root.pingDone) root.handlePing("")
    }
  }

  Timer {
    interval: root.pingIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runPing()
  }

  Process {
    id: cpuProc
    running: false
    command: ["bash", "-lc", "head -1 /proc/stat"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handleCpu(text)
    }
  }

  Timer {
    interval: root.cpuIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runCpu()
  }

  Process {
    id: memProc
    running: false
    command: ["bash", "-lc", "awk '/MemTotal|MemAvailable/ {print $2}' /proc/meminfo"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handleMem(text)
    }
  }

  Timer {
    interval: root.memIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runMem()
  }

  Process {
    id: powerProc
    running: false
    command: ["bash", "-lc", "for b in /sys/class/power_supply/BAT*; do [ -d \"$b\" ] || continue; c=$(cat \"$b/capacity\" 2>/dev/null); s=$(cat \"$b/status\" 2>/dev/null); printf '%s|%s\\n' \"$c\" \"$s\"; break; done"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handlePower(text)
    }
  }

  Timer {
    interval: root.powerIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runPower()
  }

  Process {
    id: uptimeProc
    running: false
    command: ["cat", "/proc/uptime"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handleUptime(text)
    }
  }

  Timer {
    interval: 60000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runUptime()
  }

  Process {
    id: gatewayProc
    running: false
    command: ["bash", "-lc", "ip route show default 2>/dev/null | awk '/^default/ {print $3; exit}'"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.handleGateway(text)
    }
  }

  Timer {
    interval: root.gatewayIntervalSec * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.runGateway()
  }

  onPingHostChanged: {
    reset()
    runPing()
  }

  Component.onCompleted: refreshAll()
}
