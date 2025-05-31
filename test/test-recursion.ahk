
#include ..\src\StringifyAll.ahk

test_recursion() {
    obj := {
        o1: {
            o2: {
                o3: { prop: 'val' }
              , m3: Map('key', 'val')
              , a3: [ 'val' ]
            }
        }
      , o1b: {
            o2b: { prop: 'val' }
        }
    }
    problems := []

    obj.o1.o2.o3.problem := obj.o1
    obj.o1.o2.m3.problem := obj.o1
    obj.o1.o2.a3.problem := obj.o1

    obj.o1.o2.o3.okay := obj.o1b
    obj.o1.o2.m3.okay := obj.o1b
    obj.o1.o2.a3.okay := obj.o1b

    i := 1

    options := { Multiple: true }

    StrReplace(result := stringifyall(obj, options), '"okay": {', , , &count)
    if count !== 3 {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: 3
          , actual__: count
          , str: result
        })
    }

    ++i
    options := { Multiple: false }
    StrReplace(result := stringifyall(obj, options), '"okay": "', , , &count)
    if count !== 2 {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: 2
          , actual__: count
          , str: result
        })
    }

    return problems.Length ? problems : ''
}
