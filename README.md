
# Introduction
A customizable solution for serializing AutoHotkey (AHK) object properties, including inherited properties, and/or items into a 100% valid JSON string.

`StringifyAll` works in conjunction with `GetPropsInfo` (https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance) to allow us to include all of an object's properties in the JSON string, not just the items or own properties.

`StringifyAll` exposes many options to programmatically restrict what gets included in the JSON string. It also includes options for adjusting the spacing in the string. To set your options, you can:
- Copy the template file into your project directory and set the options using the template.
- Prepare the `ConfigLibrary` class and reference the configuration by name. See the file "templates\ConfigLibrary.ahk". (Added 1.0.3).
- Define a class `StringifyAllConfig` anywhere in your code.
- Pass an object to the `Options` parameter.

The options defined by the `Options` parameter supercede options defined by the `StringifyAllConfig` class. This is convenient for setting your own defaults based on your personal preferences / project needs using the class object, and then passing an object to the `Options` parameter to adjust your defaults on-the-fly.

For usage examples, see "example\example.ahk".

There are some considerations to keep in mind when using `StringifyAll` with the intent to later parse it back into a data object.
- All objects that have one or more of its property values written to the JSON string are represented as an object using curly braces, including array objects and map objects. Since square brackets are the typical indicator that a substring is representing an array object, a parser will interpret the substring as an object with a property that is an array, rather than just an array. (Keep an eye out for my updated JSON parser to pair with `StringifyAll`).
- A parser would need to handle read-only properties in some way.
- Some properties don't necessarily need to be parsed. For example, if I stringified an array object including its native properties, a parser setting the `Length` property would be redundant.

The above considerations are mitigated by keeping separate configurations for separate purposes. For example, keep one configuration to use when intending to later parse the string back into AHK data, and keep another configuration to use when intending to visually inspect the string.

There are some conditions which will cause `Stringify` to skip stringifying an object. When this occurs, `Stringify` prints a placeholder string instead. The conditions are:
- The object is a `ComObject` or `ComValue`.
- The maximum depth is reached.
- Your callback function returned a value directing `Stringify` to skip the object.
- The object has been stringified already. The placeholder for this condition is separate from the others; it is a string representation of the object path at which the object was first encountered. This is so one's code or one's self can identify the correct object that was at that location when `Stringify` was processing.

`StringifyAll` will require more setup to be useful compared to other stringify functions, because we usually don't need information about every property. `StringifyAll` is not intended to be a replacement for other stringify functions. Where `StringifyAll` shines is in cases where we need a way to programmatically define specifically what properties we want represented in the JSON string and what we want to exclude; at the cost of requiring greater setup time investment, we receive in exchange the potential to fine-tune precisely what will be present in the JSON string.

# Parameters

<ol type="1">
  <span style="font-size:15px;"><li><b>{*} Obj</b> - The object to stringify.<span style="font-size:13px;"></li>
  <span style="font-size:15px;"><li><b>{Object|String} [Options]</b> - If you are using `ConfigLibrary`, the name of the configuration. Or, the options object with zero or more options as property : value pairs.</li>
  <span style="font-size:15px;"><li><b>{VarRef} [OutStr]</b> - A variable that will receive the JSON string. The string is also returned as a return value, but for very long strings, or for loops that process thousands of objects, it will be slightly faster to use the `OutStr` variable since the JSON string would not need to be copied.</li>
</ol>

# Returns

<b>{String}</b> - The JSON string.

# Options

