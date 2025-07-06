#include ..\src\StringifyAll.ahk

; The purpose of this file is to walk you through some of the more complex options available to
; `StringifyAll`. I recmomend working through the "inheritance\example-Inheritance.ahk" file first
; to gain an understanding of how `PropsInfo` objects work, which is needed to know how the filters
; work in `StringifyAll`.

; `StringifyAll`'s options are categorized into "Enum options", "Callbacks", "Newline and indent
; options", "Print options", and "General options". This walkthrough covers "Enum options" and "Callbacks".

; `StringifyAll` exposes a way to define your personal defaults using a class object, so you don't
; have to modify the original script. This allows us to use a tiered options system, layering
; preferences on top of others to minimize repeated code and accelerate development. Define a
; `StringifyAllConfig` class object somewhere in your project to set your defaults, and if you need
; to change an option, pass an options object to `StringifyAll` directly.

; In this walkthrough we will start with a blank class object and add options to it as needed.

class StringifyAllConfig {
}

; === I. Enum options ==============================================================================

; Enum options are the options that tell `StringifyAll` what will be represented in the JSON string.
; From the point of view of the person who wrote this library, it only takes a minute or two to
; define the needed options to get the intended result. But for someone to whom this library is
; completely foreign, this can take a while to get used to. If all you need is a basic stringify
; function, you might consider my other `Stringify` functions, or Thqby's `JSON` was my go-to before
; writing my own.
; https://github.com/Nich-Cebolla/Stringify-ahk
; https://github.com/thqby/ahk2_lib/blob/master/JSON.ahk

; --- A. Enum options - `EnumTypeMap` -------------------==-----------------------------------------

; `EnumTypeMap` directs `StringifyAll` whether or not it should call an object's enumerator, and if
; it does, to call it in 1-param mode or 2-param mode.

; See https://www.autohotkey.com/docs/v2/lib/For.htm

; What if we have a custom object that does not inherit from Map or Array, but serves a similar
; purpose?

; Consider the below class.

class Container {
    __New(Items*) {
        if Items.Length {
            this.__Item := Map(Items*)
        }
    }
    Set(Params*) {
        if Params.Length {
            ; do something
            this.__Item.Set(Params*)
        }
    }
    Delete(Name) {
        this.__Item.Delete(Name)
    }
    __Enum(VarCount) => this.__Item.__Enum(VarCount)
}

; Make an instance of the class.
containerObj := Container('key1', 'val1', 'key2', 'val2')

; Even though this does not inherit from `Map`, the value of the `__Item` property is a `Map`. If
; we direct `StringifyAll` to call `containerObj.__Enum`, it will be a copy of the items in
; `containerObj.__Item`. Let's see what this looks like.

; The "2" tells `StringifyAll` to call the enumerator in 2-param mode.
StringifyAllConfig.EnumTypeMap := Map('Array', 1, 'Map', 2, 'Container', 2)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(containerObj))
/*
{
    "__Class": "Container",
    "__Item": {
        "__Class": "Map",
        "Capacity": 2,
        "CaseSense": "On",
        "Count": 2,
        "__Items__": [
            [
                "key1",
                "val1"
            ],
            [
                "key2",
                "val2"
            ]
        ]
    },
    "__Items__": [
        [
            "key1",
            "val1"
        ],
        [
            "key2",
            "val2"
        ]
    ]
}
*/

; As we see, the output has the same items printed twice.
; We can address the duplication in a number of ways.

; We can skip enumerating `containerObj.__Item` since its already called by `containerObj`'s enumerator.
StringifyAllConfig.EnumTypeMap.Set('Map', 0)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(containerObj))
/*
{
    "__Class": "Container",
    "__Item": {
        "__Class": "Map",
        "Capacity": 2,
        "CaseSense": "On",
        "Count": 2
    },
    "__Items__": [
        [
            "key1",
            "val1"
        ],
        [
            "key2",
            "val2"
        ]
    ]
}
*/

; That's a little better, but still not quite representative of what the actual object is like.
; The items are now represented as items of the root object, which can be desirable in some
; situations, but in this case I think it's more accurate to depict the items as items of
; `containerObj.__Item`. Let's see what the default output looks like.

; Let's save the map for later.
enumTypeMap := StringifyAllConfig.EnumTypeMap

; Now delete it.
StringifyAllConfig.DeleteProp('EnumTypeMap')

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(containerObj))
/*
{
    "__Class": "Container",
    "__Item": {
        "__Class": "Map",
        "Capacity": 2,
        "CaseSense": "On",
        "Count": 2,
        "__Items__": [
            [
                "key1",
                "val1"
            ],
            [
                "key2",
                "val2"
            ]
        ]
    }
}
*/

