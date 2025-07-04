# Project Synapse - User Interface Plugin

## Overview
The **Project Synapse - User Interface Plugin** is designed to recreate the user interface from Project Synapse and seamlessly integrate it into the Helix framework. This plugin enhances the user experience by providing custom tab icons and additional functionality for your Helix-based schema.

## Features
- Customizable tab icons for various sections like inventory, settings, scoreboard, and more.
- Easy integration with Helix schemas, specifically tailored for HL2 RP.
- Example faction spawn point setup included for customization.

## Installation
1. **Download the Plugin**: Clone or download the plugin files into your Helix schema's `plugins` folder.
2. **Configure Tab Icons**: Update the `PLUGIN.tabIcons` paths in `sh_plugin.lua` to point to your custom icon files.
3. **Include Faction Spawn Points**: If needed, copy the example spawn point setup into your faction file.

## File Structure
- **cl_hooks.lua**: Client-side hooks for functionality.
- **cl_plugin.lua**: Client-side fonts and sounds setup.
- **sh_plugin.lua**: Shared plugin configuration and tab icon setup.
- **sv_plugin.lua**: Server-side functionality by replacing the default networking of character loading.

## Configuration
### Tab Icons
You can customize the tab icons by modifying the `PLUGIN.tabIcons` table in `sh_plugin.lua`. Replace the paths with your own custom icon paths.

Example:
```lua
PLUGIN.tabIcons = {
    ["config"] = ix.util.GetMaterial("your/custom/path/cogs.png", "smooth mips"),
    ["help"] = ix.util.GetMaterial("your/custom/path/help.png", "smooth mips"),
    ...
}
```

### Faction Spawn Points
To set up faction spawn points, use the provided example in `sh_plugin.lua`:
```lua
FACTION.spawnPoints = {
    ["Location"] = {
        canUse = function(character)
            return true -- Customize this logic as needed
        end
        spawnPoints = {
            Vector(0, 0, 0), -- Replace with actual spawn points
        }
    },
    ["Another Location"] = {
        canUse = function(character)
            return character:GetClass() == CLASS_REBEL -- Example condition
        end,
        spawnPoints = {
            Vector(100, 100, 0), -- Replace with actual spawn points
        }
    }
}
```

## Credits
- **Author**: Riggs
- **Framework**: Helix
- **Schema**: HL2 RP

## License
This project is licensed under the MIT License. See the LICENSE file for details.

## Support
For questions or issues, feel free to reach out to me or consult the Helix documentation.