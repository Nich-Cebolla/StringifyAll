
# StringifyAll - v1.3.1
A customizable solution for serializing AutoHotkey (AHK) object properties, including inherited properties, and/or items into a 100% valid JSON string.

## AutoHotkey forum post
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=137415&p=604407

## Table of contents

<ol type="I">
  <li><a href="#introduction">Introduction</a></li>
  <li><a href="#parameters">Parameters</a></li>
  <li><a href="#returns">Returns</a></li>
  <li><a href="#options">Options</a></li>
  <ol type="A">
    <li><a href="#enum-options">Enum options</a></li>
    <li><a href="#callbacks">Callbacks</a></li>
    <li><a href="#newline-and-indent-options">Newline and indent options</a></li>
    <li><a href="#print-options">Print options</a></li>
    <li><a href="#general-options">General options</a></li>
  </ol>
  <li><a href="#stringifyallpath">StringifyAll.Path</a></li>
  <li><a href="#stringifyalls-process">StringifyAll's process</a></li>
  <ol type="A">
    <li><a href="#properties">Properties</a></li>
    <li><a href="#callbackgeneral">CallbackGeneral</a></li>
    <li><a href="#calling-the-enumerator">Calling the enumerator</a></li>
  </ol>
  <li><a href="#changelog">Changelog</a></li>
</ol>

## Introduction
`StringifyAll` works in conjunction with [`GetPropsInfo`](https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance) to allow us to include all of an object's properties in the JSON string, not just the items or own properties.

`StringifyAll` exposes many options to programmatically restrict what gets included in the JSON string. It also includes options for adjusting the spacing in the string. To set your options, you can:
- Copy the template file into your project directory and set the options using the template.
- Prepare the `ConfigLibrary` class and reference the configuration by name. See the file "templates\ConfigLibrary.ahk". (Added 1.0.3).
- Define a class `StringifyAllConfig` anywhere in your code.
- Pass an object to the `Options` parameter.

The options defined by the `Options` parameter supercede options defined by the `StringifyAllConfig` class. This is convenient for setting your own defaults based on your personal preferences / project needs using the class object, and then passing an object to the `Options` parameter to adjust your defaults on-the-fly.

Callback functions must not call `StringifyAll`. `StringifyAll` relies on several variables in the function's scope. Concurrent function calls would change their values, causing unexpected behavior for earlier calls.

For usage examples, see "example\example.ahk".

There are some considerations to keep in mind when using `StringifyAll` with the intent to later parse it back into a data object.
- All objects that have one or more of its property values written to the JSON string are represented as an object using curly braces, including array objects and map objects. Since square brackets are the typical indicator that a substring is representing an array object, a parser will interpret the substring as an object with a property that is an array, rather than just an array. (Keep an eye out for my updated JSON parser to pair with `StringifyAll`).
- A parser would need to handle read-only properties in some way.
- Some properties don't necessarily need to be parsed. For example, if I stringified an array object including its native properties, a parser setting the `Length` property would be redundant.

The above considerations are mitigated by keeping separate configurations for separate purposes. For example, keep one configuration to use when intending to later parse the string back into AHK data, and keep another configuration to use when intending to visually inspect the string.

There are some conditions which will cause `StringifyAll` to skip stringifying an object. When this occurs, `StringifyAll` prints a placeholder string instead. The conditions are:
- The object is a `ComObject` or `ComValue`.
- The maximum depth is reached.
- Your callback function returned a value directing `StringifyAll` to skip the object.

When `StringifyAll` encounters an object multiple times, it may skip the object and print a string representation of the object path at which the object was first encountered. Using the object path instead of the standard placeholder is so one's code or one's self can identify the correct object that was at that location when `StringifyAll` was processing. This will occur when one or both of the following are true:
- `Options.Multiple` is false (the default is false).
- Processing the object will result in infinite recursion.

`StringifyAll` will require more setup to be useful compared to other stringify functions, because we usually don't need information about every property. `StringifyAll` is not intended to be a replacement for other stringify functions. Where `StringifyAll` shines is in cases where we need a way to programmatically define specifically what properties we want represented in the JSON string and what we want to exclude; at the cost of requiring greater setup time investment, we receive in exchange the potential to fine-tune precisely what will be present in the JSON string.

## Parameters

<ol type="1">
  <li><b>{*} Obj</b> - The object to stringify.</li>
  <li><b>{Object|String} [Options]</b> -
  <ul>
    <li>If you are using <code>ConfigLibrary</code>, the name of the configuration as string. See the explanation within the file "templates\ConfigLibrary.ahk".
    <li>When not using <code>ConfigLibrary</code>, the options object with zero or more options as property : value pairs.</li>
  </ul>
  <li><b>{VarRef} [OutStr]</b> - A variable that will receive the JSON string. The string is also returned as a return value, but for very long strings, or for loops that process thousands of objects, it will be slightly faster to use the `OutStr` variable since the JSON string would not need to be copied.</li>
  <li><b>{Boolean} [SkipOptions = false]</b> - If true, <code>StringifyAll.Options.Call</code> is not called. The
  purpose of this options is to enable the caller to avoid the overhead cost of processing the
  input options for repeated calls. Note that <code>Options</code> must be set with an object that has been
  returned from <code>StringifyAll.Options.Call</code> or must be set with an object that inherits from
  <code>StringifyAll.Options.Default</code>. See the documentation section <a href="options">Options</a> for more information.</li>
</ol>

## Returns

**{String}** - The JSON string.

## Options

The format for these options are:<br>
<b>{Value type}</b> [ <b>Option name</b>  = <code>Default value</code> ]<br>
<span style="padding-left: 24px;">Description</span>

