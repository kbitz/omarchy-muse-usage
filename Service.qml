import QtQuick
import Quickshell
import Quickshell.Io

// Keeps Muse's usage record fresh in ~/.local/state/omarchy/agents/usage/.
// Omarchy's Agents panel draws any record that lands there, so this only has
// to run the collector; the panel does the rest.
Item {
  id: root
  visible: false

  readonly property string collector: decodeURIComponent(String(Qt.resolvedUrl("muse-usage")).replace(/^file:\/\//, ""))
  readonly property string record: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/omarchy/agents/usage/muse.json"

  Process {
    id: collectProcess
    running: false
    command: ["python3", root.collector]

    stderr: StdioCollector {
      waitForEnd: true
      onStreamFinished: if (text.trim() !== "") console.warn("muse-usage", text.trim())
    }
  }

  Timer {
    interval: 300 * 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!collectProcess.running) collectProcess.running = true
  }

  // Disabling or removing the plugin tears the service down; take the record
  // with it so the Agents panel drops the Muse tab. The numbers are recounted
  // from the session logs on every run, so a reload repopulates it at once.
  // If Omarchy ever ships its own Muse collector the record is that
  // collector's, so leave it alone.
  Component.onDestruction: Quickshell.execDetached(["sh", "-c",
    "command -v omarchy-agent-usage-muse >/dev/null || rm -f \"$1\"", "sh", root.record])
}