Jump to:
<ul>
  <a href="#callbackgeneral"><br>CallbackGeneral</a>
  <a href="#callbackplaceholder"><br>CallbackPlaceholder</a>
  <a href="#enumtypemap"><br>EnumTypeMap</a>
  <a href="#excludemethods"><br>ExcludeMethods</a>
  <a href="#excludeprops"><br>ExcludeProps</a>
  <a href="#filtertypemap"><br>FilterTypeMap</a>
  <a href="#indent"><br>Indent</a>
  <a href="#initialptrlistcapacity"><br>InitialPtrListCapacity</a>
  <a href="#initialstrcapacity"><br>InitialStrCapacity</a>
  <a href="#itemprop"><br>ItemProp</a>
  <a href="#maxdepth"><br>MaxDepth</a>
  <a href="#newline"><br>Newline</a>
  <a href="#newlinedepthlimit"><br>NewlineDepthLimit</a>
  <a href="#printerrors"><br>PrintErrors</a>
  <a href="#propstypemap"><br>PropsTypeMap</a>
  <a href="#quotenumerickeys"><br>QuoteNumericKeys</a>
  <a href="#rootname"><br>RootName</a>
  <a href="#singleline"><br>Singleline</a>
  <a href="#stopattypemap"><br>StopAtTypeMap</a>
  <a href="#unsetarrayitem"><br>UnsetArrayItem</a>
</ul>

## Enum options

Name|Type|Default|Description
----------|----|-------|-----
<span id="enumtypemap" style="font-size:16px;"><b>EnumTypeMap</b></span>|Map|Map("Array", 1, "Map", 2, "RegExMatchInfo", 2)|A <code>Map</code> object where the keys are object types and the values are either:<ul><li>An integer:</li><ul><li>1: Directs <code>StringifyAll</code> to call the object's enumerator in 1-param mode.</li><li>2: Directs <code>StringifyAll</code> to call the object's enumerator in 2-param mode.</li><li>0: Directs <code>StringifyAll</code> to not call the object's enumerator.</li></ul><li>A function or callable object:</li><ul><li>The function should accept the object being evaluated as its only parameter.</li><li>The function should return one of the above listed integers.</li></ul></ul>Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.
<span id="excludemethods" style="font-size:16px;"><b>ExcludeMethods</b></span>|Boolean|true|If true, properties with a <code>Call</code> accessor and properties with only a <code>Set</code> accessor are excluded from stringification. If false or unset, those kinds of properties are included in the JSON string with the name of the function object.
<span id="excludeprops" style="font-size:16px;"><b>ExcludeProps</b></span>|String|""|A comma-delimited, case-insensitive list of property names to exclude from stringification.
<span id="filtertypemap" style="font-size:16px;"><b>FilterTypeMap</b></span>|Map|""|A <code>Map</code> object where the keys are object types and the values are <code>PropsInfo.FilterGroup</code> objects. <code>StringifyAll</code> will apply the filter when iterating the properties of an object of the indicated types.
<span id="maxdepth" style="font-size:16px;"><b>MaxDepth</b>|Integer|0|The maximum depth <code>StringifyAll</code> will recurse into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up. At any given point, the indentation level can be as large as 3x the depth level. This is due to how <code>StringifyAll</code> handles map and array items.
<span id="propstypemap" style="font-size:16px;"><b>PropsTypeMap</b></span>|Map|{ __Class: "Map", Default: 1, Count: 0 }|A <code>Map</code> object where the keys are object types and the values are either:<ul><li>A boolean indicating whether or not <code>StringifyAll</code> should process the object's properties. A nonzero value directs <code>StringifyAll</code> to process the properties. A falsy value directs <code>StringifyAll</code> to skip the properties.</li><li>A function or callable object:</li><ul><li>The function should accept the object being evaluated as its only parameter.</li><li>The function should return a boolean value described above.</li></ul>The default value is a `Map` object with zero items and a `Default` property value of 1, directing `StringifyAll` to process the properties of all object types. Keep this in mind when you set `PropsTypeMap`; if you intend to direct `StringifyAll` to process object properties by default while using `PropsTypeMap` to exclude certain object types, you'll need to set the `Default` value to 1 as well. If you want `StringifyAll` to not process any properties by default, and to use `PropsTypeMap` to specify which object types should have their properties processed, you can leave the `Default` property unset, or set it with `0`.</ul>
<span id="stopattypemap" style="font-size:16px;"><b>StopAtTypeMap</b></span>|Map|""|A <code>Map</code> object where the keys are object types and the values are either: <ul><li>A string or number that will be passed to the <code>StopAt</code> parameter of <code>GetPropsInfo</code>.</li><li>A function or callable object:</li><ul><li>The function should accept the object being evaluated as its only parameter.</li><li>The function should return a string or number to be passed to the <code>StopAt</code> parameter of <code>GetPropsInfo</code>.</li></ul></ul>Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.


