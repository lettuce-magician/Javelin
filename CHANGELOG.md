# Changelog

## Version 1.0.2
- Merged fork from [michlbro](https://github.com/michlbro/Javelin), adding Javelin:Wrap (changed it a little bit).
- New tests for [init.spec.lua](https://github.com/lettuce-magician/Javelin/tree/main/src/init.spec.lua).
- Fixed a bug on Connections where if you add and remove a connection it will think there are connections therefore not trigerring `[Code '1']`.

## Version 1.0.1

- Made it so `Javelin:Emit` first executes all async events first then the synced ones.
- If a connection errors it will throw a warning explaining what got wrong.
- Made `Javelin._useDiag` actually private (I don't know why I made it public).