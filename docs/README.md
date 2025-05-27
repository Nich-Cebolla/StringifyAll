
# Introduction
A customizable solution for serializing AutoHotkey (AHK) object properties, including inherited properties, and/or items into a 100% valid JSON string.

`StringifyAll` works in conjunction with `GetPropsInfo` (https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance) to allow us to include all of an object's properties in the JSON string, not just the items or own properties.

`StringifyAll` exposes many options to programmatically restrict what gets included in the JSON string. It also includes options for adjusting the spacing in the string. To set your options, you can:
- Copy one of the template files into your project directory and set the options using the template.
- Define a class `StringifyAllConfig` anywhere in your code.
- Pass an object to the `Options` parameter.

The options defined by the `Options` parameter supercede options defined by the `StringifyConfig` class. This is convenient for setting your own defaults based on your personal preferences / project needs using the class object, and then passing an object to the `Options` parameter to adjust your defaults on-the-fly.

For usage examples, see "example\example.ahk".

There are some considerations to keep in mind when using `StringifyAll` with the intent to later parse it back into a data object.
- All objects that have one or more of its property values written to the JSON string are represented as an object using curly braces, including array objects and map objects. Since square brackets are the typical indicator that a substring is representing an array object, a parser will interpret the substring as an object with a property that is an array, rather than just an array. (Keep an eye out for my updated JSON parser to pair with `StringifyAll`).
- A parser would need to handle read-only properties in some way.
- Some properties don't necessarily need to be parsed. For example, if I stringified an array object including its native properties, a parser setting the `Length` property would be redundant.

The above considerations are mitigated by keeping separate configuration files for separate purposes. For example, keep one configuration to use when intending to later parse the string back into AHK data, and keep another configuration to use when intending to visually inspect the string.

There are some conditions which will cause `Stringify` to skip stringifying an object. When this occurs, `Stringify` prints a placeholder string instead. The conditions are:
- The object is a `ComObject` or `ComValue`.
- The maximum depth is reached.
- Your callback function returned a value directing `Stringify` to skip the object.
- The object has been stringified already. The placeholder for this condition is separate from the others; it is a string representation of the object path at which the object was first encountered. This is so one's code or one's self can identify the correct object that was at that location when `Stringify` was processing.

`StringifyAll` does not inherently direct the flow of action as a condition of whether an object is a map, array, or some other type of object. Instead, the options can be used to specify precisely what should be included in the JSON string and what should not be included.

`StringifyAll` will require more setup to be useful compared to other stringify functions, because we usually don't need information about every property. `StringifyAll` is not intended to be a replacement for other stringify functions. Where `StringifyAll` shines is in cases where we need a way to programmatically define specifically what properties we want represented in the JSON string and what we want to exclude; at the cost of requiring greater setup time investment, we receive in exchange the potential to fine-tune precisely what will be present in the JSON string.

# Parameters

<ol type="1">
  <span style="font-size:15px;"><li><b>{*} Obj</b> - The object to stringify.<span style="font-size:13px;"></li>
  <span style="font-size:15px;"><li><b>{Object} [Options]</b> - The options object with zero or more options as property : value pairs.</li>
  <span style="font-size:15px;"><li><b>{VarRef} [OutStr]</b> - A variable that will receive the JSON string. The string is also returned as a return value, but for very long strings, or for loops that process thousands of objects, it will be slightly faster to use the `OutStr` variable since the JSON string would not need to be copied.</li>
</ol>

# Returns

<b>{String}</b> - The JSON string.

# Options

