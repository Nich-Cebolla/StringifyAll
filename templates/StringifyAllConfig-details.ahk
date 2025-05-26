
class  StringifyAllConfig {

; ==== Enum options ---------------------------------------------------------------------------------
    /**
     * @property {*} StringifyConfig.EnumCondition - A function or callable object that returns an
     * indicator if an object should be enumerated, and if so, to use 1-param mode or 2-param mode.
     * The function should accept one parameter, the object that is being evaluated, and should
     * return one of the indicators described below.
     * Valid indicators are:
     * - 1 = call `Obj.__Enum` in 1-parameter mode.
     * - 2 = call `Obj.__Enum` in 2-parameter mode.
     * - 0 / empty string = Do not call `Obj.__Enum`.
     * Also see {@link StringifyConfig.EnumTypeMap}.
     */
    static EnumCondition := unset
    /**
     * @property {Map} StringifyConfig.EnumTypeMap - A `Map` object where the keys are object types
     * and the values are an integer indicating how `Stringify` should enumerate objects of that type.
     * When unset, `Stringify` only uses `EnumCondition` to determine how to handle enumeration. When
     * set, `Stringify`'s behavior adapts in these ways:
     * - During initialization, `Stringify` checks if the `Default` property has been set on the `Map`
     * object.
     *   - If `Default` is set, then `Stringify` ignores `StringifyConfig.EnumCondition` completely
     * and calls `StringifyConfig.EnumTypeMap.Get(Type(Obj))` for all objects that `Stringify` processes.
     *   - If `Default` is not set, then `Stringify` calls `StringifyConfig.EnumTypeMap.Has(Type(Obj))`.
     * If true, `Stringify` uses the item's value. If false, `Stringify` uses the return value from
     * `StringifyConfig.EnumCondition`.
     * - See {@link StringifyConfig.EnumCondition} for valid indicator values.
     */
    static EnumTypeMap := unset
    /**
     * @property {Boolean} StringifyConfig.ExcludeMethods - If true, properties with a `Call`
     * accessor and properties with only a `Set` accessor are excluded from stringification. If false
     * or unset, those kinds of properties are included in the JSON string with the name of the
     * function object.
     */
    static ExcludeMethods := unset
    /**
     * @property {String} StringifyConfig.ExcludeProps - A comma-delimited, case-insensitive list of
     * property names to exclude from stringification. Also see {@link StringifyConfig.Filter} and
     * {@link StringifyConfig.FilterMap}.
     */
    static ExcludeProps := unset
    /**
     * @property {PropsInfo.FilterGroup} StringifyConfig.Filter - A single `PropsInfo.FilterGroup`
     * object that will be applied to all `PropsInfo` objects iterated during stringification. If
     * `StringifyConfig.FilterMap` is set, this is ignored.
     */
    static Filter := unset
    /**
     * @property {Map} StringifyConfig.FilterMap - A `Map` object where the keys are object types
     * and the values are `PropsInfo.FilterGroup` objects. `Stringify` will apply the filter when
     * iterating the properties of an object of the indicated types. You can use the `Default` property
     * of the map object to specify a default `PropsInfo.FilterGroup` to use for all objects, and then
     * add additional items to the map for specific object types.
     *
     * Note that if you do not set the `Map` object's `Default` value, `Stringify` will set it to `0`.
     */
    static FilterMap := unset
    /**
     * @property {Integer} StringifyConfig.MaxDepth - The maximum depth `Stringify` will recurse
     * into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up. At
     * any given point, the indentation level can be as large as 3x the depth level. This is due
     * to how `Stringify` handles map and array items.
     */
    static MaxDepth := unset
    /**
     * @property {*} StringifyConfig.PropsCondition - A function or callable object that returns an
     * indicator if an object's properties should be stringified. The function should accept one
     * parameter, the object being evaluated, and should return a nonzero value if the object's
     * properties should be stringified, or a falsy value if the object's properties should not
     * be stringified.
     * Also see {@link StringifyConfig.PropsTypeMap}.
     */
    static PropsCondition := unset
    /**
     * @property {Map} StringifyConfig.PropsTypeMap - A `Map` object where the keys are object types
     * and the values are a boolean indicating whether or not `Stringify` should process the object's
     * properties.
     * - The baseline behavior for `Stringify` is to create a `PropsInfo` object for all objects that
     * are stringified. If `PropsInfoObj.Count > 0`, then `Stringify` will process the properties
     * included among the `PropsInfo` object. If `PropsInfoObj.Count == 0`, `Stringify` does not
     * process properties for the object.
     * - When `StringifyConfig.PropsTypeMap` and `StringifyConfig.PropsCondition` are both unset,
     * `Stringify` uses the baseline process described above for all objects.
     * - When `StringifyConfig.PropsTypeMap` is set, `Stringify`'s behavior adapts in these ways:
     *   - During initialization, `Stringify` checks if the `Default` property has been set on the
     * `Map` object.
     *     - If `Default` is set, then `Stringify` ignores `StringifyConfig.PropsCondition` completely
     * and calls `StringifyConfig.PropsTypeMap.Get(Type(Obj))` for all objects that `Stringify` processes.
     *     - If `Default` is not set, then `Stringify` calls `StringifyConfig.PropsTypeMap.Has(Type(Obj))`.
     * If true, `Stringify` uses the item's value. If false, `Stringify` uses the return value from
     * `StringifyConfig.PropsCondition` if it is in use. If not in use, `Stringify` uses the baseline
     * behavior described above.
     *
     * - A nonzero value directs `Stringify` to process the object's properties using the behavior
     * described above. A falsy value directs `Stringify` to skip processing an object's properties.
     */
    static PropsTypeMap := unset

