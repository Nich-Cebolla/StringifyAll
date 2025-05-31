
#include ..\src\StringifyAll.ahk

class cls {
    prop => this.__prop
    prop2 := 'val'
}

test_errors() {
    obj := cls()
    problems := []
    i := 1
    StringifyAllConfig.Newline := '`n'

    ; ======== 1
    options := { PrintErrors: false }
    str := '
    (
    {
        "__Class": "cls",
        "prop2": "val"
    }
    )'
    if (result := StringifyAll(obj, options)) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }


    ; ======== 2
    ++i
    options := { PrintErrors: true }
    str := '
    (
    {
        "__Class": "cls",
        "prop": "This value of type \"cls\" has no property named \"__prop\".",
        "prop2": "val"
    }
    )'
    if (result := StringifyAll(obj, options)) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }
    ; outputdebug('`n====`n' str '`n======`n' result)


    ; ======== 3
    ++i
    options := { PrintErrors: 'Message,What' }
    str := '
    (
    {
        "__Class": "cls",
        "prop": "Message: This value of type \"cls\" has no property named \"__prop\".; What: ",
        "prop2": "val"
    }
    )'
    if (result := StringifyAll(obj, options)) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }


    ; ======== 4
    ++i
    options := { CallbackError: (controller, err, obj, infoItem) => InStr(err.Message, 'cls') ? (StringifyAll.StrEscapeJson(&(s := 'Message: ' err.Message '; Extra: ' err.Extra), true) || s) : '' }
    str := '
    (
    {
        "__Class": "cls",
        "prop": "Message: This value of type \"cls\" has no property named \"__prop\".; Extra: ",
        "prop2": "val"
    }
    )'
    if (result := StringifyAll(obj, options)) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }


    ; ======== 5
    ++i
    options := { CallbackError: (controller, err, obj, infoItem) => -1 }
    str := '
    (
    {
        "__Class": "cls",
        "prop2": "val"
    }
    )'
    if (result := StringifyAll(obj, options)) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }


    ; ======== 6
    ++i
    options := { CallbackError: (controller, err, obj, infoItem) => 1 }
    str := '
    (
    {
        "__Class": "cls",
        "prop": "This value of type \"cls\" has no property named \"__prop\".",
        "prop2": "val"
    }
    )'
    if (result := StringifyAll(obj, options)) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }


    ; ======== 7
    ++i
    options := { CallbackError: (controller, err, obj, infoItem) => 0 }
    str := '
    (
    {
        "__Class": "cls",
        "prop": {
            "__Class": "PropertyError",
            "Extra": "",
            "Line": 5,
            "Message": "This value of type \"cls\" has no property named \"__prop\".",
            "What": ""
        },
        "prop2": "val"
    }
    )'
    if (result := RegExReplace(StringifyAll(obj, options), '\R.+?(?:Stack|File).+', '')) !== str {
        problems.Push({
            line: A_LineNumber
          , index: i
          , expected: str
          , actual__: result
        })
    }

    return problems.Length ? problems : ''
}
