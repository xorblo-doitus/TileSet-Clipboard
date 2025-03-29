# TileSet Clipboard

![Addon's icon](/icon.svg)

Add copy and pasting to the tile set editor.

![Copying and pasting 4 tiles in a TileSet](/addons/bbcode_edit.editor/.assets_for_readme/color_completion.gif)


## RoadMap

- [ ] Add shortcut (ctrl + c and ctr + v). Unknown feasibility. Maybe needs [this Godot PR](https://github.com/godotengine/godot/pull/102807).
- [ ] Add a way to filter which properties are pasted.
- [ ] Paste from upper left corner. (Similar to LO Calc when pasting multiple cells in one cell). Unknown feasibility.
- [ ] Add wrapping pasting. (Similar to LO Calc when pasting in more cells than there are selected) . Unknown feasibility.
- [ ] (Maybe) Cross instance copy paste (though serialization in the OS paste bin). Unknown feasibility.


## Godot version

Godot 4.4


## Credits

The way to interact with the tile set editor trough GDScript was found on
[github.com/dandeliondino/tile_bit_tools](https://github.com/dandeliondino/tile_bit_tools/).
I used some of his code in [scrapper.gd](/addons/tile_set_clipboard.editor/scrapper.gd)


## Development Status

Under development
