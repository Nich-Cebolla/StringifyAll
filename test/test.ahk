#include test-errors.ahk
#include test-example.ahk
#include test-recursion.ahk

PrintResult(test_errors(), 'errors')
ClearProps()
PrintResult(test_example(), 'example')
ClearProps()
PrintResult(test_recursion(), 'recursion')




ClearProps() {
    props := []
    for prop in StringifyAllConfig.OwnProps() {
        if prop !== 'Prototype' {
            props.Push(prop)
        }
    }
    for prop in props {
        StringifyAllConfig.DeleteProp(prop)
    }
}
PrintResult(result, test) {
    if !result {
        return
    }
    M := Map('Array', 0, 'Map', 0)
    M.Default := 1
    if result {
        OutputDebug('`n=================`n' test '`n' stringifyall(result, { PropsTypeMap: M }))
    }
}
