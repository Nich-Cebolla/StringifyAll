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
