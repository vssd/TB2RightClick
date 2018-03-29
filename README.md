Consider: This is *really* old stuff.

# TB2RightClick

Delphi unit to be able to be notified of right clicks on Toolbar2000 items, e.g. to have popup menus for menu items.

Version 1.0
https://github.com/vssd/TB2RightClick

Copyright (C) 2006 Volker Siebert, <flocke@vssd.de>

## Compatibility

Verified Delphi versions: 5 to 2006

Verified Toolbar2000 versions: 2.1.7

## Description

Someone asked if it was able to assign a popup menu to individual Toolbar2000 items. Since they are not really visible controls, this is not possible.

If you capture the `WM_RBUTTONDOWN` or `WM_CONTEXTMENU` of the toolbar itself, it only fires for clicks on the toolbar directly and not on items in popup menus.

The included unit works around this by hooking all `WM_RBUTTONDOWN` messages via a `WH_GETMESSAGE` message hook and posts an application defined message to the toolbar's owner form.

See the included sample application for how to use this unit.
