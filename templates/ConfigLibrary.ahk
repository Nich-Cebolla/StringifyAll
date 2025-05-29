
#include <Inheritance>

/**
 * @description - This is a way to keep your configurations in a single location, which might be
 * convenient to use instead of creating a new file, particularly during testing and development,
 * but also for personal scripts and short projects. For code that will be compiled or distributed,
 * it is probably best to create dedicated objects within the project itself.
 *
 * To use the `ConfigLibrary`:
 * - Copy the template into your AHK library, usually %A_MyDocuments%\AutoHotkey\lib, with the name
 * "ConfigLibrary.ahk".
 * {@link https://www.autohotkey.com/docs/v2/lib/_Include.htm}
 * - Add your configurations. You can do this within the function {@link ConfigLibrary.__New}.
 *`ConfigLibrary.__Item` is a `Map` object, so just add another `this.__Item.Set("key", { config })`
 * expression for each configuration.
 *
 * If `StringifyAll` detects `ConfigLibrary` exists, it will make use of it. In place of the `Options`
 * parameter, you can just write the name of the config item needed.
 *
 * `ConfigLibrary.__New` gets called automatically the first time `ConfigLibrary` is referenced, so
 * you don't need to call it specifically in your code.
 *
 * Make use of the `SA_MapHelper` class, which allows you to set the `CaseSense` and `Default` properties
 * with the items all in one expression.
 */
class ConfigLibrary {
    static Call(Key) => this.__Item.Get(Key)

    static __New() {
        this.DeleteProp('__New')
        this.__Item := Map()
        this.__Item.CaseSense := false
        this.__Item.Set(
            'array,map-own only'
          , {
                FilterTypeMap: SA_MapHelper(
                    false
                  , 1
                  ; There is a description of these two filters at the bottom of the file.
                  , 'Array', PropsInfo.FilterGroup((Item) => Item.Index)
                  , 'Map', PropsInfo.FilterGroup((Item) => Item.Index)
                )
            }
        )
        this.__Item.Set(
            'array,map-no props'
          ; This configuration directs `StringifyAll` to not process any properties for arrays and maps.
          , { PropsTypeMap: SA_MapHelper(false, 1, 'Array', 0, 'Map', 0) }
        )
    }

    static Clear() => this.__Item.Clear()
    static Clone() => this.__Item.Clone()
    static Delete(Key) => this.__Item.Delete(Key)
    static Get(Key) => this.__Item.Get(Key)
    static Has(key) => this.__Item.Has(Key)
    static Set(Key, Value) => this.__Item.Set(Key, Value)
    static __Enum(VarCount) => this.__Item.__Enum(VarCount)

    static Capacity {
        Get => this.__Item.Capacity
        Set => this.__Item.Capacity := Value
    }
    static CaseSense => this.__Item.CaseSense
    static Count => this.__Item.Count
    static Default {
        Get => this.__Item.Default
        Set => this.__Item.Default := Value
    }
}

/**
 * @description - `SA_MapHelper` exists to allow us to create the `Map` object with all significant
 * properties in a single expression, instead of requiring two or three expressions.
 */
class SA_MapHelper extends Map {
    __New(CaseSense := false, Default?, Values*) {
        this.CaseSense := CaseSense
        if IsSet(Default) {
            this.Default := Default
        }
        if Values.Length {
            this.Set(Values*)
        }
    }
}


/*

This is a description of the two filters included with the "array,map-own only" configuration.
The filters direct `StringifyAll` to only process properties if they are own
properties. For the typical `Array` and `Map` object, its properties are defined
on the prototype, not on the object itself. So if we direct `StringifyAll` to
only include own properties, for most objects the string representation will look
like what we expect, with a square brace being the initial brace.

Array
[
  "item",
  "item"
]

Map
[
  [
    "key",
    "item"
  ],
  [
    "key",
    "item"
  ]
]

But if your code adds properties to the object, then those properties will still
be included, which is probably desirable but changes how the object will
look in the string. It will have the appearance of an object with a property
that is an array/map.

{
  "prop": "value",
  __Items__: [
    "item",
    "item"
  ]
}

*/
