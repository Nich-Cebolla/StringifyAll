/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-StringifyAll
    Author: Nich-Cebolla
    Version: 1.2.0
    License: MIT
*/

#include *i <ConfigLibrary>

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance
#include <Inheritance>

/**
 * @description - A customizable solution for serializing an object's properties, including inherited
 * properties, and/or items into a 100% valid JSON string. See the documentation for full details.
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
 * Note that `StringifyAll` changes the base of the `StringifyAllConfig` class to
 * `StringifyAll.Options.Default`, and changes the base of the input options object to either
 * `StringifyAllConfig` if it exists, or to `StringifyAll.Options.Default` if `StringifyAllConfig`
 * does not exist.
 *
 * The options defined by the `Options` parameter supercede options defined by the `StringifyConfig`
 * class. This is convenient for setting your own defaults based on your personal preferences /
 * project needs using the class object, and then passing an object to the `Options` parameter to
 * adjust your defaults on-the-fly.
 *
 * Note that these are short descriptions of the options. For complete details about the options,
 * see the documentation "README.md".
 *
 * @param {*} Obj - The object to stringify.
 *
 * @param {Object|String} [Options] - If you are using `ConfigLibrary, the name of the configuration.
 * Or, the options object with zero or more of the following properties.
 *
 * ## Options
 *
 * ### Enum options -------------
 *
 * @param {*} [Options.EnumTypeMap = Map('Array', 1, 'Map', 2, 'RegExMatchInfo', 2) ] -
 * `Options.EnumTypeMap` controls which objects have `__Enum` called, and if it is called in 1-param
 * mode or 2-param mode.
 *
 * @param {Boolean} [Options.ExcludeMethods = true ] - If true, properties with a `Call`
 * accessor and properties with only a `Set` accessor are excluded from stringification.
 *
 * @param {String} [Options.ExcludeProps = '' ] - A comma-delimited, case-insensitive list of
 * property names to exclude from stringification. Also see `Options.Filter` and
 * `Options.FilterTypeMap`.
 *
 * @param {*} [Options.FilterTypeMap = '' ] - `Options.FilterTypeMap` controls the filter applied to
 * the `PropsInfo` objects, if any.
 *
 * @param {Integer} [Options.MaxDepth = 0 ] - The maximum depth `StringifyAll` will recurse
 * into. The root depth is 1. Note "depth" and "indent level" do not necessarily line up.
 *
 * @param {Boolean} [Options.Multiple = false ] - When true, there is no limit to how many times
 * `StringifyAll` will process an object. Each time an individual object is encountered, it will
 * be processed unless doing so will result in infinite recursion. When false, `StringifyAll`
 * processes each individual object a maximum of 1 time, and all other encounters result in
 * `StringifyAll` printing a placeholder string that is a string representation of the object path
 * at which the object was first encountered.
 *
 * @param {*} [Options.PropsTypeMap = 1 ] - `Options.PropsTypeMap` controls which objects have
 * their properties iterated and written to the JSON string.
 *
 * @param {*} [Options.StopAtTypeMap = "-Object" ] - `Options.StopAtTypeMap` controls the value
 * that is passed to the `StopAt` parameter of `GetPropsInfo`.
 *
 * ### Callbacks ----------------
 *
 * @param {*} [Options.CallbackError = '' ] - A function or callable object that is called when `StringifyAll`
 * encounters an error when attempting to access the value of a property.
 *
 * @param {*} [Options.CallbackGeneral = '' ] - A function or callable object, or an array of
 * one or more functions or callable objects, that will be called for each object prior to processing.
 *
 * @param {*} [Options.CallbackPlaceholder = '' ] - When `StringifyAll` skips processing an
 * object, a placeholder is printed instead. You can define `Options.CallbackPlaceholder`
 * with any callable object to customize the string that gets printed.
 *
 * ### Newline and indent options
 *
 * @param {Integer} [Options.CondenseCharLimit = 0 ]
 * @param {Integer} [Options.CondenseCharLimitEnum1 = 0 ]
 * @param {Integer} [Options.CondenseCharLimitEnum2 = 0 ]
 * @param {Integer} [Options.CondenseCharLimitEnum2Item = 0 ]
 * @param {Integer} [Options.CondenseCharLimitProps = 0 ] -
 * Sets a threshold which `StringifyAll` uses to determine whether an object's JSON substring should
 * be condensed to a single line as a function of the character length of the substring.
 *
 * @param {Boolean} [Options.CondenseDepthThreshold = 0
 * @param {Integer} [Options.CondenseDepthThresholdEnum1 = 0 ]
 * @param {Integer} [Options.CondenseDepthThresholdEnum2 = 0 ]
 * @param {Integer} [Options.CondenseDepthThresholdEnum2Item = 0 ]
 * @param {Integer} [Options.CondenseDepthThresholdProps = 0 ] -
 * If any of the `Options.CondenseCharLimit` options are in use, the `Options.CondenseDepthThreshold`
 * options set a depth requirement to apply the option. For example, if
 * `Options.CondenseDepthThreshold == 2`, all `Options.CondenseCharLimit` options will only be
 * applied if the current depth is 2 or more; values at the root depth (1) will be processed without
 * applying the `Options.CondenseCharLimit` option.
 *
 * @param {String} [Options.Indent = '`s`s`s`s' ] - The literal string that will be used for one level
 * of indentation. Note that the first line with the opening brace is not indented.
 *
 * @param {String} [Options.InitialIndent = 0 ] - The initial indent level.
 *
 * @param {String} [Options.Newline = '`r`n' ] - The literal string that will be used for line
 * breaks. If set to zero or an empty string, the `Options.Singleline` option is effectively
 * enabled.
 *
 * @param {Integer} [Options.NewlineDepthLimit = 0 ] - Sets a threshold directing `StringifyAll`
 * to stop adding line breaks between values after exceeding the threshold.
 *
 * @param {Boolean} [Options.Singleline = false ] - If true, the JSON string is printed without
 * line breaks or indentation. All other "Newline and indent options" are ignored.
 *
 * ### Print options ------------
 *
 * @param {String} [Options.ItemProp = '__Item__' ] - The name that `StringifyAll` will use as a
 * faux-property for including an object's items returned by its enumerator.
 *
 * @param {Boolean|String} [Options.PrintErrors = false ] - When `StringifyAll` encounters an error
 * accessing a property's value, `Options.PrintErrors` influences how it is handled. `Options.PrintErrors`
 * is ignored if `Options.CallbackError` is set.
 * - If `Options.PrintErrors` is a string value, it should be a comma-delimited list of `Error` property
 * names to include in the output as the value of the property that caused the error.
 * - If any other nonzero value, `StringifyAll` will print just the "Message" property of the `Error`
 * object in the string.
 * - If zero or an empty string, `StringifyAll` skips the property.
 *
 * @param {Boolean} [Options.QuoteNumericKeys = false ] - When true, and when `StringifyAll` is
 * processing an object's enumerator in 2-param mode, if the value returned to the first parameter
 * (the "key") is numeric, it will be quoted in the JSON string.
 *
 * @param {String} [Options.RootName = '$' ] - Specifies the name of the root object used in the
 * string representation of an object's path when the object is skipped due to already having been
 * stringified.
 *
 * @param {String} [Options.UnsetArrayItem = '""' ] - The string to print for unset array items.
 *
 * ### General options ----------
 *
 * @param {Integer} [Options.InitialPtrListCapacity = 64 ] - `StringifyAll` tracks the ptr
 * addresses of every object it stringifies to prevent infinite recursion. `StringifyAll` will set
 * the initial capacity of the `Map` object used for this purpose to
 * `Options.InitialPtrListCapacity`.
 *
 * @param {Integer} [Options.InitialStrCapacity = 65536 ] - `StringifyAll` calls `VarSetStrCapacity`
 * using `Options.InitialStrCapacity` for the output string during the initialization stage.
 * For the best performance, you can overestimate the approximate length of the string; `StringifyAll`
 * calls `VarSetStrCapacity(&OutStr, -1)` at the end of the function to release any unused memory.
 *
 * ------------------------------
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
        controllerBase := {
            LenContainerEnum: ''
          , LenContainerEnum2Item: ''
          , LenContainerProps: ''
          , PrepareNextProp: _PrepareNextProp1
          , PrepareNextEnum1: _PrepareNextEnum11
          , ProcessProps: (excludeMethods := Options.ExcludeMethods) ? _ProcessProps1 : _ProcessProps2
        }
        objectsToDeleteDefault := []
        objectsToDeleteDefault.Capacity := 4
        controllerBase.DefineProp('Path', { Get: (Self) => Self.PathObj.Call() })
        enumTypeMap := Options.EnumTypeMap
        if IsObject(enumTypeMap) {
            if enumTypeMap is Map {
                if enumTypeMap.Count {
                    if !enumTypeMap.HasOwnProp('Default') {
                        enumTypeMap.Default := 0
                        objectsToDeleteDefault.Push(enumTypeMap)
                    }
                    CheckEnum := _CheckEnum1
                } else {
                    enumTypeMap := enumTypeMap.HasOwnProp('Default') ? enumTypeMap.Default : 0
                    CheckEnum := IsObject(enumTypeMap) ? enumTypeMap : _CheckEnum2
                }
            } else {
                CheckEnum := enumTypeMap
            }
        } else {
            CheckEnum := _CheckEnum2
        }
        excludeProps := Options.ExcludeProps
        maxDepth := Options.MaxDepth > 0 ? Options.MaxDepth : 9223372036854775807
        propsTypeMap := Options.PropsTypeMap
        if IsObject(propsTypeMap) {
            if propsTypeMap is Map {
                if propsTypeMap.Count {
                    if !propsTypeMap.HasOwnProp('Default') {
                        propsTypeMap.Default := 0
                        objectsToDeleteDefault.Push(propsTypeMap)
                    }
                    CheckProps := _CheckProps1
                } else {
                    propsTypeMap := propsTypeMap.HasOwnProp('Default') ? propsTypeMap.Default : 0
                    CheckProps := IsObject(propsTypeMap) ? propsTypeMap : _CheckProps2
                }
            } else {
                CheckProps := propsTypeMap
            }
        } else {
            CheckProps := _CheckProps2
        }
        if filterTypeMap := Options.FilterTypeMap {
            if filterTypeMap is Map {
                if filterTypeMap.Count {
                    if !filterTypeMap.HasOwnProp('Default') {
                        filterTypeMap.Default := 0
                        objectsToDeleteDefault.Push(filterTypeMap)
                    }
                    SetFilter := _SetFilter1
                } else {
                    if filterTypeMap.HasOwnProp('Default') && filterTypeMap.Default {
                        filterTypeMap := filterTypeMap.Default
                        SetFilter := HasMethod(filterTypeMap, 'Call') ? _SetFilter2 : _SetFilter3
                    }
                }
            } else if HasMethod(filterTypeMap, 'Call') {
                SetFilter := _SetFilter2
            } else {
                throw ValueError('If ``Options.FilterTypeMap`` is nonzero, it must inherit from ``Map``'
                ' or must be an object with a "Call" property.', -1)
            }
        }
        stopAtTypeMap := Options.StopAtTypeMap
        if IsSet(SetFilter) {
            if IsObject(stopAtTypeMap) {
                if stopAtTypeMap is Map {
                    if stopAtTypeMap.Count {
                        if !stopAtTypeMap.HasOwnProp('Default') {
                            stopAtTypeMap.Default := '-Object'
                            objectsToDeleteDefault.Push(stopAtTypeMap)
                        }
                        _GetPropsInfo := _GetPropsInfo1
                    } else {
                        stopAtTypeMap := stopAtTypeMap.HasOwnProp('Default') ? stopAtTypeMap.Default : '-Object'
                        _GetPropsInfo := IsObject(stopAtTypeMap) ? _GetPropsInfo2 : _GetPropsInfo3
                    }
                } else {
                    _GetPropsInfo := _GetPropsInfo2
                }
            } else {
                _GetPropsInfo := _GetPropsInfo3
            }
        } else {
            if IsObject(stopAtTypeMap) {
                if stopAtTypeMap is Map {
                    if stopAtTypeMap.Count {
                        if !stopAtTypeMap.HasOwnProp('Default') {
                            stopAtTypeMap.Default := '-Object'
                            flag_deleteStopAtTypeMapDefault := true
                        }
                        _GetPropsInfo := _GetPropsInfo4
                    } else {
                        stopAtTypeMap := stopAtTypeMap.HasOwnProp('Default') ? stopAtTypeMap.Default : '-Object'
                        _GetPropsInfo := IsObject(stopAtTypeMap) ? _GetPropsInfo5 : _GetPropsInfo6
                    }
                } else {
                    _GetPropsInfo := _GetPropsInfo5
                }
            } else {
                _GetPropsInfo := _GetPropsInfo6
            }
        }
        HandleMultiple := Options.Multiple ? _HandleMultiple : (*) => 1
        if Options.CallbackError {
            HandleError := Options.CallbackError
        } else if printErrors := Options.PrintErrors {
            if IsNumber(printErrors) {
                HandleError := _HandleError1
            } else {
                HandleError := _HandleError2
            }
        } else {
            HandleError := _HandleError3
        }
        if Options.CallbackGeneral {
            if Options.CallbackGeneral is Array {
                CallbackGeneral := Options.CallbackGeneral
            } else {
                CallbackGeneral := [Options.CallbackGeneral]
            }
            HandleProp := _HandleProp2
            HandleEnum1 := _HandleEnum12
            HandleEnum2 := _HandleEnum22
        } else {
            HandleProp := _HandleProp1
            HandleEnum1 := _HandleEnum11
            HandleEnum2 := _HandleEnum21
        }
        GetPlaceholder := Options.CallbackPlaceholder ? Options.CallbackPlaceholder : _GetPlaceholder
        itemProp := Options.ItemProp
        quoteNumericKeys := Options.QuoteNumericKeys
        unsetArrayItem := Options.UnsetArrayItem

        Recurse := _Recurse1
        OutStr := ''
        VarSetStrCapacity(&OutStr, Options.InitialStrCapacity)
        depth := 0

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
            controllerBase.PrepareNextEnum2 := _PrepareNextEnum21
            controllerBase.ProcessEnum2 := _ProcessEnum21
            IncDepth := _IncDepth2
        } else {
            ; Newline / indent options
            CondenseCharLimitEnum1 := Options.CondenseCharLimitEnum1 || Options.CondenseCharLimit
            CondenseCharLimitEnum2 := Options.CondenseCharLimitEnum2 || Options.CondenseCharLimit
            CondenseCharLimitEnum2Item := Options.CondenseCharLimitEnum2Item || Options.CondenseCharLimit
            CondenseCharLimitProps := Options.CondenseCharLimitProps || Options.CondenseCharLimit
            if Options.newlineDepthLimit > 0 {
                newlineDepthLimit := Options.NewlineDepthLimit
                IncDepth := _IncDepth1
            } else {
                IncDepth := _IncDepth2
            }
            newlineCount := whitespaceChars := singleLineActive := 0
            indent := [Options.Indent]
            indent.Capacity := Options.MaxDepth ? Options.MaxDepth + 1 : 16
            nlStr := Options.Newline
            newlineLen := StrLen(nlStr)
            indentlevel := Options.InitialIndent
            nl := _nl1
            ind := _ind1
            if CondenseCharLimitEnum1 > 0 {
                CondenseDepthThresholdEnum1 := Options.CondenseDepthThresholdEnum1 || Options.CondenseDepthThreshold
                if CondenseDepthThresholdEnum1 > 0 {
                    controllerBase.OpenEnum1 := _OpenEnum14
                } else {
                    controllerBase.OpenEnum1 := _OpenEnum12
                }
                controllerBase.CloseEnum1 := _CloseEnum12
            } else {
                controllerBase.OpenEnum1 := _OpenEnum11
                controllerBase.CloseEnum1 := _CloseEnum11
            }
            if CondenseCharLimitEnum2 > 0 {
                CondenseDepthThresholdEnum2 := Options.CondenseDepthThresholdEnum2 || Options.CondenseDepthThreshold
                if CondenseDepthThresholdEnum2 > 0 {
                    controllerBase.OpenEnum2 := _OpenEnum24
                } else {
                    controllerBase.OpenEnum2 := _OpenEnum22
                }
                controllerBase.CloseEnum2 := _CloseEnum22
            } else {
                controllerBase.OpenEnum2 := _OpenEnum21
                controllerBase.CloseEnum2 := _CloseEnum21
            }
            if CondenseCharLimitEnum2Item > 0 {
                CondenseDepthThresholdEnum2Item := Options.CondenseDepthThresholdEnum2Item || Options.CondenseDepthThreshold
                if CondenseDepthThresholdEnum2Item > 0 {
                    controllerBase.PrepareNextEnum2 := _PrepareNextEnum25
                } else {
                    controllerBase.PrepareNextEnum2 := _PrepareNextEnum23
                }
                controllerBase.ProcessEnum2 := _ProcessEnum22
            } else {
                controllerBase.PrepareNextEnum2 := _PrepareNextEnum21
                controllerBase.ProcessEnum2 := _ProcessEnum21
            }
            if CondenseCharLimitProps > 0 {
                CondenseDepthThresholdProps := Options.CondenseDepthThresholdProps || Options.CondenseDepthThreshold
                if CondenseDepthThresholdProps > 0 {
                    controllerBase.OpenProps := _OpenProps4
                } else {
                    controllerBase.OpenProps := _OpenProps2
                }
                controllerBase.CloseProps := _CloseProps2
            } else {
                controllerBase.OpenProps := _OpenProps1
                controllerBase.CloseProps := _CloseProps1
            }
        }

        GetController := ClassFactory(controllerBase)
        controller := GetController()
        controller.PathObj := StringifyAll.Path(Options.RootName)
        ptrList := Map(ObjPtr(Obj), controller)
        ptrList.Capacity := Options.InitialPtrListCapacity

        Recurse(controller, Obj, &OutStr)

        VarSetStrCapacity(&OutStr, -1)
        for o in objectsToDeleteDefault {
            o.DeleteProp('Default')
        }

        return OutStr

        _Recurse1(controller, Obj, &OutStr) {
            IncDepth(1)
            controller.Obj := Obj
            flag_enum := HasMethod(Obj, '__Enum') ? CheckEnum(Obj) : 0
            if flag_props := CheckProps(Obj) {
                PropsInfoObj := _GetPropsInfo(Obj)
                flag_props := PropsInfoObj.Count
            }
            if flag_props {
                controller.OpenProps(&OutStr)
                controller.ProcessProps(Obj, PropsInfoObj, &OutStr)
                if flag_enum == 1 {
                    OutStr .= ',' nl() ind() '"' itemProp '": '
                    controller.OpenEnum1(&OutStr)
                    controller.CloseEnum1(_ProcessEnum1(controller, Obj, &OutStr), &OutStr)
                } else if flag_enum == 2 {
                    OutStr .= ',' nl() ind() '"' itemProp '": '
                    controller.OpenEnum2(&OutStr)
                    controller.CloseEnum2(controller.ProcessEnum2(Obj, &OutStr), &OutStr)
                } else if flag_enum {
                    throw Error('Invalid return value from ``Options.EnumTypeMap``.', -1, flag_enum)
                }
                controller.CloseProps(&OutStr)
            } else if flag_enum == 1 {
                controller.OpenEnum1(&OutStr)
                controller.CloseEnum1(_ProcessEnum1(controller, Obj, &OutStr), &OutStr)
            } else if flag_enum == 2 {
                controller.OpenEnum2(&OutStr)
                controller.CloseEnum2(controller.ProcessEnum2(Obj, &OutStr), &OutStr)
            } else if flag_enum {
                throw Error('Invalid return value from ``Options.EnumTypeMap``.', -1, flag_enum)
            }else {
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
        _CheckEnum2(*) {
            return enumTypeMap
        }
        _CheckProps1(Obj) {
            if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
                return Item(Obj)
            } else {
                return Item
            }
        }
        _CheckProps2(*) {
            return propsTypeMap
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
                if container := controller.LenContainerEnum {
                    if StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitEnum1 {
                        whitespaceChars -= diff
                        OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                    }
                }
            } else {
                OutStr .= ']'
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
                if container := controller.LenContainerEnum {
                    if StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitEnum2 {
                        whitespaceChars -= diff
                        OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                    }
                }
            } else {
                OutStr .= '[]]'
            }
        }
        _CloseProps1(controller, &OutStr) {
            indentLevel--
            OutStr .= nl() ind() '}'
        }
        _CloseProps2(controller, &OutStr) {
            indentLevel--
            OutStr .= nl() ind() '}'
            if container := controller.LenContainerProps {
                if StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitProps {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _GetPlaceholder(PathObj, Val, *) {
            return '"{ ' this.GetType(Val) ':' ObjPtr(Val) ' }"'
        }
        _GetPropsInfo1(Obj) {
            if IsObject(Item := stopAtTypeMap.Get(Type(Obj))) {
                pi := GetPropsInfo(Obj, Item(Obj), excludeProps, false, , excludeMethods)
            } else {
                pi := GetPropsInfo(Obj, Item, excludeProps, false, , excludeMethods)
            }
            SetFilter(Obj, pi)
            return pi
        }
        _GetPropsInfo2(Obj) {
            pi := GetPropsInfo(Obj, stopAtTypeMap(Obj), excludeProps, false, , excludeMethods)
            SetFilter(Obj, pi)
            return pi
        }
        _GetPropsInfo3(Obj) {
            pi := GetPropsInfo(Obj, stopAtTypeMap, excludeProps, false, , excludeMethods)
            SetFilter(Obj, pi)
            return pi
        }
        _GetPropsInfo4(Obj) {
            if IsObject(Item := stopAtTypeMap.Get(Type(Obj))) {
                return GetPropsInfo(Obj, Item(Obj), excludeProps, false, , excludeMethods)
            } else {
                return GetPropsInfo(Obj, Item, excludeProps, false, , excludeMethods)
            }
        }
        _GetPropsInfo5(Obj) {
            return GetPropsInfo(Obj, stopAtTypeMap(Obj), excludeProps, false, , excludeMethods)
        }
        _GetPropsInfo6(Obj) {
            return GetPropsInfo(Obj, stopAtTypeMap, excludeProps, false, , excludeMethods)
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
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    OutStr .= '"{ ' ptrList.Get(ptr)[1].Path ' }"'
                } else {
                    newController := GetController()
                    newController.PathObj := controller.PathObj.MakeItem(&Key)
                    ptrList.Get(ptr).Push(newController)
                    Recurse(newController, Val, &OutStr)
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
            } else {
                newController := GetController()
                newController.PathObj := controller.PathObj.MakeItem(&Key)
                ptrList.Set(ptr, [newController])
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum12(controller, Val, &Key, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    controller.PrepareNextEnum1(&OutStr)
                    OutStr .= '"{ ' ptrList.Get(ptr)[1].Path ' }"'
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                controller.PrepareNextEnum1(&OutStr)
                OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
                return
            }
            for cb in CallbackGeneral {
                if result := cb(controller.PathObj, Val, &OutStr, , key) {
                    if result is String {
                        controller.PrepareNextEnum1(&OutStr)
                        OutStr .= result
                    } else if result !== -1 {
                        controller.PrepareNextEnum1(&OutStr)
                        OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
                    }
                    return
                }
            }
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeItem(&Key)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            controller.PrepareNextEnum1(&OutStr)
            Recurse(newController, Val, &OutStr)
        }
        _HandleEnum21(controller, Val, &Key, &OutStr) {
            controller.PrepareNextEnum2(&OutStr)
            OutStr .= Key ',' nl() ind()
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    OutStr .= '"{ ' ptrList.Get(ptr)[1].Path ' }"'
                } else {
                    newController := GetController()
                    newController.PathObj := controller.PathObj.MakeItem(&Key)
                    ptrList.Get(ptr).Push(newController)
                    Recurse(newController, Val, &OutStr)
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
            } else {
                newController := GetController()
                newController.PathObj := controller.PathObj.MakeItem(&Key)
                ptrList.Set(ptr, [newController])
                Recurse(newController, Val, &OutStr)
            }
        }
        _HandleEnum22(controller, Val, &Key, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    controller.PrepareNextEnum2(&OutStr)
                    OutStr .= Key ',' nl() ind()
                    OutStr .= '"{ ' ptrList.Get(ptr)[1].Path ' }"'
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                controller.PrepareNextEnum2(&OutStr)
                OutStr .= Key ',' nl() ind()
                OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
                return
            }
            for cb in CallbackGeneral {
                if result := cb(controller.PathObj, Val, &OutStr, , key) {
                    if result is String {
                        controller.PrepareNextEnum2(&OutStr)
                        OutStr .= Key ',' nl() ind()
                        OutStr .= result
                    } else if result !== -1 {
                        controller.PrepareNextEnum2(&OutStr)
                        OutStr .= Key ',' nl() ind()
                        OutStr .= GetPlaceholder(controller.PathObj, Val, , &Key)
                    }
                    return
                }
            }
            controller.PrepareNextEnum2(&OutStr)
            OutStr .= Key ',' nl() ind()
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeItem(&Key)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            Recurse(newController, Val, &OutStr)
        }
        _HandleError1(PathObj, Err, *) {
            local s := Err.Message
            StringifyAll.StrEscapeJson(&s, true)
            return s
        }
        _HandleError2(PathObj, Err, *) {
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
        _HandleMultiple(PathObj, Val) {
            path := '$.' PathObj()
            for c in ptrList.Get(ObjPtr(Val)) {
                if InStr(path, '$.' c.Path) {
                    return 1
                }
            }
        }
        _HandleProp1(controller, Val, &Prop, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    Val := '{ ' ptrList.Get(ptr)[1].Path ' }'
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                _WriteProp2(controller, &Prop, GetPlaceholder(controller.PathObj, Val, &Prop), &OutStr)
                return
            }
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": '
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeProp(&Prop)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            Recurse(newController, Val, &OutStr)
        }
        _HandleProp2(controller, Val, &Prop, &OutStr) {
            if ptrList.Has(ptr := ObjPtr(Val)) {
                if HandleMultiple(controller.PathObj, Val) {
                    Val := '{ ' ptrList.Get(ptr)[1].Path ' }'
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                    return
                }
            } else if depth >= maxDepth || Val is ComObject || Val is ComValue {
                _WriteProp2(controller, &Prop, GetPlaceholder(controller.PathObj, Val, &Prop), &OutStr)
                return
            }
            for cb in CallbackGeneral {
                if result := cb(controller.PathObj, Val, &OutStr, Prop) {
                    if result is String {
                        _WriteProp3(controller, &Prop, &result, &OutStr)
                    } else if result !== -1 {
                        _WriteProp2(controller, &Prop, GetPlaceholder(controller.PathObj, Val, &Prop), &OutStr)
                    }
                    return
                }
            }
            controller.PrepareNextProp(&OutStr)
            OutStr .= '"' Prop '": '
            newController := GetController()
            newController.PathObj := controller.PathObj.MakeProp(&Prop)
            if ptrList.Has(ptr) {
                ptrList.Get(ptr).Push(newController)
            } else {
                ptrList.Set(ptr, [newController])
            }
            Recurse(newController, Val, &OutStr)
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
            controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum13(controller, &OutStr) {
            OutStr .= '['
        }
        _OpenEnum14(controller, &OutStr) {
            if depth >= CondenseDepthThresholdEnum1 {
                controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum21(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum22(controller, &OutStr) {
            controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum23(controller, &OutStr) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum24(controller, &OutStr) {
            if depth >= CondenseDepthThresholdEnum2 {
                controller.LenContainerEnum := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            OutStr .= '['
            indentLevel++
        }
        _OpenProps1(controller, &OutStr) {
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps2(controller, &OutStr) {
            controller.LenContainerProps := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps3(controller, &OutStr) {
            OutStr .= '{'
        }
        _OpenProps4(controller, &OutStr) {
            if depth >= CondenseDepthThresholdProps {
                controller.LenContainerProps := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            OutStr .= '{'
            indentLevel++
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
        _PrepareNextEnum23(controller, &OutStr) {
            OutStr .= nl() ind() '['
            controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            indentLevel++
            OutStr .= nl() ind()
            controller.PrepareNextEnum2 := _PrepareNextEnum24
        }
        _PrepareNextEnum24(controller, &OutStr) {
            OutStr .= ',' nl() ind() '['
            controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            indentLevel++
            OutStr .= nl() ind()
        }
        _PrepareNextEnum25(controller, &OutStr) {
            OutStr .= nl() ind() '['
            if depth >= CondenseDepthThresholdEnum2Item {
                controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
            indentLevel++
            OutStr .= nl() ind()
            controller.PrepareNextEnum2 := _PrepareNextEnum26
        }
        _PrepareNextEnum26(controller, &OutStr) {
            OutStr .= ',' nl() ind() '['
            if depth >= CondenseDepthThresholdEnum2Item {
                controller.LenContainerEnum2Item := { len: StrLen(OutStr), whitespaceChars: whitespaceChars }
            }
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
                        HandleEnum1(controller, Val, &(i := A_Index), &OutStr)
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
        _ProcessEnum21(controller, Obj, &OutStr) {
            count := 0
            for Key, Val in Obj {
                count++
                if IsObject(Key) {
                    Key := '"{ ' this.GetType(Key) ':' ObjPtr(Key) ' }"'
                } else {
                    _GetVal(&Key, quoteNumericKeys)
                }
                if IsObject(Val) {
                    HandleEnum2(controller, Val, &Key, &OutStr)
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
        _ProcessEnum22(controller, Obj, &OutStr) {
            count := 0
            for Key, Val in Obj {
                count++
                if IsObject(Key) {
                    Key := '"{ ' this.GetType(Key) ':' ObjPtr(Key) ' }"'
                } else {
                    _GetVal(&Key, quoteNumericKeys)
                }
                if IsObject(Val) {
                    HandleEnum2(controller, Val, &Key, &OutStr)
                } else {
                    controller.PrepareNextEnum2(&OutStr)
                    OutStr .= Key ',' nl() ind()
                    _GetVal(&Val)
                    OutStr .= Val
                }
                indentLevel--
                OutStr .= nl() ind() ']'
                if container := controller.LenContainerEnum2Item {
                    if StrLen(OutStr) - container.len - (diff := whitespaceChars - container.whitespaceChars) <= condenseCharLimitEnum2Item {
                        whitespaceChars -= diff
                        OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                    }
                }
            }
            return count
        }
        ; ExcludeMethod = true
        _ProcessProps1(controller, Obj, PropsInfoObj, &OutStr) {
            for Prop, InfoItem in PropsInfoObj {
                if InfoItem.GetValue(&Val) {
                    if IsSet(Val) {
                        if errorResult := HandleError(controller.PathObj, Val, Obj, InfoItem) {
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
                    HandleProp(controller, Val, &Prop, &OutStr)
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
                        if errorResult := HandleError(controller.PathObj, Val, Obj, InfoItem) {
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
                    HandleProp(controller, Val, &Prop, &OutStr)
                } else {
                    _WriteProp1(controller, &Prop, &Val, &OutStr)
                }
                Val := unset
            }
        }
        _SetFilter1(Obj, pi) {
            if Item := filterTypeMap.Get(Type(Obj)) {
                if HasMethod(Item, 'Call') {
                    if val := Item(Obj) {
                        pi.FilterSet(Val)
                    }
                } else {
                    pi.FilterSet(Item)
                }
            }
        }
        _SetFilter2(Obj, pi) {
            if val := filterTypeMap(Obj) {
                pi.FilterSet(val)
            }
        }
        _SetFilter3(Obj, pi) {
            pi.FilterSet(filterTypeMap)
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
        n := 0xFFFD
        while InStr(Str, Chr(n)) {
            n++
        }
        Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\\', Chr(n)), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t'), Chr(n), '\')
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
     * @param {*} Obj - The object being evaluated.
     */
    static GetPlaceholder(Obj) {
        return '"{ ' this.GetType(Obj) ':' ObjPtr(Obj) ' }"'
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
          , FilterTypeMap: ''
          , MaxDepth: 0
          , Multiple: false
          , PropsTypeMap: 1
          , StopAtTypeMap: '-Object'

            ; Callbacks
          , CallbackError: ''
          , CallbackGeneral: ''
          , CallbackPlaceholder: ''

            ; Newline and indent options
          , CondenseCharLimit: 0
          , CondenseCharLimitEnum1: 0
          , CondenseCharLimitEnum2: 0
          , CondenseCharLimitEnum2Item: 0
          , CondenseCharLimitProps: 0
          , CondenseDepthThreshold: 0
          , CondenseDepthThresholdEnum1: 0
          , CondenseDepthThresholdEnum2: 0
          , CondenseDepthThresholdEnum2Item: 0
          , CondenseDepthThresholdProps: 0
          , Indent: '`s`s`s`s'
          , InitialIndent: 0
          , Newline: '`r`n'
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

    /**
     * @classdesc - This is a solution for tracking object paths using strings.
     * @example
     *  Obj := {
     *      Prop1: {
     *          NestedProp1: {
     *              NestedMap: Map(
     *                  'Key1', Map(
     *                      'Key2', 'Val1'
     *                  )
     *              )
     *          }
     *      }
     *  }
     *  Root := PathObj('Obj')
     *  O1 := Root.MakeProp('Prop1')
     *  O2 := O1.MakeProp('NestedProp1')
     *  O3 := O2.MakeProp('NestedMap')
     *  O4 := O3.MakeItem('Key1')
     *  O5 := O4.MakeItem('Key2')
     *  OutputDebug(O5()) ; Obj.Prop1.NestedProp1.NestedMap["Key1"]["Key2"]
     *
     *  ; You can start another branch
     *  Obj.Prop1.Branch := [ 1, 2, { Prop: 'Val' }, 4 ]
     *  B1 := O1.MakeProp('Branch')
     *  B2 := B1.MakeItem(3)
     *  B3 := B2.MakeProp('Prop')
     *  OutputDebug('`n' B3()) ; Obj.Prop1.Branch[3].Prop
     * @
     */
    class Path {
        __New(Name := '$') {
            this.Name := Name
            this.DefineProp('GetPathSegment', StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentRoot'))
        }
        Call(*) {
            o := this
            p := ''
            loop {
                if o.GetPathSegment(&p) {
                    break
                }
                o := o.Base
            }
            return o.Name p
        }
        MakeProp(&Name) {
            static desc := StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentProp')
            ObjSetBase(Segment := { Name: Name }, this)
            Segment.DefineProp('GetPathSegment', desc)
            return Segment
        }
        MakeItem(&Name) {
            static desc := StringifyAll.Path.Prototype.GetOwnPropDesc('__GetPathSegmentItem')
            ObjSetBase(Segment := { Name: Name }, this)
            Segment.DefineProp('GetPathSegment', desc)
            return Segment
        }
        __GetPathSegmentItem(&Path) {
            Path := '[' this.Name ']' Path
        }
        __GetPathSegmentProp(&Path) {
            Path := '.' this.Name Path
        }
        __GetPathSegmentRoot(*) {
            return 1
        }

        Path => this()
    }

}
