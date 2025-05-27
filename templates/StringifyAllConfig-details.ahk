
class  StringifyAllConfig {

; ==== Enum options ---------------------------------------------------------------------------------
    /**
     * @property {*} StringifyAllConfig.EnumCondition - A function or callable object that returns an
     * indicator if an object should be enumerated, and if so, to use 1-param mode or 2-param mode.
     * The function should accept one parameter, the object that is being evaluated, and should
     * return one of the indicators described below.
     * Valid indicators are:
     * - 1 = call `Obj.__Enum` in 1-parameter mode.
     * - 2 = call `Obj.__Enum` in 2-parameter mode.
     * - 0 / empty string = Do not call `Obj.__Enum`.
     * Also see {@link StringifyAllConfig.EnumTypeMap}.
     */
    static EnumCondition := unset
    /**
     * @property {Map} StringifyAllConfig.EnumTypeMap - A `Map` object where the keys are object types
     * and the values are either:
     * - An integer indicating how `StringifyAll` should enumerate objects of that type.
     * - A function or callable object that takes the object being evaluated as its only parameter
     * and returns an integer indicating how `StringifyAll` should enumerate the object.
     * When unset, `StringifyAll` only uses `EnumCondition` to determine how to handle enumeration. When
     * set, `StringifyAll`'s behavior adapts in these ways:
     * - During initialization, `StringifyAll` checks if the `Default` property has been set on the `Map`
     * object.
     *   - If `Default` is set, then `StringifyAll` ignores `StringifyAllConfig.EnumCondition` completely
     * and calls `StringifyAllConfig.EnumTypeMap.Get(Type(Obj))` for all objects that `StringifyAll` processes.
     *   - If `Default` is not set, then `StringifyAll` calls `StringifyAllConfig.EnumTypeMap.Has(Type(Obj))`.
     * If true, `StringifyAll` uses the item's value. If false, `StringifyAll` uses the return value from
     * `StringifyAllConfig.EnumCondition`.
     * - See {@link StringifyAllConfig.EnumCondition} for valid indicator values.
     */
    static EnumTypeMap := unset
    /**
     * @property {Boolean} StringifyAllConfig.ExcludeMethods - If true, properties with a `Call`
     * accessor and properties with only a `Set` accessor are excluded from stringification. If false
     * or unset, those kinds of properties are included in the JSON string with the name of the
     * function object.
     */
    static ExcludeMethods := unset
    /**
     * @property {String} StringifyAllConfig.ExcludeProps - A comma-delimited, case-insensitive list of
     * property names to exclude from stringification. Also see {@link StringifyAllConfig.Filter} and
     * {@link StringifyAllConfig.FilterTypeMap}.
     */
    static ExcludeProps := unset
    /**
     * @property {PropsInfo.FilterGroup} StringifyAllConfig.Filter - A single `PropsInfo.FilterGroup`
     * object that will be applied to all `PropsInfo` objects iterated during stringification. If
     * `StringifyAllConfig.FilterTypeMap` is set, this is ignored.
     */
    static Filter := unset
    /**
     * @property {Map} StringifyAllConfig.FilterTypeMap - A `Map` object where the keys are object types
     * and the values are `PropsInfo.FilterGroup` objects. `StringifyAll` will apply the filter when
     * iterating the properties of an object of the indicated types. You can use the `Default` property
     * of the map object to specify a default `PropsInfo.FilterGroup` to use for all objects, and then
     * add additional items to the map for specific object types.
     */
    static FilterTypeMap := unset
    /**
     * @property {Integer} StringifyAllConfig.MaxDepth - The maximum depth `StringifyAll` will recurse
     * into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up. At
     * any given point, the indentation level can be as large as 3x the depth level. This is due
     * to how `StringifyAll` handles map and array items.
     */
    static MaxDepth := unset
    /**
     * @property {*} StringifyAllConfig.PropsCondition - A function or callable object that returns an
     * indicator if an object's properties should be stringified. The function should accept one
     * parameter, the object being evaluated, and should return a nonzero value if the object's
     * properties should be stringified, or a falsy value if the object's properties should not
     * be stringified.
     * Also see {@link StringifyAllConfig.PropsTypeMap}.
     */
    static PropsCondition := unset
    /**
     * @property {Map} StringifyAllConfig.PropsTypeMap - A `Map` object where the keys are object types
     * and the values are a boolean indicating whether or not `StringifyAll` should process the object's
     * properties.
     * - The baseline behavior for `StringifyAll` is to create a `PropsInfo` object for all objects that
     * are stringified. If `PropsInfoObj.Count > 0`, then `StringifyAll` will process the properties
     * included among the `PropsInfo` object. If `PropsInfoObj.Count == 0`, `StringifyAll` does not
     * process properties for the object.
     * - When `StringifyAllConfig.PropsTypeMap` and `StringifyAllConfig.PropsCondition` are both unset,
     * `StringifyAll` uses the baseline process described above for all objects.
     * - When `StringifyAllConfig.PropsTypeMap` is set, `StringifyAll`'s behavior adapts in these ways:
     *   - During initialization, `StringifyAll` checks if the `Default` property has been set on the
     * `Map` object.
     *     - If `Default` is set, then `StringifyAll` ignores `StringifyAllConfig.PropsCondition` completely
     * and calls `StringifyAllConfig.PropsTypeMap.Get(Type(Obj))` for all objects that `StringifyAll`
     * processes.
     *     - If `Default` is not set, then `StringifyAll` calls `StringifyAllConfig.PropsTypeMap.Has(Type(Obj))`.
     * If true, `StringifyAll` uses the item's value. If false, `StringifyAll` uses the return value from
     * `StringifyAllConfig.PropsCondition` if it is in use. If not in use, `StringifyAll` uses the baseline
     * behavior described above.
     *
     * - A nonzero value directs `StringifyAll` to process the object's properties using the behavior
     * described above. A falsy value directs `StringifyAll` to skip processing an object's properties.
     */
    static PropsTypeMap := unset

