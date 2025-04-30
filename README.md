# BRouter


### Config
1. put config.js at `~/.config/BRouter/config.js`
2. example:
    ```
    {
        "defaultBrowser": "Firefox",
        "editor": "Sublime Text",
        "github": {
            "localDirs": [
                "~/Documents/code",
                "~/Documents/github"
            ],
            "menuMatchs": [
                "*github.com/*/pull/*"
            ],
            "modifiers": [
                "command"
            ]
        },
        "dispatchers": [
            {
                "matchs": [
                    "*.ui.com/*",
                    "*github.com/*",
                    "*figma.com/*",
                    "*apple.com/*",
                    "*icloud.com*",
                    "*icloud.com.cn*",
                    "*.atlassian.net/*",
                    "*slack.com/*",
                    "*.notion.so/*"
                ],
                "browser": "Safari"
            },
            {
                "matchs": [
                    "google.com*"
                ],
                "browser": "Google Chrome"
            }
        ]
    }
    ```
