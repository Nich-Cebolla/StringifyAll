/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-StringifyAll
    Author: Nich-Cebolla
    Version: 1.1.1
    License: MIT
*/

#include *i <ConfigLibrary>

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance
#include <Inheritance>

/**
 * @description - A customizable solution for serializing an object's properties, including inherited
 * properties, and/or items into a 100% valid JSON string.
 *
 * `StringifyAll` utilizes `GetPropsInfo` from the "Inheritance" library linked at the top of the
 * file. This allows us to include every property, even inherited properties, in the JSON string.
 *
 * `StringifyAll` exposes many options to programmatically restrict what gets included in the JSON
 * string. It also includes options for adjusting the spacing in the string. To set your options, you
 * can:
 * - Copy "templates\StringifyAllConfigTemplate.ahk" into your project directory and set the options
 * using the template.
 * - Prepare the `ConfigLibrary` class and reference the configuration by name. See the file
 * "templates\ConfigLibrary.ahk".
 * - Define a class `StringifyAllConfig` anywhere in your code.
 * - Pass an object to the `Options` parameter.
 *
 * The options defined by the `Options` parameter supercede options defined by the `StringifyConfig`
 * class. This is convenient for setting your own defaults based on your personal preferences /
 * project needs using the class object, and then passing an object to the `Options` parameter to
 * adjust your defaults on-the-fly.
 *
 * Callback functions must not call `StringifyAll`. `StringifyAll` relies on several variables in
 * the function's scope. Concurrent function calls would change their values, causing unexpected
 * behavior for earlier calls.
 *
 * For usage examples, see "example\example.ahk".
 *
 * There are some considerations to keep in mind when using `StringifyAll` with the intent to later
 * parse it back into a data object.
 * - All objects that have one or more of its property values written to the JSON string are represented
 * as an object using curly braces, including array objects and map objects. Since square brackets
 * are the typical indicator that a substring is representing an array object, a parser will interpret
 * the substring as an object with a property that is an array, rather than just an array. (Keep an
 * eye out for my updated JSON parser to pair with `StringifyAll`).
 * - A parser would need to handle read-only properties in some way.
 * - Some properties don't necessarily need to be parsed. For example, if I stringified an array object
 * including its native properties, a parser setting the `Length` property would be redundant.
 *
 * The above considerations are mitigated by keeping separate configuration files for separate purposes.
 * For example, keep one configuration to use when intending to later parse the string back into AHK
 * data, and keep another configuration to use when intending to visually inspect the string.
 *
 * There are some conditions which will cause `Stringify` to skip stringifying an object. When this
 * occurs, `Stringify` prints a placeholder string instead. The conditions are:
 * - The object is a `ComObject` or `ComValue`.
 * - The maximum depth is reached.
 * - Your callback function returned a value directing `Stringify` to skip the object.
 *
 * When `StringifyAll` encounters an object multiple times, it may skip the object and print a
 * string representation of the object path at which the object was first encountered. Using the
 * object path instead of the standard placeholder is so one's code or one's self can identify the
 * correct object that was at that location when `Stringify` was processing. This will occur when one or
 * both of the following are true:
 * - `Options.Multiple` is false (the default is false).
 * - Processing the object will result in infinite recursion.
 *
 * `StringifyAll` does not inherently direct the flow of action as a condition of whether an object
 * is a map, array, or some other type of object. Instead, the options can be used to specify precisely
 * what should be included in the JSON string and what should not be included.
 *
 * `StringifyAll` will require more setup to be useful compared to other stringify functions, because
 * we usually don't need information about every property. `StringifyAll` is not intended to be a
 * replacement for other stringify functions. Where `StringifyAll` shines is in cases where we need
 * a way to programmatically define specifically what properties we want represented in the JSON
 * string and what we want to exclude; at the cost of requiring greater setup time investment, we
 * receive in exchange the potential to fine-tune precisely what will be present in the JSON string.
 *
 * Note that these are short descriptions of the options. For complete details about the options,
 * see the documentation within "docs\README.md".
 *
 * @param {*} Obj - The object to stringify.
 *
 * @param {Object|String} [Options] - If you are using `ConfigLibrary, the name of the configuration.
 * Or, the options object with zero or more of the following properties.
 * @param {Map} [Options.EnumTypeMap=Map('Array', 1, 'Map', 2, 'RegExMatchInfo', 2)] - A `Map` object
 * where the keys are object types and the values are either:
 * - An integer:
 *   - 1: Directs `StringifyAll` to call the object's enumerator in 1-param mode.
 *   - 2: Directs `StringifyAll` to call the object's enumerator in 2-param mode.
 *   - 0: Directs `StringifyAll` to not call the object's enumerator.
 * - A function or callable object:
 *   - The function should accept the object being evaluated as its only parameter.
 *   - The function should return one of the above listed integers.
 * Use the `Map`'s `Default` property to set a condition for all types not included within the `Map`.
 * @param {Boolean} [Options.ExcludeMethods=true] - If true, properties with a `Call`
 * accessor and properties with only a `Set` accessor are excluded from stringification.
 * @param {String} [Options.ExcludeProps=''] - A comma-delimited, case-insensitive list of
 * property names to exclude from stringification. Also see `Options.Filter` and
 * `Options.FilterTypeMap`.
 * @param {Map} [Options.FilterTypeMap=''] - A `Map` object where the keys are object types
 * and the values are `PropsInfo.FilterGroup` objects. `StringifyAll` will apply the filter when
 * iterating the properties of an object of the indicated types.
 * @param {Integer} [Options.MaxDepth=0] - The maximum depth `StringifyAll` will recurse
 * into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up.
 * @param {Boolean} [Options.Multiple=false] - When true, there is no limit to how many times
 * `StringifyAll` will process an object. Each time an individual object is encountered, it will
 * be processed unless doing so will result in infinite recursion. When false, `StringifyAll`
 * processes each individual object a maximum of 1 time, and all other encounters result in
 * `StringifyAll` printing a placeholder string that is a string representation of the object path
 * at which the object was first encountered.
 * @param {Map} [Options.PropsTypeMap={ __Class: "Map", Default: 1, Count: 0 }] - A `Map` object where the keys are object types
 * and the values are either:
 * - A boolean indicating whether or not `StringifyAll` should process the object's properties. A
 * nonzero value directs `StringifyAll` to process the properties. A falsy value directs `StringifyAll`
 * to skip the properties.
 * - A function or callable object:
 *   - The function should accept the object being evaluated as its only parameter.
 *   - The function should return a boolean value described above.
 * Use the `Map`'s `Default` property to set a condition for all types not included within the `Map`.
 * @param {Map} [Options.StopAtTypeMap=''] - A `Map` object where the keys are object types and
 * the values are either:
 * - A string or number that will be passed to the `StopAt` parameter of `GetPropsInfo`.
 * - A function or callable object:
 *   - The function should accept the object being evaluated as its only parameter.
 *   - The function should return a string or number to be passed to the `StopAt` parameter of
 * `GetPropsInfo`.
 * Use the `Map`'s `Default` property to set a condition for all types not included within the `Map`.
 * @param {*} [Options.CallbackError=''] - A function or callable object that is called when `StringifyAll`
 * encounters an error when attempting to access the value of a property.
 * @param {*} [Options.CallbackGeneral=''] - A function or callable object, or an array of
 * one or more functions or callable objects, that will be called for each object prior to processing.
 * @param {*} [Options.CallbackPlaceholder=''] - When `StringifyAll` skips processing an
 * object, a placeholder is printed instead. You can define `Options.CallbackPlaceholder`
 * with any callable object to customize the string that gets printed.
 * @param {String} [Options.Indent='`s`s`s`s'] - The literal string that will be used for one level
 * of indentation.
 * @param {String} [Options.Newline='`r`n'] - The literal string that will be used for line
 * breaks. If set to zero or an empty string, the `Options.Singleline` option is effectively
 * enabled.
 * @param {Integer} [Options.CondenseCharLimit=0]
 * @param {Integer} [Options.CondenseCharLimitEnum1=0]
 * @param {Integer} [Options.CondenseCharLimitEnum2=0]
 * @param {Integer} [Options.CondenseCharLimitProps=0] -
 * Sets a threshold which `StringifyAll` uses to determine whether an object's JSON substring should
 * be condensed to a single line as a function of the character length of the substring.
 * @param {Integer} [Options.NewlineDepthLimit=0] - Sets a threshold directing `StringifyAll`
 * to stop adding line breaks between values after exceeding the threshold.
 * @param {Boolean} [Options.Singleline=false] - If true, the JSON string is printed without
 * line breaks or indentation. All other "Newline and indent options" are ignored.
 * @param {String} [Options.ItemProp='__Item__'] - The name that `StringifyAll` will use as a
 * faux-property for including an object's items returned by its enumerator.
 * @param {Boolean|String} [Options.PrintErrors=false] - When `StringifyAll` encounters an error
 * accessing a property's value, `Options.PrintErrors` influences how it is handled. `Options.PrintErrors`
 * is ignored if `Options.CallbackError` is set.
 * - If `Options.PrintErrors` is a string value, it should be a comma-delimited list of `Error` property
 * names to include in the output as the value of the property that caused the error.
 * - If any other nonzero value, `StringifyAll` will print just the "Message" property of the `Error`
 * object in the string.
 * - If zero or an empty string, `StringifyAll` skips the property.
 * @param {Boolean} [Options.QuoteNumericKeys=false] - When true, and when `StringifyAll` is
 * processing an object's enumerator in 2-param mode, if the value returned to the first parameter
 * (the "key") is numeric, it will be quoted in the JSON string.
 * @param {String} [Options.RootName='$'] - Specifies the name of the root object used in the
 * string representation of an object's path when the object is skipped due to already having been
 * stringified.
 * @param {String} [Options.UnsetArrayItem='""'] - The string to print for unset array items.
 * @param {Integer} [Options.InitialPtrListCapacity=64] - `StringifyAll` tracks the ptr
 * addresses of every object it stringifies to prevent infinite recursion. `StringifyAll` will set
 * the initial capacity of the `Map` object used for this purpose to
 * `Options.InitialPtrListCapacity`.
 * @param {Integer} [Options.InitialStrCapacity=65536] - `StringifyAll` calls `VarSetStrCapacity`
 * using `Options.InitialStrCapacity` for the output string during the initialization stage.
 * For the best performance, you can overestimate the approximate length of the string; `StringifyAll`
 * calls `VarSetStrCapacity(&OutStr, -1)` at the end of the function to release any unused memory.
 *
 * @param {VarRef} [OutStr] - A variable that will be set with the JSON string value. The value
 * is also returned as the return value, but for very long strings receiving the string via the
 * `VarRef` will be slightly faster because the string will not need to be copied.
 *
 * @returns {String}
 */
