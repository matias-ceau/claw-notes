# Contributing to Claw Notes

Thank you for your interest in contributing to Claw Notes!

## Development Setup

1. Clone the repository
2. Test on an actual Android device with Termux (emulators may not work properly)
3. Install from F-Droid (not Google Play):
   - Termux
   - Termux:API
   - Termux:Boot (optional)

## Guidelines

### Code Style

- Use bash scripts for Termux-specific functionality
- Use Node.js for OpenClaw integrations
- Include the Android compatibility shim (`hijack.js`) for all Node.js code

### Testing

Always test on actual Android hardware:
- Non-rooted devices (most common)
- Different Android versions (7.0+)
- Various storage configurations

### Pull Requests

1. Create a feature branch from `main`
2. Make your changes
3. Test on Android device
4. Submit PR with clear description

### Commit Messages

Use clear, descriptive commit messages:
- `feat: add whisper integration`
- `fix: handle storage permission denial`
- `docs: update setup instructions`

## Key Technical Considerations

### Android Constraints

- No root access assumed
- System Error 13 workaround required (hijack.js)
- Use 127.0.0.1, never 0.0.0.0
- SAF storage access

### Battery & Performance

- Minimize wake lock usage
- Implement proper cleanup
- Consider background restrictions

## Questions?

Open an issue for questions or suggestions.