<h2>Callbacks</h2>

Name|Type|Default|Description
----------|----|-------|-----
<span id="callbackgeneral" style="font-size:16px;"><b>CallbackGeneral</b></span>|*|""|A function or callable object, or an array of one or more functions or callable objects, that will be called for each object prior to processing. The function should accept up to two parameters:<ol><li><b>{*}</b> - The object about to be processed.</li><li><b>{VarRef}</b> - A variable that will receive a reference to the JSON string being created.</li></ol><b>Return:</b> The function(s) can return a nonzero value to direct <code>StringifyAll</code> to skip processing the object. Any further functions in an array of functions are necessarily also skipped in this case.The function should return a value to one of these effects:<ul><li>If the return value is a <b>string</b>, that string will be used as the placeholder for the object in the JSON string.</li><li>If the return value is <b>-1</b>, <code>StringifyAll</code> skips that object completely and it is not represented in the JSON string.</li><li>If the return value is <b>any other nonzero value</b>, then:</li><ul><li>If <code>CallbackPlaceholder</code> is set, <code>CallbackPlaceholder</code> will be called to generate the placeholder. Else,</li><li>If <code>CallbackPlaceholder</code> is unset, the built-in placeholder is used.</li></ul><li>If the return value is <b>zero or an empty string</b>, <code>StringifyAll</code> proceeds calling the next function if there is one, or proceeds stringifying the object.</li></ul>If your function returns a string:<ul><li>Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code>to do this.</li><li>Note that <code>StringifyAll</code> does not enclose the value in quotes when adding it to the JSON string. Your function should add the quote characters, or call <code>StringifyAll.StrEscapeJson</code> which has the option to add the quote characters for you.</li></ul><br>The function(s) should not call <code>StringifyAll</code>; <code>StringifyAll</code> relies on several variables in the function's scope that would be altered by concurrent function calls, causing unexpected behavior for any earlier <code>StringifyAll</code> calls.<br><br>The following is a description of the part of the process which the function(s) are called. <ul><li><code>StringifyAll</code> proceeds in two stages, initialization and recursive processing. After initialization, the function <code>Recurse</code> is called once, which starts the second stage. When <code>StringifyAll</code> encounters a value that is an object, it proceeds through a series of condition checks to determine if it will call <code>Recurse</code> again for that value. Before calling <code>Recurse</code>, <code>StringifyAll</code> checks the following conditions. When a value is skipped, a placeholder is printed instead.</li><ul><li>If the value is a <code>ComObject</code> or <code>ComValue</code>, the value is skipped.</li><li>If the value has already been stringified, the value is skipped. This is intended to prevent infinite recursion, but currently causes <code>StringifyAll</code> to skip all subsequent encounters of an object after the first, not just problematic ones. I will implement a more flexible solution.</li><li>If no further recursion is permitted according to <code>MaxDepth</code>, the value is skipped. If none of the above conditions cause <code>StringifyAll</code> to skip the object, <code>StringifyAll</code> then calls the callback function(s). This occurs right before <code>Recurse</code> is called.</ul></ul>
<span id="callbackplaceholder" style="font-size:16px;"><b>CallbackPlaceholder</b></span>|*|""|When <code>StringifyAll</code> skips processing an object, a placeholder is printed instead. You can define <code>CallbackPlaceholder</code> with any callable object to customize the string that gets printed. The function must follow these specifications:<li><b>Parameters:</b><ol type="1"></li><li><b>{Object}</b> - The <code>controller</code> object. The <code>controller</code> is an internal mechanism with various callable properties, but the only property of use for this purpose is <code>Path</code>, which has a string value representing the object path up to but not including the object that is currently being evaluated. In the below example, if your function is called for a placeholder for the object at <code>obj.nestedObj.doubleNestedObj</code>, the path will be "$.nestedObj".<pre>Obj := {<br>    nestedObj: {<br>        doubleNestedObj: {  prop: 'value' }<br>    }<br>}</pre></li><li><b>{\*}</b> - The object being evaluated.</li><li><b>{VarRef}</b> - An optional <code>VarRef</code> parameter that will receive the name of the property for objects that are encountered while iterating the parent object's properties.</li><li><b>{VarRef}</b> - An optional <code>VarRef</code> parameter that will receive either of:</li><ul><li>The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.</li><li>The "key" (the value received by the first variable in a for-loop) for objects that are encountered while enumerating an object in 2-parameter mode. The key will already have been escaped and enclosed in double quotes at this point, making it somewhat awkward to work with because escaping it again will re-escape the existing escape sequences. If your function will use the key for some purpose, then you will likely want to do something like the below example.</li></ul><pre>MyPlaceholderFunc(controller, obj, &prop?, &key?) {<br>    if IsSet(prop) {<br>        ; make something<br>    } else if IsSet(key) {<br>        if IsNumber(key) {<br>            ; make something<br>        } else {<br>            key := Trim(key, '"')<br>        if InStr(key, '\') {<br>            StringifyAll.StrUnescapeJson(&key)<br>        }<br>        ; make something<br>    }<br>}</pre></ol></li><li><b>Return:</b> The function should return the placeholder string. Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code> to do this. Also don't forget to enclose the string in double quotes.</li>It does not matter if the function modifies the two <code>VarRef</code> parameters as <code>StringifyAll</code> will not use them again at that point.<br>If your function will not use one or more parameters, specify the "*" operator to exclude them.


