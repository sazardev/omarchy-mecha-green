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

  Process {
    id: liveNext
    command: ["bash", "-lc", "exec mecha-live-next"]
    onExited: function(exitCode) { if (exitCode !== 0) bgNext.running = true }
  }

  Process {
    id: bgNext
    command: ["omarchy", "theme", "bg", "next"]
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
    contentWidth: panel.fittedContentWidth(Style.space(660))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(900))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Canvas {
        id: backdrop
        anchors.fill: parent
        z: -1
        enabled: false
        opacity: 0.9
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
        Connections {
          target: root
          function onForegroundChanged() { backdrop.requestPaint() }
          function onAccentChanged() { backdrop.requestPaint() }
        }
        onPaint: {
          var ctx = getContext("2d")
          ctx.clearRect(0, 0, width, height)
          ctx.strokeStyle = Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
          ctx.lineWidth = 1
          for (var y = 0; y < height; y += 4) {
            ctx.beginPath(); ctx.moveTo(0, y + 0.5); ctx.lineTo(width, y + 0.5); ctx.stroke()
          }
          ctx.strokeStyle = Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.025)
          for (var x = 0; x < width; x += 64) {
            ctx.beginPath(); ctx.moveTo(x + 0.5, 0); ctx.lineTo(x + 0.5, height); ctx.stroke()
          }
          var pad = 8
          var arm = 20
          ctx.strokeStyle = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.52)
          ctx.lineWidth = 2
          ctx.beginPath()
          ctx.moveTo(pad, pad + arm); ctx.lineTo(pad, pad); ctx.lineTo(pad + arm, pad)
          ctx.moveTo(width - pad - arm, pad); ctx.lineTo(width - pad, pad); ctx.lineTo(width - pad, pad + arm)
          ctx.moveTo(pad, height - pad - arm); ctx.lineTo(pad, height - pad); ctx.lineTo(pad + arm, height - pad)
          ctx.moveTo(width - pad - arm, height - pad); ctx.lineTo(width - pad, height - pad); ctx.lineTo(width - pad, height - pad - arm)
          ctx.stroke()
        }
      }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(8)

        PanelHero {
          width: parent.width
          title: "MECHA COMMAND"
          meta: "UNSC // SPARTAN-117 // TACTICAL UPLINK"
          detail: telemetry.pingOk ? "LINK ACTIVE" : "LINK LOST"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        RowLayout {
          width: parent.width

          Text {
            Layout.fillWidth: true
            text: "MISSION // HOLD THE LINE"
            color: root.accent
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.letterSpacing: 2
            font.bold: true
          }
          Text {
            text: "SECTOR 07 // 117"
            color: root.muted
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            font.letterSpacing: 2
          }
        }

        RowLayout {
          width: parent.width
          spacing: Style.space(10)

          StatusBar {
            Layout.fillWidth: true
            Layout.preferredWidth: Style.space(130)
            label: "UPLINK"
            value: telemetry.pingOk ? root.pad3(telemetry.latency) + " MS" : "NO LINK"
            fill: telemetry.pingOk ? Math.max(0, Math.min(1, 1 - telemetry.latency / 150)) : 0
            tone: root.colorForLatency(telemetry.latency)
          }

          StatusBar {
            Layout.fillWidth: true
            Layout.preferredWidth: Style.space(130)
            label: "CORE"
            value: String(Math.round(100 - telemetry.cpu)) + "%"
            fill: Math.max(0, Math.min(1, 1 - telemetry.cpu / 100))
            tone: root.colorForCpu(telemetry.cpu)
          }

          StatusBar {
            Layout.fillWidth: true
            Layout.preferredWidth: Style.space(130)
            label: "AMMO"
            value: String(Math.round(100 - telemetry.ramUsage)) + "%"
            fill: Math.max(0, Math.min(1, 1 - telemetry.ramUsage / 100))
            tone: root.colorForAmmo(telemetry.ramUsage)
          }

          StatusBar {
            visible: telemetry.hasBattery
            Layout.fillWidth: true
            label: "POWER"
            value: telemetry.hasBattery ? telemetry.batteryLevel + "%" : "AC"
            fill: telemetry.hasBattery ? telemetry.batteryLevel / 100 : 1
            tone: root.colorForPower()
          }
        }

        PanelSeparator { foreground: root.foreground }

        Row {
          width: parent.width
          spacing: Style.space(10)

          GridLayout {
            id: telemetryGrid
            width: parent.width - objectives.width - Style.space(10)
            columns: 2
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
            Layout.fillWidth: true
            label: "SHIELD"
            value: telemetry.pingOk ? root.nf(Math.max(0, 100 - telemetry.latency / 1.5), 0) : "0"
            unit: "%"
            detail: telemetry.pingOk ? "UPLINK INTEGRITY" : "SIGNAL LOST"
            fill: telemetry.pingOk ? Math.max(0, Math.min(1, 1 - telemetry.latency / 150)) : 0
            tone: root.colorForLatency(telemetry.latency)
            segments: 8
          }

          TelemetryCard {
            Layout.fillWidth: true
            label: "PACKET"
            value: root.nf(100 - telemetry.packetLoss, 0)
            unit: "%"
            detail: telemetry.sent + " samples  ·  " + root.nf(telemetry.packetLoss, 0) + "% loss"
            fill: Math.max(0, Math.min(1, 1 - telemetry.packetLoss / 100))
            tone: root.colorForLatency(telemetry.latency)
            segments: 8
          }

          TelemetryCard {
            visible: !telemetry.hasBattery
            Layout.fillWidth: true
            label: "MISSION"
            value: telemetry.formatUptime(telemetry.uptimeSec)
            unit: ""
            detail: "SECTOR 07  ·  HOLD THE LINE"
            fill: 1
            tone: root.accent
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

          ObjectivesPanel {
            id: objectives
            width: Style.space(218)
            height: Math.max(telemetryGrid.height, implicitHeight)
          }
        }

        Text {
          text: "UPLINK LATENCY // LAST 60 SAMPLES"
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
          spacing: Style.space(10)

          Column {
            width: parent.width - feedButton.width - Style.space(10)
            spacing: Style.space(2)

            Text {
              text: "LIVE FEED // VIDEO WALLPAPERS"
              color: root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.letterSpacing: 2
            }

            Text {
              text: "OWE // H.264 // 2560×1440 // NEXT LIVE CYCLES VIDEOS"
              color: root.muted
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }

          FeedButton {
            id: feedButton
            label: "NEXT LIVE"
            onClicked: liveNext.running = true
          }
        }

        PanelSeparator { foreground: root.foreground }

        RowLayout {
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

          Item { Layout.fillWidth: true; height: 1 }

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

  component StatusBar: Column {
    id: status
    property string label: ""
    property string value: ""
    property real fill: 0
    property color tone: root.accent

    spacing: Style.space(4)

    Row {
      width: parent.width
      Text {
        text: status.label
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.letterSpacing: 2
      }
      Item { width: Math.max(0, parent.width - parent.children[0].width - valueLabel.width); height: 1 }
      Text {
        id: valueLabel
        text: status.value
        color: status.tone
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.bold: true
      }
    }

    Row {
      width: parent.width
      spacing: 2
      Repeater {
        model: 14
        Rectangle {
          required property int index
          width: Math.max(2, (status.width - 26) / 14)
          height: 4
          color: index < Math.ceil(Math.max(0, Math.min(1, status.fill)) * 14)
            ? status.tone
            : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.13)
        }
      }
    }
  }

  component ObjectiveRow: Row {
    id: objective
    property string label: ""
    property string state: ""
    property color tone: root.accent

    width: parent ? parent.width : 0
    spacing: Style.space(7)

    Rectangle {
      width: 6
      height: 6
      rotation: 45
      color: objective.tone
      anchors.verticalCenter: parent.verticalCenter
    }

    Column {
      width: parent.width - 20
      spacing: 1
      Text {
        text: objective.label
        color: root.foreground
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.letterSpacing: 1
      }
      Text {
        text: objective.state
        color: objective.tone
        font.family: root.fontFamily
        font.pixelSize: Math.max(8, Style.font.caption - 2)
        font.letterSpacing: 1
      }
    }
  }

  component ObjectivesPanel: Rectangle {
    id: objectivePanel

    implicitHeight: objectivesColumn.implicitHeight + Style.space(20)
    radius: Style.cornerRadius
    color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.035)
    border.width: 1
    border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.14)

    Column {
      id: objectivesColumn
      anchors.left: parent.left
      anchors.right: parent.right
      anchors.top: parent.top
      anchors.margins: Style.space(10)
      spacing: Style.space(7)

      Text {
        text: "OBJECTIVES // ACTIVE"
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Style.font.caption
        font.letterSpacing: 2
      }

      Radar {
        width: parent.width
        height: width
      }

      ObjectiveRow {
        label: "MAINTAIN UPLINK"
        state: telemetry.pingOk ? (telemetry.latency < 100 ? "SECURE" : "DEGRADED") : "LOST"
        tone: root.colorForLatency(telemetry.latency)
      }
      ObjectiveRow {
        label: "MONITOR THREAT"
        state: telemetry.cpu < 40 ? "LOW" : (telemetry.cpu < 70 ? "GUARDED" : "CRITICAL")
        tone: root.colorForCpu(telemetry.cpu)
      }
      ObjectiveRow {
        label: "PRESERVE AMMO"
        state: telemetry.ramUsage < 60 ? "NOMINAL" : (telemetry.ramUsage < 85 ? "LOW" : "CRITICAL")
        tone: root.colorForAmmo(telemetry.ramUsage)
      }
      ObjectiveRow {
        label: "SECURE POWER"
        state: telemetry.hasBattery ? (telemetry.charging ? "CHARGING" : (telemetry.batteryLevel > 35 ? "NOMINAL" : "LOW")) : "AC LINK"
        tone: root.colorForPower()
      }

      Rectangle {
        width: parent.width
        height: 1
        color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
      }

      Text {
        text: "MISSION CLOCK"
        color: root.muted
        font.family: root.fontFamily
        font.pixelSize: Math.max(8, Style.font.caption - 2)
        font.letterSpacing: 2
      }
      Text {
        text: telemetry.formatUptime(telemetry.uptimeSec)
        color: root.accent
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
        font.bold: true
        font.letterSpacing: 2
      }
    }
  }

  component Radar: Canvas {
    id: radar
    property real sweep: 0

    NumberAnimation on sweep {
      from: 0
      to: 360
      duration: 6000
      loops: Animation.Infinite
      running: panel.open
    }
    onSweepChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    Component.onCompleted: requestPaint()

    onPaint: {
      var ctx = getContext("2d")
      ctx.clearRect(0, 0, width, height)
      var cx = width / 2
      var cy = height / 2
      var r = Math.min(width, height) / 2 - 4
      var accent = root.accent
      var fg = root.foreground

      ctx.strokeStyle = Qt.rgba(fg.r, fg.g, fg.b, 0.20)
      ctx.lineWidth = 1
      for (var ring = 1; ring <= 3; ring++) {
        ctx.beginPath()
        ctx.arc(cx, cy, r * ring / 3, 0, Math.PI * 2)
        ctx.stroke()
      }
      for (var spoke = 0; spoke < 8; spoke++) {
        var a = spoke * Math.PI / 4
        ctx.beginPath()
        ctx.moveTo(cx + Math.cos(a) * r * 0.18, cy + Math.sin(a) * r * 0.18)
        ctx.lineTo(cx + Math.cos(a) * r, cy + Math.sin(a) * r)
        ctx.stroke()
      }

      var sweepAngle = (radar.sweep - 90) * Math.PI / 180
      ctx.beginPath()
      ctx.moveTo(cx, cy)
      ctx.arc(cx, cy, r, sweepAngle - 0.55, sweepAngle, false)
      ctx.closePath()
      ctx.fillStyle = Qt.rgba(accent.r, accent.g, accent.b, 0.12)
      ctx.fill()
      ctx.beginPath()
      ctx.moveTo(cx, cy)
      ctx.lineTo(cx + Math.cos(sweepAngle) * r, cy + Math.sin(sweepAngle) * r)
      ctx.strokeStyle = Qt.rgba(accent.r, accent.g, accent.b, 0.85)
      ctx.lineWidth = 1.5
      ctx.stroke()

      var contacts = [
        { a: 38, r: 0.56, label: "C-01", tone: accent },
        { a: 146, r: 0.42, label: "C-02", tone: fg },
        { a: 258, r: 0.68, label: "C-03", tone: root.urgent }
      ]
      ctx.font = "10px " + root.fontFamily
      ctx.textAlign = "center"
      for (var i = 0; i < contacts.length; i++) {
        var c = contacts[i]
        var ca = (c.a - 90) * Math.PI / 180
        var px = cx + Math.cos(ca) * r * c.r
        var py = cy + Math.sin(ca) * r * c.r
        ctx.beginPath()
        ctx.arc(px, py, 3, 0, Math.PI * 2)
        ctx.fillStyle = Qt.rgba(c.tone.r, c.tone.g, c.tone.b, 0.9)
        ctx.fill()
        ctx.fillStyle = Qt.rgba(fg.r, fg.g, fg.b, 0.62)
        ctx.fillText(c.label, px, py - 7)
      }
    }
  }

  component FeedButton: Rectangle {
    id: feed
    property string label: ""
    signal clicked()

    implicitWidth: Style.space(112)
    implicitHeight: Style.space(32)
    radius: Style.cornerRadius
    color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, mouse.containsMouse ? 0.16 : 0.07)
    border.width: 1
    border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.55)

    Text {
      anchors.centerIn: parent
      text: feed.label
      color: root.accent
      font.family: root.fontFamily
      font.pixelSize: Style.font.caption
      font.bold: true
      font.letterSpacing: 2
    }

    MouseArea {
      id: mouse
      anchors.fill: parent
      hoverEnabled: true
      cursorShape: Qt.PointingHandCursor
      onClicked: feed.clicked()
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
