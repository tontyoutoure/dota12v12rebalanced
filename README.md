# Table of Contents
- [About](#About)
- [Useful Skills](#Useful-Skills)
- [Resources](#Resources)
- [Getting Started](#Getting-Started)
- [Concepts](#Concepts)
- [Project Structure](#Project-Structure)
- [Lua Programming](#Lua-Programming)

# About

This is the open-source github for [Dota 12v12 Rebalanced](https://steamcommunity.com/sharedfiles/filedetails/?id=2019924529).

Our website is here:
- [Dota 12v12 Website](https://dota12v12.com/Rebalanced/)

And our discord is here:
- [Dota 12v12 Discord](https://dota12v12.com/discord)

# Useful Skills

The following are useful skills:
- Web Development (for programming the UI)
    - (The UI uses a Valve framework called Panorama.)
    - JavaScript for implementing the UI logic
    - XML (similar to HTML) for manipulating the UI DOM tree
    - CSS for styling the XML
- Lua
    - for programming game logic
    - this is easy to pick up if you are familiar with another scripting language
- Using the Hammer Editor
    - (not that important since this project used the vanilla Dota map)

# Resources

You will spend a lot of time here:
- [Dota 2 Workshop Tools Wiki](https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools)

For Lua:
- [Programming in Lua](https://www.lua.org/pil/contents.html)

ModDota Discord:
- [Discord Invite](https://discord.gg/wXUs57g)


# Getting Started

When you first download the repo, there will be two folders:
- content
- game

I will explain what to do what these after providing some background. (You will simply need to run a script I've created
but please read through to understand what is going on.)

When in development, Dota 2 custom games are divided into two folders, which are but are in two different locations:
- one which is a subdirectory of "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\content\dota_addons"
    - This is referred to as the "content" folder for the custom game because it is under the "content" directory.
    - This folder contains UI code and other uncompiled resources, like images.
- one which is a subdirectory of "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons"
    - This is referred to as the "game" folder because it is under the "game" directory". 
    - This folder contains the Lua game logic code and the compiled versions of the resources in the content folder.

Both are given the same name, which will be used as the name for the custom game by Dota 2 Workshop Tools.

For example, I used the name "dota12v12rebalanced" and during development I must manage two folders: 
- "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\content\dota_addons\dota12v12rebalanced"
- "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons\dota12v12rebalanced"

It is not practical to manage two folders in different directories.
What we can do is create a single folder somewhere else and, inside that folder,
create links to those two directories above so that we can work in this new folder
as if those two directories are contained within. (It even works with git!)

To make these shortcuts, we must:
move the "content" folder into:
- "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\content\dota_addons"
and rename it "dota12v12rebalanced", and
move the "game" folder into:
- "C:\Program Files (x86)\Steam\steamapps\common\dota 2 beta\game\dota_addons"
and rename it "dota12v12rebalanced".

Then, in some new working directory, we create symbolic links to the newly renamed directories.

I have automated this with a very simple batch script: "setup_links.bat"

You can double click to run the script or execute it from the command prompt.

After getting setup, you should see it listed under "Addon Name" when launching Dota 2 Workshop Tools.

# Concepts 

(This section is a WIP.)

There are three programming components that make up a Dota 2 custom game:
- Client-side UI JavaScript
    - Implements the logic for the UI on the player's machine, such as buttons, etc.
- Client-side Lua
    - Game logic running on the player's machine.
- Server-side Lua
    - Game logic running on the server.

The client-side and server-side Lua use the same Lua code, but there are API methods that allow you to tell which side the current code is running on.

The reason why Lua runs on both the client and server is out-of-scope for this discussion, but more info can be found [here](https://developer.valvesoftware.com/wiki/Latency_Compensating_Methods_in_Client/Server_In-game_Protocol_Design_and_Optimization).

In practice, you can think of all Lua code as running on the server.

There are two ways to communicate between Lua and JavaScript, namely:
- game events
    - one side can trigger an event the other side is listening to
    - see the wiki for more details
- custom net tables
    - each side can write to a table that can be accessed by either side

# Project Structure

(This section is a WIP.)

## UI
The UI code (JavaScript, XML, CSS) go into the "content/panorama" folder.
Panorama is the name of the UI framework developed and used by Valve games.

## Game Logic
The game logic code (Lua scripts) go into the "game/scripts/vscripts" folder.

## Resources
Other resources, such as the map, textures, images, go into other content subdirectories.
When building the project, the compiled versions of these resources are automatically placed in corresponding subdirectories of the game directory.


# Lua Programming

The entry point for custom games is [addon_game_mode.lua](https://github.com/dota12v12rebalanced/dota12v12rebalanced/blob/master/game/scripts/vscripts/addon_game_mode.lua).

This script is like our "main" funciton. Everything our code does must be referenced from here in some way.

## Conventions

While I work as a software developer, I am new to custom game development, so I do not know what the Lua coding conventions are and established my own.

I have tried to keep the code as modular as possible. Each feature is implemented as a separate module (Lua file) that gets "required" by the main script.

Note: I assume below that you are familiar with Lua. Lua does not inherently have classes, similar to JavaScript, but class behavior can be mimicked. (See the Lua documentation.) I generally do not use classes, since I have yet to find a need for a class that produce object instances. Instead, I use "classes" as a package of related methods. (Example below.)

Take for example the "Rune.lua" module:
```Lua
local Rune = class({});

function Rune:Initialize()
    GameRules:GetGameModeEntity():SetRuneSpawnFilter( Dynamic_Wrap( Rune, "RuneSpawnFilter" ), Rune );
end

function Rune:RuneSpawnFilter( filterTable )
	local r = RandomInt( 0, 5 );
    if r == 5 then
        r = 6;
    end
	filterTable.rune_type = r;
	return true;
end

return Rune;
```
I create a class object at the beginning and define all relevant functions as methods of this class object.
This is to avoid polluting the global name space.
At the very end, I return the newly created object.

To use this module, I can use the following line in "addon_game_mode.lua":
```Lua
Rune = require("Rune");
```
which will execute the code in "Rune.lua" and set Rune to the return value of "Rune.lua".

I can then use the contents of the "Rune" module like so:
```Lua
Rune:Initialize();
```

By my own convention, I keep all logic needed to begin using a module in a method named "Initialize()".
