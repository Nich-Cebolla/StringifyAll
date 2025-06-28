#include ..\src\StringifyAll.ahk

test()
test() {
    copy := str := '\\"\\`r\\`t\\`n\\'
    outputdebug(StrReplace(StrReplace(str, '`r', '``r'), '`n', '``n') '`n')
    stringifyall.strescapejson(&str)
    outputdebug(str '`n')
    stringifyall.strunescapejson(&str)
    outputdebug(StrReplace(StrReplace(str, '`r', '``r'), '`n', '``n') '`n')
    if str !== copy {
        throw Error('failed.', -1, str)
    }
}
