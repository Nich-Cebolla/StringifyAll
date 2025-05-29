#include ..\src\StringifyAll.ahk

; This test validates the example strings within "example.ahk".

class StringifyAllConfig {
}
class Container {
    __New(Items*) {
        if Items.Length {
            this.__Item := Map(Items*)
        }
    }
    Set(Params*) {
        if Params.Length {

            this.__Item.Set(Params*)
        }
    }
    Delete(Name) {
        this.__Item.Delete(Name)
    }
    __Enum(VarCount) => this.__Item.__Enum(VarCount)
}
class DataItem {
    __New(Index) {
        this.Index := Index
    }
}

result := test()
M := Map('Array', 0, 'Map', 0)
M.Default := 1
if result {
    outputdebug(stringifyall(result, { PropsTypeMap: M }))
}

test() {
    test_content := StrSplit(FileRead('test-content.txt'), '####', '`s`r`t`n')
    problems := []
    i := 0

    ; -------- 1

    containerObj := Container('key1', 'val1', 'key2', 'val2')
    StringifyAllConfig.EnumTypeMap := Map('Array', 1, 'Map', 2, 'Container', 2)
    if (result := StringifyAll(containerObj)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 2

    StringifyAllConfig.EnumTypeMap.Set('Map', 0)
    if (result := StringifyAll(containerObj)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 3

    enumTypeMap := StringifyAllConfig.EnumTypeMap
    StringifyAllConfig.DeleteProp('EnumTypeMap')
    if (result := StringifyAll(containerObj)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 4

    StringifyAllConfig.PropsTypeMap := Map('Array', 0, 'Map', 0, 'Container', 1)
    if (result := StringifyAll(containerObj)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 5

    StringifyAllConfig.PropsTypeMap.Set('Container', 0)
    if (result := StringifyAll(containerObj)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 6

    StringifyAllConfig.EnumTypeMap := enumTypeMap
    if (result := StringifyAll(containerObj)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 7

    Content := FileRead('..\example\example.ahk')
    RegExMatch(Content, '((?<=\n); --- C.)([^-]+)-([^-]+)', &Match1)
    StringifyAllConfig.PropsTypeMap.Set('RegExMatchInfo', 1)
    if (result := StringifyAll(Match1)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 8

    StringifyAllConfig.EnumTypeMap.Set('RegExMatchInfo', 2)
    if (result := StringifyAll(Match1)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 9

    RegExMatch(Content, 'There we go!.+', &Match2, InStr(Content, 'There we go!', , , 2) - 1)
    EnumCondition(Obj) {
        return Obj.Count ? 2 : 0
    }
    StringifyAllConfig.EnumTypeMap.Set('RegExMatchInfo', EnumCondition)
    arr := [Match1, Match2]
    if (result := StringifyAll(arr)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 10

    RegExMatch(Content, 'that have a value for ``Mark``.(*MARK:PropsCondition)', &Match3)
    arr.Push(Match3)
    PropsCondition(Obj) {
        return Obj.Mark
    }
    StringifyAllConfig.PropsTypeMap := Map('RegExMatchInfo', PropsCondition)
    if (result := StringifyAll(arr)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 11

    Filter := PropsInfo.FilterGroup('Mark,Count')
    StringifyAllConfig.FilterTypeMap := Map('RegExMatchInfo', Filter)
    StringifyAllConfig.DeleteProp('PropsTypeMap')
    if (result := StringifyAll(arr)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 12

    Filter.RemoveFromExclude('Mark')
    FilterFunc1(Item) {
        ; This expression is directing `PropsInfo.Prototype.FilterActivate` to exclude properties
        ; named "Mark" that have a value of 0 or an empty string.
        ; `Item.GetValue` sets the `VarRef` variable with the value of the property. In the case of
        ; `RegExMatchInfoObj.Mark`, it will always have a value because that is how it is designed.
        ; But the default value is an empty string, which is what we want to exclude. So to direct
        ; `StringifyAll` to skip the `Mark` property for `RegExMatchInfo` objects that do not have
        ; a significant `Mark` value, we can use this code.
        if Item.Name == 'Mark' {
            Item.GetValue(&Value)
            return !Value
        }
    }
    Filter.Add(FilterFunc1)
    if (result := StringifyAll(arr)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 13

    StringifyAllConfig.PropsTypeMap := Map('Array', 1, 'Map', 1)
    StringifyAllConfig.FilterTypeMap := Map('Array', PropsInfo.FilterGroup('Capacity,__Class'))
    StringifyAllConfig.FilterTypeMap.Default := PropsInfo.FilterGroup('__Class')
    arr := [
        [1, 2, 3, 4, 5]
      , Map('key1', 'val1', 'key2', 'val2')
    ]
    if (result := StringifyAll(arr)) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 14

    props := []
    for prop in StringifyAllConfig.OwnProps() {
        if prop !== 'Prototype' {
            props.Push(prop)
        }
    }
    for prop in props {
        StringifyAllConfig.DeleteProp(prop)
    }
    arr := []
    k := 0
    loop 10 {
        if ++k > 5 {
            k := 1
        }
        switch k {
            case 1: arr.Push(DataItem(A_Index))
            case 2:
                arr.Push(Map('Index', A_Index))
                if Mod(A_Index, 2) {
                    arr[-1].Capacity := 1001
                }
            case 3:
                arr.Push([A_Index])
                if Mod(A_Index, 2) {
                    arr[-1].Capacity := 1001
                }
            default:
                arr.Push({Index: A_Index})
        }
    }
    CallbackGeneral(Obj, *) {
        if ((not Obj is Map && not Obj is Array) || Obj.Capacity <= 1000) && not Obj is DataItem {
            return 1
        }
    }
    arr.SkipProps := 1
    PropsCondition2(Obj) {
        if !Obj.HasOwnProp('SkipProps') || !Obj.SkipProps {
            return 1
        }
    }
    propsTypeMap := Map('Array', PropsCondition2)
    propsTypeMap.Default := 1
    if (result := RegExReplace(StringifyAll(arr, { CallbackGeneral: CallbackGeneral, PropsTypeMap: propsTypeMap }), '\d+', 'numbers')) !== RegExReplace(test_content[++i], '\d+', 'numbers') {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 15

    CallbackGeneral2(Obj, *) {
        if Obj is Map {
            if Obj.Capacity <= 1000 {
                StringifyAll.StrEscapeJson(&(Name := Obj['Index']))
            }
        } else if Obj is Array {
            if Obj.Capacity <= 1000 {
                StringifyAll.StrEscapeJson(&(Name := Obj[1]))
            }
        } else if not Obj is DataItem {
            StringifyAll.StrEscapeJson(&(Name := Obj.Index))
        }
        if IsSet(Name) {
            return '"Index: ' Name '"'
        }
    }
    if (result := StringifyAll(arr, { CallbackGeneral: CallbackGeneral2, PropsTypeMap: propsTypeMap })) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    ; -------- 16

    CallbackGeneral3(Obj, *) {
        if ((not Obj is Map && not Obj is Array) || Obj.Capacity <= 1000) && not Obj is DataItem {
            return -1
        }
    }
    if (result := StringifyAll(arr, { CallbackGeneral: CallbackGeneral3, PropsTypeMap: propsTypeMap })) !== test_content[++i] {
        problems.Push({ index: i, result__: result, expected: test_content[i] })
    }

    return problems.Length ? problems : ''
}