    /**
     * @property {Map} StringifyConfig.StopAtMap - A `Map` object where the keys are object types and
     * the values are strings or numbers that will be passed to the `StopAt` parameter of `GetPropsInfo`.
     * For example, if I don't want `Stringify` to include the `Length`, `Capacity`, or `__Item`
     * properties when processing `Array` objects, one way to do this would be to define
     * `StringifyConfig.StopAtMap` to direct `GetPropsInfo` not to include properties owned by
     * `Array.Prototype`, as seen in the below example.
     * @example
     *  StringifyConfig.StopAtMap := Map('Array', '-Array')
     * @
     *
     * Note that if you use this option and do not set the `Map` object's default value, `Stringify`
     * will set the default to "-Object".
     *
     * See the parameter hints for `GetBaseObjects` within the file "GetBaseObjects.ahk" for full
     * details about this parameter.
     */
    static StopAtMap := unset

; ==== Callbacks -----------------------------------------------------------------------------------
    /**
     * @property {*} StringifyConfig.CallbackGeneral - A function or callable object, or an array of
     * one or more functions or callable objects, that will be called for each object prior to processing.
     * The function should accept up to two parameters:
     * - The object about to be processed
     * - {VarRef} A variable that will receive a reference to the JSON string being created.
     *
     * The function(s) can return a nonzero value to direct `Stringify` to skip processing the object.
     * Any further functions in an array of functions are necessarily also skipped in this case.
     * If the return value is a string, that string will be used as the placeholder for the object
     * in the JSON string. If the return value is a number, and if `StringifyConfig.CallbackPlaceholder`
     * is set, `StringifyConfig.CallbackPlaceholder` will be called to generate the placeholder. If
     * `StringifyConfig.CallbackPlaceholder` is unset, the built-in placeholder is used. If
     * your function returns a string:
     * - Don't forget to escape the necessary characters. You can call `Stringify.StrEscapeJson`
     * to do this for you.
     * - Note that `Stringify` does **not** enclose the value in quotes when adding it to the JSON
     * string. Your function should add the quote characters, or call `Stringify.StrEscapeJson` which
     * has the option to add the quote characters for you.
     *
     * The function(s) should not call `Stringify`; `Stringify` relies on several variables in the
     * function's scope that would be altered by concurrent function calls, causing unexpected
     * behavior for any earlier `Stringify` calls.
     *
     * The following is a description of the part of the process which the function(s) are called.
     * `Stringify` proceeds in two stages, initialization and recursive processing. After initialization,
     * the function `Recurse` is called once, which starts the second stage. When `Stringify`
     * encounters a value that is an object, it proceeds through a series of condition checks to
     * determine if it will call `Recurse` again for that value. Before calling `Recurse`,
     * `Stringify` checks the following conditions. When a value is skipped, a placeholder is
     * printed instead.
     * - If the value is a `ComObject` or `ComValue`, the value is skipped.
     * - If the value has already been stringified, the value is skipped. This is intended to prevent
     * infinite recursion, but currently causes `Stringify` to skip all subsequent encounters of an
     * object after the first, not just problematic ones. I will implement a more flexible solution.
     * - If no further recursion is permitted according to `StringifyConfig.MaxDepth`, the value is
     * skipped.
     * If none of the above conditions cause `Stringify` to skip the object, `Stringify` then calls
     * the callback function(s). This occurs right before `Recurse` is called. Regarding the contents
     * of the JSON string:
     * - For object properties, the function(s) are called after the property name, close quote,
     * colon, and whitespace characters have been added to the JSON string.
     * - For array items, if its the first item in the array, the function(s) are called after the
     * open bracket and whitespace characters have been added to the JSON string. If its not the
     * first item in the array, the function(s) are called after the comma and whitespace characters
     * have been added to the JSON string.
     * - For map items, the function(s) are called after the comma and whitespace characters that follow
     * the key have been added to the JSON string.
     */
    static CallbackGeneral := unset

