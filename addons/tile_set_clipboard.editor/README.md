# [BETA] TileSet Clipboard

![Addon's icon](/icon.svg)

Adds copy and pasting to the tile set editor.



## Features showcase

You can **copy** and **paste** tiles:

![Copying and pasting 4 tiles in a TileSet](/addons/tile_set_clipboard.editor/.assets_for_readme/copy_paste.gif)

You can **filter** which **properties** are pasted:

![Choosing to paste only modulate, then only probability](/addons/tile_set_clipboard.editor/.assets_for_readme/filter_properties.gif)



## RoadMap

- [ ] Add shortcut (ctrl + c and ctr + v). Unknown feasibility. Maybe needs [this Godot PR](https://github.com/godotengine/godot/pull/102807).
- [x] Add a way to filter which properties are pasted.
  - [ ] Display custom data name instead of "custom_data_0", "custom_data_1", "custom_data_2"...
  - [ ] Add a way to filter property components (such as x and y for Vector2 properties)
  - [ ] (Maybe) Display value type
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