Jump to:
<a href="#callbackerror"><br>CallbackError</a>
<a href="#options-callbackgeneral"><br>CallbackGeneral</a>
<a href="#callbackplaceholder"><br>CallbackPlaceholder</a>
<a href="#condensecharlimit"><br>CondenseCharLimit</a>
<a href="#condensecharlimitenum1"><br>CondenseCharLimitEnum1</a>
<a href="#condensecharlimitenum2"><br>CondenseCharLimitEnum2</a>
<a href="#condensecharlimitenum2item"><br>CondenseCharLimitEnum2Item</a>
<a href="#condensecharlimitprops"><br>CondenseCharLimitProps</a>
<a href="#condensedepththreshold"><br>CondenseDepthThreshold</a>
<a href="#condensedepththresholdenum1"><br>CondenseDepthThresholdEnum1</a>
<a href="#condensedepththresholdenum2"><br>CondenseDepthThresholdEnum2</a>
<a href="#condensedepththresholdenum2item"><br>CondenseDepthThresholdEnum2Item</a>
<a href="#condensedepththresholdprops"><br>CondenseDepthThresholdProps</a>
<a href="#enumtypemap"><br>EnumTypeMap</a>
<a href="#excludemethods"><br>ExcludeMethods</a>
<a href="#excludeprops"><br>ExcludeProps</a>
<a href="#filtertypemap"><br>FilterTypeMap</a>
<a href="#indent"><br>Indent</a>
<a href="#initialindent"><br>InitialIndent</a>
<a href="#initialptrlistcapacity"><br>InitialPtrListCapacity</a>
<a href="#initialstrcapacity"><br>InitialStrCapacity</a>
<a href="#correctfloatingpoint"><br>CorrectFloatingPoint</a>
<a href="#itemprop"><br>ItemProp</a>
<a href="#maxdepth"><br>MaxDepth</a>
<a href="#multiple"><br>Multple</a>
<a href="#newline"><br>Newline</a>
<a href="#newlinedepthlimit"><br>NewlineDepthLimit</a>
<a href="#printerrors"><br>PrintErrors</a>
<a href="#propstypemap"><br>PropsTypeMap</a>
<a href="#quotenumerickeys"><br>QuoteNumericKeys</a>
<a href="#rootname"><br>RootName</a>
<a href="#singleline"><br>Singleline</a>
<a href="#stopattypemap"><br>StopAtTypeMap</a>
<a href="#unsetarrayitem"><br>UnsetArrayItem</a>

### New in 1.3.1

Previously, `StringifyAll.Options.Call` would change the base of the input `Options` and of `StringifyAllConfig` to facilitate inheriting the defaults. This behavior has been changed. `StringifyAll.Options.Call` now copies the options onto a new object which is then used as the options object for that function call. This opens the opportunity for external code to define its own system of inheriting options while still enabling the usage of the `StringifyAllConfig` class. Old code which uses `StringifyAll` does not need to change anything. New code which uses `StringifyAll` can define options the same as before, but new code now may define options on any of the options object's base objects. For example, this used to not be possible:
```ahk
    MyDefaultOptions := {
        Newline: "`r`n"
      , QuoteNumericKeys: true
    }
    Options := {
        Indent: "`s`s"
    }
    ObjSetBase(Options, MyDefaultOptions)
    StringifyAll(SomeObj, Options)
```
Before 1.3.1, when `StringifyAll` was called neither the "Newline" new "QuoteNumericKeys" options would have been used because the base of `Options` would have been changed. Now, they both get used.

`StringifyAllConfig` is optional; it does not need to exist, same as before.

When `StringifyAll.Options.Call` processes the options, it copies the input (input options object) and config (`StringifyAllConfig` class) options onto a new object. If an option is not defined on either object, then it copies the default value onto the new object. When `StringifyAll.Options.Call` copies the default value, it creates a deep clone of the default value. This is to ensure that the built-in default does not get altered inadvertently. The same is not true for input or config values; the value is always copied directly onto the new object.

Given that this is a more costly process than the original approach, your code can call `StringifyAll.Options.Call` with its options object (or no object) to get a fully processed options object, then pass that to `StringifyAll.Call` while passing `true` to the fourth parameter "SkipOptions". This would be slightly more efficient for repeated calls.

For even greater efficiency, you could even use the old approach in your external code. Simply define the base of your options as `StringifyAll.Options.Default` and pass `true` to the fourth parameter, and that is sufficient.

### Enum options