    /**
     * @property {*} StringifyConfig.CallbackPlaceholder - When `Stringify` skips processing an
     * object, a placeholder is printed instead. You can define `StringifyConfig.CallbackPlaceholder`
     * with any callable object to customize the string that gets printed. The function must follow
     * these specifications:
     * - Parameters:
     *   - 1: The `controller` object. The `controller` is an internal mechanism with various callable
     * properties, but the only property of use for this purpose is `Path`, which has a string value
     * representing the object path up to but not including the object that is currently being evaluated.
     * In the below example, if your function is called for a placeholder for the object at
     * `obj.nestedObj.doubleNestedObj`, the path will be "$.nestedObj".
     * @example
     *  obj := {
     *     nestedObj: {
     *          doubleNestedObj: {  prop: 'value' }
     *     }
     * }
     * @
     *   - 2: The object being evaluated.
     *   - 3: An optional `VarRef` parameter that will receive the name of the property for objects
     * that are encountered while iterating the parent object's properties.
     *   - 4: An optional `VarRef` parameter that will receive either of:
     *     - The name of the "key" for objects that are encountered while enumerating an object in
     * 2-parameter mode. The key will already have been escaped and enclosed in double quotes at this
     * point, making it somewhat awkward to work with because escaping it again will re-escape the
     * existing escape sequences. If your function will use the key for some purpose, then you will
     * likely want to do something like the below example.
     * @example
     *  MyPlaceholderFunc(controller, obj, &prop?, &key?) {
     *      if IsSet(prop) {
     *          ; make something
     *      } else if IsSet(key) {
     *          if IsNumber(key) {
     *              ; make something
     *          } else {
     *              key := Trim(key, '"')
     *              if InStr(key, '\') {
     *                  Stringify.StrUnescapeJson(&key)
     *              }
     *              ; make something
     *          }
     *      }
     *  }
     * @
     *     - The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.
     * - Return: The function should return the placeholder string. Don't forget to escape the necessary
     * characters. You can call `Stringify.StrEscapeJson` to do this. Also don't forget to enclose the
     * string in double quotes.
     *
     * It does not matter if the function modifies the two `VarRef` parameters as `Stringify` will not
     * use them again at that point.
     *
     * If your function will not use any of the parameters, specify the "*" symbol to exclude them.
     */
    static CallbackPlaceholder := unset

; ==== Newline and indent options ------------------------------------------------------------------
    /**
     * @property {String} StringifyConfig.Indent - The literal string that will be used for one level
     * of indentation.
     */
    static Indent := unset
    /**
     * @property {String} StringifyConfig.Newline - The literal string that will be used for line
     * breaks. If set to zero or an empty string, the `StringifyConfig.Singleline` option is effectively
     * enabled.
     */
    static Newline := unset
    /**
     * @property {Integer} StringifyConfig.CondenseCharLimit
     * @property {Integer} StringifyConfig.CondenseCharLimitEnum1
     * @property {Integer} StringifyConfig.CondenseCharLimitEnum2
     * @property {Integer} StringifyConfig.CondenseCharLimitProps -
     * Sets a threshold which `Stringify` uses to determine whether an object's JSON substring should
     * be condensed to a single line as a function of the character length of the substring. If
     * `StringifyConfig.CondenseCharLimit` is set, you can still specify individual options for the
     * other three and the individual option will take precedence over `StringifyConfig.CondenseCharLimit`.
     * The substring length is measured beginning from the open brace.
     */
    static CondenseCharLimit := unset
    static CondenseCharLimitEnum1 := unset
    static CondenseCharLimitEnum2 := unset
    static CondenseCharLimitProps := unset
    /**
     * @property {Integer} StringifyConfig.NewlineDepthLimit - Sets a threshold directing `Stringify`
     * to stop adding line breaks between values after exceeding the threshold.
     */
    static NewlineDepthLimit := unset
    /**
     * @property {Boolean} StringifyConfig.Singleline - If true, the JSON string is printed without
     * line breaks or indentation. All other "Newline and indent options" are ignored.
     */
    static Singleline := unset

; ==== Print options -------------------------------------------------------------------------------
    /**
     * @property {String} StringifyConfig.ItemProp - The name that `Stringify` will use as a
     * faux-property for including an object's items returned by its enumerator.
     */
    static ItemProp := unset
    /**
     * @property {Boolean} StringifyConfig.PrintErrors - When true, if `Stringify` encounters an
     * error when attempting to access the value of an object's property, the error message is
     * included in the JSON string as the value of the property. When false, `Stringify` skips
     * the property.
     */
    static PrintErrors := unset
    /**
     * @property {Boolean|String} StringifyConfig.PrintTypeTag - NOT CURRENTLY IN USE
     * When true, `Stringify` includes a
     * "TypeTag", which codifies additional information about the object into the JSON string, intended
     * to be used by the accompanying parser to reconstruct the object. The parser does not exist at
     * this time. When "TypeTag" is in use, it carries the consequence of all objects being stringified
     * as objects (including native arrays and maps) because the "TypeTag" property must be included as
     * an object property. The items returned by an object's enumerator are set to the faux-property
     * named using the option `StringifyConfig.ItemProp`.
     *
     * Set `StringifyConfig.PrintTypeTag` with a string value to specify the name of the property.
     */
    ; static PrintTypeTag := unset
    /**
     * @property {Boolean} StringifyConfig.QuoteNumericKeys - When true, and when `Stringify` is
     * processing an object's enumerator in 2-param mode, if the value returned to the first parameter
     * (the "key") is numeric, it will be quoted in the JSON string.
     */
    static QuoteNumericKeys := unset
    /**
     * @property {String} StringifyConfig.RootName - Prior to recursively stringifying a nested object,
     * `Stringify` checks if the object has already been processed. (This is to prevent infinite
     * recursion, and more flexible processing will be implemented). If an object has already been
     * processed, a placeholder is printed in its place. The placeholder printed as a result of this
     * condition is different than placeholders printed for other reasons. In this case, the
     * placeholder is a string representation of the object path at which the object was first
     * encountered. This is so one's self, or one's code, can locate the object in the JSON string
     * if needed. `StringifyConfig.RootName` specifies the name of the root object used within
     * any occurrences of this placeholder string.
     */
    static RootName := unset
    /**
     * @property {String} StringifyConfig.UnsetArrayItem - The string to print for unset array items.
     */
    static UnsetArrayItem := unset

; ==== General options -----------------------------------------------------------------------------
    /**
     * @property {Integer} StringifyConfig.InitialPtrListCapacity - `Stringify` tracks the ptr
     * addresses of every object it stringifies to prevent infinite recursion. `Stringify` will set
     * the initial capacity of the `Map` object used for this purpose to
     * `StringifyConfig.InitialPtrListCapacity`.
     */
    static InitialPtrListCapacity := unset
    /**
     * @property {Integer} StringifyConfig.InitialStrCapacity - `Stringify` calls
     * `VarSetStrCapacity` using `StringifyConfig.InitialStrCapacity` for the output string during
     * the initialization stage. For the best performance, you can overestimate the approximate
     * length of the string; `Stringify` calls `VarSetStrCapacity(&OutStr, -1)` at the end
     * of the function to release any unused memory.
     */
    static InitialStrCapacity := unset
}
