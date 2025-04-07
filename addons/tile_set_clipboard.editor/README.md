# [BETA] TileSet Clipboard

![Addon's icon](/icon.svg)

A Godot addon that adds advanced copying-and-pasting to the tile set editor.



## Features showcase

You can **copy** and **paste** multiple tiles:

![Copying and pasting 4 tiles in a TileSet](/addons/tile_set_clipboard.editor/.assets_for_readme/copy_paste_v2.gif)


You can **filter** which **properties** are pasted:

![Choosing to paste only modulate, then only probability](/addons/tile_set_clipboard.editor/.assets_for_readme/filter_properties_v2.gif)


You can **undo** and **redo** pasting:

![Choosing to paste only modulate, then only probability](/addons/tile_set_clipboard.editor/.assets_for_readme/undo_redo.gif)



## RoadMap

- [x] ~~Add shortcut (ctrl + c and ctr + v). Unknown feasibility. Maybe needs [this Godot PR](https://github.com/godotengine/godot/pull/102807).~~
  - [x] Add shortcut: shift + c and shift + v
        (Found after a lot of trouble that it was possible by grabing focus and using BaseButton's `shortcut`, and that the shift modifier was the only one not intercepted by other GUI)
- [x] Add a way to filter which properties are pasted.
  - [ ] Display custom data name instead of "custom_data_0", "custom_data_1", "custom_data_2"...
  - [ ] Add a way to filter property components (such as x and y for Vector2 properties)
  - [ ] (Maybe) Display value type
  - [ ] (Maybe) Fold peering bits into one property
- [ ] Paste from upper left corner. (Similar to LO Calc when pasting multiple cells in one cell). Unknown feasibility.
- [x] Add wrapping pasting. (Similar to LO Calc when pasting in more cells than there are selected) .
- [ ] (Maybe) Cross instance copy paste (though serialization in the OS paste bin). Unknown feasibility.
- [ ] Add a way to flip or rotate the copied properties (or the selection?)



## Installation

You can download the addon:
- On GitHub: `Code` → `Download ZIP`.
- Through the editor: `AssetLib` → Search for "TileSet Clipboard"

*By default, this readme is included, along with it's illustrations. If you don't want them,
do not download `addons/tile_set_clipboard.editor/README.md` nor `addons/tile_set_clipboard.editor/.assets_for_readme/*`*

You can also exclude `*.editor/*` or `tile_set_clipboard.editor/` from your export presets,
because this addon is editor-only.



## FAQ

### Doesn't Godot's TileSetEditor already have copying-and-pasting?

Yes, but only for one source tile and one property at a time. This addons supports copying-and-pasting multiple properties from multiple tiles at the same time.

### How to change the copy and paste shortcuts?

Modifying shortcuts is not officially supported, but you can modify the addon to achieve this:
- Open [/addons/tile_set_clipboard.editor/buttons.tscn](/addons/tile_set_clipboard.editor/buttons.tscn)
- Select CopyButton or PasteButton
- Expand the `shortcut` property
- Expand the `events` property
- Expand the first InputEvent in this Array
- Click the "Configure" button at the top of the resource
- Save the scene



## Godot version

Minimal version: Godot 4.3



## Credits

The way to interact with the tile set editor trough GDScript was found on
[github.com/dandeliondino/tile_bit_tools](https://github.com/dandeliondino/tile_bit_tools/).
I used some of his code in [scrapper.gd](/addons/tile_set_clipboard.editor/scrapper.gd)



## Development Status

Under development
