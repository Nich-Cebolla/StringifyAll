#include ..\src\StringifyAll.ahk

test_GetPlaceholderSubstrings()

class test_GetPlaceholderSubstrings {
    static Call() {
        o := this.Obj
        Options := {
            Multiple: false
          , FilterTypeMap: PropsInfo.FilterGroup(1)
          , EnumTypeMap: 2
        }
        StringifyAll(o, Options, &json)
        A_Clipboard := json
        OutputDebug(json '`n')
        result := StringifyAll.GetPlaceholderSubstrings(&json)

        sleep 1
    }

    static __New() {
        this.DeleteProp('__New')
        k1 := 'k1"`'\`r`n'
        k2 := 'k2"`'\`r`n'
        o := this.Obj := {
            p1: {
                p1: Map(
                    k1, [
                        {
                            p1: '$.p1.p1["k1"][1].p1'
                        }
                    ]
                  , k2, Map(
                        k1, '$.p1.p1["k2"]["k1"]'
                    )
                )
            }
          , p2: {
                p1: [
                    Map(
                        k1, {
                            p1: '$.p2.p1[1]["k1"].p1'
                        }
                    )
                ]
            }
        }
        o.p1.p1[k1].Push(o.p1)
        o.p1.p1[k2].Set(k2, o.p1.p1[k2])
        o.p2.p1.Push(o.p1)
        o.p2.p1[1].Set(k2, o.p1.p1)
    }
}