<h2>Newline and indent options</h2>

Name|Type|Default|Description
----------|----|-------|-----
<span id="condensecharlimit" style="font-size:16px;"><b>CondenseCharLimit<br>CondenseCharLimitEnum1<br>CondenseCharLimitEnum2<br>CondenseCharLimitProps</b></span>|Integer|0|Sets a threshold which <code>StringifyAll</code> uses to determine whether an object's JSON substring should be condensed to a single line as a function of the character length of the substring. If <code>CondenseCharLimit</code> is set, you can still specify individual options for the other three and the individual option will take precedence over <code>CondenseCharLimit</code>. The substring length is measured beginning from the open brace.
<span id="indent" style="font-size:16px;"><b>Indent</b></span>|String|"\`s\`s\`s\`s"|The literal string that will be used for one level of indentation.
<span id="newline" style="font-size:16px;"><b>Newline</b></span>|String|"\`r\`n"|The literal string that will be used for line breaks. If set to zero or an empty string, the <code>Singleline</code> option is effectively enabled.
<span id="newlinedepthlimit" style="font-size:16px;"><b>NewlineDepthLimit</b></span>|Integer|0|Sets a threshold directing <code>StringifyAll</code> to stop adding line breaks between values after exceeding the threshold.
<span id="singleline" style="font-size:16px;"><b>Singleline</b></span>|Boolean|false|If true, the JSON string is printed without line breaks or indentation. All other "Newline and indent options" are ignored.

<h2>Print options</h2>

