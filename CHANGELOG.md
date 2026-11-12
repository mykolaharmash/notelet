# Changelog

## 2.0.0

### Breaking changes

- Removed `NoteletSheetHeight` and the `sheetHeight` option from `NoteletConfiguration`. The optional `presentationDetents: Set<PresentationDetent>?` configuration option replaces it and overrides the default `[.fraction(0.85), .large]` detents on all devices.

### Layout improvements

- Adapted page widths when folding and unfolding iPhone Duo and hid inactive pages to prevent neighboring content from peeking through.
- Added centered progress dots and a circular arrow or checkmark button, with the button at the bottom of a vertical toolbar when available.
- Aligned the footer with the sheet's bottom edge while preserving the soft scroll edge effect.
