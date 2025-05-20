import Foundation

class ScreenLockObserver {
    init() {
        let dnc = DistributedNotificationCenter.default()

        let _ = dnc.addObserver(forName: NSNotification.Name("com.apple.screenIsLocked"), object: nil, queue: .main) { _ in
            NSLog("Screen Locked")
            self.runBashScript(shortcutName: "Set Personal Focus")
        }

        let _ = dnc.addObserver(forName: NSNotification.Name("com.apple.screenIsUnlocked"), object: nil, queue: .main) { _ in
            NSLog("Screen Unlocked")
            self.runBashScript(shortcutName: "Set Work Focus")
        }

        RunLoop.main.run()
    }

    private func runBashScript(shortcutName: String) {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = ["bash", "-c", "shortcuts run '\(shortcutName)'"]
        task.launch()
        task.waitUntilExit()
    }
}

let _ = ScreenLockObserver()
