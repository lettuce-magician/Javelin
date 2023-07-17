# Changelog

## Version 1.0.1

- Made it so `Javelin:Emit` first executes all non-sync events first then the synced ones.
- If a connection errors it will throw a warning explaining what got wrong.
- Made `Javelin._useDiag` actually private (I don't know why I made it public).