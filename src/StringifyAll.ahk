/*
   Github: https://github.com/Nich-Cebolla/AutoHotkey-StringifyAll
    Author: Nich-Cebolla
    Version: 1.0.0
    License: MIT
*/

; https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance
#include <Inheritance>

/**
 * @description - `StringifyAll` is a customizable solution for serializing an AHK object into a JSON
 * string. `StringifyAll` utilizes `GetPropsInfo` from the "Inheritance" library linked
 * at the top of the file. This allows us to include every property, even inherited properties,
 * in the resulting JSON string.
 *
 * `StringifyAll` exposes many options to programmatically restrict what gets included in the JSON
 * string. It also includes options for adjusting the spacing in the string. To set your options, you
 * can:
 * - Copy one of the template files into your project directory and set the options using the
 * template.
 * - Define a class `StringifyAllConfig` anywhere in your code.
 * - Pass an object to the `Options` parameter.
 *
 * The options defined by the `Options` parameter supercede options defined by the `StringifyConfig`
 * class. This is convenient for setting your own defaults based on your personal preferences /
 * project needs using the class object, and then passing an object to the `Options` parameter to
 * adjust your defaults on-the-fly.
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
 * The template "StringifyAllConfig-special-template.ahk" restricts `StringifyAll` to skip all native
 * array properties so array objects will be represented with the usual square brackets in the JSON
 * string. This template also causes `StringifyAll` to skip native map properties for the same purpose;
 * `Map` objects are represented as arrays of tuples in the JSON string.
 *
 * There are some conditions which will cause `Stringify` to skip stringifying an object. When this
 * occurs, `Stringify` prints a placeholder string instead. The conditions are:
 * - The object is a `ComObject` or `ComValue`.
 * - The maximum depth is reached.
 * - Your callback function returned a value directing `Stringify` to skip the object.
 * - The object has been stringified already. The placeholder for this condition is separate from
 * the others; it is a string representation of the object path at which the object was first encountered.
 * This is so one's code or one's self can identify the correct object that as at that location
 * when `Stringify` was processing.
 *
 * Note that these are short descriptions of the options. For complete details about the options,
 * see the documentation within "StringifyAllConfig-details.ahk".
 *
 * @param {*} Obj - The object to stringify.
 *
 * @param {Object} [Options] - The options object with zero or more of the following properties.
 * @param {*} [Options.EnumCondition=unset] - A function or callable object that returns an
 * indicator if an object should be enumerated, and if so, to use 1-param mode or 2-param mode.
 * Also see {@link StringifyConfig.EnumTypeMap}.
 * @param {Map} [Options.EnumTypeMap=unset] - A `Map` object where the keys are object types
 * and the values are an integer indicating how `Stringify` should enumerate objects of that type.
 * @param {Boolean} [Options.ExcludeMethods=unset] - If true, properties with a `Call`
 * accessor and properties with only a `Set` accessor are excluded from stringification.
 * @param {String} [Options.ExcludeProps=unset] - A comma-delimited, case-insensitive list of
 * property names to exclude from stringification. Also see {@link StringifyConfig.Filter} and
 * {@link StringifyConfig.FilterMap}.
 * @param {PropsInfo.FilterGroup} [Options.Filter=unset] - A single `PropsInfo.FilterGroup`
 * object that will be applied to all `PropsInfo` objects iterated during stringification. If
 * `StringifyConfig.FilterMap` is set, this is ignored.
 * @param {Map} [Options.FilterMap=unset] - A `Map` object where the keys are object types
 * and the values are `PropsInfo.FilterGroup` objects. `Stringify` will apply the filter when
 * iterating the properties of an object of the indicated types. Note that if you do not set the
 * `Map` object's `Default` value, `Stringify` will set it to `0`.
 * @param {Integer} [Options.MaxDepth=unset] - The maximum depth `Stringify` will recurse
 * into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up.
 * @param {*} [Options.PropsCondition=unset] - A function or callable object that returns an
 * indicator if an object's properties should be stringified.
 * @param {Map} [Options.PropsTypeMap=unset] - A `Map` object where the keys are object types
 * and the values are a boolean indicating whether or not `Stringify` should process the object's
 * properties.
 * @param {Map} [Options.StopAtMap=unset] - A `Map` object where the keys are object types and
 * the values are strings or numbers that will be passed to the `StopAt` parameter of `GetPropsInfo`.
 * @param {*} [Options.CallbackGeneral=unset] - A function or callable object, or an array of
 * one or more functions or callable objects, that will be called for each object prior to processing.
 * @param {*} [Options.CallbackPlaceholder=unset] - When `Stringify` skips processing an
 * object, a placeholder is printed instead. You can define `StringifyConfig.CallbackPlaceholder`
 * with any callable object to customize the string that gets printed.
 * @param {String} [Options.Indent=unset] - The literal string that will be used for one level
 * of indentation.
 * @param {String} [Options.Newline=unset] - The literal string that will be used for line
 * breaks. If set to zero or an empty string, the `StringifyConfig.Singleline` option is effectively
 * enabled.
 * @param {Integer} [Options.CondenseCharLimit=0]
 * @param {Integer} [Options.CondenseCharLimitEnum1=0]
 * @param {Integer} [Options.CondenseCharLimitEnum2=0]
 * @param {Integer} [Options.CondenseCharLimitProps=0] -
 * Sets a threshold which `Stringify` uses to determine whether an object's JSON substring should
 * be condensed to a single line as a function of the character length of the substring.
 * @param {Integer} [Options.NewlineDepthLimit=unset] - Sets a threshold directing `Stringify`
 * to stop adding line breaks between values after exceeding the threshold.
 * @param {Boolean} [Options.Singleline=unset] - If true, the JSON string is printed without
 * line breaks or indentation. All other "Newline and indent options" are ignored.
 * @param {String} [Options.ItemProp=unset] - The name that `Stringify` will use as a
 * faux-property for including an object's items returned by its enumerator.
 * @param {Boolean} [Options.PrintErrors=unset] - When true, if `Stringify` encounters an
 * error when attempting to access the value of an object's property, the error message is
 * included in the JSON string as the value of the property. When false, `Stringify` skips
 * the property.
 * @param {Boolean} [Options.QuoteNumericKeys=false] - When true, and when `Stringify` is
 * processing an object's enumerator in 2-param mode, if the value returned to the first parameter
 * (the "key") is numeric, it will be quoted in the JSON string.
 * @param {String} [Options.RootName=unset] - Specifies the name of the root object used in the
 * string representation of an object's path when the object is skipped due to already having been
 * stringified.
 * @param {String} [Options.UnsetArrayItem=unset] - The string to print for unset array items.
 * @param {Integer} [Options.InitialPtrListCapacity=64] - `Stringify` tracks the ptr
 * addresses of every object it stringifies to prevent infinite recursion. `Stringify` will set
 * the initial capacity of the `Map` object used for this purpose to
 * `StringifyConfig.InitialPtrListCapacity`.
 * @param {Integer} [Options.InitialStrCapacity=65537] - `Stringify` calls `VarSetStrCapacity`
 * using `StringifyConfig.InitialStrCapacity` for the output string during the initialization stage.
 * For the best performance, you can overestimate the approximate length of the string; `Stringify`
 * calls `VarSetStrCapacity(&OutStr, -1)` at the end of the function to release any unused memory.
 *
 * @param {VarRef} [OutStr] - A variable that will be set with the JSON string value. The value
 * is also returned as the return value, but for very long strings receiving the string via the
 * `VarRef` will be slightly faster because the string will not need to be copied.
 */