class StringifyAll {

    static Call(Obj, Options?, &OutStr?) {
        if IsSet(Options) {
            if IsObject(Options) {
                Options := this.Options(Options)
            } else {
                if IsSet(ConfigLibrary) {
                    Options := this.Options(ConfigLibrary(Options))
                } else {
                    throw Error('``ConfigLibrary`` is not loaded into the project. String options are invalid.', -1)
                }
            }
        } else {
            Options := this.Options({})
        }
        controllerBase := {}
        controllerBase.PrepareNextProp := _PrepareNextProp1
        controllerBase.PrepareNextEnum1 := _PrepareNextEnum11
        controllerBase.PrepareNextEnum2 := _PrepareNextEnum21
        controllerBase.ProcessEnum1 := _ProcessEnum1
        controllerBase.ProcessEnum2 := _ProcessEnum2
        controllerBase.GetPlaceholder := ObjBindMethod(this, 'GetPlaceholder')

        ; Enum options
        if enumTypeMap := Options.EnumTypeMap {
            CheckEnum := enumTypeMap.HasOwnProp('Default') ? _CheckEnum1 : _CheckEnum2
        } else {
            CheckEnum := (*) => 0
        }
        if excludeMethods := Options.ExcludeMethods {
            controllerBase.ProcessProps := _ProcessProps1
        } else {
            controllerBase.ProcessProps := _ProcessProps2
        }
        excludeProps := Options.ExcludeProps
        filterTypeMap := Options.FilterTypeMap
        maxDepth := Options.MaxDepth > 0 ? Options.MaxDepth : 9223372036854775807
        controllerBase.HandleMultiple := Options.Multiple ? (controller, Val) => InStr('$$$.' controller.Path, '$$$.' ptrList.Get(ObjPtr(Val)).Path) : (*) => 1
        if !(propsTypeMap := Options.PropsTypeMap) {
            throw ValueError('The option ``PropsTypeMap`` must be set with an object value.', -1)
        }
        CheckProps := propsTypeMap.HasOwnProp('Default') ? _CheckProps1 : _CheckProps2
        stopAtTypeMap := Options.StopAtTypeMap
        if filterTypeMap {
            _GetPropsInfo := stopAtTypeMap ? _GetPropsInfo1 : _GetPropsInfo2
        } else if stopAtTypeMap {
            _GetPropsInfo := _GetPropsInfo3
        } else {
            _GetPropsInfo := _GetPropsInfo4
        }
        ; Callbacks
        if CallbackError := Options.CallbackError {
            controllerBase.HandleError := CallbackError
        }
        if CallbackGeneral := Options.CallbackGeneral {
            if not CallbackGeneral is Array {
                CallbackGeneral := [CallbackGeneral]
            }
            controllerBase.HandleProp := _HandleProp2
            controllerBase.HandleEnum1 := _HandleEnum12
            controllerBase.HandleEnum2 := _HandleEnum22
        } else {
            controllerBase.HandleProp := _HandleProp1
            controllerBase.HandleEnum1 := _HandleEnum11
            controllerBase.HandleEnum2 := _HandleEnum21
        }
        if Options.CallbackPlaceholder {
            controllerBase.GetPlaceholder := Options.CallbackPlaceholder
        }
        ; Print options
        itemProp := Options.ItemProp
        if !CallbackError {
            if printErrors := Options.PrintErrors {
                if IsNumber(printErrors) {
                    controllerBase.HandleError := _HandleError1
                } else {
                    controllerBase.HandleError := _HandleError2
                }
            } else {
                controllerBase.HandleError := _HandleError3
            }
        }
        quoteNumericKeys := Options.QuoteNumericKeys
        unsetArrayItem := Options.UnsetArrayItem
        ; Init vars
        Recurse := _Recurse1
        OutStr := ''
        VarSetStrCapacity(&OutStr, Options.InitialStrCapacity)
        depth := indentlevel := 0

        ; The functions set in this block are: nl, ind, controller.OpenProps, controller.OpenEnum1,
        ; controller.OpenEnum2, controller.CloseProps, controller.CloseEnum1, controller.CloseEnum2,
        ; IncDepth
        if Options.SingleLine || !Options.Newline {
            singleLineActive := 1
            nl := _nl2
            ind := _ind2
            controllerBase.OpenProps := _OpenProps3
            controllerBase.OpenEnum1 := _OpenEnum13
            controllerBase.OpenEnum2 := _OpenEnum23
            controllerBase.CloseProps := _CloseProps1
            controllerBase.CloseEnum1 := _CloseEnum11
            controllerBase.CloseEnum2 := _CloseEnum21
            IncDepth := _IncDepth2
        } else {
            ; Newline / indent options
            indent := [Options.Indent]
            newline := Options.Newline
            CondenseCharLimitEnum1 := Options.CondenseCharLimitEnum1 || Options.CondenseCharLimit
            CondenseCharLimitEnum2 := Options.CondenseCharLimitEnum2 || Options.CondenseCharLimit
            CondenseCharLimitProps := Options.CondenseCharLimitProps || Options.CondenseCharLimit
            if Options.newlineDepthLimit > 0 {
                newlineDepthLimit := Options.NewlineDepthLimit
                IncDepth := _IncDepth1
            } else {
                IncDepth := _IncDepth2
            }
            newlineCount := whitespaceChars := singleLineActive := 0
            lenContainer := Map()
            lenContainer.Default := 0
            indent := [Options.Indent]
            indent.Capacity := Options.MaxDepth ? Options.MaxDepth + 1 : 16
            nlStr := Options.Newline
            newlineLen := StrLen(nlStr)
            nl := _nl1
            ind := _ind1
            if CondenseCharLimitProps > 0 {
                controllerBase.OpenProps := _OpenProps2
                controllerBase.CloseProps := _CloseProps2
            } else {
                controllerBase.OpenProps := _OpenProps1
                controllerBase.CloseProps := _CloseProps1
            }
            if CondenseCharLimitEnum1 > 0 {
                controllerBase.OpenEnum1 := _OpenEnum12
                controllerBase.CloseEnum1 := _CloseEnum12
            } else {
                controllerBase.OpenEnum1 := _OpenEnum11
                controllerBase.CloseEnum1 := _CloseEnum11
            }
            if CondenseCharLimitEnum2 > 0 {
                controllerBase.OpenEnum2 := _OpenEnum22
                controllerBase.CloseEnum2 := _CloseEnum22
            } else {
                controllerBase.OpenEnum2 := _OpenEnum21
                controllerBase.CloseEnum2 := _CloseEnum21
            }
        }

        GetController := ClassFactory(controllerBase)
        controller := GetController()
        controller.Path := Options.RootName
        ptrList := Map(ObjPtr(Obj), controller)
        ptrList.Capacity := Options.InitialPtrListCapacity
        OutStr := ''

        Recurse(controller, Obj, &OutStr)

        VarSetStrCapacity(&OutStr, -1)

        return OutStr

        _Recurse1(controller, Obj, &OutStr) {
            IncDepth(1)
            controller.Obj := Obj
            flag_enum := CheckEnum(Obj)
            if flag_props := CheckProps(Obj) {
                PropsInfoObj := _GetPropsInfo(Obj)
                flag_props := PropsInfoObj.Count
            }
            if flag_props {
                controller.OpenProps(&OutStr)
                controller.ProcessProps(Obj, PropsInfoObj, &OutStr)
                if flag_enum == 1 {
                    if flag_props {
                        OutStr .= ',' nl() ind() '"' itemProp '": '
                    }
                    controller.OpenEnum1(&OutStr)
                    controller.CloseEnum1(controller.ProcessEnum1(Obj, &OutStr), &OutStr)
                } else if flag_enum == 2 {
                    if flag_props {
                        OutStr .= ',' nl() ind() '"' itemProp '": '
                    }
                    controller.OpenEnum2(&OutStr)
                    controller.CloseEnum2(controller.ProcessEnum2(Obj, &OutStr), &OutStr)
                }
                controller.CloseProps(&OutStr)
            } else if flag_enum == 1 {
                controller.OpenEnum1(&OutStr)
                controller.CloseEnum1(controller.ProcessEnum1(Obj, &OutStr), &OutStr)
            } else if flag_enum == 2 {
                controller.OpenEnum2(&OutStr)
                controller.CloseEnum2(controller.ProcessEnum2(Obj, &OutStr), &OutStr)
            } else {
                OutStr .= '{}'
            }
            if IsSet(PropsInfoObj) {
                PropsInfoObj.Dispose()
                PropsInfoObj := unset
            }
            IncDepth(-1)
        }
        _CheckEnum1(Obj) {
            if IsObject(Item := enumTypeMap.Get(Type(Obj))) {
                return Item(Obj)
            } else {
                return Item
            }
        }
        _CheckEnum2(Obj) {
            if enumTypeMap.Has(Type(Obj)) {
                if IsObject(Item := enumTypeMap.Get(Type(Obj))) {
                    return Item(Obj)
                } else {
                    return Item
                }
            }
        }
        _CheckProps1(Obj) {
            if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
                return Item(Obj)
            } else {
                return Item
            }
        }
        _CheckProps2(Obj) {
            if propsTypeMap.Has(Type(Obj)) {
                if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
                    return Item(Obj)
                } else {
                    return Item
                }
            }
        }
        _CloseEnum11(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= ']'
            }
        }
        _CloseEnum12(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= ']'
            }
            if container := lenContainer.Get(ObjPtr(controller) '-1') {
                if (obj.result := StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars)) <= container.limit {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _CloseEnum21(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= '[]]'
            }
        }
        _CloseEnum22(controller, count, &OutStr) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= '[]]'
            }
            if container := lenContainer.Get(ObjPtr(controller) '-2') {
                if (obj.result := StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars)) <= container.limit {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _CloseProps1(controller, &OutStr) {
            indentLevel--
            OutStr .= nl() ind() '}'
        }
        _CloseProps2(controller, &OutStr) {
            indentLevel--
            OutStr .= nl() ind() '}'
            if container := lenContainer.Get(ObjPtr(controller) '-3') {
                if (obj.result := StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars)) <= container.limit {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _GetPropsInfo1(Obj) {
            if stopAtTypeMap.Has(Type(Obj)) || stopAtTypeMap.HasOwnProp('Default') {
                if IsObject(Item := stopAtTypeMap.Get(Type(Obj))) {
                    pi := GetPropsInfo(Obj, Item(Obj), excludeProps, false, , excludeMethods)
                } else {
                    pi := GetPropsInfo(Obj, Item, excludeProps, false, , excludeMethods)
                }
            } else {
                pi := GetPropsInfo(Obj, '-Object', excludeProps, false, , excludeMethods)
            }
            if filterTypeMap.Has(Type(Obj)) || filterTypeMap.HasOwnProp('Default') {
                if val := filterTypeMap.Get(Type(Obj)) {
                    pi.DefineProp('Filter', { Value: val })
                    pi.FilterActivate()
                }
            }
            return pi
        }
        _GetPropsInfo2(Obj) {
            pi := GetPropsInfo(Obj, '-Object', excludeProps, false, , excludeMethods)
            if filterTypeMap.Has(Type(Obj)) || filterTypeMap.HasOwnProp('Default') {
                if val := filterTypeMap.Get(Type(Obj)) {
                    pi.DefineProp('Filter', { Value: val })
                    pi.FilterActivate()
                }
            }
            return pi
        }
        _GetPropsInfo3(Obj) {
            if stopAtTypeMap.Has(Type(Obj)) || stopAtTypeMap.HasOwnProp('Default') {
                if IsObject(Item := stopAtTypeMap.Get(Type(Obj))) {
                    return GetPropsInfo(Obj, Item(Obj), excludeProps, false, , excludeMethods)
                } else {
                    return GetPropsInfo(Obj, Item, excludeProps, false, , excludeMethods)
                }
            } else {
                return GetPropsInfo(Obj, '-Object', excludeProps, false, , excludeMethods)
            }
        }
        _GetPropsInfo4(Obj) {
            return GetPropsInfo(Obj, '-Object', excludeProps, false, , excludeMethods)
        }
        _GetVal(&Val, flag_quote_number := false) {
            if IsNumber(Val) {
                if flag_quote_number {
                    Val := '"' Val '"'
                }
            } else {
                Val := '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Val, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
            }
        }
        _HandleEnum11(controller, Val, &Key, &OutStr) {
            controller.PrepareNextEnum1(&OutStr)
            if ptrList.Has(ObjPtr(Val)) && controller.HandleMultiple(Val) {
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else {
                newController := GetController()
                newController.Path := controller.Path '[' Key ']'
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum12(controller, Val, &Key, &OutStr) {
            if ptrList.Has(ObjPtr(Val)) && controller.HandleMultiple(Val) {
                controller.PrepareNextEnum1(&OutStr)
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                controller.PrepareNextEnum1(&OutStr)
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else {
                for cb in CallbackGeneral {
                    if result := cb(controller, Val, &OutStr, , key) {
                        if result is String {
                            controller.PrepareNextEnum1(&OutStr)
                            OutStr .= result
                        } else if result !== -1 {
                            controller.PrepareNextEnum1(&OutStr)
                            OutStr .= controller.GetPlaceholder(Val, , &Key)
                        }
                        return
                    }
                }
                controller.PrepareNextEnum1(&OutStr)
                newController := GetController()
                newController.Path := controller.Path '[' Key ']'
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum21(controller, Val, &Key, &OutStr) {
            controller.PrepareNextEnum2(&OutStr)
            OutStr .= Key ',' nl() ind()
            if ptrList.Has(ObjPtr(Val)) && controller.HandleMultiple(Val) {
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else {
                newController := GetController()
                newController.Path := controller.Path '[' Key ']'
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum22(controller, Val, &Key, &OutStr) {
            if ptrList.Has(ObjPtr(Val)) && controller.HandleMultiple(Val) {
                controller.PrepareNextEnum2(&OutStr)
                OutStr .= Key ',' nl() ind()
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                controller.PrepareNextEnum2(&OutStr)
                OutStr .= Key ',' nl() ind()
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else {
                for cb in CallbackGeneral {
                    if result := cb(controller, Val, &OutStr, , key) {
                        if result is String {
                            controller.PrepareNextEnum2(&OutStr)
                            OutStr .= Key ',' nl() ind()
                            OutStr .= result
                        } else if result !== -1 {
                            controller.PrepareNextEnum2(&OutStr)
                            OutStr .= Key ',' nl() ind()
                            OutStr .= controller.GetPlaceholder(Val, , &Key)
                        }
                        return
                    }
                }
                controller.PrepareNextEnum2(&OutStr)
                OutStr .= Key ',' nl() ind()
                newController := GetController()
                newController.Path := controller.Path '[' Key ']'
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleError1(controller, Err, *) {
            local s := Err.Message
            StringifyAll.StrEscapeJson(&s, true)
            return s
        }
        _HandleError2(controller, Err, *) {
            local str := ''
            for s in StrSplit(Options.PrintErrors, ',') {
                if s {
                    str .= s ': ' Err.%s% '; '
                }
            }
            str := SubStr(str, 1, -2)
            StringifyAll.StrEscapeJson(&str, true)
            return str
        }
        _HandleError3(*) {
            return -1
        }
        _HandleProp1(controller, Val, &Prop, &OutStr) {
            if ptrList.Has(ObjPtr(Val)) && controller.HandleMultiple(Val) {
                Val := '{ ' ptrList.Get(ObjPtr(Val)).Path ' }'
                _WriteProp1(controller, &Prop, &Val, &OutStr)
            } else if depth >= maxDepth  || Val is ComObject || Val is ComValue {
                _WriteProp2(controller, &Prop, controller.GetPlaceholder(Val, &Prop), &OutStr)
            } else {
                controller.PrepareNextProp(&OutStr)
                OutStr .= '"' Prop '": '
                newController := GetController()
                newController.Path := controller.Path '.' Prop
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleProp2(controller, Val, &Prop, &OutStr) {
            if ptrList.Has(ObjPtr(Val)) && controller.HandleMultiple(Val) {
                Val := '{ ' ptrList.Get(ObjPtr(Val)).Path ' }'
                _WriteProp1(controller, &Prop, &Val, &OutStr)
            } else if depth >= maxDepth  || Val is ComObject || Val is ComValue {
                _WriteProp2(controller, &Prop, controller.GetPlaceholder(Val, &Prop), &OutStr)
            } else {
                for cb in CallbackGeneral {
                    if result := cb(controller, Val, &OutStr, Prop) {
                        if result is String {
                            _WriteProp3(controller, &Prop, &result, &OutStr)
                        } else if result !== -1 {
                            _WriteProp2(controller, &Prop, controller.GetPlaceholder(Val, &Prop), &OutStr)
                        }
                        return
                    }
                }
                controller.PrepareNextProp(&OutStr)
                OutStr .= '"' Prop '": '
                newController := GetController()
                newController.Path := controller.Path '.' Prop
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val, &OutStr)
            }
        }
        _IncDepth1(delta) {
            _depth := depth
            depth += delta
            if _depth > newlineDepthLimit {
                if depth <= newlineDepthLimit {
                    nl := _nl1
                    ind := _ind1
                }
            } else if _depth <= newlineDepthLimit {
                if depth > newlineDepthLimit {
                    nl := _nl2
                    ind := _ind2
                }
            } else if delta > 0 {
                nl := _nl2
                ind := _ind2
            }
        }
        _IncDepth2(delta) {
            depth += delta
        }
        _ind1() {
            if singleLineActive || !indentLevel {
                return ''
            }
            while indentLevel > indent.Length {
                indent.Push(indent[-1] indent[1])
            }
            whitespaceChars += StrLen(indent[indentLevel])
            return indent[indentLevel]
        }
        _ind2() {
            return ''
        }
        _nl1() {
            if singleLineActive {
                return ''
            }
            whitespaceChars += newlineLen
            newlineCount++
            return nlStr
        }
        _nl2() {
            return ''
        }
        _OpenEnum11(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum12(controller, &OutStr) {
            lenContainer.Set(ObjPtr(controller) '-1', { len: StrLen(OutStr), whitespaceChars: whitespaceChars, limit: condenseCharLimitEnum1 })
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum13(controller, &OutStr) {
            OutStr .= '['
        }
        _OpenEnum21(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum22(controller, &OutStr) {
            lenContainer.Set(ObjPtr(controller) '-2', { len: StrLen(OutStr), whitespaceChars: whitespaceChars, limit: condenseCharLimitEnum2 })
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum23(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenProps1(controller, &OutStr) {
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps2(controller, &OutStr) {
            lenContainer.Set(ObjPtr(controller) '-3', { len: StrLen(OutStr), whitespaceChars: whitespaceChars, limit: condenseCharLimitProps })
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps3(controller, &OutStr) {
            OutStr .= '{'
        }
        _PrepareNextEnum11(controller, &OutStr) {
            OutStr .= nl() ind()
            controller.PrepareNextEnum1 := _PrepareNextEnum12
        }
        _PrepareNextEnum12(controller, &OutStr) {
            OutStr .= ',' nl() ind()
        }
        _PrepareNextEnum21(controller, &OutStr) {
            OutStr .= nl() ind() '['
            indentLevel++
            OutStr .= nl() ind()
            controller.PrepareNextEnum2 := _PrepareNextEnum22
        }
        _PrepareNextEnum22(controller, &OutStr) {
            OutStr .= ',' nl() ind() '['
            indentLevel++
            OutStr .= nl() ind()
        }
        _PrepareNextProp1(controller, &OutStr) {
            OutStr .= nl() ind()
            controller.PrepareNextProp := _PrepareNextProp2
        }
        _PrepareNextProp2(controller, &OutStr) {
            OutStr .= ',' nl() ind()
        }
        _ProcessEnum1(controller, Obj, &OutStr) {
            count := 0
            for Val in Obj {
                count++
                if IsSet(Val) {
                    if IsObject(Val) {
                        controller.HandleEnum1(Val, &(i := A_Index), &OutStr)
                    } else {
                        controller.PrepareNextEnum1(&OutStr)
                        _GetVal(&Val)
                        OutStr .= Val
                    }
                } else {
                    controller.PrepareNextEnum1(&OutStr)
                    OutStr .= unsetArrayItem
                }
            }
            return count
        }
        _ProcessEnum2(controller, Obj, &OutStr) {
            count := 0
            for Key, Val in Obj {
                count++
                if IsObject(Key) {
                    Key := '"{ ' this.GetType(Key) ':' ObjPtr(Key) ' }"'
                } else {
                    _GetVal(&Key, quoteNumericKeys)
                }
                if IsObject(Val) {
                    controller.HandleEnum2(Val, &Key, &OutStr)
                } else {
                    controller.PrepareNextEnum2(&OutStr)
                    OutStr .= Key ',' nl() ind()
                    _GetVal(&Val)
                    OutStr .= Val
                }
                indentLevel--
                OutStr .= nl() ind() ']'
            }
            return count
        }
        ; ExcludeMethod = true
        _ProcessProps1(controller, Obj, PropsInfoObj, &OutStr) {
            for Prop, InfoItem in PropsInfoObj {
                if InfoItem.GetValue(&Val) {
                    if IsSet(Val) {
                        if errorResult := controller.HandleError(Val, Obj, InfoItem) {
                            if errorResult is String {
                                _WriteProp3(controller, &Prop, &errorResult, &OutStr)
                            } else if errorResult !== -1 {
                                Val := Val.Message
                                _WriteProp1(controller, &Prop, &Val, &OutStr)
                            }
                            Val := unset
                            continue
                        }
                    } else {
                        continue
                    }
                }
                if IsObject(Val) {
                    controller.HandleProp(Val, &Prop, &OutStr)
                } else {
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                }
                Val := unset
            }
        }
        ; ExcludeMethod = false
        _ProcessProps2(controller, Obj, PropsInfoObj, &OutStr) {
            for Prop, InfoItem in PropsInfoObj {
                if InfoItem.GetValue(&Val) {
                    if IsSet(Val) {
                        if errorResult := controller.HandleError(Val, Obj, InfoItem) {
                            if errorResult is String {
                                _WriteProp3(controller, &Prop, &errorResult, &OutStr)
                            } else if errorResult !== -1 {
                                Val := Val.Message
                                _WriteProp1(controller, &Prop, &Val, &OutStr)
                            }
                            Val := unset
                            continue
                        }
                    } else {
                        Val := '{ ' InfoItem.GetFunc().Name ' }'
                    }
                }
                if IsObject(Val) {
                    controller.HandleProp(Val, &Prop, &OutStr)
                } else {
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                }
                Val := unset
            }
        }
        _WriteProp1(controller, &Prop, &Val, &OutStr) {
            controller.PrepareNextProp(&OutStr)
            _GetVal(&Val)
            OutStr .= '"' Prop '": ' Val
        }
        _WriteProp2(controller, &Prop, Val, &OutStr) {
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": ' Val
        }
        _WriteProp3(controller, &Prop, &Val, &OutStr) {
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": ' Val
        }
    }
    /**
     * @description - Escapes the following with a backslash: tab, carriage return, line feed, double quote, backslash.
     * @param {VarRef} Str - The string to escape.
     * @param {Boolean} [AddQuotes] - If true, the result string is enclosed in double quotes.
     */
    static StrEscapeJson(&Str, AddQuotes := false) {
        if AddQuotes {
            Str := '"' StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t') '"'
        } else {
            Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\', '\\'), '`n', '\n'), '`r', '\r'), '"', '\"'), '`t', '\t')
        }
    }

    /**
     * @description - Unescapes the following with a backslash: tab, carriage return, line feed, double quote, backslash.
     * @param {VarRef} Str - The string to unescape.
     */
    static StrUnescapeJson(&Str) {
        Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), '\\', '\')
    }

    /**
     * @description - Returns a string with information about the object's type. There are two
     * details included in the string, separated by a colon. The left side of the string is either
     * "Class", "Prototype", or "Instance". The right side of the string is the name of the class to
     * which the object is associated.
     * @param {*} Obj - Any object.
     * @returns {String}
     */
    static GetType(Obj) {
        if Obj is Class {
            return 'Class:' Obj.Prototype.__Class
        }
        if Type(Obj) == 'Prototype' {
            return 'Prototype:' Obj.__Class
        }
        return 'Instance:' Type(Obj)
    }

    /**
     * @description - The function that produces the default placeholder string for skipped objects.
     * @param {Object} Controller - An internal mechanism used by `Stringify`. It has a property `Path`
     * that has a string value representing the object path up to but not including `Obj`. The
     * `controller` is not used by this function, but exists as a parameter because the function is
     * set as a method to the `controller` object.
     * @param {*} Obj - The object being evaluated.
     */
    static GetPlaceholder(Controller, Obj, *) {
        return '"{ ' this.GetType(Obj) ':' ObjPtr(Obj) ' }"'
    }

    static __New() {
        this.DeleteProp('__New')
        this.Options.Default.PropsTypeMap := m := Map()
        m.Default := 1
    }


    /**
     * @classdesc - Handles the input options.
     */
    class Options {
        static Default := {
            ; Enum options
            EnumTypeMap: Map('Array', 1, 'Map', 2, 'RegExMatchInfo', 2)
          , ExcludeMethods: true
          , ExcludeProps: ''
          , Filter: ''
          , FilterTypeMap: ''
          , MaxDepth: 0
          , Multiple: false
          ; `PropsTypeMap` is set by `StringifyAll.__New`.
          , PropsTypeMap: ''
          , StopAtTypeMap: ''

            ; Callbacks
          , CallbackError: ''
          , CallbackGeneral: ''
          , CallbackPlaceholder: ''

            ; Newline and indent options
          , Indent: '`s`s`s`s'
          , Newline: '`r`n'
          , CondenseCharLimit: 0
          , CondenseCharLimitEnum1: 0
          , CondenseCharLimitEnum2: 0
          , CondenseCharLimitProps: 0
          , NewlineDepthLimit: 0
          , Singleline: false

            ; Print options
          , ItemProp: '__Items__'
          , PrintErrors: false
          , QuoteNumericKeys: false
          , RootName: '$'
          , UnsetArrayItem: '""'

            ; General options
          , InitialPtrListCapacity: 64
          , InitialStrCapacity: 65536
        }

        /**
         * @description - Sets the base object such that the values are used in this priority order:
         * - 1: The input object.
         * - 2: The configuration object (if present).
         * - 3: The default object.
         * @param {Object} Options - The input object.
         * @return {Object} - The same input object.
         */
        static Call(Options) {
            if IsSet(StringifyAllConfig) {
                ObjSetBase(StringifyAllConfig, StringifyAll.Options.Default)
                ObjSetBase(Options, StringifyAllConfig)
            } else {
                ObjSetBase(Options, StringifyAll.Options.Default)
            }
            return Options
        }
    }
}