Name|Type|Default|Description
----------|----|-------|-----
<span id="itemprop" style="font-size:16px;"><b>ItemProp</b></span>|String|"\_\_Items\_\_"|The name that <code>StringifyAll</code> will use as a faux-property for including an object's items returned by its enumerator.
<span id="printerrors" style="font-size:16px;"><b>PrintErrors</b></span>|Boolean|false|When true, if <code>StringifyAll</code> encounters an error when attempting to access the value of an object's property, the error message is included in the JSON string as the value of the property. When false, <code>StringifyAll</code> skips the property.
<span id="quotenumerickeys" style="font-size:16px;"><b>QuoteNumericKeys</b></span>|Boolean|false|When true, and when <code>StringifyAll</code> is processing an object's enumerator in 2-param mode, if the value returned to the first parameter (the "key") is numeric, it will be quoted in the JSON string.
<span id="rootname" style="font-size:16px;"><b>RootName</b></span>|String|"$"|Prior to recursively stringifying a nested object, <code>StringifyAll</code> checks if the object has already been processed. (This is to prevent infinite recursion, and more flexible processing will be implemented). If an object has already been processed, a placeholder is printed in its place. The placeholder printed as a result of this condition is different than placeholders printed for other reasons. In this case, the placeholder is a string representation of the object path at which the object was first encountered. This is so one's self, or one's code, can locate the object in the JSON string if needed. <code>RootName</code> specifies the name of the root object used within any occurrences of this placeholder string.
<span id="unsetarrayitem" style="font-size:16px;"><b>UnsetArrayItem</b></span>|String|"\`"\`""|The string to print for unset array items.

<h2>General options</h2>

Name|Type|Default|Description
----------|----|-------|-----
<span id="initialptrlistcapacity" style="font-size:16px;"><b>InitialPtrListCapacity</b></span>|Integer|64|<code>StringifyAll</code> tracks the ptr addresses of every object it stringifies to prevent infinite recursion. <code>StringifyAll</code> will set the initial capacity of the <code>Map</code> object used for this purpose to <code>InitialPtrListCapacity</code>.
<span id="initialstrcapacity" style="font-size:16px;"><b>InitialStrCapacity</b>|Integer|65536|<code>StringifyAll</code> calls <code>VarSetStrCapacity</code> using <code>InitialStrCapacity</code> for the output string during the initialization stage. For the best performance, you can overestimate the approximate length of the string; <code>StringifyAll</code> calls <code>VarSetStrCapacity(&OutStr, -1)</code> at the end of the function to release any unused memory.

<h1>StringifyAll's process</h1>

This section describes `StringifyAll`'s process. This section is intended to help you better understand how the options will impact the output string. This section is not complete.

<b>Properties</b>

For every object, prior to adding the object's open brace to the string, <code>StringifyAll</code> proceeds through these steps:
<ul>
  <li>If <code>Options.PropsTypeMap.HasOwnProp('Default')</code> then this code is used:</li>

```
if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
    return Item(Obj)
} else {
    return Item
}
```

  <li>Else, this code is used:</li>

```
if propsTypeMap.Has(Type(Obj)) {
    if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
        return Item(Obj)
    } else {
        return Item
    }
}
```

  <li>If the return value is nonzero:</li>
    <ul>
      <li><code>StringifyAll</code> calls <code>PropsInfoObj := GetPropsInfo(Obj, StopAt, excludeProps, false, , excludeMethods)</code>.</li>
      <li>If <code>PropsInfoObj.Count > 0</code>, <code>StringifyAll</code> processes only the properties exposed by <code>PropsInfoObj</code>. You can control this with two options.</li>
      <ul>
        <li><code>Options.ExcludeProps</code> is effective and straightforward. Write a comma-delimited string of property names to exclude. This would apply to all objects.</li>
        <li><code>Options.FilterTypeMap</code> affords greater flexibility. <code>PropsInfo</code> objects are designed with a filter system to make it easy to programmatically include a set of properties, and exclude the other, from whatever one's code is doing with the <code>PropsInfo</code> object. See "example\example.ahk" and/or "inheritance\example-Inheritance.ahk" for examples.</li>
      </ul>
      <li>Else, <code>StringifyAll</code> skips the properties for that object and goes on to check if the enumerator will be called.</li>
    </ul>
    <li>If the return value is falsy, <code>StringifyAll</code> skips the properties for that object and goes on to check if the enumerator will be called.</li>
  </ul>
</ul>

This will come into play if you want an <code>Array</code> or <code>Map</code> object's string representation to have the appearance of what we typically expect for arrays and maps. To accomplish this, <code>StringifyAll</code> must not process any properties for those objects. You can accomplish this by simply defining two items in the map: <code>Options.PropsTypeMap := Map("Array", 0, "Map", 0)</code>. Don't forget to set <code>Options.PropsTypeMap.Default := 1</code> if you still want other objects to have their properties processed.


<h1>Changelog</h1>

2025-05-29 - 1.0.3
- Implemented `ConfigLibrary`.

2025-05-28 - 1.0.1
- Adjusted how `Options.PropsTypeMap` is handled. This change did not modify `StringifyAll`'s behavior, but it is now more clear both in the code and in the documentation what the default value is and what the default value does.
- Added "StringifyAll's process" to the docs.