; I think that looks more accurate, but all the properties seem unnecessary. I don't really care about
; all the built-in properties, I just need the string to represent the items themselves, not the
; details about the `Map` object. To accomplish this, we must use a different option.

; --- B. Enum options - `PropsTypeMap` -------------------------------------------------------------

; `PropsTypeMap` is similar to `EnumTypeMap`, but for properties. And its a binary specification: to
; include or not to include.

; For general usage, we typically don't want array or map built-in properties represented in the
; JSON string. It's simple to direct `StringifyAll` to ignore them. Here's how to do it with
; `PropsTypeMap`:
StringifyAllConfig.PropsTypeMap := Map('Array', 0, 'Map', 0, 'Container', 1)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(containerObj))
/*
{
    "__Class": "Container",
    "__Item": [
        [
            "key1",
            "val1"
        ],
        [
            "key2",
            "val2"
        ]
    ]
}
*/

; There we go! Now that is what I would expect a JSON representation of `containerObj` would look
; like. But to be honest, I don't really care about that `containerObj.__Class` property either.
; Can we make this look any cleaner? Let's try skipping the properties of `Container` objects.

; Set the option.
StringifyAllConfig.PropsTypeMap.Set('Container', 0)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(containerObj))
/*
{}
*/

; This is the result because we have now directed `StringifyAll` to skip the properties AND to skip
; calling its enumerator, resulting in an empty object. `StringifyAll` doesn't process
; `containerObj.__Item` since we told `StringifyAll` to skip the properties. To get the result
; that we are expecting, we have to loop back around to `EnumTypeMap` to direct `StringifyAll`
; to call `containerObj.__Enum`.

; Set the option.
StringifyAllConfig.EnumTypeMap := enumTypeMap

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(containerObj))
/*
[
    [
        "key1",
        "val1"
    ],
    [
        "key2",
        "val2"
    ]
]
*/

; There we go! That's what we were expecting.

; === === === To summarize:

; - `StringifyAll` is designed to be maximally flexible and customizable, which introduces some
; complexity when trying to get the input parameters just right.
; - Set `EnumTypeMap` to direct `StringifyAll` to call, or not to call, the enumerator for objects
; of a specified type.
; - Set `PropsTypeMap` to direct `StringifyAll` to iterate or to skip an object's properties.
; - Both `EnumTypeMap` and `PropsTypeMap` can be set with a default value that will be applied to
; all objects that do not have an associated item within the container.

; --- C. Enum options - Using functions ------------------------------------------------------------

; `EnumTypeMap` and `PropsTypeMap` can use functions as well as integers for the items.

; Let's use a `RegExMatchInfo` object as an example. Say I'm doing some string parsing and need to
; later visually inspect the results for errors.

; Get the match object.
Content := FileRead(A_ScriptFullpath)
RegExMatch(Content, '((?<=\n); --- C.)([^-]+)-([^-]+)', &Match1)

; Let's see what the object looks like without the enumerator.
StringifyAllConfig.PropsTypeMap.Set('RegExMatchInfo', 1)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(Match1))
/*
{
    "__Class": "RegExMatchInfo",
    "__Item": "; --- C. Enum options - Using functions ",
    "Count": 3,
    "Mark": ""
}
*/

; Okay, so we see the match there, that's good. But I'd really like to see the subcapture groups
; as well. Earlier we set `enumTypeMap` with an object that specifies values for `Array` and `Map`.
; We can add `RegExMatchInfo` onto it.
StringifyAllConfig.EnumTypeMap.Set('RegExMatchInfo', 2)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(Match1))
/*
{
    "__Class": "RegExMatchInfo",
    "__Item": "; --- C. Enum options - Using functions ",
    "Count": 3,
    "Mark": "",
    "__Items__": [
        [
            0,
            "; --- C. Enum options - Using functions "
        ],
        [
            1,
            "; --- C."
        ],
        [
            2,
            " Enum options "
        ],
        [
            3,
            " Using functions "
        ]
    ]
}
*/

; There we go! That's the information I needed to inspect. Note how the items are set to a property
; that does not actually exist, `__Items__`. This is a faux-property added to the string since the
; subcapture groups don't actually exist as properties on the `RegExMatchInfo` object in a way
; that is accessible to a function that knows nothing else about the object.

; Going along with this example, let's direct `StringifyAll` to call the enumerator only in cases
; where the `RegExMatchInfo` object has one or more subcapture groups, and to skip the enumerator
; otherwise.

