# Default Scene Selector

A minimal editor tool to select the project's default scene via dropdown for Godot Engine 3.5+.

## Why?
For testing and export purposes I want to switch the project's main scene quite frequently for some of my projects. That's how it can be done quickly.

## Installation
1. Close Godot Editor if currently open.
2. Move directory **bifractal-default-scene-selector** from the **addons/** folder to your project's **addons/** folder.
3. Re-open Godot Editor, open your project and go to the **Project Settings / Plugins** tab.
4. Activate plugin by checking **Enable** for **Default Scene Selector**.

## How-To

The plugin's UI is located at the top of the editor window, inside the toolbar.

![UI Preview](images/ui_top.jpg)

* Click on the folder icon to look for a scene you want to add to the list.
* Select your project's main scene from the dropdown menu or **None** to use no default scene.
* Right-click on the dropdown button to open the context menu and select **Clear List** to remove all scene items. Removing single items is not supported yet.

## Limitations
As of the initial version, your current project's main scene is not applied automatically on activation! Make sure to add it to the addon's list and select it afterwards.
