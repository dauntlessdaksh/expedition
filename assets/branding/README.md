# Expedition Branding Assets

Place production-ready branding files in this folder before generating store builds.

## Required files

| File | Size | Purpose |
|------|------|---------|
| `app_icon.png` | 1024×1024 | iOS App Store icon source |
| `app_icon_foreground.png` | 1024×1024 | Android adaptive icon foreground |
| `splash_logo.png` | 512×512 (optional) | Native splash center logo |

## Generate native assets

After adding the PNG files above:

```bash
dart run flutter_native_splash:create
dart run flutter_launcher_icons
```

## Theme

- Primary background: `#0A0E14`
- Adaptive icon background: `#0A0E14`
- Splash: dark background with optional centered logo

## Notes

- Keep icon foreground transparent where adaptive icons are used.
- iOS icons should not include alpha (`remove_alpha_ios: true` is configured).
- Replace screenshot placeholders in `/README.md` before App Store submission.
