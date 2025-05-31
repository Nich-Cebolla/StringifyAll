
<h4>2025-05-31 - 1.1.3</h4>

- When `StringifyAll` processes an object, it caches a the string object path. Previously, the cached path was overwritten each time an object was processed, resulting in a possibility for `StringifyAll` to cause AHK to crash if it entered into an infinite loop. This has been corrected by adjusted the tracking of object ptr addresses to add the string object path to an array each time an object is processed, and to check all paths when testing if two objects share a parent-child relationship.

<h4>2025-05-31 - 1.1.2</h4>

- Added error for invalid return values from `Options.EnumTypeMap`.

<h4>2025-05-31 - 1.1.1</h4>

- Fixed: If an object's enumerator is called in 1-param mode but returns zero valid items, the empty object no longer has a line break between the open and close bracket.

<h4>2025-05-31 - 1.1.0</h4>

- **Breaking:** Increased the number of values passed to `CallbackGeneral`.
- Implemented `Options.CallbackError`.
- Implemented `Options.Multiple`.
- Created "test\test-errors.ahk" to test the error-related options.
- Created "test\test-recursion.ahk" to test `Options.Multiple`.
- Created "test\test.ahk" to run all tests.
- Adjusted `Options.PrintErrors` to allow specifying what properties to be included in the output string.
- Fixed an error causing a small chance for `StringifyAll` to incorrectly apply a property value to the subsequent property.
- Fixed an error that occurred when using `Options.CallbackGeneral` and `StringifyAll` encounters a duplicate object resulting in an invalid JSON string.

<h4>2025-05-30 - 1.0.5</h4>

- Fixed an error causing `StringifyAll` to incorrectly handle objects returned by a `Map` object's enumerator, resulting in an invalid JSON string.

<h4>2025-05-29 - 1.0.4</h4>

- Corrected the order of operations in `StringifyAll.StrUnescapeJson`.

<h4>2025-05-29 - 1.0.3</h4>

- Implemented `ConfigLibrary`.

<h4>2025-05-28 - 1.0.1</h4>

- Adjusted how `Options.PropsTypeMap` is handled. This change did not modify `StringifyAll`'s behavior, but it is now more clear both in the code and in the documentation what the default value is and what the default value does.
- Added "StringifyAll's process" to the docs.
