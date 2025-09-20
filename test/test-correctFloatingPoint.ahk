
#include ..\src\StringifyAll.ahk

test_correctFloatingPoint() {
    problems := []
    list := [
        [ 0.1 + 0, '0.1' ]
      , [ (0.1 + 0) * -1, '-0.1' ]
      , [ 0.1 + 0.2, '0.3' ]
      , [ (0.1 + 0.2) * -1, '-0.3' ]
      , [ 0.3 + 0, '0.3' ]
      , [ (0.3 + 0) * -1, '-0.3' ]
      , [ 0.03, '0.03' ]
      , [ -0.03, '-0.03' ]
      , [ 0.06, '0.06' ]
      , [ -0.06, '-0.06' ]
      , [ 10.00004, '10' ]
      , [ -10.00004, '-10' ]
      , [ 9999.99499999, '9999.995' ]
      , [ -9999.99499999, '-9999.995' ]
      , [ 9999.9990009, '9999.9990009' ]
      , [ -9999.9990009, '-9999.9990009' ]
      , [ 101.10000009901, '101.10000009901' ]
      , [ -101.10000009901, '-101.10000009901' ]
      , [ 9999.999999099, '9999.999999099' ]
      , [ -9999.999999099, '-9999.999999099' ]
    ]
    pattern := 'S)"fp{}": ([-.\d]+)'

    ; Correction enabled
    StringifyAllConfig.CorrectFloatingPoint := true
    _Proc(list, _ConditionEnabled)

    ; Correction disabled
    StringifyAllConfig.CorrectFloatingPoint := false
    _Proc(list, _ConditionDisabled)

    ; Using custom pattern
    ; Requires four consecutive zeroes or nines
    StringifyAllConfig.CorrectFloatingPoint := 'S)(?<round>(?:0{4,}|9{4,})\d)$'
    ; The original list should have the same result
    _Proc(list, _ConditionEnabled)
    ; A few items that should not get corrected
    list2 := [
        [ 1.00010001, '1.00010001' ]
      , [ -1.00010001, '-1.00010001' ]
      , [ 0.0055999, '0.0055999' ]
      , [ -0.0055999, '-0.0055999' ]
      , [ 0.0030001, '0.0030001' ]
      , [ -0.0030001, '-0.0030001' ]
    ]
    _Proc(list2, _ConditionEnabled)

    return problems.Length ? problems : ''

    _Proc(list, condition) {
        obj := {}
        for tuple in list {
            obj.DefineProp('fp' A_Index, { Value: tuple[1] } )
        }
        StringifyAll(obj, , &result)
        ; The items in `list` should produce the same results
        for tuple in list {
            _pattern := Format(pattern, A_Index)
            if RegExMatch(result, _pattern, &match) {
                if expected := condition(match, tuple) {
                    problems.Push({
                        line: A_LineNumber
                      , index: A_Index
                      , expected: expected
                      , actual__: match[1]
                      , str: result
                    })
                }
            } else {
                problems.Push({
                    line: A_LineNumber
                  , index: A_Index
                  , expected: tuple[2]
                  , actual__: 'failed to match with pattern: ' _pattern
                  , str: result
                })
            }
        }
    }
    _ConditionDisabled(match, tuple) {
        if match[1] !== String(tuple[1]) {
            return String(tuple[1])
        }
    }
    _ConditionEnabled(match, tuple) {
        if tuple[2] !== match[1] {
            return tuple[2]
        }
    }
}
