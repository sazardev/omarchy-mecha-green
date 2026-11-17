import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

// Mecha HUD — a tactical status strip for the Omarchy bar.
// NET = ping latency, THRT = CPU threat, AMMO = RAM pressure, PWR = battery
// when the machine has one. Left click opens the telemetry panel.
Panel {
  id: root
  moduleName: "sazardev.mecha-hud"
  ipcTarget: "sazardev.mecha-hud"
  manageIpc: false

  readonly property color foreground: bar ? bar.barForeground : Color.foreground
  readonly property color accent: Color.accent
  readonly property color urgent: Color.urgent
  readonly property color muted: Color.muted
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property int pingInterval: Math.max(2, Number(setting("pingIntervalSec", 5)))
  readonly property bool showCpu: setting("showCpu", true) !== false
  readonly property bool showAmmo: setting("showAmmo", true) !== false
  readonly property bool showPower: setting("showPower", true) !== false
  readonly property string configuredHost: String(setting("pingHost", "1.1.1.1"))

  readonly property var hostChoices: [
    { label: "CLOUDFLARE", host: "1.1.1.1" },
    { label: "GOOGLE", host: "8.8.8.8" },
    { label: "GATEWAY", host: telemetry.gateway }
  ]

  function nf(value, digits) {
    var n = Number(value)
    if (!isFinite(n)) return "--"
    return n.toFixed(digits)
  }

  function pad3(value) {
    var text = String(Math.round(value))
    while (text.length < 3) text = "0" + text
    return text
  }

  function colorForLatency(ms) {
    if (!telemetry.pingOk || ms < 0) return urgent
    if (ms < 40) return accent
    if (ms < 100) return foreground
    return urgent
  }

  function colorForCpu(value) {
    if (value < 40) return accent
    if (value < 70) return foreground
    return urgent
  }

  function colorForAmmo(value) {
    if (value < 60) return accent
    if (value < 85) return foreground
    return urgent
  }

  function colorForPower() {
    if (!telemetry.hasBattery) return accent
    if (telemetry.charging) return accent
    if (telemetry.batteryLevel > 35) return foreground
    return urgent
  }

  readonly property string hudTooltip:
    "NET " + (telemetry.pingOk ? nf(telemetry.latency, 0) + " ms" : "no reply") +
    "  ·  THREAT " + nf(telemetry.cpu, 0) + "% " + telemetry.threatLabel +
    "  ·  AMMO " + nf(telemetry.ramUsage, 0) + "% " + telemetry.ammoLabel +
    (telemetry.hasBattery ? "  ·  PWR " + telemetry.batteryLevel + "% " + telemetry.batteryStatus : "  ·  PWR AC") +
    "  ·  right-click cycles ping target"

  function setHost(host) {
    if (!host) return
    var entry = { id: root.moduleName }
    for (var key in root.settings)
      if (key !== "id") entry[key] = root.settings[key]
    entry.pingHost = host
    root.settings = entry
    if (root.bar && root.bar.shell && typeof root.bar.shell.updateEntryInline === "function")
      root.bar.shell.updateEntryInline(root.moduleName, entry)
    telemetry.reset()
    telemetry.pingHost = host
    telemetry.refreshAll()
  }

  function cycleHost() {
    var hosts = ["1.1.1.1", "8.8.8.8"]
    if (telemetry.gateway) hosts.push(telemetry.gateway)
    var current = root.configuredHost
    var index = hosts.indexOf(current)
    root.setHost(hosts[(index + 1) % hosts.length])
  }

  implicitWidth: strip.implicitWidth + Style.space(10)
  implicitHeight: bar ? bar.barSize : Style.bar.sizeHorizontal

  Telemetry {
    id: telemetry
    pingHost: root.configuredHost
    pingIntervalSec: root.pingInterval
  }

  IpcHandler {
    target: root.ipcTarget

    function open(): void { root.open() }
    function close(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): void { telemetry.refreshAll() }
  }

  Row {
    id: strip
    anchors.centerIn: parent
    spacing: Style.space(8)

    HudBlock {
      label: "NET"
      value: telemetry.pingOk ? root.pad3(telemetry.latency) : "--"
      unit: "ms"
      tone: root.colorForLatency(telemetry.latency)
      fill: telemetry.pingOk ? Math.max(0, Math.min(1, 1 - telemetry.latency / 150)) : 0
      segments: 4
    }

    HudSeparator { visible: root.showCpu }

    HudBlock {
      visible: root.showCpu
      label: "THRT"
      value: String(Math.round(telemetry.cpu))
      unit: "%"
      tone: root.colorForCpu(telemetry.cpu)
      fill: telemetry.cpu / 100
      segments: 6
    }

    HudSeparator { visible: root.showAmmo }

    HudBlock {
      visible: root.showAmmo
      label: "AMMO"
      value: String(Math.round(telemetry.ramUsage))
      unit: "%"
      tone: root.colorForAmmo(telemetry.ramUsage)
      fill: telemetry.ramUsage / 100
      segments: 8
    }

    HudSeparator { visible: root.showPower && telemetry.hasBattery }

    HudBlock {
      visible: root.showPower && telemetry.hasBattery
      label: "PWR"
      value: String(telemetry.batteryLevel)
      unit: "%"
      tone: root.colorForPower()
      fill: telemetry.batteryLevel / 100
      segments: 6
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    z: 2
    bar: root.bar
    text: ""
    labelVisible: false
    hasVisualContent: true
    foreground: root.foreground
    tooltipText: root.hudTooltip
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.MiddleButton) telemetry.refreshAll()
      else if (buttonCode === Qt.RightButton) root.cycleHost()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(500))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(650))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(10)

        PanelHero {
          width: parent.width
          title: "MECHA HUD"
          meta: "TACTICAL TELEMETRY // SPARTAN-117"
          detail: "THREAT " + telemetry.threatLabel
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        PanelSeparator { foreground: root.foreground }

        GridLayout {
          width: parent.width
          columns: telemetry.hasBattery ? 2 : 3
          columnSpacing: Style.space(8)
          rowSpacing: Style.space(8)

          TelemetryCard {
            Layout.fillWidth: true
            label: "NET"
            value: telemetry.pingOk ? root.nf(telemetry.latency, 0) : "--"
            unit: "ms"
            detail: "LOSS " + root.nf(telemetry.packetLoss, 0) + "%  ·  " + telemetry.sent + " pkts"
            fill: telemetry.pingOk ? Math.max(0, Math.min(1, 1 - telemetry.latency / 150)) : 0
            tone: root.colorForLatency(telemetry.latency)
            segments: 8
          }

          TelemetryCard {
            visible: root.showCpu
            Layout.fillWidth: true
            label: "THREAT"
            value: root.nf(telemetry.cpu, 0)
            unit: "%"
            detail: telemetry.threatLabel + "  ·  " + root.nf(telemetry.cpu, 0) + "% CPU"
            fill: telemetry.cpu / 100
            tone: root.colorForCpu(telemetry.cpu)
            segments: 8
          }

          TelemetryCard {
            visible: root.showAmmo
            Layout.fillWidth: true
            label: "AMMO"
            value: root.nf(telemetry.ramUsage, 0)
            unit: "%"
            detail: root.nf(telemetry.ramUsed, 1) + " / " + root.nf(telemetry.ramTotal, 1) + " GB"
            fill: telemetry.ramUsage / 100
            tone: root.colorForAmmo(telemetry.ramUsage)
            segments: 8
          }

          TelemetryCard {
            visible: root.showPower && telemetry.hasBattery
            Layout.fillWidth: true
            label: "POWER"
            value: String(telemetry.batteryLevel)
            unit: "%"
            detail: telemetry.batteryStatus !== "" ? telemetry.batteryStatus.toUpperCase() : "AC"
            fill: telemetry.batteryLevel / 100
            tone: root.colorForPower()
            segments: 8
          }
        }

        Text {
          text: "LATENCY // LAST 60 SAMPLES"
          color: root.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 2
        }

        Item {
          width: parent.width
          height: Style.space(118)

          Text {
            text: root.nf(Math.max(50, Math.max.apply(null, telemetry.latencyHistory.concat([50]))), 0) + " ms"
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            anchors.left: parent.left
            anchors.top: parent.top
          }

          Text {
            text: "0"
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            anchors.left: parent.left
            anchors.bottom: parent.bottom
          }

          Canvas {
            id: graph
            anchors.fill: parent
            anchors.leftMargin: Style.space(26)
            anchors.topMargin: Style.space(12)
            anchors.bottomMargin: Style.space(12)

            Connections {
              target: telemetry
              function onLatencyHistoryChanged() { graph.requestPaint() }
            }

            onPaint: {
              var ctx = getContext("2d")
              ctx.clearRect(0, 0, width, height)

              var samples = telemetry.latencyHistory || []
              var count = samples.length
              var maxValue = 50
              for (var i = 0; i < count; i++)
                if (samples[i] > maxValue) maxValue = samples[i]
              maxValue = Math.ceil(maxValue / 50) * 50

              // Grid
              ctx.strokeStyle = Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.10)
              ctx.lineWidth = 1
              for (var g = 0; g <= 4; g++) {
                var gy = Math.round(height * g / 4) + 0.5
                ctx.beginPath()
                ctx.moveTo(0, gy)
                ctx.lineTo(width, gy)
                ctx.stroke()
              }
              for (var v = 0; v <= 6; v++) {
                var gx = Math.round(width * v / 6) + 0.5
                ctx.beginPath()
                ctx.moveTo(gx, 0)
                ctx.lineTo(gx, height)
                ctx.stroke()
              }

              if (count < 2) return

              // Area and line. Gaps are skipped so a lost packet reads as a break.
              var accent = root.accent
              var line = Qt.rgba(accent.r, accent.g, accent.b, 0.92)
              var fill = Qt.rgba(accent.r, accent.g, accent.b, 0.10)
              ctx.lineWidth = 2
              ctx.lineJoin = "round"
              ctx.lineCap = "round"
              ctx.strokeStyle = line
              ctx.fillStyle = fill

              var started = false
              var firstX = 0
              var lastX = 0
              var lastY = 0
              ctx.beginPath()
              for (var j = 0; j < count; j++) {
                var value = samples[j]
                if (value < 0) {
                  started = false
                  continue
                }
                var x = count === 1 ? 0 : (width * j / (count - 1))
                var y = height - Math.max(0, Math.min(1, value / maxValue)) * height
                if (!started) {
                  ctx.moveTo(x, y)
                  started = true
                  firstX = x
                } else {
                  ctx.lineTo(x, y)
                }
                lastX = x
                lastY = y
              }
              ctx.stroke()

              // Soft fill below the line, one segment at a time.
              started = false
              ctx.beginPath()
              for (var k = 0; k < count; k++) {
                var v2 = samples[k]
                if (v2 < 0) {
                  started = false
                  continue
                }
                var x2 = count === 1 ? 0 : (width * k / (count - 1))
                var y2 = height - Math.max(0, Math.min(1, v2 / maxValue)) * height
                if (!started) {
                  ctx.moveTo(x2, height)
                  ctx.lineTo(x2, y2)
                  started = true
                } else {
                  ctx.lineTo(x2, y2)
                }
              }
              if (started && count > 0) {
                ctx.lineTo(lastX, height)
                ctx.closePath()
                ctx.fill()
              }

              // Current point
              ctx.beginPath()
              ctx.arc(lastX, lastY, 2.5, 0, Math.PI * 2)
              ctx.fillStyle = line
              ctx.fill()
            }
          }
        }

        PanelSeparator { foreground: root.foreground }

        Text {
          text: "PING TARGET"
          color: root.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 2
        }

        Row {
          width: parent.width
          spacing: Style.space(8)

          Repeater {
            model: root.hostChoices

            HostButton {
              required property var modelData
              width: (parent.width - Style.space(16)) / 3
              label: modelData.label
              address: modelData.host === telemetry.gateway && telemetry.gateway !== "" ? "LOCAL" : modelData.host
              active: root.configuredHost === modelData.host
              onClicked: root.setHost(modelData.host)
            }
          }
        }

        PanelSeparator { foreground: root.foreground }

        Row {
          width: parent.width
          spacing: Style.space(16)

          Text {
            text: "LOSS " + root.nf(telemetry.packetLoss, 0) + "%"
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Text {
            text: "SAMPLES " + telemetry.sent
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Text {
            text: "UPDATED " + telemetry.lastUpdate
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }
        }

        RowLayout {
          width: parent.width
          spacing: Style.space(16)

          Text {
            Layout.fillWidth: true
            text: "MISSION TIME " + telemetry.formatUptime(telemetry.uptimeSec)
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.letterSpacing: 1
          }

          Text {
            id: resetText
            text: "RESET"
            color: root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.letterSpacing: 2
            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: telemetry.reset()
            }
          }
        }
      }
    }
  }

  component HudSeparator: Rectangle {
    width: 1
    height: Style.space(16)
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.16)
  }

  component HudBlock: Column {
    id: block
    property string label: ""
    property string value: ""
    property string unit: ""
    property color tone: root.accent
    property real fill: 0
    property int segments: 6

    spacing: Style.space(2)
    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    Row {
      spacing: Style.space(3)
      anchors.horizontalCenter: parent.horizontalCenter

      Text {
        text: block.label
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Math.max(7, Style.font.caption - 3)
        font.letterSpacing: 1
        anchors.baseline: valueText.baseline
      }

      Text {
        id: valueText
        text: block.value
        color: block.tone
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
      }

      Text {
        text: block.unit
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Math.max(7, Style.font.caption - 3)
        anchors.baseline: valueText.baseline
      }
    }

    Row {
      spacing: 1
      anchors.horizontalCenter: parent.horizontalCenter

      Repeater {
        model: block.segments

        Rectangle {
          required property int index
          width: 4
          height: 3
          radius: 1
          color: index < Math.ceil(Math.max(0, Math.min(1, block.fill)) * block.segments)
            ? block.tone
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.14)
        }
      }
    }
  }

  component TelemetryCard: Rectangle {
    id: card

    property string label: ""
    property string value: ""
    property string unit: ""
    property string detail: ""
    property real fill: 0
    property color tone: root.accent
    property int segments: 8

    implicitHeight: cardColumn.implicitHeight + Style.space(20)
    radius: Style.cornerRadius
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.045)
    border.width: 1
    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)

    Column {
      id: cardColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(10)
      anchors.rightMargin: Style.space(10)
      spacing: Style.space(5)

      Text {
        text: card.label
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.letterSpacing: 2
      }

      Row {
        spacing: Style.space(3)

        Text {
          id: cardValueText
          text: card.value
          color: card.tone
          font.family: root.fontFamily
          font.pixelSize: Style.font.display
          font.bold: true
        }

        Text {
          text: card.unit
          color: root.muted
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          anchors.baseline: cardValueText.baseline
        }
      }

      Row {
        spacing: 2

        Repeater {
          model: card.segments

          Rectangle {
            required property int index
            width: 6
            height: 4
            radius: 1
            color: index < Math.ceil(Math.max(0, Math.min(1, card.fill)) * card.segments)
              ? card.tone
              : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
          }
        }
      }

      Text {
        text: card.detail
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        width: parent.width
      }
    }
  }

  component HostButton: CursorSurface {
    id: host
    property string label: ""
    property string address: ""
    property bool active: false
    signal clicked()

    foreground: root.foreground
    hasCursor: mouse.containsMouse
    current: active
    implicitHeight: hostColumn.implicitHeight + Style.space(14)
    radius: Style.cornerRadius
    opacity: address !== "" ? 1 : 0.35

    Column {
      id: hostColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      anchors.leftMargin: Style.space(8)
      anchors.rightMargin: Style.space(8)
      spacing: Style.space(2)

      Text {
        text: host.label
        color: host.active ? root.accent : root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
        font.letterSpacing: 1
      }

      Text {
        text: host.address !== "" ? host.address : "UNAVAILABLE"
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        elide: Text.ElideRight
        width: parent.width
      }
    }

    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
      enabled: host.address !== ""
      cursorShape: Qt.PointingHandCursor
      onClicked: host.clicked()
    }
  }
}
