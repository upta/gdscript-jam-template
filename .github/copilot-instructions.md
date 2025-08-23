## Overview
Everything in this project is related to game development using the Godot game engine with GDScript.

Don't add extraneous comments or documentation. Only add comments that clarify complex logic.

## Generated files
Godot automatically creates all files that end with the .uid file extension.  They should never be created or edited manually.

## Formatting
- Place two blank lines between functions

## Dictionaries
When working with dicionaries, use the following conventions:
- Prefer strongly-typed dictionaries over untyped ones. (e.g. Dictionary[String, int] instead of Dictionary)
- Prefer to use .get() and .set() methods for accessing dictionary values instead of using the [] operator.