; Get a match object with no subcapture groups.
RegExMatch(Content, 'There we go!.+', &Match2, InStr(Content, 'There we go!', , , 2) - 1)

; Define the function.
EnumCondition(Obj) {
    return Obj.Count ? 2 : 0
}

; Set the option.
StringifyAllConfig.EnumTypeMap.Set('RegExMatchInfo', EnumCondition)

; Add the matches to an array.
arr := [Match1, Match2]

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr))
/*
[
    {
        "__Class": "RegExMatchInfo",
        "__Item": "; --- C. Enum options - Using functions ",
        "Count": 3,
        "Mark": "",
        "__Items__": [
            [
                0,
                "; --- C. Enum options - Using functions "
            ],
            [
                1,
                "; --- C."
            ],
            [
                2,
                " Enum options "
            ],
            [
                3,
                " Using functions "
            ]
        ]
    },
    {
        "__Class": "RegExMatchInfo",
        "__Item": "There we go! That's what we were expecting.",
        "Count": 0,
        "Mark": ""
    }
]
*/

; `PropsTypeMap` is similar. Let's say I only want to process the properties of match objects that
; have a value for `Mark`.

; Get a match object with a `Mark` value.
RegExMatch(Content, 'that have a value for ``Mark``.(*MARK:PropsCondition)', &Match3)
arr.Push(Match3)

; Define the function.
PropsCondition(Obj) {
    return Obj.Mark
}

; Set the option.
StringifyAllConfig.PropsTypeMap := Map('RegExMatchInfo', PropsCondition)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr))
/*
[
    [
        [
            0,
            "; --- C. Enum options - Using functions "
        ],
        [
            1,
            "; --- C."
        ],
        [
            2,
            " Enum options "
        ],
        [
            3,
            " Using functions "
        ]
    ],
    {},
    {
        "__Class": "RegExMatchInfo",
        "__Item": "that have a value for `Mark`.",
        "Count": 0,
        "Mark": "PropsCondition"
    }
]
*/

; That's not quite what I was imagining. It's missing that entire second object, and now I don't
; really know what the first object is just by looking at it. Maybe I actually do want at least the
; `__Class` property included there, and the `__Item` property too.

; === === === To summarize:

; - `EnumTypeMap` and `PropsTypeMap` can be defined with either an integer or a function. The value
; is used only for the specified types.

; --- D. Enum options - `FilterTypeMap` -------------------------------------------------------------------

; I wrote `StringifyAll` to make use of the "Inheritance" library. Since `Object.Prototype.OwnProps`
; only iterates an object's own properties, it was often challenging to serialize information I needed
; for later use.

; However, since `StringifyAll` makes use of "Inheritance", it now often includes information I do
; not want included.

; Before proceeding, you might consider working through "inheritance\example-Inheritance.ahk" to
; understand the `PropsInfo` class. It's probably not necessary, but may help.

; I wrote "example-Inheritance.ahk" before I added the `PropsInfo.FilterGroup` class, so information
; about `PropsInfo.FilterGroup` is absent in the example.

; `PropsInfo.FilterGroup` allows us to create a custom filter independently from any `PropsInfo`
; object to be reused across any number of `PropsInfo` objects.

; We can call the constructor with any number of valid filter values. For example, we can filter
; properties by name, which is the simplest and most direct way to fine-tune our JSON string.
Filter := PropsInfo.FilterGroup('Mark,Count')
StringifyAllConfig.FilterTypeMap := Map('RegExMatchInfo', Filter)

; Delete the previous `PropsTypeMap` since that actually didn't help.
StringifyAllConfig.DeleteProp('PropsTypeMap')

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr))
/*
{
    "__Class": "Array",
    "Capacity": 4,
    "Length": 3,
    "__Items__": [
        {
            "__Class": "RegExMatchInfo",
            "__Item": "; --- C. Enum options - Using functions ",
            "__Items__": [
                [
                    0,
                    "; --- C. Enum options - Using functions "
                ],
                [
                    1,
                    "; --- C."
                ],
                [
                    2,
                    " Enum options "
                ],
                [
                    3,
                    " Using functions "
                ]
            ]
        },
        {
            "__Class": "RegExMatchInfo",
            "__Item": "There we go! That's what we were expecting."
        },
        {
            "__Class": "RegExMatchInfo",
            "__Item": "that have a value for `Mark`."
        }
    ]
}
*/

; Looks great! Clean, has the needed information, but we did lose the `Mark` value from the third
; item. I actually would like to have that information available, but if there is no `Mark` I would
; prefer that the property is skipped.