    /**
     * @property {Map} StringifyAllConfig.StopAtTypeMap - A `Map` object where the keys are object types and
     * the values are strings or numbers that will be passed to the `StopAt` parameter of `GetPropsInfo`.
     * For example, if I don't want `StringifyAll` to include the `Length`, `Capacity`, or `__Item`
     * properties when processing `Array` objects, one way to do this would be to define
     * `StringifyAllConfig.StopAtTypeMap` to direct `GetPropsInfo` not to include properties owned by
     * `Array.Prototype`, as seen in the below example.
     * @example
     *  StringifyAllConfig.StopAtTypeMap := Map('Array', '-Array')
     * @
     *
     * See the parameter hints for `GetBaseObjects` within the file "inheritance\GetBaseObjects.ahk"
     * for full details about this parameter.
     */
    static StopAtTypeMap := unset

; ==== Callbacks -----------------------------------------------------------------------------------
    /**
     * @property {*} StringifyAllConfig.CallbackGeneral - A function or callable object, or an array of
     * one or more functions or callable objects, that will be called for each object prior to processing.
     * The function should accept up to two parameters:
     * - The object about to be processed
     * - {VarRef} A variable that will receive a reference to the JSON string being created.
     *
     * The function(s) can return a nonzero value to direct `StringifyAll` to skip processing the object.
     * Any further functions in an array of functions are necessarily also skipped in this case.
     *
     * The function should return a value to one of these effects:
     * - If the return value is a string, that string will be used as the placeholder for the object
     * in the JSON string.
     * - If the return value is -1, `StringifyAll` skips that object completely and it is not
     * represented in the JSON string.
     * - If the return value is any other nonzero value, then:
     *   - If `StringifyAllConfig.CallbackPlaceholder` is set, `StringifyAllConfig.CallbackPlaceholder`
     * will be called to generate the placeholder. Else,
     *   - If `StringifyAllConfig.CallbackPlaceholder` is unset, the built-in placeholder is used.
     * - If the return value is zero or an empty string, `StringifyAll` proceeds calling the next
     * function if there is one, or proceeds stringifying the object.
     *
     * If your function returns a string:
     * - Don't forget to escape the necessary characters. You can call `StringifyAll.StrEscapeJson`
     *to do this.
     * - Note that `StringifyAll` does **not** enclose the value in quotes when adding it to the JSON
     * string. Your function should add the quote characters, or call `StringifyAll.StrEscapeJson` which
     * has the option to add the quote characters for you.
     *
     * The function(s) should not call `StringifyAll`; `StringifyAll` relies on several variables in the
     * function's scope that would be altered by concurrent function calls, causing unexpected
     * behavior for any earlier `StringifyAll` calls.
     *
     * The following is a description of the part of the process which the function(s) are called.
     * `StringifyAll` proceeds in two stages, initialization and recursive processing. After initialization,
     * the function `Recurse` is called once, which starts the second stage. When `StringifyAll`
     * encounters a value that is an object, it proceeds through a series of condition checks to
     * determine if it will call `Recurse` again for that value. Before calling `Recurse`,
     * `StringifyAll` checks the following conditions. When a value is skipped, a placeholder is
     * printed instead.
     * - If the value is a `ComObject` or `ComValue`, the value is skipped.
     * - If the value has already been stringified, the value is skipped. This is intended to prevent
     * infinite recursion, but currently causes `StringifyAll` to skip all subsequent encounters of an
     * object after the first, not just problematic ones. I will implement a more flexible solution.
     * - If no further recursion is permitted according to `StringifyAllConfig.MaxDepth`, the value is
     * skipped.
     * If none of the above conditions cause `StringifyAll` to skip the object, `StringifyAll` then calls
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
     * @property {*} StringifyAllConfig.CallbackPlaceholder - When `StringifyAll` skips processing an
     * object, a placeholder is printed instead. You can define `StringifyAllConfig.CallbackPlaceholder`
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
     *                  StringifyAll.StrUnescapeJson(&key)
     *              }
     *              ; make something
     *          }
     *      }
     *  }
     * @
     *     - The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.
     * - Return: The function should return the placeholder string. Don't forget to escape the necessary
     * characters. You can call `StringifyAll.StrEscapeJson` to do this. Also don't forget to enclose the
     * string in double quotes.
     *
     * It does not matter if the function modifies the two `VarRef` parameters as `StringifyAll` will not
     * use them again at that point.
     *
     * If your function will not use any of the parameters, specify the "*" symbol to exclude them.
     */
    static CallbackPlaceholder := unset

; ==== Newline and indent options ------------------------------------------------------------------
    /**
     * @property {String} StringifyAllConfig.Indent - The literal string that will be used for one level
     * of indentation.
     */
    static Indent := unset
    /**
     * @property {String} StringifyAllConfig.Newline - The literal string that will be used for line
     * breaks. If set to zero or an empty string, the `StringifyAllConfig.Singleline` option is effectively
     * enabled.
     */
    static Newline := unset
    /**
     * @property {Integer} StringifyAllConfig.CondenseCharLimit
     * @property {Integer} StringifyAllConfig.CondenseCharLimitEnum1
     * @property {Integer} StringifyAllConfig.CondenseCharLimitEnum2
     * @property {Integer} StringifyAllConfig.CondenseCharLimitProps -
     * Sets a threshold which `StringifyAll` uses to determine whether an object's JSON substring should
     * be condensed to a single line as a function of the character length of the substring. If
     * `StringifyAllConfig.CondenseCharLimit` is set, you can still specify individual options for the
     * other three and the individual option will take precedence over `StringifyAllConfig.CondenseCharLimit`.
     * The substring length is measured beginning from the open brace.
     */
    static CondenseCharLimit := unset
    static CondenseCharLimitEnum1 := unset
    static CondenseCharLimitEnum2 := unset
    static CondenseCharLimitProps := unset
    /**
     * @property {Integer} StringifyAllConfig.NewlineDepthLimit - Sets a threshold directing `StringifyAll`
     * to stop adding line breaks between values after exceeding the threshold.
     */
    static NewlineDepthLimit := unset
    /**
     * @property {Boolean} StringifyAllConfig.Singleline - If true, the JSON string is printed without
     * line breaks or indentation. All other "Newline and indent options" are ignored.
     */
    static Singleline := unset

; ==== Print options -------------------------------------------------------------------------------
    /**
     * @property {String} StringifyAllConfig.ItemProp - The name that `StringifyAll` will use as a
     * faux-property for including an object's items returned by its enumerator.
     */
    static ItemProp := unset
    /**
     * @property {Boolean} StringifyAllConfig.PrintErrors - When true, if `StringifyAll` encounters an
     * error when attempting to access the value of an object's property, the error message is
     * included in the JSON string as the value of the property. When false, `StringifyAll` skips
     * the property.
     */
    static PrintErrors := unset
    /**
     * @property {Boolean|String} StringifyAllConfig.PrintTypeTag - NOT CURRENTLY IN USE
     * When true, `StringifyAll` includes a
     * "TypeTag", which codifies additional information about the object into the JSON string, intended
     * to be used by the accompanying parser to reconstruct the object. The parser does not exist at
     * this time. When "TypeTag" is in use, it carries the consequence of all objects being stringified
     * as objects (including native arrays and maps) because the "TypeTag" property must be included as
     * an object property. The items returned by an object's enumerator are set to the faux-property
     * named using the option `StringifyAllConfig.ItemProp`.
     *
     * Set `StringifyAllConfig.PrintTypeTag` with a string value to specify the name of the property.
     */
    ; static PrintTypeTag := unset
    /**
     * @property {Boolean} StringifyAllConfig.QuoteNumericKeys - When true, and when `StringifyAll` is
     * processing an object's enumerator in 2-param mode, if the value returned to the first parameter
     * (the "key") is numeric, it will be quoted in the JSON string.
     */
    static QuoteNumericKeys := unset
    /**
     * @property {String} StringifyAllConfig.RootName - Prior to recursively stringifying a nested object,
     * `StringifyAll` checks if the object has already been processed. (This is to prevent infinite
     * recursion, and more flexible processing will be implemented). If an object has already been
     * processed, a placeholder is printed in its place. The placeholder printed as a result of this
     * condition is different than placeholders printed for other reasons. In this case, the
     * placeholder is a string representation of the object path at which the object was first
     * encountered. This is so one's self, or one's code, can locate the object in the JSON string
     * if needed. `StringifyAllConfig.RootName` specifies the name of the root object used within
     * any occurrences of this placeholder string.
     */
    static RootName := unset
    /**
     * @property {String} StringifyAllConfig.UnsetArrayItem - The string to print for unset array items.
     */
    static UnsetArrayItem := unset

; ==== General options -----------------------------------------------------------------------------
    /**
     * @property {Integer} StringifyAllConfig.InitialPtrListCapacity - `StringifyAll` tracks the ptr
     * addresses of every object it stringifies to prevent infinite recursion. `StringifyAll` will set
     * the initial capacity of the `Map` object used for this purpose to
     * `StringifyAllConfig.InitialPtrListCapacity`.
     */
    static InitialPtrListCapacity := unset
    /**
     * @property {Integer} StringifyAllConfig.InitialStrCapacity - `StringifyAll` calls
     * `VarSetStrCapacity` using `StringifyAllConfig.InitialStrCapacity` for the output string during
     * the initialization stage. For the best performance, you can overestimate the approximate
     * length of the string; `StringifyAll` calls `VarSetStrCapacity(&OutStr, -1)` at the end
     * of the function to release any unused memory.
     */
    static InitialStrCapacity := unset
}
