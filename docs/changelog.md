<h4>2025-07-06 - 1.3.0</h4>

- Added `StringifyAll.GetPlaceholderSubstrings`.
- Fixed: After 1.2.0, if `Options.FilterTypeMap` was set with a `PropsInfo.FilterGroup` object, `StringifyAll` erroneously treated the value as a `Map` object. This has been corrected.
- Fixed: After 1.2.0, map keys had a change to not be escaped properly. This is corrected.
- Adjusted how `StringifyAll` handles the "key" values (the value assigned to the first parameter of a 2-param <code>for</code> loop). The value is no longer escaped prior to calling `Options.CallbackPlaceholder` or `Options.CallbackGeneral`.
- Adjusted `StringifyAll.Path`. It now caches the path value, and the process for constructing the path string has been optimized. Item names that are strings are quoted with single quote characters, and internal single quote characters are always escaped with a backtick.

<h4>2025-07-05 - 1.2.0</h4>

- Added `StringifyAll.Path`.
- Added `Options.CondenseDepthThreshold`, `Options.CondenseDepthThresholdEnum1`, `Options.CondenseDepthThresholdEnum2`, `Options.CondenseDepthThresholdEnum2Item`, and `Options.CondenseDepthThresholdProps`.
- Removed `StringifyAll.__New` as it is no longer needed.
- Removed some documentation in the parameter hint for `StringifyAll.Call`.
- Fixed two errors in "example\example.ahk".
- Fixed `Options.CallbackGeneral` not receiving the `Controller` (now `Stringify.Path`) object to the first parameter as described in the documentation.
- Adjusted the parameters passed to the callback functions. The `Controller` object is no longer passed to callback functions. Instead, a `StringifyAll.Path` object is passed to the parameters that used to receive the `Controller` object. In this documentation an instance of `StringifyAll.Path` is referred to as `PathObj`. `StringifyAll.Path` is a solution for tracking object paths using string values. Accessing the `PathObj.Path` property  returns the object path, so this change is backward-compatible (unless external code made use of any of the methods that are available on the `Controller` object, which will no longer be available). See the documentation section "StringifyAll.Path" for further details.
- Adjusted the handling of all of the "TypeMap" options. If any of these options are defined with a value that does not inherit from `Map`, that value is used for all types. If any of these options are defined with an object that inherits from `Map` and that object has a property "Count" with a value of `0`, `StringifyAll` optimizes the handling of the option by creating a reference to the "Default" value and using that for all types.
- Adjusted `Recurse`. `HasMethod(Obj, "__Enum")` is checked prior to calling `CheckEnum`.
- Optimized handling of various options.

<h4>2025-06-28 - 1.1.7</h4>

- Fixed `StringifyAll.StrUnescapeJson`.
- Added "test\test-StrUnescapeJson.ahk".

<h4>2025-06-19 - 1.1.6</h4>

- Implemented `Options.InitialIndent`.

<h4>2025-06-15 - 1.1.5</h4>

- Improved the handling of the "CondenseCharLimit" options.
- Implemented `Options.CondenseCharLimitEnum2Item`.

<h4>2025-06-08 - 1.1.4</h4>

- Removed duplicate line of code.

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