; We can do this with a bit more code. Let's delete `Mark` from the filter.
Filter.RemoveFromExclude('Mark')

; Define our function.
FilterFunc1(InfoItem) {
    ; This block is directing `PropsInfo.Prototype.FilterActivate` to exclude properties
    ; named "Mark" that have a value of 0 or an empty string.
    ; `Item.GetValue` sets the `VarRef` variable with the value of the property. In the case of
    ; `RegExMatchInfoObj.Mark`, it will always have a value because that is how it is designed.
    ; But the default value is an empty string, which is what we want to exclude. So to direct
    ; `StringifyAll` to skip the `Mark` property for `RegExMatchInfo` objects that do not have
    ; a significant `Mark` value, we can use this code.
    if InfoItem.Name == 'Mark' {
        InfoItem.GetValue(&Value)
        return !Value
    }
}

; Add the filter.
Filter.Add(FilterFunc1)

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr))
/*
{
    "__Class": "Array",
    "Capacity": 4,
    "Length": 3,
    "__Items__": [
        {
            "__Class": "RegExMatchInfo",
            "__Item": "; --- C. Enum options - Using functions ",
            "__Items__": [
                [
                    0,
                    "; --- C. Enum options - Using functions "
                ],
                [
                    1,
                    "; --- C."
                ],
                [
                    2,
                    " Enum options "
                ],
                [
                    3,
                    " Using functions "
                ]
            ]
        },
        {
            "__Class": "RegExMatchInfo",
            "__Item": "There we go! That's what we were expecting."
        },
        {
            "__Class": "RegExMatchInfo",
            "__Item": "that have a value for `Mark`.",
            "Mark": "PropsCondition"
        }
    ]
}
*/

; Perfect. The string contains only the information I need, nothing more, nothing less.

; For one more quick example, let's use `Array` and `Map`, which both have `Capacity`.

; We need to tell `StringifyAll` to iterate the properties for `Map` and `Array` objects.
StringifyAllConfig.PropsTypeMap := Map('Array', 1, 'Map', 1)

; For some reason I am only interested in `Capacity` on `Map` objects, so I want to skip it for
; `Array` objects only.
StringifyAllConfig.FilterTypeMap := Map('Array', PropsInfo.FilterGroup('Capacity,__Class'))

; Also, I don't want the `__Class` property for any objects. Note how "__Class" is added to
; the above filter. The default is only called for object types not represented in the map's items,
; so to exclude it from all types, "__Class" must be represented among any items as well as the
; default.
StringifyAllConfig.FilterTypeMap.Default := PropsInfo.FilterGroup('__Class')

; Call `Array` and `Map` object enumerators.
StringifyAllConfig.EnumTypeMap := Map('Array', 1, 'Map', 2)

; Create the objects.
arr := [
    [1, 2, 3, 4, 5]
  , Map('key1', 'val1', 'key2', 'val2')
]

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr))
/*
{
    "Length": 2,
    "__Items__": [
        {
            "Length": 5,
            "__Items__": [
                1,
                2,
                3,
                4,
                5
            ]
        },
        {
            "Capacity": 2,
            "CaseSense": "On",
            "Count": 2,
            "__Items__": [
                [
                    "key1",
                    "val1"
                ],
                [
                    "key2",
                    "val2"
                ]
            ]
        }
    ]
}
*/

; As we see, `StringifyAll` has skipped `__Class` for all objects, and skips `Capacity` for `Array`
; objects.

; === === === To summarize:

; - `FilterTypeMap` allows us to define `PropsInfo.FilterGroup` objects that will be applied only
; for objects of the specified type.
; - Set the `Default` property to define a filter for objects of all types not included in the `Map`.

; === II. Callbacks ================================================================================

; The above options are great for fine-tuning what gets included in the JSON string per object type
; or per individual object, but sometimes we may simply want to exclude an object altogether.

; --- A. Callbacks - `CallbackGeneral` -------------------------------------------------------------

; Let's say I'm trying to find a problem in my code causing the application to consume more memory
; than expected. I'm having trouble finding it programmatically, so I'm just going to visually
; review some information to see if I can find some clues. My code uses various objects to store
; various types of information. I only want to review the objects if one of the following is true:
; - The object is `Map` or `Array` and the capacity is > 1000.
; - The object is a `DataItem` object.

; `CallbackGeneral` allows us to define a function that can direct `StringifyAll` to skip the object
; altogether.