class StringifyAll {

    static Call(Obj, Options?, &OutStr?) {
        if !this.HasOwnProp('Getcontroller') {
            Proto := this.ControllerPrototype := {}
            Proto.PrepareNextProp := _PrepareNextProp1
            Proto.PrepareNextEnum1 := _PrepareNextEnum11
            Proto.PrepareNextEnum2 := _PrepareNextEnum21
            Proto.ProcessEnum1 := _ProcessEnum1
            Proto.ProcessEnum2 := _ProcessEnum2
            Proto.GetPlaceholder := ObjBindMethod(this, 'GetPlaceholder')
            this.DefineProp('Getcontroller', { Call: ((cb, *) => cb()).Bind(ClassFactory(Proto)) })
        }

        Options := this.Options(Options ?? {})
        controllerBase := this.GetController()

        ; Enum options
        EnumCondition := Options.EnumCondition
        if enumTypeMap := Options.EnumTypeMap {
            CheckEnum := enumTypeMap.HasOwnProp('Default') ? _CheckEnum3 : _CheckEnum1
        } else {
            CheckEnum := _CheckEnum2
        }
        excludeMethods := Options.ExcludeMethods
        excludeProps := Options.ExcludeProps
        if filterMap := Options.FilterMap {
            _GetPropsInfo := _GetPropsInfo1
            if !filterMap.HasOwnProp('Default') {
                filterMap.Default := 0
            }
        } else if filter := Options.Filter {
            _GetPropsInfo := _GetPropsInfo2
        } else {
            _GetPropsInfo := _GetPropsInfo3
        }
        maxDepth := Options.MaxDepth > 0 ? Options.MaxDepth : 9223372036854775807
        PropsCondition := Options.PropsCondition
        if propsTypeMap := Options.PropsTypeMap {
            if propsTypeMap.HasOwnProp('Default') {
                CheckProps := _CheckProps1
            } else if PropsCondition {
                CheckProps := _CheckProps2
            } else {
                CheckProps := _CheckProps3
            }
        } else if PropsCondition {
            CheckProps := _CheckProps4
        } else {
            CheckProps := (*) => 1
        }
        if stopAtMap := Options.StopAtMap {
            if !stopAtMap.HasOwnProp('Default') {
                stopAtMap.Default := '-Object'
            }
        } else {
            stopAtMap := Map()
            stopAtMap.Default := '-Object'
        }
        ; Callbacks
        if CallbackGeneral := Options.CallbackGeneral {
            if not CallbackGeneral is Array {
                CallbackGeneral := [CallbackGeneral]
            }
            controllerBase.HandleProp := _HandleProp2
            controllerBase.HandleEnum1 := _HandleEnum2
            controllerBase.HandleEnum2 := _HandleEnum2
        } else {
            controllerBase.HandleProp := _HandleProp1
            controllerBase.HandleEnum1 := _HandleEnum1
            controllerBase.HandleEnum2 := _HandleEnum1
        }
        if Options.CallbackPlaceholder {
            controllerBase.GetPlaceholder := Options.CallbackPlaceholder
        }
        ; Print options
        itemProp := Options.ItemProp
        if Options.PrintErrors {
            controllerBase.ProcessProps := Options.ExcludeMethods ? _ProcessProps1 : _ProcessProps2
        } else {
            controllerBase.ProcessProps := Options.ExcludeMethods ? _ProcessProps3 : _ProcessProps4
        }
        quoteNumericKeys := Options.QuoteNumericKeys
        unsetArrayItem := Options.UnsetArrayItem
        ; Init vars
        Recurse := _Recurse1
        OutStr := ''
        VarSetStrCapacity(&OutStr, Options.InitialStrCapacity)
        replacements := []
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

        ObjSetBase(controllerBase, this.ControllerPrototype)
        GetController := ClassFactory(controllerBase)
        controller := GetController()
        controller.Path := Options.RootName
        ptrList := Map(ObjPtr(Obj), controller)
        ptrList.Capacity := Options.InitialPtrListCapacity

        Recurse(controller, Obj)

        VarSetStrCapacity(&OutStr, -1)

        return OutStr

        _Recurse1(controller, Obj) {
            IncDepth(1)
            controller.Obj := Obj
            flag_enum := CheckEnum(Obj)
            if flag_props := CheckProps(Obj) {
                PropsInfoObj := _GetPropsInfo(Obj)
                flag_props := PropsInfoObj.Count
            }
            if flag_props {
                controller.OpenProps()
                controller.ProcessProps(PropsInfoObj)
                if flag_enum == 1 {
                    if flag_props {
                        OutStr .= ',' nl() ind() '"' itemProp '": '
                    }
                    controller.OpenEnum1()
                    controller.ProcessEnum1(Obj)
                    controller.CloseEnum1()
                } else if flag_enum == 2 {
                    if flag_props {
                        OutStr .= ',' nl() ind() '"' itemProp '": '
                    }
                    controller.OpenEnum2()
                    controller.CloseEnum2(controller.ProcessEnum2(Obj))
                }
                controller.CloseProps()
            } else if flag_enum == 1 {
                controller.OpenEnum1()
                controller.ProcessEnum1(Obj)
                controller.CloseEnum1()
            } else if flag_enum == 2 {
                controller.OpenEnum2()
                controller.CloseEnum2(controller.ProcessEnum2(Obj))
            } else {
                OutStr .= '{}'
            }
            IncDepth(-1)
        }
        _CheckEnum1(o) {
            if enumTypeMap.Has(Type(o)) {
                return enumTypeMap.Get(Type(o))
            }
            return EnumCondition(o)
        }
        _CheckEnum2(o) {
            return EnumCondition(o)
        }
        _CheckEnum3(o) {
            return enumTypeMap.Get(Type(o))
        }
        _CheckProps1(o) {
            return propsTypeMap.Get(Type(o))
        }
        _CheckProps2(o) {
            if propsTypeMap.Has(Type(o)) {
                return propsTypeMap.Get(Type(o))
            } else {
                return PropsCondition(o)
            }
        }
        _CheckProps3(o) {
            if propsTypeMap.Has(Type(o)) {
                return propsTypeMap.Get(Type(o))
            }
            return 1
        }
        _CheckProps4(o) {
            return PropsCondition(o)
        }
        _CloseEnum11(Self) {
            indentLevel--
            OutStr .= nl() ind() ']'
        }
        _CloseEnum12(Self) {
            indentLevel--
            OutStr .= nl() ind() ']'
            if container := lenContainer.Get(ObjPtr(Self) '-1') {
                if (obj.result := StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars)) <= container.limit {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _CloseEnum21(Self, count) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= '[]]'
            }
        }
        _CloseEnum22(Self, count) {
            indentLevel--
            if count {
                OutStr .= nl() ind() ']'
            } else {
                OutStr .= '[]]'
            }
            if container := lenContainer.Get(ObjPtr(Self) '-2') {
                if (obj.result := StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars)) <= container.limit {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _CloseProps1(Self) {
            indentLevel--
            OutStr .= nl() ind() '}'
        }
        _CloseProps2(Self) {
            indentLevel--
            OutStr .= nl() ind() '}'
            if container := lenContainer.Get(ObjPtr(Self) '-3') {
                if (obj.result := StrLen(OutStr) - container.Len - (diff := whitespaceChars - container.whitespaceChars)) <= container.limit {
                    whitespaceChars -= diff
                    OutStr := RegExReplace(OutStr, '\R *(?!$)', '', , , container.len || 1)
                }
            }
        }
        _GetPropsInfo1(o) {
            pi := GetPropsInfo(o, stopAtMap.Get(Type(o)), excludeProps, false, , excludeMethods)
            if val := filterMap.Get(Type(o)) {
                pi.DefineProp('Filter', { Value: val })
                pi.FilterActivate()
            }
            return pi
        }
        _GetPropsInfo2(o) {
            pi := GetPropsInfo(o, stopAtMap.Get(Type(o)), excludeProps, false, , excludeMethods)
            pi.DefineProp('Filter', { Value: filter })
            pi.FilterActivate()
            return pi
        }
        _GetPropsInfo3(o) {
            return GetPropsInfo(o, stopAtMap.Get(Type(o)), excludeProps, false, , excludeMethods)
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
        _HandleEnum1(controller, Val, &Key) {
            if Val is ComObject || Val is ComValue {
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else if ptrList.Has(ObjPtr(Val)) {
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth {
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else {
                newController := GetController()
                newController.Path := controller.Path '[' Key ']'
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val)
            }
        }
        _HandleProp1(controller, Val, &Prop) {
            if Val is ComObject || Val is ComValue {
                OutStr .= controller.GetPlaceholder(Val, &Prop)
            } else if ptrList.Has(ObjPtr(Val)) {
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth {
                OutStr .= controller.GetPlaceholder(Val, &Prop)
            } else {
                newController := GetController()
                newController.Path := controller.Path '.' Prop
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val)
            }
        }
        _HandleEnum2(controller, Val, &Key) {
            if Val is ComObject || Val is ComValue {
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else if ptrList.Has(ObjPtr(Val)) {
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth {
                OutStr .= controller.GetPlaceholder(Val, , &Key)
            } else {
                for cb in CallbackGeneral {
                    if result := cb(Val, &OutStr) {
                        if result is String {
                            OutStr .= result
                        } else {
                            OutStr .= controller.GetPlaceholder(Val, , &Key)
                        }
                        return
                    }
                }
                newController := GetController()
                newController.Path := controller.Path '[' Key ']'
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val)
            }
        }
        _HandleProp2(controller, Val, &Prop) {
            if Val is ComObject || Val is ComValue {
                OutStr .= controller.GetPlaceholder(Val, &Prop)
            } else if ptrList.Has(ObjPtr(Val)) {
                OutStr .= '"{ ' ptrList.Get(ObjPtr(Val)).Path ' }"'
            } else if depth >= maxDepth {
                OutStr .= controller.GetPlaceholder(Val, &Prop)
            } else {
                for cb in CallbackGeneral {
                    if result := cb(Val, &OutStr) {
                        if result is String {
                            OutStr .= result
                        } else {
                            OutStr .= controller.GetPlaceholder(Val, &Prop)
                        }
                        return
                    }
                }
                newController := GetController()
                newController.Path := controller.Path '.' Prop
                ptrList.Set(ObjPtr(Val), newController)
                Recurse(newController, Val)
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
        _OpenEnum11(Self) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum12(Self) {
            lenContainer.Set(ObjPtr(Self) '-1', { len: StrLen(OutStr), whitespaceChars: whitespaceChars, limit: condenseCharLimitEnum1 })
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum13(Self) {
            OutStr .= '['
        }
        _OpenEnum21(Self) {
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum22(Self) {
            lenContainer.Set(ObjPtr(Self) '-2', { len: StrLen(OutStr), whitespaceChars: whitespaceChars, limit: condenseCharLimitEnum2 })
            OutStr .= '['
            indentLevel++
        }
        _OpenEnum23(Self) {
            OutStr .= '['
            indentLevel++
        }
        _OpenProps1(Self) {
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps2(Self) {
            lenContainer.Set(ObjPtr(Self) '-3', { len: StrLen(OutStr), whitespaceChars: whitespaceChars, limit: condenseCharLimitProps })
            OutStr .= '{'
            indentLevel++
        }
        _OpenProps3(Self) {
            OutStr .= '{'
        }
        _PrepareNextEnum11(Self) {
            OutStr .= nl() ind()
            Self.PrepareNextEnum1 := _PrepareNextEnum12
        }
        _PrepareNextEnum12(Self) {
            OutStr .= ',' nl() ind()
        }
        _PrepareNextEnum21(Self) {
            OutStr .= nl() ind() '['
            indentLevel++
            OutStr .= nl() ind()
            Self.PrepareNextEnum2 := _PrepareNextEnum22
        }
        _PrepareNextEnum22(Self) {
            OutStr .= ',' nl() ind() '['
            indentLevel++
            OutStr .= nl() ind()
        }
        _PrepareNextProp1(Self) {
            OutStr .= nl() ind()
            Self.PrepareNextProp := _PrepareNextProp2
        }
        _PrepareNextProp2(Self) {
            OutStr .= ',' nl() ind()
        }
        _ProcessEnum1(controller, o) {
            for Val in o {
                controller.PrepareNextEnum1()
                if IsSet(Val) {
                    if IsObject(Val) {
                        controller.HandleEnum1(Val, &(i := A_Index))
                    } else {
                        _GetVal(&Val)
                        OutStr .= Val
                    }
                } else {
                    OutStr .= unsetArrayItem
                }
            }
        }
        _ProcessEnum2(controller, o) {
            count := 0
            for Key, Val in o {
                count++
                controller.PrepareNextEnum2()
                if IsObject(Key) {
                    Key := '"{ ' this.GetType(Key) ':' ObjPtr(Key) ' }"'
                } else {
                    _GetVal(&Key, quoteNumericKeys)
                }
                OutStr .= Key ',' nl() ind()
                if IsObject(Val) {
                    controller.HandleEnum2(Val, &Key)
                } else {
                    _GetVal(&Val)
                    OutStr .= Val
                }
                indentLevel--
                OutStr .= nl() ind() ']'
            }
            return count
        }
        _ProcessProps1(Self, _pi) {
            for Prop, Item in _pi {
                if Item.GetValue(&Val) {
                    if IsSet(Val) {
                        Val := Val.Message
                    } else {
                        continue
                    }
                }
                Self.PrepareNextProp()
                OutStr .= '"' Prop '": '
                    if IsObject(Val) {
                        Self.HandleProp(Val, &Prop)
                    } else {
                        _GetVal(&Val)
                        OutStr .= Val
                    }
                Val := unset
            }
        }
        _ProcessProps2(Self, _pi) {
            for Prop, Item in _pi {
                if Item.GetValue(&Val) {
                    if IsSet(Val) {
                        Val := Val.Message
                    } else {
                        Val := '{ ' Item.GetFunc().Name ' }'
                    }
                }
                Self.PrepareNextProp()
                OutStr .= '"' Prop '": '
                    if IsObject(Val) {
                        Self.HandleProp(Val, &Prop)
                    } else {
                        _GetVal(&Val)
                        OutStr .= Val
                    }
                Val := unset
            }
        }
        _ProcessProps3(Self, _pi) {
            for Prop, Item in _pi {
                if Prop = 'M_Map' {
                    sleep 1
                }
                if !Item.GetValue(&Val) {
                    Self.PrepareNextProp()
                    OutStr .= '"' Prop '": '
                    if IsObject(Val) {
                        Self.HandleProp(Val, &Prop)
                    } else {
                        _GetVal(&Val)
                        OutStr .= Val
                    }
                }
                Val := unset
            }
        }
        _ProcessProps4(Self, _pi) {
            for Prop, Item in _pi {
                if Item.GetValue(&Val) {
                    if IsSet(Val) {
                        Val := unset
                        continue
                    } else {
                        Val := '{ ' Item.GetFunc().Name ' }'
                    }
                }
                Self.PrepareNextProp()
                OutStr .= '"' Prop '": '
                    if IsObject(Val) {
                        Self.HandleProp(Val, &Prop)
                    } else {
                        _GetVal(&Val)
                        OutStr .= Val
                    }
                Val := unset
            }
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
        Str := StrReplace(StrReplace(StrReplace(StrReplace(StrReplace(Str, '\\', '\'), '\n', '`n'), '\r', '`r'), '\"', '"'), '\t', '`t')
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
     * that has a string value representing the object path up to but not including `Obj`.
     * @param {*} Obj - The object being evaluated.
     */
    static GetPlaceholder(Controller, Obj, *) {
        return '"{ ' this.GetType(Obj) ':' ObjPtr(Obj) ' }"'
    }


    /**
     * @classdesc - Handles the input options.
     */
    class Options {
        static Default := {
            ; Enum options
            EnumCondition: (Obj) => Obj is Array ? 1 : Obj is Map || Obj is RegExMatchInfo ? 2 : 0
          , EnumTypeMap: ''
          , ExcludeMethods: true
          , ExcludeProps: ''
          , Filter: ''
          , FilterMap: ''
          , MaxDepth: 0
          , PropsCondition: ''
          , PropsTypeMap: ''
          , StopAtMap: ''

            ; Callbacks
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
        ;   , PrintTypeTag: false
          , QuoteNumericKeys: false
          , RootName: '$'
          , UnsetArrayItem: '""'

            ; General options
          , InitialPtrListCapacity: 64
          , InitialStrCapacity: 65537
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