Jump to:
<ul>
  <a href="#callbackgeneral"><br>CallbackGeneral</a>
  <a href="#callbackplaceholder"><br>CallbackPlaceholder</a>
  <a href="#enumcondition"><br>EnumCondition</a>
  <a href="#enumtypemap"><br>EnumTypeMap</a>
  <a href="#excludemethods"><br>ExcludeMethods</a>
  <a href="#excludeprops"><br>ExcludeProps</a>
  <a href="#filter"><br>Filter</a>
  <a href="#filtertypemap"><br>FilterTypeMap</a>
  <a href="#indent"><br>Indent</a>
  <a href="#initialptrlistcapacity"><br>InitialPtrListCapacity</a>
  <a href="#initialstrcapacity"><br>InitialStrCapacity</a>
  <a href="#itemprop"><br>ItemProp</a>
  <a href="#maxdepth"><br>MaxDepth</a>
  <a href="#newline"><br>Newline</a>
  <a href="#newlinedepthlimit"><br>NewlineDepthLimit</a>
  <a href="#printerrors"><br>PrintErrors</a>
  <a href="#propscondition"><br>PropsCondition</a>
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
<span id="enumcondition" style="font-size:16px;"><b>EnumCondition</b></span>|*|(Obj) => Obj is Array<br>? 1 : Obj is Map<br>\|\| Obj is RegExMatchInfo<br>? 2 : 0|A function or callable object that returns an indicator if an object should be enumerated, and if so, to use 1-param mode or 2-param mode. The function should accept one parameter, the object that is being evaluated, and should return one of:<li><b>1</b> - Directs <code>StringifyAll</code> to call <code>Obj.__Enum</code> in 1-parameter mode.</li><li><b>2</b> - Directs <code>StringifyAll</code> to call <code>Obj.__Enum</code> in 2-parameter mode.</li><li><b>0 / empty string</b> - Directs <code>StringifyAll</code> not to call <code>Obj.__Enum</code>.</li>
<span id="enumtypemap" style="font-size:16px;"><b>EnumTypeMap</b></span>|Map|""|A <code>Map</code> object where the keys are object types and the values are either:<ul><li>An integer indicating how <code>StringifyAll</code> should enumerate objects of that type.</li><li>A function or callable object that takes the object being evaluated as its only parameter and returns an integer indicating how <code>StringifyAll</code> should enumerate the object.</li></ul>Both <code>EnumCondition</code> and <code>EnumTypeMap</code> are used for the same purpose. Their roles intersect following these rules:<ul><li>When <code>EnumTypeMap</code> is unset, <code>StringifyAll</code> only uses <code>EnumCondition</code> to determine how to handle enumeration.</li><li>When <code>EnumTypeMap</code> is set, <code>StringifyAll</code> checks if the <code>Default</code> property has been set on the <code>EnumTypeMap</code> object.</li><ul><li>If <code>Default</code> is set, then <code>StringifyAll</code> ignores <code>EnumCondition</code> completely and calls <code>EnumTypeMap.Get(Type(Obj))</code> for all objects that <code>StringifyAll</code> processes.</li><li>If <code>Default</code> is not set, then <code>StringifyAll</code> calls <code>EnumTypeMap.Has(Type(Obj))</code>.</li><ul><li>If true, <code>StringifyAll</code> uses the item's value.</li><li>If false, <code>StringifyAll</code> uses the return value from <code>EnumCondition</code>.</li></ul></ul></ul>
<span id="excludemethods" style="font-size:16px;"><b>ExcludeMethods</b></span>|Boolean|true|If true, properties with a <code>Call</code> accessor and properties with only a <code>Set</code> accessor are excluded from stringification. If false or unset, those kinds of properties are included in the JSON string with the name of the function object.
<span id="excludeprops" style="font-size:16px;"><b>ExcludeProps</b></span>|String|""|A comma-delimited, case-insensitive list of property names to exclude from stringification.
<span id="filter" style="font-size:16px;"><b>Filter</b></span>|PropsInfo.FilterGroup|""|A single <code>PropsInfo.FilterGroup</code> object that will be applied to all <code>PropsInfo</code> objects iterated during stringification. If <code>FilterTypeMap</code> is set, this is ignored.
<span id="filtertypemap" style="font-size:16px;"><b>FilterTypeMap</b></span>|Map|""|A <code>Map</code> object where the keys are object types and the values are <code>PropsInfo.FilterGroup</code> objects. <code>StringifyAll</code> will apply the filter when iterating the properties of an object of the indicated types. You can use the <code>Default</code> property of the map object to specify a default <code>PropsInfo.FilterGroup</code> to use for all objects, and then add additional items to the map for specific object types. Note that if you do not set the <code>Map</code> object's <code>Default</code> value, <code>StringifyAll</code> will set it to <code>0</code>.
<span id="maxdepth" style="font-size:16px;"><b>MaxDepth</b>|Integer|0|The maximum depth <code>StringifyAll</code> will recurse into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up. At any given point, the indentation level can be as large as 3x the depth level. This is due to how <code>StringifyAll</code> handles map and array items.
<span id="propscondition" style="font-size:16px;"><b>PropsCondition</b></span>|*|""|A function or callable object that returns an indicator if an object's properties should be stringified. The function should accept one parameter, the object being evaluated, and should return a nonzero value if the object's properties should be stringified, or a falsy value if the object's properties should not be stringified.
<span id="propstypemap" style="font-size:16px;"><b>PropsTypeMap</b></span>|Map|""|A <code>Map</code> object where the keys are object types and the values and the values are one of:<ul><li><b>A nonzero value</b> - Directs <cody>StringifyAll</code> to process the object's properties.</li><li><b>Zero or an empty string</b> - Directs <code>StringifyAll</code> to skip the object's properties.</li><li><b>A function or callable object</b> - The function should accept the object being evaluated as its only parameter and returns either indicator described above. </li></ul>The baseline behavior for <code>StringifyAll</code> is to create a <code>PropsInfo</code> object for all objects that are stringified. If <code>PropsInfoObj.Count > 0</code>, then <code>StringifyAll</code> will process the properties included among the <code>PropsInfo</code> object. If <code>PropsInfoObj.Count == 0</code>, <code>StringifyAll</code> does not process properties for the object.Both <code>PropsCondition</code> and <code>PropsTypeMap</code> are used for the same purpose. Their roles intersect following these rules:<ul><li>When <code>PropsTypeMap</code> and <code>PropsCondition</code> are both unset, <code>StringifyAll</code> uses the baseline process described above for all objects.</li><li>When <code>PropsTypeMap</code> is set, <code>StringifyAll</code>'s behavior adapts in these ways:</li><ul><li>During initialization, <code>StringifyAll</code> checks if the <code>Default</code> property has been set on the <code>Map</code> object.<ul><li>If <code>Default</code> is set, then <code>StringifyAll</code> ignores <code>PropsCondition</code> completely and calls <code>PropsTypeMap.Get(Type(Obj))</code> for all objects that <code>StringifyAll</code> processes.</li><li>If <code>Default</code> is not set, then <code>StringifyAll</code> calls <code>PropsTypeMap.Has(Type(Obj))</code>.</li><ul>If true, <code>StringifyAll</code> uses the item's value.</li><li>If false, <code>StringifyAll</code> uses the return value from <code>PropsCondition</code> if it is in use. If not in use, <code>StringifyAll</code> uses the baseline behavior described above.</li></ul></ul></ul></ul>
<span id="stopattypemap" style="font-size:16px;"><b>StopAtTypeMap</b></span>|Map|""|A <code>Map</code> object where the keys are object types and the values are strings or numbers that will be passed to the <code>StopAt</code> parameter of <code>GetPropsInfo</code>. For example, if I don't want <code>StringifyAll</code> to include the <code>Length</code>, <code>Capacity</code>, or <code>__Item</code> properties when processing <code>Array</code> objects, one way to do this would be to define <code>StopAtTypeMap</code> to direct <code>GetPropsInfo</code> not to include properties owned by <code>Array.Prototype</code>: <code>StringifyAllConfig.StopAtMap := Map('Array', '-Array')</code><br>Note that if you use this option and do not set the <code>Map</code> object's default value, <code>StringifyAll</code> will set the default to "-Object".<br>See the parameter hints for <code>GetBaseObjects</code> within the file "inheritance\GetBaseObjects.ahk" for full details about this parameter.


