# Hojicha ☕

I felt like it would be neat to experiment with a DSL for action bar layouts

```lua
ab {
    id = 1,
    point = "BOTTOM",
    page = "[$cat]7;[$tree]8;[$bear]9;[$moonkin]10;1"
},
ab {
    id = 2,
    point = "BOTTOM",
    y = 38,
    visible = "[mod][combat]true;false"
},
ab { id = 3, columns = 1, point = "RIGHT" },
ab { id = 4, columns = 1, point = "RIGHT", x = -38 },
bags { point = "BOTTOMRIGHT", y = 40 },
menu { point = "BOTTOMRIGHT" },
stance { point = "BOTTOM", x = 38 * -5, y = 40 * 2 },
pet { point = "BOTTOM", y = 40 * 2 },
extra {},
zone {},
vehicle {}
```
