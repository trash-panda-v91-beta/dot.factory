{
  lib,
  config,
  hostname,
  pkgs,
  ...
}:
let
  cfg = config.modules.raycast;
  scripts = "raycast/scripts";
in
{
  options.modules.raycast = {
    enable = lib.mkEnableOption "raycast";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ raycast ];

    xdg.configFile = {
      "${scripts}/rebuild-dots.sh" = {
        text = ''
          #!${pkgs.bash}/bin/bash

          # @raycast.schemaVersion 1
          # @raycast.title Rebuild dots
          # @raycast.mode compact
          # @raycast.packageName Raycast Scripts
          # @raycast.icon ⚫
          # @raycast.currentDirectoryPath ~
          # @raycast.needsConfirmation false
          # Documentation:
          # @raycast.description Run NixOS rebuild command

          /run/current-system/sw/bin/darwin-rebuild switch --flake "git+ssh://git@github.com/aka-raccoon/dot.factory/#${hostname}"
        '';
        executable = true;
      };
      "${scripts}/dismiss-notification.js" = {
        text = ''
          #!/usr/bin/env osascript

          // @raycast.schemaVersion 1
          // @raycast.title Dismiss notification
          // @raycast.mode inline
          // @raycast.packageName Raycast Scripts
          // @raycast.icon 🔔
          // @raycast.currentDirectoryPath ~
          // @raycast.needsConfirmation false
          // Documentation:
          // @raycast.description Dismiss MacOS notification


          (function() {
            const alertAndBannerSet = ["AXNotificationCenterAlert", "AXNotificationCenterBanner"];
            const closeActionSet = [
              "Close", "Clear All", "Zavři!"
            ];

            function getIndexOfItem(anItem, aList) {
              const index = aList.indexOf(anItem);
              if (index === -1) {
                throw new Error(`Item '$${anItem}' not found in list.`);
              }
              return index + 1;
            }

            function closeNotifications() {
              const systemEvents = Application("System Events");
              systemEvents.includeStandardAdditions = true;

              let mainGroup;
              try {
                mainGroup = systemEvents.applicationProcesses["NotificationCenter"]
                  .windows[0].groups[0].groups[0].scrollAreas[0].groups[0];
              } catch (error) {
                systemEvents.displayNotification(error.message, {
                  withTitle: `Error $${error.number}`,
                  soundName: "Frog"
                });
                return;
              }

              const headings = mainGroup.uiElements().filter(el => el.role() === "AXHeading");
              const headingsCount = headings.length;

              for (let i = 0; i < headingsCount; i++) {
                const roles = mainGroup.uiElements().map(el => el.role());
                const headingIndex = getIndexOfItem("AXHeading", roles);
                const closeButtonIndex = headingIndex + 1;

                mainGroup.uiElements[closeButtonIndex - 1].click();
                delay(0.4);
              }

              try {
                const groups = mainGroup.groups();
                if (groups.length === 0) {
                  if (alertAndBannerSet.includes(mainGroup.subrole())) {
                    const actions = mainGroup.actions();
                    actions.forEach(action => {
                      if (closeActionSet.includes(action.description())) {
                        action.perform();
                      }
                    });
                  }
                  return;
                }

                groups.forEach(group => {
                  const actions = group.actions();
                  actions.forEach(action => {
                    if (closeActionSet.includes(action.description())) {
                      action.perform();
                    }
                  });
                });
              } catch (error) {
                if (alertAndBannerSet.includes(mainGroup.subrole())) {
                  const actions = mainGroup.actions();
                  actions.forEach(action => {
                    if (closeActionSet.includes(action.description())) {
                      action.perform();
                    }
                  });
                }
              }
            }

            closeNotifications();
          })();
        '';
        executable = true;
      };
      "${scripts}/open-notification.js" = {
        text = ''
          #!/usr/bin/env osascript

          // @raycast.schemaVersion 1
          // @raycast.title Open notification
          // @raycast.mode inline
          // @raycast.packageName Raycast Scripts
          // @raycast.icon 🔔
          // @raycast.currentDirectoryPath ~
          // @raycast.needsConfirmation false
          // Documentation:
          // @raycast.description Open MacOS notification

          const showActionSet = ["Show"];
          const alertAndBannerSet = ["AXNotificationCenterAlert", "AXNotificationCenterBanner"];

          (function() {
            const systemEvents = Application("System Events");
            try {
              const notificationCenter = systemEvents.processes.byName("NotificationCenter");
              const mainGroup = notificationCenter.windows[0].groups[0].groups[0].scrollAreas[0].groups[0];
              let groups = mainGroup.groups.whose({ subrole: "AXNotificationCenterAlert" });

              let targetGroup;
              if (groups.length === 0) {
                if (alertAndBannerSet.includes(mainGroup.subrole())) {
                  targetGroup = mainGroup;
                } else {
                  return;
                }
              } else {
                targetGroup = groups[0];
              }

              const actions = targetGroup.actions();
              let showActionExists = false;

              for (let action of actions) {
                if (showActionSet.includes(action.description())) {
                  action.perform();
                  showActionExists = true;
                  break;
                }
              }

              if (!showActionExists) {
                targetGroup.actions.byName("AXPress").perform();
              }
            } catch (error) {
              const notification = Application.currentApplication();
              notification.includeStandardAdditions = true;
              notification.displayNotification(error.message, {
                withTitle: `Error $${error.number}`,
              });
            }
          })();
        '';
        executable = true;
      };
    };
  };
}