; Before we get started, let's just clear out all our previous options.
props := []
for prop in StringifyAllConfig.OwnProps() {
    if prop !== 'Prototype' {
        props.Push(prop)
    }
}
for prop in props {
    StringifyAllConfig.DeleteProp(prop)
}

; Let's set up the scenario code so we have something to work with.

class DataItem {
    __New(Index) {
        this.Index := Index
    }
}
arr := []
i := 0
loop 10 {
    if ++i > 5 {
        i := 1
    }
    switch i {
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

; Define the function to return a nonzero value when the conditions are not met. We don't need the
; second parameter (which is the JSON string in its current state), so we use the "*" operator.
CallbackGeneral(PathObj, Obj, *) {
    if ((not Obj is Map && not Obj is Array) || Obj.Capacity <= 1000) && not Obj is DataItem {
        return 1
    }
}

; Also, I don't want the properties of the `arr` array to be included. I want it to look just like
; a regular array so it doesn't distract from what I'm trying to look at. Let's just do this...
arr.SkipProps := 1
PropsCondition2(Obj) {
    if !Obj.HasOwnProp('SkipProps') || !Obj.SkipProps {
        return 1
    }
}
propsTypeMap := Map('Array', PropsCondition2)
; Set `1` as the default so other objects have their properties stringified.
propsTypeMap.Default := 1

; Up to this point, I've been using `StringifyAllConfig` for the options to highlight its usage,
; but we can use any regular object too, so I'll demonstrate that here.

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr, {
    CallbackGeneral: CallbackGeneral
  , PropsTypeMap: propsTypeMap
}))
/*
[
    {
        "__Class": "DataItem",
        "Index": 1
    },
    "{ Instance:Map:23769936 }",
    {
        "__Class": "Array",
        "Capacity": 1001,
        "Length": 1,
        "__Items__": [
            3
        ]
    },
    "{ Instance:Object:2088880 }",
    "{ Instance:Object:2089072 }",
    {
        "__Class": "DataItem",
        "Index": 6
    },
    {
        "__Class": "Map",
        "Capacity": 1001,
        "CaseSense": "On",
        "Count": 1,
        "__Items__": [
            [
                "Index",
                7
            ]
        ]
    },
    "{ Instance:Array:23768080 }",
    "{ Instance:Object:2088544 }",
    "{ Instance:Object:2087776 }"
]
*/

; As we can see, the object is represented by a placeholder indicating the type of object and its
; address. We can define our `CallbackGeneral` function to return a string value to use that
; as the placeholder instead.
CallbackGeneral2(PathObj, Obj, *) {
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

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr, { CallbackGeneral: CallbackGeneral2, PropsTypeMap: propsTypeMap }))
/*
[
    {
        "__Class": "DataItem",
        "Index": 1
    },
    "Index: 2",
    {
        "__Class": "Array",
        "Capacity": 1001,
        "Length": 1,
        "__Items__": [
            3
        ]
    },
    "Index: 4",
    "Index: 5",
    {
        "__Class": "DataItem",
        "Index": 6
    },
    {
        "__Class": "Map",
        "Capacity": 1001,
        "CaseSense": "On",
        "Count": 1,
        "__Items__": [
            [
                "Index",
                7
            ]
        ]
    },
    "Index: 8",
    "Index: 9",
    "Index: 10"
]
*/

; Or, if we want to skip the objects entirely, we can return `-1`.
CallbackGeneral3(PathObj, Obj, *) {
    if ((not Obj is Map && not Obj is Array) || Obj.Capacity <= 1000) && not Obj is DataItem {
        return -1
    }
}

OutputDebug('`n' A_LineNumber '=========================`n' StringifyAll(arr, { CallbackGeneral: CallbackGeneral3, PropsTypeMap: propsTypeMap }))
/*
[
    {
        "__Class": "DataItem",
        "Index": 1
    },
    {
        "__Class": "Array",
        "Capacity": 1001,
        "Length": 1,
        "__Items__": [
            3
        ]
    },
    {
        "__Class": "DataItem",
        "Index": 6
    },
    {
        "__Class": "Map",
        "Capacity": 1001,
        "CaseSense": "On",
        "Count": 1,
        "__Items__": [
            [
                "Index",
                7
            ]
        ]
    }
]
*/

; === === === To summarize:

; - `CallbackGeneral` will be called for every object value prior to processing.
; - If the function returns a nonzero value, the object is skipped and a placeholder is written instead.
; - The function can return a string value to direct `StringifyAll` to use that as a placeholder.
; - The function can return `-1` to direct `StringifyAll` to skip the object completely.