<ul id="enumtypemap"><b>{*}</b> [ <b>EnumTypeMap</b>  = <code>Map("Array", 1, "Map", 2, "RegExMatchInfo", 2)</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.EnumTypeMap</code> directs <code>StringifyAll</code> to call, or not to call, an object's <code>__Enum</code> method. If it is called, <code>Options.EnumTypeMap</code> also specifies whether it should be called in 1-param mode or 2-param mode. If the object being evaluated does not have an <code>__Enum</code> method, <code>Options.EnumTypeMap</code> is ignored for that object.
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.EnumTypeMap</code> can be defined as a <code>Map</code> object that differentiates between object types, or it can be defined with a value that is applied to objects of any type. If it is a <code>Map</code> object, the keys are object type names and the values are either an <code>Integer</code>, or a function that accepts the object being evaluted as its only parameter and returns an <code>Integer</code>.
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.EnumTypeMap</code> is an <code>Integer</code>:
    <ul style="margin-bottom: 6px;">
      <li><code>1</code>: Directs <code>StringifyAll</code> to call the object's enumerator in 1-param mode.</li>
      <li><code>2</code>: Directs <code>StringifyAll</code> to call the object's enumerator in 2-param mode.</li>
      <li><code>0</code>: Directs <code>StringifyAll</code> to not call the object's enumerator.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.EnumTypeMap</code> is a <code>Func</code> or callable <code>Object</code>:
    <br>
    <i>Parameters</i>
    <ol type="1" style="margin-bottom: 0;">
      <li>The <code>Object</code> being evaluated.</li>
    </ol>
    <i>Return</i>
    <ul style="margin-bottom: 0;">
      <li><code>Integer:</code> One of the above listed integers.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.EnumTypeMap</code> is a <code>Map</code> object:
    <ul style="margin-bottom: 6px;">
      <li>The keys are object types and the values are either <code>Integer</code>, <code>Func</code>, or callable <code>Object</code> as described above.</li>
      <li>Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.</li>
      <li>If you define <code>Options.EnumTypeMap</code> as a <code>Map</code> object, and if <code>Options.EnumTypeMap</code> does not have a property <code>Options.EnumTypeMap.Default</code>, <code>StringifyAll</code> sets <code>Options.EnumTypeMap.Default := 0</code> before processing then deletes it before returning. If an error occurs while processing that causes the thread to exit before the function returns, the <code>Options.EnumTypeMap.Default</code> property will not be deleted.</li>
    </ul>
  </ul>
</ul>

<ul id="excludemethods"><b>{Boolean}</b> [ <b>ExcludeMethods</b>  = <code>true</code> ]
  <ul style="padding-left: 24px; margin-top: 0;">
    If true, properties with a <code>Call</code> accessor and properties with only a <code>Set</code> accessor are excluded from stringification.<br>
    If false or unset, those kinds of properties are included in the JSON string with the name of the function object.
  </ul>
</ul>

<ul id="excludeprops"><b>{String}</b> [ <b>ExcludeProps</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0;">A comma-delimited, case-insensitive list of property names to exclude from stringification.</ul>
</ul>

<ul id="filtertypemap"><b>{*}</b> [ <b>FilterTypeMap</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.FilterTypeMap</code> directs <code>StringifyAll</code> to apply, or not to apply, a filter to the <code>PropsInfo</code> objects used when processing an object's properties.
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.FilterTypeMap</code> can be defined as a <code>Map</code> object that differentiates between object types, or it can be defined with a value that is applied to objects of any type. If it is a <code>Map</code> object, the keys are object type names and the values are either a <a href ="https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance#propsinfofiltergroup">PropsInfo.FilterGroup</a> object, or a function that accepts the object being evaluted as its only parameter and returns a <code>PropsInfo.FilterGroup</code> object.
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.FilterTypeMap</code> is a <code>Func</code> or callable <code>Object</code>:
    <br>
    <i>Parameters</i>
    <ol type="1" style="margin-bottom: 0;">
      <li>The <code>Object</code> being evaluated.</li>
    </ol>
    <i>Return</i>
    <ul style="margin-bottom: 0;">
      <li>A <code>PropsInfo.FilterGroup</code> object to apply a filter, or zero or an empty string to not apply a filter.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.FilterTypeMap</code> is a <code>Map</code> object:
    <ul style="margin-bottom: 6px;">
      <li>The keys are object types and the values are either <code>PropsInfo.FilterGroup</code>, <code>Func</code>, or callable <code>Object</code> as described above.</li>
      <li>Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.</li>
      <li>If you define <code>Options.FilterTypeMap</code> as a <code>Map</code> object, and if <code>Options.FilterTypeMap</code> does not have a property <code>Options.FilterTypeMap.Default</code>, <code>StringifyAll</code> sets <code>Options.FilterTypeMap.Default := 0</code> before processing then deletes it before returning. If an error occurs while processing that causes the thread to exit before the function returns, the <code>Options.FilterTypeMap.Default</code> property will not be deleted.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    For usage examples you can review the "inheritance\example-Inheritance.ahk" walkthrough which demonstrates using filters in the context of the <code>PropsInfo</code> class, which is the same as how they are applied by <code>StringifyAll</code>.
    <br>
    The following is a brief explanation of how to use filters:
    <ul style="padding-left: 48px; margin-top: 0;">
      <li>The term "filter" here refers to a collection of <code>PropsInfo.Filter</code> objects which comprise a <code>PropsInfo.FilterGroup</code> object. Just think of a "filter" as a collection of functions that <code>StringifyAll</code> processes to exclude properties from stringification.</li>
      <li>Filters are functions that return a nonzero value to direct <code>PropsInfo.Prototype.FilterActivate</code> to exclude a property from being exposed by the <code>PropsInfo</code> object. Within the context of <code>StringifyAll</code>, this effectively causes <code>StringifyAll</code> to skip the property completely; the property's value does not get evaluated.</li>
      <li>Although filters are applied on a per-object basis, <code>StringifyAll</code> must categorize objects by their type, and so <code>StringifyAll</code> uses the same filter group for all objects of the indicated type. The significance this has for you is that you can include code that responds to characteristics or conditions about individual objects. An example of this is within the "example\example.ahk" file in section I.D. "Enum options - <code>FilterTypeMap</code>". The function conditionally excludes the <code>Mark</code> property only if the property does not have a significant value.</li>
    </ul>
    <ul style="padding-left: 48px; margin-top: 12px; margin-bottom: 6px;">
      <b>Built-in filters</b>:
      <ul style="padding-left: 48px; margin-top: 12px; margin-bottom: 6px;">
        There are five built-in filters, four of which can be added by simply adding the index to the filter.
        <li><b>Exclude properties by name:</b> To exclude properties by name, simply add a comma-delimited list of property names to the filter.</li>
        <pre>
filter := PropsInfo.FilterGroup('__New,__Init,__Delete,Length,Capacity')
filterTypeMap := Map('Array', filter)
</pre>
        <li><b>1:</b> Exclude all items that are not own properties of the root object.</li>
        <li><b>2:</b> Exclude all items that are own properties of the root object.</li>
        <li><b>3:</b> Exclude all items that have an <code>Alt</code> property, i.e. exclude all properties that have multiple owners.</li>
        <li>
          <b>4:</b> Exclude all items that do not have an <code>Alt</code> property, i.e. exclude all properties that have only one owner.
          <br>
          Example adding a filter by index:
        </li>
        <pre>
; Assume we are continuing with the filter created above.
filter.Add(1)
</pre>
      </ul>
      <b>Custom filters</b>:
      <ul style="padding-left: 48px; margin-top: 12px; margin-bottom: 6px;">
        <li>You can define a filter with any function or callable object. The function must accept the <code>PropsInfoItem</code> object as its only parameter, and should return a nonzero value if the property should be skipped for the object. Understand that the filter gets called once for every property for every object of the indicated type (unless a property gets excluded by a filter before it). The filter function isn't evaluating the object, it's evaluating the <code>PropsInfoItem</code> objects associated with the object's properties.</li>
        <li><code>Options.FilterTypeMap</code> is the only option that allows us to choose what properties are included at an individual-object level.</li>
        <li>Example using a function and applying it to the <code>MapObj.Default</code>:</li>
        <pre>
MyFilterFunc(InfoItem) {
    switch InfoItem.Kind {
        case 'Get', 'Get_Set':
            if InfoItem.GetValue(&Value) {
                return 1            ; Skip properties that fail to return a value
            } else if !IsNumber(Value) {
                return 1            ; Skip properties that have a non-numeric value
            }
        default: return 1           ; Skip all other properties
    }
}
filter := PropsInfo.FilterGroup(MyFilterFunc)
FilterTypeMap := Map()
FilterTypeMap.Default := filter
</pre>
      </ul>
    </ul>
  </ul>
</ul>

<ul id="maxdepth"><b>{Integer}</b> [ <b>MaxDepth</b>  = <code>0</code> ]
  <ul style="padding-left: 24px; margin-top: 0;">The maximum depth <code>StringifyAll</code> will recurse into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up. At any given point, the indentation level can be as large as 3x the depth level. This is due to how <code>StringifyAll</code> handles map and array items.</ul>
</ul>

<ul id="multiple"><b>{Boolean}</b> [ <b>Multiple</b>  = <code>false</code> ]
  <ul style="padding-left: 24px; margin-top: 0;">When true, there is no limit to how many times <code>StringifyAll</code> will process an object. Each time an individual object is encountered, it will be processed unless doing so will result in infinite recursion. When false, <code>StringifyAll</code> processes each individual object a maximum of 1 time, and all other encounters result in <code>StringifyAll</code> printing a placeholder string that is a string representation of the object path at which the object was first encountered.</ul>
</ul>

<ul id="propstypemap"><b>{*}</b> [ <b>PropsTypeMap</b>  = <code>1</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.PropsTypeMap</code> directs <code>StringifyAll</code> iterate an object's properties and include their values in the JSON string.
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.PropsTypeMap</code> can be defined as a <code>Map</code> object that differentiates between object types, or it can be defined with a value that is applied to objects of any type. If it is a <code>Map</code> object, the keys are object type names and the values are either an <code>Integer</code>, or a function that accepts the object being evaluted as its only parameter and returns an <code>Integer</code>.
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.PropsTypeMap</code> is an <code>Integer</code>:
    <ul style="margin-bottom: 6px;">
      <li><code>1</code>: Directs <code>StringifyAll</code> to process the properties.</li>
      <li><code>0</code>: Directs <code>StringifyAll</code> to skip the properties.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.PropsTypeMap</code> is a <code>Func</code> or callable <code>Object</code>:
    <br>
    <i>Parameters</i>
    <ol type="1" style="margin-bottom: 0;">
      <li>The <code>Object</code> being evaluated.</li>
    </ol>
    <i>Return</i>
    <ul style="margin-bottom: 0;">
      <li><code>Integer:</code> One of the above listed integers.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.PropsTypeMap</code> is a <code>Map</code> object:
    <ul style="margin-bottom: 6px;">
      <li>The keys are object types and the values are either <code>Integer</code>, <code>Func</code>, or callable <code>Object</code> as described above.</li>
      <li>Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.</li>
      <li>If you define <code>Options.PropsTypeMap</code> as a <code>Map</code> object, and if <code>Options.PropsTypeMap</code> does not have a property <code>Options.PropsTypeMap.Default</code>, <code>StringifyAll</code> sets <code>Options.PropsTypeMap.Default := 0</code> before processing then deletes it before returning. If an error occurs while processing that causes the thread to exit before the function returns, the <code>Options.PropsTypeMap.Default</code> property will not be deleted.</li>
    </ul>
  </ul>
</ul>

<ul id="stopattypemap"><b>{*}</b> [ <b>StopAtTypeMap</b>  = <code>"-Object"</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.StopAtTypeMap</code> defines the value that is passed to the <a href="https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance#parameters">StopAt parameter of GetPropsInfo</a>.
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 6px;">
    <code>Options.StopAtTypeMap</code> can be defined as a <code>Map</code> object that differentiates between object types, or it can be defined with a value that is applied to objects of any type. If it is a <code>Map</code> object, the keys are object type names and the values are either an <code>Integer</code>, <code>String</code>, or a function that accepts the object being evaluted as its only parameter and returns an <code>Integer</code> or <code>String</code>.
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.StopAtTypeMap</code> is an <code>Integer</code> or <code>String</code>:
    <ul style="margin-bottom: 6px;">
      <li>The value is pass to the <code>StopAt</code> parameter of <code>GetPropsInfo</code></li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.StopAtTypeMap</code> is a <code>Func</code> or callable <code>Object</code>:
    <br>
    <i>Parameters</i>
    <ol type="1" style="margin-bottom: 0;">
      <li>The <code>Object</code> being evaluated.</li>
    </ol>
    <i>Return</i>
    <ul style="margin-bottom: 0;">
      <li>An <code>Integer</code> or <code>String</code>.</li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-top: 12px; margin-bottom: 6px;">
    If <code>Options.StopAtTypeMap</code> is a <code>Map</code> object:
    <ul style="margin-bottom: 6px;">
      <li>The keys are object types and the values are either <code>Integer</code>, <code>String</code>, <code>Func</code>, or callable <code>Object</code> as described above.</li>
      <li>Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.</li>
      <li>If you define <code>Options.StopAtTypeMap</code> as a <code>Map</code> object, and if <code>Options.StopAtTypeMap</code> does not have a property <code>Options.StopAtTypeMap.Default</code>, <code>StringifyAll</code> sets <code>Options.StopAtTypeMap.Default := "-Object"</code> before processing then deletes it before returning. If an error occurs while processing that causes the thread to exit before the function returns, the <code>Options.StopAtTypeMap.Default</code> property will not be deleted.</li>
    </ul>
  </ul>
</ul>

### Callbacks

<ul id="callbackerror"><b>{*}</b> [ <b>CallbackError</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">A <b>Func</b> or callable <b>Object</b> that will be called when <code>StringifyAll</code> encounters an error attempting to access a property's value. When <code>CallbackError</code> is set, <code>StringifyAll</code> ignores <code>PrintErrors</code>.</ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Parameters</i>
    <ol type="1" style="margin-top: 4px; margin-bottom: 6px; padding-left: 36px;">
      <li><b>{StringifyAll.Path}</b> - An object with properties <code>Name</code> and <code>Path</code>. See the section <a href="#stringifyallpath">StringifyAll.Path</a>. Also see the example in section <a href="#callbackplaceholder">CallbackPlaceholder</a>.</li>
      <li><b>{Error}</b> - The error object.</li>
      <li><b>{*}</b> - The object currently being evaluated.</li>
      <li><b>{PropsInfoItem}</b> - The <code>PropsInfoItem</code> object associated with the property that caused the error.</li>
    </ol>
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Return</i>
    <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"></ul>
    <ul style="margin-top: 4px; margin-bottom: 6px; padding-left: 36px;">
      <li><b>String</b>: The string will be printed as the property's value.</li>
      <li><b>-1</b>: <code>StringifyAll</code> skips property completely and it is not represented in the JSON string.</li>
      <li><b>Any other nonzero value</b>: <code>StringifyAll</code> prints just the <code>Message</code> property of the <code>Error</code> object.</li>
      <li><b>Zero or an empty string</b>: <code>StringifyAll</code> treats the <code>Error</code> object as the property's value. If no other conditions prevents it, the <code>Error</code> object will be stringified.</li>
    </ul>
  </ul>
  <ul style="padding-left: 48px; margin-bottom: 0;">If the function returns a string:</ul>
  <ul style="margin-top: 4px; margin-bottom: 6px; padding-left: 88px;">
    <li>Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code>to do this.</li>
    <li>Note that <code>StringifyAll</code> does not enclose the value in quotes when adding it to the JSON string. Your function should add the quote characters, or call <code>StringifyAll.StrEscapeJson</code> which has the option to add the quote characters for you.</li>
  </ul>
</ul>


<ul id="options-callbackgeneral"><b>{*}</b> [ <b>CallbackGeneral</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">A <b>Func</b> or callable <b>Object</b>, or an array of one or more <b>Func</b> or callable <b>Object</b> values, that will be called for each object prior to processing.</ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Parameters</i>
    <ol type="1" style="margin-top: 4px; margin-bottom: 6px; padding-left: 36px;">
      <li><b>{StringifyAll.Path}</b> - An object with properties <code>Name</code> and <code>Path</code>. See the section <a href="#stringifyallpath">StringifyAll.Path</a>. Also see the example in section <a href="#callbackplaceholder">CallbackPlaceholder</a>.</li>
      <li><b>{*}</b> - The object being evaluated.</li>
      <li><b>{VarRef}</b> - A variable that will receive a reference to the JSON string being created.</li>
      <li><b>{String}</b> - An <b>optional</b> parameter that will receive the name of the property for objects that are encountered while iterating the parent object's properties.</li>
      <li><b>{String|Integer}</b> - An <b>optional</b> parameter that will receive either of:</li>
      <ul style="margin-bottom: 0; padding-left: 24px;">
        <li>The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.</li>
        <li>
          The "key" (the value received by the first variable in a for-loop) for objects that are encountered while enumerating an object in 2-parameter mode.
        </li>
      </ul>
    </ol>
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Return</i>
    <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">The function(s) can return a nonzero value to direct <code>StringifyAll</code> to skip processing the object. Any further functions in an array of functions are necessarily also skipped in this case. The function should return a value to one of these effects:</ul>
    <ul style="margin-top: 4px; margin-bottom: 6px; padding-left: 36px;">
      <li><b>String</b>: The string will be used as the placeholder for the object in the JSON string.</li>
      <li><b>-1</b>: <code>StringifyAll</code> skips that object completely and it is not represented in the JSON string.</li>
      <li><b>Any other nonzero value</b>:</li>
      <ul style="margin-bottom: 0; padding-left: 24px;">
        <li>If <code>CallbackPlaceholder</code> is set, <code>CallbackPlaceholder</code> will be called to generate the placeholder.</li>
        <li>If <code>CallbackPlaceholder</code> is unset, the built-in placeholder is used.</li>
      </ul>
      <li><b>Zero or an empty string</b>: <code>StringifyAll</code> proceeds calling the next function if there is one, or proceeds stringifying the object.</li>
    </ul>
  </ul>
  <ul style="padding-left: 48px; margin-bottom: 0;">If the function returns a string:</ul>
  <ul style="margin-top: 4px; margin-bottom: 6px; padding-left: 88px;">
    <li>Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code>to do this.</li>
    <li>Note that <code>StringifyAll</code> does not enclose the value in quotes when adding it to the JSON string. Your function should add the quote characters, or call <code>StringifyAll.StrEscapeJson</code> which has the option to add the quote characters for you.</li>
  </ul>
</ul>

<ul id="callbackplaceholder"><b>{*}</b> [ <b>CallbackPlaceholder</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">When <code>StringifyAll</code> skips processing an object, a placeholder is printed instead. You can define <code>CallbackPlaceholder</code> with any callable object to customize the string that gets printed.</ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Parameters</i>
    <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">It does not matter if the function modifies the two <code>VarRef</code> parameters as <code>StringifyAll</code> will not use them again at that point.</ul>
    <ol type="1" style="margin-top: 4px; margin-bottom: 6px; padding-left: 64px;">
      <li>
        <b>{StringifyAll.Path}</b> - An object with properties <code>Name</code> and <code>Path</code>. See the section <a href="#stringifyallpath">StringifyAll.Path</a>. In the below example, if your function is called for a placeholder for the object at <code>obj.nestedObj.doubleNestedObj</code>, the path will be "$.nestedObj.doubleNestedObj".
        <pre>
Obj := {
    nestedObj: {
        doubleNestedObj: { prop: 'value' }
    }
}</pre>
      </li>
      <li><b>{*}</b> - The object being evaluated.</li>
      <li><b>{VarRef}</b> - An <b>optional</b> <code>VarRef</code> parameter that will receive the name of the property for objects that are encountered while iterating the parent object's properties.</li>
      <li><b>{VarRef}</b> - An <b>optional</b> <code>VarRef</code> parameter that will receive either of:</li>
      <ul style="margin-bottom: 0; padding-left: 24px;">
        <li>The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.</li>
        <li>The "key" (the value received by the first variable in a for-loop) for objects that are encountered while enumerating an object in 2-parameter mode.</li>
      </ul>
    </ol>
  </ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Return</i>
    <ul style="margin-bottom: 0; padding-left: 48px;">
      <li><b>String</b>: The placeholder string.</li>
      <ul style="margin-bottom: 0; padding-left: 24px;">
        <li>Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code>to do this.</li>
        <li>Note that <code>StringifyAll</code> does not enclose the value in quotes when adding it to the JSON string. Your function should add the quote characters, or call <code>StringifyAll.StrEscapeJson</code> which has the option to add the quote characters for you.</li>
      </ul>
    </ul>
  </ul>
</ul>

### Newline and indent options

<ul style="margin-top: 0;">
  Each of <code>CondenseCharLimit</code>, <code>CondenseCharLimitEnum1</code>, <code>CondenseCharLimitEnum2</code>, <code>CondenseCharLimitEnum2Item</code>, and <code>CondenseCharLimitProps</code> set a threshold which <code>StringifyAll</code> will use to condense an object's substring if the length, in characters, of the substring is less than or equal to the value. The substring length is measured beginning from the open brace and excludes external whitespace such as newline characters and indentation that are not part of a string literal value.
  <br>
  If any of the <code>Options.CondenseCharLimit</code> options are in use, the <code>Options.CondenseDepthThreshold</code> options set a depth requirement to apply the option. For example, if <code>Options.CondenseDepthThreshold == 2</code>, all <code>Options.CondenseCharLimit</code> options will only be applied if the current depth is 2 or more; values at the root depth (1) will be processed without applying the <code>Options.CondenseCharLimit</code> option.
</ul>

<ul id="condensecharlimit" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimit</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to all substrings. If <code>Options.CondenseCharLimit</code> is set, you can still specify individual options for the others and the individual option will take precedence over <code>CondenseCharLimit</code>.</ul>
</ul>

<ul id="condensecharlimitenum1" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitEnum1</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by calling an object's enumerator in 1-param mode.</ul>
</ul>

<ul id="condensecharlimitenum2" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitEnum2</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by calling an object's enumerator in 2-param mode.</ul>
</ul>

<ul id="condensecharlimitenum2item" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitEnum2Item</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created for each key-value pair when iterating an object's enumerator in 2-param mode. (Added in 1.1.5)</ul>
</ul>

<ul id="condensecharlimitprops" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitProps</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by processing an object's properties.</ul>
</ul>

<ul id="condensedepththreshold" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseDepthThreshold</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to all substrings. If <code>Options.CondenseDepthThreshold</code> is set, you can still specify individual options for the others and the individual option will take precedence over <code>Options.CondenseDepthThreshold</code>. (Added in 1.2.0)</ul>
</ul>

<ul id="condensedepththresholdenum1" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseDepthThresholdEnum1</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by calling an object's enumerator in 1-param mode. (Added in 1.2.0)</ul>
</ul>

<ul id="condensedepththresholdenum2" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseDepthThresholdEnum2</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by calling an object's enumerator in 2-param mode. (Added in 1.2.0)</ul>
</ul>

<ul id="condensedepththresholdenum2item" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseDepthThresholdEnum2Item</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created for each key-value pair when iterating an object's enumerator in 2-param mode. (Added in 1.2.0)</ul>
</ul>

<ul id="condensedepththresholdprops" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseDepthThresholdProps</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by processing an object's properties. (Added in 1.2.0)</ul>
</ul>

<ul id="indent"><b>{String}</b> [ <b>Indent</b>  = <code>"`s`s`s`s"</code> ]
  <ul style="padding-left:24px;">The literal string that will be used for one level of indentation.</ul>
</ul>

<ul id="initialindent"><b>{String}</b> [ <b>InitialIndent</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">The initial indent level. Note that the first line with the opening brace is not indented. This is to make it easier to use the output from one `StringifyAll` call as a property value in a separate JSON string.</ul>
</ul>

```ahk
obj1 := { prop1: { prop2: 'val2' } }
obj2 := { prop3: { prop4: 'val3' } }
; To exclude the `Object` inherited properties.
filter := PropsInfo.FilterGroup(1)
FilterTypeMap := Map('Object', filter)
json := StringifyAll(obj1, { FilterTypeMap: FilterTypeMap })
json := StrReplace(json, '"val2"', StringifyAll(obj2, { InitialIndent: 2, FilterTypeMap: FilterTypeMap }))
OutputDebug(A_Clipboard := json)
```
```json
{
    "prop1": {
        "prop2": {
            "prop3": {
                "prop4": "val3"
            }
        }
    }
}
```

<ul id="newline"><b>{String}</b> [ <b>Newline</b>  = <code>"`r`n"</code> ]
  <ul style="padding-left:24px;">The literal string that will be used for line breaks. If set to zero or an empty string, the <code>Singleline</code> option is effectively enabled and <code>StringifyAll</code> disables <code>Options.Indent</code> for you. If you have a need to direct <code>StringifyAll</code> to not use newline characters but still use indentation where it typically would, you should set <code>Options.Newline</code> with a zero-width character like 0xFEFF.</ul>
</ul>

<ul id="newlinedepthlimit"><b>{Integer}</b> [ <b>NewlineDepthLimit</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Sets a threshold directing <code>StringifyAll</code> to stop adding line breaks between values after exceeding the threshold.</ul>
</ul>

<ul id="singleline"><b>{Boolean}</b> [ <b>Singleline</b>  = <code>false</code> ]
  <ul style="padding-left:24px;">If true, the JSON string is printed without line breaks or indentation. All other "Newline and indent options" are ignored.</ul>
</ul>

### Print options

<ul id="correctfloatingpoint"><b>{Number|String}</b> [ <b>CorrectFloatingPoint</b>  = <code>false</code> ]
  <ul style="padding-left:24px;">
    If nonzero, <code>StringifyAll</code> will round numbers that appear to be effected by the floating point
    precision issue described in <a href="https://www.autohotkey.com/docs/v2/Concepts.htm#float-imprecision">AHK's documentation</a>.
    This process is facilitated by a regex pattern that attempts to identify these occurrences.
    If <code>Options.CorrectFloatingPoint</code> is a nonzero number, <code>StringifyAll</code> will use the built-in
    default pattern <code>"JS)(?&lt;round>(?:0{3,}|9{3,})\d)$"</code>. You can also set
    <code>Options.CorrectFloatingPoint</code> with your own regex pattern as a string and
    <code>StringifyAll</code> will use that pattern.<br><br>
    Default pattern:<br>
    <code>"JS)(?&lt;round>(?:0{3,}|9{3,})\d)$"</code><br>
    The pattern requires that a string ends in a sequence of three or more zeroes followed by any number, or a
    sequence of three or more nines followed by any number. The string is then passed to <code>Round</code> and
    rounded to the character before the beginning of the match.<br><br>
    Using your own pattern:<br>
    The following is the literal code that facilitates this option. <code>Val</code> is the number being
    evaluated.<br>
    <pre>
if flag_quote_number {
    if RegExMatch(Val, pattern_correctFloatingPoint, &matchNum) {
        Val := '"' Round(Val, StrLen(Val) - InStr(Val, '.') - matchNum.Len['round']) '"'
    } else {
        Val := '"' Val '"'
    }
} else {
    if RegExMatch(Val, pattern_correctFloatingPoint, &matchNum) {
        Val := Round(Val, StrLen(Val) - InStr(Val, '.') - matchNum.Len['round'])
    } else {
        Val := Val
    }
}</pre>
    I added the "round" subcapture group to make it easier to use complex logic; the default pattern
    would not actually require any subcapture group. If using your own pattern, <code>StringifyAll</code> will
    substract the length of the "round" subcapture group from the number of characters that follow the
    decimal point.<br><br>
    If <code>Options.CorrectFloatingPoint</code> is zero or an empty string, no correction occurs.
  </ul>
</ul>

<ul id="itemprop"><b>{String}</b> [ <b>ItemProp</b>  = <code>"__Items__"</code> ]
  <ul style="padding-left:24px;">The name that <code>StringifyAll</code> will use as a faux-property for including an object's items returned by its enumerator.</ul>
</ul>

<ul id="printerrors"><b>{Boolean|String}</b> [ <b>PrintErrors</b>  = <code>false</code> ]
  <ul style="padding-left:24px;">
    Influences how <code>StringifyAll</code> handles errors when accessing a property value. <code>PrintErrors</code> is ignored if <code>CallbackError</code> is set.</ul>
  <ul style="padding-left:48px;">
    <li>If <code>PrintErrors</code> is a string value, it should be a comma-delimited list of <code>Error</code> property names to include in the output as the value of the property that caused the error.</li>
    <li>If any other nonzero value, <code>StringifyAll</code> will print just the "Message" property of the <code>Error</code> object in the string.</li>
    <li>If zero or an empty string, <code>StringifyAll</code> skips the property.</li>
  </ul>
</ul>

<ul id="quotenumerickeys"><b>{Boolean}</b> [ <b>QuoteNumericKeys</b>  = <code>false</code> ]
  <ul style="padding-left:24px;">When true, and when <code>StringifyAll</code> is processing an object's enumerator in 2-param mode, if the value returned to the first parameter (the "key") is numeric, it will be quoted in the JSON string.</ul>
</ul>

<ul id="rootname"><b>{String}</b> [ <b>RootName</b>  = <code>"$"</code> ]
  <ul style="padding-left:24px;">Prior to recursively stringifying a nested object, <code>StringifyAll</code> checks if the object has already been processed. If an object has already been processed, and if <code>Options.Multiple</code> is false or if processing the object will result in infinite recursion, a placeholder is printed in its place. The placeholder printed as a result of this condition is different than placeholders printed for other reasons. In this case, the placeholder is a string representation of the object path at which the object was first encountered. This is so one's self, or one's code, can locate the object in the JSON string if needed. <code>RootName</code> specifies the name of the root object used within any occurrences of this placeholder string.</ul>
</ul>

<ul id="unsetarrayitem"><b>{String}</b> [ <b>UnsetArrayItem</b>  = <code>"`"`""</code> ]
  <ul style="padding-left:24px;">The string to print for unset array items.</ul>
</ul>

### General options

<ul id="initialptrlistcapacity"><b>{Integer}</b> [ <b>InitialPtrListCapacity</b>  = <code>64</code> ]
  <ul style="padding-left:24px;"><code>StringifyAll</code> tracks the ptr addresses of every object it stringifies to prevent infinite recursion. <code>StringifyAll</code> will set the initial capacity of the <code>Map</code> object used for this purpose to <code>InitialPtrListCapacity</code>.</ul>
</ul>

<ul id="initialstrcapacity"><b>{Integer}</b> [ <b>InitialStrCapacity</b>  = <code>65536</code> ]
  <ul style="padding-left:24px;"><code>StringifyAll</code> calls <code>VarSetStrCapacity</code> using <code>InitialStrCapacity</code> for the output string during the initialization stage. For the best performance, you can overestimate the approximate length of the string; <code>StringifyAll</code> calls <code>VarSetStrCapacity(&OutStr, -1)</code> at the end of the function to release any unused memory.</ul>
</ul>

## StringifyAll.Path

Added 1.2.0.

`StringifyAll.Path` is a solution for tracking an object path as a string value. Callback functions will receive an instance of `StringifyAll.Path` to the first parameter.

### Instance methods

<ul>
  <li><b>Call</b>: Returns the object path applying AHK escape sequences with a backtick where appropriate.
  <li><b>Unescaped</b>: Returns the object path without applying escape sequences.
</ul>

### Instance properties

<ul>
  <li><b>Name</b>:
    <ul>
      <li>If the object associated with the <code>StringifyAll.Path</code> object was encountered when enumerating its parent object in 1-param mode, an <code>Integer</code> representing the index of the associated object.</li>
      <li>If the object associated with the <code>StringifyAll.Path</code> object was encountered when enumerating its parent object in 2-param mode, a <code>String</code> representing the "key" (value set to the first parameter in the <code>for</code> loop) of the associated object.</li>
      <li>If the object associated with the <code>StringifyAll.Path</code> object was encountered when iterating its parent object's properties, a <code>String</code> representing the property's name.</li>
    </ul>
  </li>
  <li><b>Path</b>: A <code>String</code> representing the object path of the object associate with the <code>StringifyAll.Path</code> object, including the current object's <code>Name</code> as described above.</li>
</ul>

## StringifyAll's process

This section describes `StringifyAll`'s process. This section is intended to help you better understand how the options will impact the output string. This section is not complete.

### Properties

This section needs updated.

<!-- a copy of the previous text is in .archive -->

### CallbackGeneral

The following is a description of the part of the process which the function(s) are called.
<ul style="padding-left:24px;">
  <code>StringifyAll</code> proceeds in two stages, initialization and recursive processing. After initialization, the function <code>Recurse</code> is called once, which starts the second stage.
  <br>When <code>StringifyAll</code> encounters a value that is an object, it proceeds through a series of condition checks to determine if it will call <code>Recurse</code> again for that value. When a value is skipped, a placeholder is printed instead.<code>StringifyAll</code> checks the following conditions.
  <ul style="padding-left:48px;">
    <li>If the value has already been stringified, processes the object according to <a href="#multiple">Multple</a>.</li>
    <li>If the value is a <code>ComObject</code> or <code>ComValue</code>, the value is skipped.</li>
    <li>If <code>MaxDepth</code> has been reached, the value is skipped.</li>
  </ul>
  If none of the above conditions cause <code>StringifyAll</code> to skip the object, <code>StringifyAll</code> then calls the <code>CallbackGeneral</code> function(s).
  <br>If none of the <code>CallbackGeneral</code> functions direct <code>StringifyAll</code> to skip the object, <code>Recurse</code> is called.
</ul>

### Calling the enumerator

This section needs updated.

<!-- a copy of the previous text is in .archive -->

## Changelog

<h4>2025-09-19 - 1.3.1</h4>

- Added `Options.CorrectFloatingPoint`.
- Adjusted `StringifyAll.Options`. See section <a href="#options">Options</a>.
- Added parameter "SkipOptions". See section <a href="#options">Options</a>.

<h4>2025-07-06 - 1.3.0</h4>

- Added `StringifyAll.GetPlaceholderSubstrings`.
- Fixed: After 1.2.0, if `Options.FilterTypeMap` was set with a `PropsInfo.FilterGroup` object, `StringifyAll` erroneously treated the value as a `Map` object. This has been corrected.
- Fixed: After 1.2.0, map keys had a change to not be escaped properly. This is corrected.
- Adjusted how `StringifyAll` handles the "key" values (the value assigned to the first parameter of a 2-param <code>for</code> loop). The value is no longer escaped prior to calling `Options.CallbackPlaceholder` or `Options.CallbackGeneral`.
- Adjusted `StringifyAll.Path`. It now caches the path value, and the process for constructing the path string has been optimized. Item names that are strings are quoted with single quote characters, and internal single quote characters are always escaped with a backtick.

<h4>2025-07-05 - 1.2.0</h4>

- Added `StringifyAll.Path`.
- Added `Options.CondenseDepthThreshold`, `Options.CondenseDepthThresholdEnum1`, `Options.CondenseDepthThresholdEnum2`, `Options.CondenseDepthThresholdEnum2Item`, and `Options.CondenseDepthThresholdProps`.
- Removed `StringifyAll.__New` as it is no longer needed.
- Removed some documentation in the parameter hint for `StringifyAll.Call`.
- Fixed two errors in "example\example.ahk".
- Fixed `Options.CallbackGeneral` not receiving the `controller` (now `Stringify.Path`) object to the first parameter as described in the documentation.
- Adjusted the parameters passed to the callback functions. The `Controller` object is no longer passed to callback functions. Instead, a `StringifyAll.Path` object is passed to the parameters that used to receive the `Controller` object. In this documentation an instance of `StringifyAll.Path` is referred to as `PathObj`. `StringifyAll.Path` is a solution for tracking object paths using string values. Accessing the `PathObj.Path` property  returns the object path, so this change is backward-compatible (unless external code made use of any of the methods that are available on the `Controller` object, which will no longer be available). See the documentation section "StringifyAll.Path" for further details.
- Adjusted the handling of all of the "TypeMap" options. If any of these options are defined with a value that does not inherit from `Map`, that value is used for all types. If any of these options are defined with an object that inherits from `Map` and that object has a property "Count" with a value of `0`, `StringifyAll` optimizes the handling of the option by creating a reference to the "Default" value and using that for all types.
- Adjusted `Recurse`. `HasMethod(Obj, "__Enum")` is checked prior to calling `CheckEnum`.
- Optimized handling of various options.

<h4>2025-06-28 - 1.1.7</h4>

- Fixed `StringifyAll.StrUnescapeJson`.
- Added "test\test-StrUnescapeJson.ahk".

<h4>2025-06-19 - 1.1.6</h4>

- Implemented `Options.InitialIndent`.

<h4>2025-06-15 - 1.1.5</h4>

- Improved the handling of the "CondenseCharLimit" options.
- Implemented `Options.CondenseCharLimitEnum2Item`.

<h4>2025-06-08 - 1.1.4</h4>

- Removed duplicate line of code.

<h4>2025-05-31 - 1.1.3</h4>

- When `StringifyAll` processes an object, it caches the string object path. Previously, the cached path was overwritten each time an object was processed, resulting in a possibility for `StringifyAll` to cause AHK to crash if it entered into an infinite loop. This has been corrected by adjusted the tracking of object ptr addresses to add the string object path to an array each time an object is processed, and to check all paths when testing if two objects share a parent-child relationship.

<h4>2025-05-31 - 1.1.2</h4>

- Added error for invalid return values from `Options.EnumTypeMap`.

<h4>2025-05-31 - 1.1.1</h4>

- Fixed: If an object's enumerator is called in 1-param mode but returns zero valid items, the empty object no longer has a line break between the open and close bracket.

<h4>2025-05-31 - 1.1.0</h4>

- **Breaking:** Increased the number of values passed to `CallbackGeneral`.
- Implemented `Options.CallbackError`.
- Implemented `Options.Multiple`.
- Created "test\test-errors.ahk" to test the error-related options.
- Created "test\test-recursion.ahk" to test `Options.Multiple`.
- Created "test\test.ahk" to run all tests.
- Adjusted `Options.PrintErrors` to allow specifying what properties to be included in the output string.
- Fixed an error causing a small chance for `StringifyAll` to incorrectly apply a property value to the subsequent property.
- Fixed an error that occurred when using `Options.CallbackGeneral` and `StringifyAll` encounters a duplicate object resulting in an invalid JSON string.

<h4>2025-05-30 - 1.0.5</h4>

- Fixed an error causing `StringifyAll` to incorrectly handle objects returned by a `Map` object's enumerator, resulting in an invalid JSON string.

<h4>2025-05-29 - 1.0.4</h4>

- Corrected the order of operations in `StringifyAll.StrUnescapeJson`.

<h4>2025-05-29 - 1.0.3</h4>

- Implemented `ConfigLibrary`.

<h4>2025-05-28 - 1.0.1</h4>

- Adjusted how `Options.PropsTypeMap` is handled. This change did not modify `StringifyAll`'s behavior, but it is now more clear both in the code and in the documentation what the default value is and what the default value does.
- Added "StringifyAll's process" to the docs.
