/** @type {import("tailwindcss").Config} */
module.exports = {
  "content": [
    "./*.html"
  ],
  "theme": {
    "extend": {
      "colors": {
        "brand": {
          "primary": "#7C3AED",
          "secondary": "#06B6D4",
          "tertiary": "#F97316"
        },
        "primary": {
          "default": "#D0BCFF",
          "on": "#381E72",
          "container": "#4F378B",
          "on-container": "#EADDFF"
        },
        "secondary": {
          "default": "#67E8F9",
          "on": "#003738",
          "container": "#00565A",
          "on-container": "#A2EFF8"
        },
        "tertiary": {
          "default": "#FDB97D",
          "on": "#4A2800",
          "container": "#6B3D00",
          "on-container": "#FFDCBE"
        },
        "error": {
          "default": "#FFB4AB",
          "on": "#690005",
          "container": "#93000A",
          "on-container": "#FFDAD6"
        },
        "surface": {
          "default": "#0A0A0F",
          "dim": "#070B14",
          "bright": "#1A1A24",
          "container-lowest": "#050508",
          "container-low": "#13131A",
          "container": "#1A1A24",
          "container-high": "#212130",
          "container-highest": "#2D2D3D"
        },
        "on-surface": {
          "default": "#E6E1E5",
          "variant": "#CAC4D0"
        },
        "outline": {
          "default": "#938F99",
          "variant": "#49454F"
        },
        "inverse": {
          "surface": "#E6E1E5",
          "on-surface": "#313033",
          "primary": "#7C3AED"
        },
        "scrim": "#000000",
        "shadow": "#000000",
        "semantic": {
          "success": "#22C55E",
          "warning": "#F59E0B",
          "info": "#3B82F6"
        },
        "background": {
          "app": "#0A0A0F",
          "surface": "#13131A",
          "elevated": "#1A1A24",
          "overlay": "#00000080"
        },
        "text": {
          "primary": "#E6E1E5",
          "secondary": "#CAC4D0",
          "muted": "#938F99",
          "inverse": "#313033",
          "on-primary": "#381E72"
        },
        "border": {
          "default": "#49454F",
          "focus": "#D0BCFF",
          "strong": "#938F99"
        },
        "interactive": {
          "primary": "#D0BCFF",
          "primary-hover": "#E8DEF8",
          "primary-pressed": "#B69DF8",
          "primary-disabled": "#D0BCFF40",
          "secondary": "#67E8F9",
          "secondary-hover": "#A2EFF8",
          "destructive": "#FFB4AB"
        },
        "badge": {
          "now-showing": "#4F378B",
          "coming-soon": "#00565A",
          "rating": "#FBBF24",
          "new": "#22C55E"
        },
        "nav": {
          "background": "#13131AE6",
          "active": "#D0BCFF",
          "inactive": "#938F99"
        }
      },
      "spacing": {
        "0": "0px",
        "1": "4px",
        "2": "8px",
        "3": "12px",
        "4": "16px",
        "5": "20px",
        "6": "24px",
        "8": "32px",
        "10": "40px",
        "12": "48px",
        "16": "64px",
        "20": "80px"
      },
      "fontFamily": {
        "heading": [
          "Poppins",
          "Roboto",
          "sans-serif"
        ],
        "body": [
          "Inter",
          "Roboto",
          "sans-serif"
        ],
        "display": [
          "Righteous",
          "Poppins",
          "sans-serif"
        ]
      },
      "boxShadow": {
        "level-0": "0px 0px 0px 0px #00000000",
        "level-1": "0px 1px 2px 0px #00000033",
        "level-2": "0px 2px 6px 2px #00000033",
        "level-3": "0px 4px 8px 3px #00000040",
        "level-4": "0px 6px 10px 4px #00000040",
        "level-5": "0px 8px 12px 6px #00000040",
        "glow-primary": "0px 0px 20px 0px #D0BCFF40"
      }
    }
  },
  "darkMode": "class"
}
