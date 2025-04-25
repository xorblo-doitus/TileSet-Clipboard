# TileSet Clipboard

![Addon's icon](/icon.svg)

A Godot addon that adds advanced copying-and-pasting to the tile set editor.



## Features showcase

You can **copy** and **paste** multiple tiles:

![Copying and pasting 4 tiles in a TileSet](/addons/tile_set_clipboard.editor/.assets_for_readme/copy_paste_v2.gif)


You can **filter** which **properties** are pasted and optionaly **duplicate** when pasting (for instance when pasting resources):

![Choosing properties to paste](/addons/tile_set_clipboard.editor/.assets_for_readme/filter_properties_v3.gif)


You can **undo** and **redo** pasting:

![Undoing and redoing](/addons/tile_set_clipboard.editor/.assets_for_readme/undo_redo.gif)


Controls are intuitive; they work mostly like in a **spreadsheet**:

![Pasting multiple tiles into one tile, pasting patterns](/addons/tile_set_clipboard.editor/.assets_for_readme/spreadsheet_like.gif)


Features a terrain replacer too:

![Replacing a terrain by another in the selection](/addons/tile_set_clipboard.editor/.assets_for_readme/terrain_swapper.gif)


Example use case:

![Pasting a terrain setup and changing the terrain](/addons/tile_set_clipboard.editor/.assets_for_readme/example_use.gif)



### Static images

Property filters and quick settings:

![Property filters and quick settings](/addons/tile_set_clipboard.editor/.assets_for_readme/property_filter.png)


Settings:

![Settings](/addons/tile_set_clipboard.editor/.assets_for_readme/settings.png)



## RoadMap

I leave the "maybe" stuff for now. If you are interested by their implementation, open an issue.

- [x] ~~Add shortcut (ctrl + c and ctr + v). Unknown feasibility. Maybe needs [this Godot PR](https://github.com/godotengine/godot/pull/102807).~~
  - [x] Add shortcut: shift + c and shift + v
        (Found after a lot of trouble that it was possible by grabing focus and using BaseButton's `shortcut`, and that the shift modifier was the only one not intercepted by other GUI)
- [x] Add a way to filter which properties are pasted.
  - [x] Display custom data name instead of "custom_data_0", "custom_data_1", "custom_data_2"...
  - [ ] (Maybe) Add a way to filter property components (such as x and y for Vector2 properties)
  - [x] (Maybe) Display value type
  - [x] (Maybe) Fold peering bits into one property
- [x] Paste from upper left corner. (Similar to LO Calc when pasting multiple cells in one cell). Unknown feasibility.
- [x] Add wrapping pasting. (Similar to LO Calc when pasting in more cells than there are selected) .
- [ ] (Maybe) Cross instance copy paste (though serialization in the OS paste bin). Unknown feasibility.
- [ ] (Maybe) Add a way to flip or rotate the copied properties (or the selection?)



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

### Can I copy and paste from a TileSet to another?

Yes, but the addon won't paste properties that are set to the default value
(because `get_property_list()` don't give them for some reason). As a workaround,
you can copy-paste a tile from the destination TileSet to the source TileSet at an unused place.
When copying tiles from that source, the addon will notice that a cell in the source has more properties and will copy
the unmodified properties.


## Godot version

Minimal Godot version: 4.4

See the [4.3-backport](https://github.com/xorblo-doitus/TileSet-Clipboard/tree/4.3-backport) branch for a Godot 4.3 compatible version.



## Credits

The way to interact with the tile set editor trough GDScript was found on
[github.com/dandeliondino/tile_bit_tools](https://github.com/dandeliondino/tile_bit_tools/).
I used some of his code in [scrapper.gd](/addons/tile_set_clipboard.editor/scrapper.gd)



## Development Status

LTS (Only bugfixes)