<h2>Callbacks</h2>

Name|Type|Default|Description
----------|----|-------|-----
<span id="callbackgeneral" style="font-size:16px;"><b>CallbackGeneral</b></span>|*|""|A function or callable object, or an array of one or more functions or callable objects, that will be called for each object prior to processing. The function should accept up to two parameters:<ol><li><b>{*}</b> - The object about to be processed.</li><li><b>{VarRef}</b> - A variable that will receive a reference to the JSON string being created.</li></ol><b>Return:</b> The function(s) can return a nonzero value to direct <code>StringifyAll</code> to skip processing the object. Any further functions in an array of functions are necessarily also skipped in this case.The function should return a value to one of these effects:<ul><li>If the return value is a <b>string</b>, that string will be used as the placeholder for the object in the JSON string.</li><li>If the return value is <b>-1</b>, <code>StringifyAll</code> skips that object completely and it is not represented in the JSON string.</li><li>If the return value is <b>any other nonzero value</b>, then:</li><ul><li>If <code>CallbackPlaceholder</code> is set, <code>CallbackPlaceholder</code> will be called to generate the placeholder. Else,</li><li>If <code>CallbackPlaceholder</code> is unset, the built-in placeholder is used.</li></ul><li>If the return value is <b>zero or an empty string</b>, <code>StringifyAll</code> proceeds calling the next function if there is one, or proceeds stringifying the object.</li></ul>If your function returns a string:<ul><li>Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code>to do this.</li><li>Note that <code>StringifyAll</code> does not enclose the value in quotes when adding it to the JSON string. Your function should add the quote characters, or call <code>StringifyAll.StrEscapeJson</code> which has the option to add the quote characters for you.</li></ul><br>The function(s) should not call <code>StringifyAll</code>; <code>StringifyAll</code> relies on several variables in the function's scope that would be altered by concurrent function calls, causing unexpected behavior for any earlier <code>StringifyAll</code> calls.<br><br>The following is a description of the part of the process which the function(s) are called. <ul><li><code>StringifyAll</code> proceeds in two stages, initialization and recursive processing. After initialization, the function <code>Recurse</code> is called once, which starts the second stage. When <code>StringifyAll</code> encounters a value that is an object, it proceeds through a series of condition checks to determine if it will call <code>Recurse</code> again for that value. Before calling <code>Recurse</code>, <code>StringifyAll</code> checks the following conditions. When a value is skipped, a placeholder is printed instead.</li><ul><li>If the value is a <code>ComObject</code> or <code>ComValue</code>, the value is skipped.</li><li>If the value has already been stringified, the value is skipped. This is intended to prevent infinite recursion, but currently causes <code>StringifyAll</code> to skip all subsequent encounters of an object after the first, not just problematic ones. I will implement a more flexible solution.</li><li>If no further recursion is permitted according to <code>MaxDepth</code>, the value is skipped. If none of the above conditions cause <code>StringifyAll</code> to skip the object, <code>StringifyAll</code> then calls the callback function(s). This occurs right before <code>Recurse</code> is called.</ul></ul>
<span id="callbackplaceholder" style="font-size:16px;"><b>CallbackPlaceholder</b></span>|*|""|When <code>StringifyAll</code> skips processing an object, a placeholder is printed instead. You can define <code>CallbackPlaceholder</code> with any callable object to customize the string that gets printed. The function must follow these specifications:<li><b>Parameters:</b><ol type="1"></li><li><li><b>{Object}</b> - The <code>controller</code> object. The <code>controller</code> is an internal mechanism with various callable properties, but the only property of use for this purpose is <code>Path</code>, which has a string value representing the object path up to but not including the object that is currently being evaluated. In the below example, if your function is called for a placeholder for the object at <code>obj.nestedObj.doubleNestedObj</code>, the path will be "$.nestedObj".<pre>Obj := {<br>    nestedObj: {<br>        doubleNestedObj: {  prop: 'value' }<br>    }<br>}</pre></li><li><b>{\*}</b> - The object being evaluated.</li><li><b>{VarRef}</b> - An optional <code>VarRef</code> parameter that will receive the name of the property for objects that are encountered while iterating the parent object's properties.</li><li><b>{VarRef}</b> - An optional <code>VarRef</code> parameter that will receive either of:</li><ul><li>The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.</li><li>The "key" (the value received by the first variable in a for-loop) for objects that are encountered while enumerating an object in 2-parameter mode. The key will already have been escaped and enclosed in double quotes at this point, making it somewhat awkward to work with because escaping it again will re-escape the existing escape sequences. If your function will use the key for some purpose, then you will likely want to do something like the below example.</li></ul><pre>MyPlaceholderFunc(controller, obj, &prop?, &key?) {<br>    if IsSet(prop) {<br>        ; make something<br>    } else if IsSet(key) {<br>        if IsNumber(key) {<br>            ; make something<br>        } else {<br>            key := Trim(key, '"')<br>        if InStr(key, '\') {<br>            StringifyAll.StrUnescapeJson(&key)<br>        }<br>        ; make something<br>    }<br>}</pre></ol></li><li><b>Return:</b> The function should return the placeholder string. Don't forget to escape the necessary characters. You can call <code>StringifyAll.StrEscapeJson</code> to do this. Also don't forget to enclose the string in double quotes.</li>It does not matter if the function modifies the two <code>VarRef</code> parameters as <code>StringifyAll</code> will not use them again at that point.<br>If your function will not use one or more parameters, specify the "*" operator to exclude them.


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
<span id="itemprop" style="font-size:16px;"><b>ItemProp</b></span>|String|"__Items__"|The name that <code>StringifyAll</code> will use as a faux-property for including an object's items returned by its enumerator.
<span id="printerrors" style="font-size:16px;"><b>PrintErrors</b></span>|Boolean|false|When true, if <code>StringifyAll</code> encounters an error when attempting to access the value of an object's property, the error message is included in the JSON string as the value of the property. When false, <code>StringifyAll</code> skips the property.
<span id="quotenumerickeys" style="font-size:16px;"><b>QuoteNumericKeys</b></span>|Boolean|false|When true, and when <code>StringifyAll</code> is processing an object's enumerator in 2-param mode, if the value returned to the first parameter (the "key") is numeric, it will be quoted in the JSON string.
<span id="rootname" style="font-size:16px;"><b>RootName</b></span>|String|"$"|Prior to recursively stringifying a nested object, <code>StringifyAll</code> checks if the object has already been processed. (This is to prevent infinite recursion, and more flexible processing will be implemented). If an object has already been processed, a placeholder is printed in its place. The placeholder printed as a result of this condition is different than placeholders printed for other reasons. In this case, the placeholder is a string representation of the object path at which the object was first encountered. This is so one's self, or one's code, can locate the object in the JSON string if needed. <code>RootName</code> specifies the name of the root object used within any occurrences of this placeholder string.
<span id="unsetarrayitem" style="font-size:16px;"><b>UnsetArrayItem</b></span>|String|"\`"\`""|The string to print for unset array items.

<h2>General options</h2>

Name|Type|Default|Description
----------|----|-------|-----
<span id="initialptrlistcapacity" style="font-size:16px;"><b>InitialPtrListCapacity</b></span>|Integer|64|<code>StringifyAll</code> tracks the ptr addresses of every object it stringifies to prevent infinite recursion. <code>StringifyAll</code> will set the initial capacity of the <code>Map</code> object used for this purpose to <code>InitialPtrListCapacity</code>.
<span id="initialstrcapacity" style="font-size:16px;"><b>InitialStrCapacity</b>|Integer|65536|<code>StringifyAll</code> calls <code>VarSetStrCapacity</code> using <code>InitialStrCapacity</code> for the output string during the initialization stage. For the best performance, you can overestimate the approximate length of the string; <code>StringifyAll</code> calls <code>VarSetStrCapacity(&OutStr, -1)</code> at the end of the function to release any unused memory.
