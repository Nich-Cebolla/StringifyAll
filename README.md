
# StringifyAll - v1.1.2
A customizable solution for serializing AutoHotkey (AHK) object properties, including inherited properties, and/or items into a 100% valid JSON string.

## AutoHotkey forum post
https://www.autohotkey.com/boards/viewtopic.php?f=83&t=137415&p=604407#p604407

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
  <li><a href="#stringifyalls-process">StringifyAll's process</a></li>
  <ol type="A">
    <li><a href="#properties">Properties</a></li>
    <li><a href="#callbackgeneral">CallbackGeneral</a></li>
    <li><a href="#calling-the-enumerator">Calling the enumerator</a></li>
  </ol>
  <li><a href="#changelog">Changelog</a></li>
</ol>

## Introduction
`StringifyAll` works in conjunction with `GetPropsInfo` (https://github.com/Nich-Cebolla/AutoHotkey-LibV2/tree/main/inheritance) to allow us to include all of an object's properties in the JSON string, not just the items or own properties.

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
</ol>

## Returns

**{String}** - The JSON string.

## Options

The format for these options are:<br>
<b>{Value type}</b> [ <b>Option name</b>  = <code>Default value</code> ]<br>
<span style="padding-left: 24px;">Description</span>

Jump to:
<a href="#callerror"><br>CallbackError</a>
<a href="#callbackgeneral"><br>CallbackGeneral</a>
<a href="#callbackplaceholder"><br>CallbackPlaceholder</a>
<a href="#condensecharlimit"><br>CondenseCharLimit</a>
<a href="#condensecharlimitenum1"><br>CondenseCharLimitEnum1</a>
<a href="#condensecharlimitenum2"><br>CondenseCharLimitEnum2</a>
<a href="#condensecharlimitprops"><br>CondenseCharLimitProps</a>
<a href="#enumtypemap"><br>EnumTypeMap</a>
<a href="#excludemethods"><br>ExcludeMethods</a>
<a href="#excludeprops"><br>ExcludeProps</a>
<a href="#filtertypemap"><br>FilterTypeMap</a>
<a href="#indent"><br>Indent</a>
<a href="#initialptrlistcapacity"><br>InitialPtrListCapacity</a>
<a href="#initialstrcapacity"><br>InitialStrCapacity</a>
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

### Enum options

<ul id="enumtypemap"><b>{Map}</b> [ <b>EnumTypeMap</b>  = <code>Map("Array", 1, "Map", 2, "RegExMatchInfo", 2)</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">
    A <code>Map</code> object where the keys are object types and the values are either:
    <ul style="margin-top: 4px; margin-bottom: 6px; ">
      <li><b>Integer</b>:</li>
      <ul style="margin-bottom: 0;">
        <li><code>1</code>: Directs <code>StringifyAll</code> to call the object's enumerator in 1-param mode.</li>
        <li><code>2</code>: Directs <code>StringifyAll</code> to call the object's enumerator in 2-param mode.</li>
        <li><code>0</code>: Directs <code>StringifyAll</code> to not call the object's enumerator.</li>
      </ul>
      <li><b>Func</b> or callable <b>Object</b>:
        <br>
        <i>Parameters</i>
        <ol type="1" style="margin-bottom: 0;">
          <li>The <b>Object</b> being evaluated.</li>
        </ol>
        <i>Return</i>
        <ul style="margin-bottom: 0;">
          <li><b>Integer:</b> One of the above listed integers.</li>
        </ol>
      </ul>
    </ul>
    Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.
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

<ul id="filtertypemap"><b>{Map}</b> [ <b>FilterTypeMap</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0;">A <code>Map</code> object where the keys are object types and the values are <code>PropsInfo.FilterGroup</code> objects. <code>StringifyAll</code> will apply the filter when iterating the properties of an object of the indicated types.</ul>
</ul>

<ul id="maxdepth"><b>{Integer}</b> [ <b>MaxDepth</b>  = <code>0</code> ]
  <ul style="padding-left: 24px; margin-top: 0;">The maximum depth <code>StringifyAll</code> will recurse into. The root depth is 1. Note "Depth" and "indent level" do not necessarily line up. At any given point, the indentation level can be as large as 3x the depth level. This is due to how <code>StringifyAll</code> handles map and array items.</ul>
</ul>

<ul id="propstypemap"><b>{Map}</b> [ <b>PropsTypeMap</b>  = <code>{ __Class: "Map", Default: 1, Count: 0 }</code> ]
  <ul style="padding-left: 24px; margin-bottom: 0; margin-top: 0;">
    A <code>Map</code> object where the keys are object types and the values are either:
    <ul style="margin-top: 4px; margin-bottom: 6px;">
      <li><b>Boolean</b>:</li>
      <ul style="margin-bottom: 0; padding-left: 24px;">
        <li><code>true</code>: Directs <code>StringifyAll</code> to process the properties.</li>
        <li><code>false</code>: Directs <code>StringifyAll</code> to skip the properties.</li>
      </ul>
      <li><b>Func</b> or callable <b>Object</b>:
        <br>
        <i>Parameters</i>
        <ol type="1" style="margin-bottom: 0;">
          <li>The <b>Object</b> being evaluated.</li>
        </ol>
        <i>Return</i>
        <ul style="margin-bottom: 0;">
          <li><b>Boolean:</b> Either value described above.</li>
        </ul>
      </li>
    </ul>
  </ul>
  <ul style="padding-left: 24px; margin-bottom: 6px;">The default value is a <code>Map</code> object with <b>0</b> items and a <code>Default</code> property value of <code>1</code>, directing <code>StringifyAll</code> to process the properties of all object types. Keep this in mind when you set <code>PropsTypeMap</code>.
  <ul style="margin-top: 4px; margin-bottom: 6px;">
    <li>If you intend to direct <code>StringifyAll</code> to process object properties by default while using <code>PropsTypeMap</code> to exclude certain object types, you'll need to set the <code>Default</code> value to 1 as well.</li>
    <li>If you want <code>StringifyAll</code> to not process any properties by default, and to use <code>PropsTypeMap</code> to specify which object types should have their properties processed, you can leave the <code>Default</code> property unset, or set it with <code>0</code>.</li>
  </ul>
  <p style="padding-left: 24px;">Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.</ul>
</ul>

<ul id="stopattypemap"><b>{Map}</b> [ <b>StopAtTypeMap</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-bottom: 0; margin-top: 0;">A <code>Map</code> object where the keys are object types and the values are either:</ul>
  <ul style="margin-top: 4px; margin-bottom: 6px; padding-left: 64px;">
    <li><b>Integer</b> or <b>String</b>:</li>
    <ul style="margin-bottom: 0; padding-left: 24px;">
      <li>Both <b>Integer</b> and <b>String</b> are passed to the <code>StopAt</code> parameter of <code>GetPropsInfo</code>.</li>
    </ul>
    <li><b>Func</b> or callable <b>Object</b>:
      <br>
      <i>Parameters</i>
      <ol type="1" style="margin-bottom: 0;">
        <li>The <b>Object</b> being evaluated.</li>
      </ol>
      <i>Return</i>
      <ul style="margin-bottom: 0;">
        <li><b>Integer</b> or <b>String</b>: The value to pass to the <code>StopAt</code> parameter of <code>GetPropsInfo</code>.</li>
      </ol>
    </ul>
  </ul>
  <ul style="padding-left: 24px;">Use the <code>Map</code>'s <code>Default</code> property to set a condition for all types not included within the <code>Map</code>.</ul>
</ul>

### Callbacks

<ul id="callbackerror"><b>{*}</b> [ <b>CallbackError</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">A <b>Func</b> or callable <b>Object</b> that will be called when <code>StringifyAll</code> encounters an error attempting to access a property's value. When <code>CallbackError</code> is set, <code>StringifyAll</code> ignores <code>PrintErrors</code>.</ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Parameters</i>
    <ol type="1" style="margin-top: 4px; margin-bottom: 6px; padding-left: 36px;">
      <li><b>{Object}</b> - The <code>controller</code> object. The <code>controller</code> is an internal mechanism with various callable properties, but the only property of use for this purpose is <code>Path</code>, which has a string value representing the object path up to the object that is currently being evaluated. See the example in section <a href="#callbackplaceholder">CallbackPlaceholder</a>.</li>
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


<ul id="callbackgeneral"><b>{*}</b> [ <b>CallbackGeneral</b>  = <code>""</code> ]
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;">A <b>Func</b> or callable <b>Object</b>, or an array of one or more <b>Func</b> or callable <b>Object</b> values, that will be called for each object prior to processing.</ul>
  <ul style="padding-left: 24px; margin-top: 0; margin-bottom: 0;"><i>Parameters</i>
    <ol type="1" style="margin-top: 4px; margin-bottom: 6px; padding-left: 36px;">
      <li><b>{Object}</b> - The <code>controller</code> object. The <code>controller</code> is an internal mechanism with various callable properties, but the only property of use for this purpose is <code>Path</code>, which has a string value representing the object path up to the object that is currently being evaluated. See the example in section <a href="#callbackplaceholder">CallbackPlaceholder</a>.</li>
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
        <b>{Object}</b> - The <code>controller</code> object. The <code>controller</code> is an internal mechanism with various callable properties, but the only property of use for this purpose is <code>Path</code>, which has a string value representing the object path up to the object that is currently being evaluated. In the below example, if your function is called for a placeholder for the object at <code>obj.nestedObj.doubleNestedObj</code>, the path will be "$.nestedObj.doubleNestedObj".
        <pre>
Obj := {
  nestedObj: {
      doubleNestedObj: {  prop: 'value' }
  }
}</pre>
      </li>
      <li><b>{*}</b> - The object being evaluated.</li>
      <li><b>{VarRef}</b> - An <b>optional</b> <code>VarRef</code> parameter that will receive the name of the property for objects that are encountered while iterating the parent object's properties.</li>
      <li><b>{VarRef}</b> - An <b>optional</b> <code>VarRef</code> parameter that will receive either of:</li>
      <ul style="margin-bottom: 0; padding-left: 24px;">
        <li>The loop index integer value for objects that are encountered while enumerating an object in 1-parameter mode.</li>
        <li>
          The "key" (the value received by the first variable in a for-loop) for objects that are encountered while enumerating an object in 2-parameter mode. The key will already have been escaped and enclosed in double quotes at this point, making it somewhat awkward to work with because escaping it again will re-escape the existing escape sequences. If your function will use the key for some purpose, then you will likely want to do something like the below example.
          <pre>
MyPlaceholderFunc(controller, obj, &prop?, &key?) {
  if IsSet(prop) {
      ; make something
  } else if IsSet(key) {
      if IsNumber(key) {
          ; make something
      } else {
          key := Trim(key, '"')
          if InStr(key, '\') {
              StringifyAll.StrUnescapeJson(&key)
          }
          ; make something
      }
  }
}</pre>
        </li>
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

<ul style="margin-top: 0;">Each of <code>CondenseCharLimit</code>, <code>CondenseCharLimitEnum1</code>, <code>CondenseCharLimitEnum2</code>, and <code>CondenseCharLimitProps</code> set a threshold which <code>StringifyAll</code> will use to condense an object's substring if the length, in characters, of the substring is less than or equal to the value. The substring length is measured beginning from the open brace and excludes external whitespace such as newline characters and indentation that are not part of a string literal value.</ul>

<ul id="condensecharlimit" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimit</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to all substrings. If <code>CondenseCharLimit</code> is set, you can still specify individual options for the other three and the individual option will take precedence over <code>CondenseCharLimit</code>.</ul>
</ul>

<ul id="condensecharlimitenum1" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitEnum1</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by calling an object's enumerator in 1-param mode.</ul>
</ul>

<ul id="condensecharlimitenum2" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitEnum2</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by calling an object's enumerator in 2-param mode.</ul>
</ul>

<ul id="condensecharlimitprops" style="margin-top: 0; margin-bottom: 0;"><b>{Integer}</b> [ <b>CondenseCharLimitProps</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Applies to substrings that are created by processing an object's properties.</ul>
</ul>

<ul id="indent"><b>{String}</b> [ <b>Indent</b>  = <code>"`s`s`s`s"</code> ]
  <ul style="padding-left:24px;">The literal string that will be used for one level of indentation.</ul>
</ul>

<ul id="newline"><b>{String}</b> [ <b>Newline</b>  = <code>"`r`n"</code> ]
  <ul style="padding-left:24px;">The literal string that will be used for line breaks. If set to zero or an empty string, the <code>Singleline</code> option is effectively enabled.</ul>
</ul>

<ul id="newlinedepthlimit"><b>{Integer}</b> [ <b>NewlineDepthLimit</b>  = <code>0</code> ]
  <ul style="padding-left:24px;">Sets a threshold directing <code>StringifyAll</code> to stop adding line breaks between values after exceeding the threshold.</ul>
</ul>

<ul id="singleline"><b>{Boolean}</b> [ <b>Singleline</b>  = <code>false</code> ]
  <ul style="padding-left:24px;">If true, the JSON string is printed without line breaks or indentation. All other "Newline and indent options" are ignored.</ul>
</ul>

### Print options

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
  <ul style="padding-left:24px;">Prior to recursively stringifying a nested object, <code>StringifyAll</code> checks if the object has already been processed. (This is to prevent infinite recursion, and more flexible processing will be implemented). If an object has already been processed, a placeholder is printed in its place. The placeholder printed as a result of this condition is different than placeholders printed for other reasons. In this case, the placeholder is a string representation of the object path at which the object was first encountered. This is so one's self, or one's code, can locate the object in the JSON string if needed. <code>RootName</code> specifies the name of the root object used within any occurrences of this placeholder string.</ul>
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

## StringifyAll's process

This section describes `StringifyAll`'s process. This section is intended to help you better understand how the options will impact the output string. This section is not complete.

### Properties

For every object, prior to adding the object's open brace to the string, `StringifyAll` proceeds through these steps:

  - If `Options.PropsTypeMap.HasOwnProp('Default')` then this code is used:

```
if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
    return Item(Obj)
} else {
    return Item
}
```

  - Else, this code is used:

```
if propsTypeMap.Has(Type(Obj)) {
    if IsObject(Item := propsTypeMap.Get(Type(Obj))) {
        return Item(Obj)
    } else {
        return Item
    }
}
```
  - If the return value is nonzero:

    - `StringifyAll` calls `PropsInfoObj := GetPropsInfo(Obj, StopAt, excludeProps, false, , excludeMethods)`.
    - If `PropsInfoObj.Count > 0`, `StringifyAll` processes only the properties exposed by `PropsInfoObj`. You can control this with two options.

      - `Options.ExcludeProps` is effective and straightforward. Write a comma-delimited string of property names to exclude. This would apply to all objects.
      - `Options.FilterTypeMap` affords greater flexibility. `PropsInfo` objects are designed with a filter system to make it easy to programmatically include a set of properties, and exclude the other, from whatever one's code is doing with the `PropsInfo` object. See "example\example.ahk" and/or "inheritance\example-Inheritance.ahk" for examples.

    - Else, `StringifyAll` skips the properties for that object and goes on to check if the enumerator will be called.

  - If the return value is falsy, `StringifyAll` skips the properties for that object and goes on to check if the enumerator will be called.

This will come into play if you want an `Array` or `Map` object's string representation to have the appearance of what we typically expect for arrays and maps. To accomplish this, `StringifyAll` must not process any properties for those objects. You can accomplish this by simply defining two items in the map: `Options.PropsTypeMap := Map("Array", 0, "Map", 0)`. Don't forget to set `Options.PropsTypeMap.Default := 1` if you still want other objects to have their properties processed.

### CallbackGeneral

The following is a description of the part of the process which the function(s) are called.
<ul style="padding-left:24px;">
  <code>StringifyAll</code> proceeds in two stages, initialization and recursive processing. After initialization, the function <code>Recurse</code> is called once, which starts the second stage.
  <br>When <code>StringifyAll</code> encounters a value that is an object, it proceeds through a series of condition checks to determine if it will call <code>Recurse</code> again for that value. When a value is skipped, a placeholder is printed instead.<code>StringifyAll</code> checks the following conditions.
  <ul style="padding-left:48px;">
    <li>If the value is a <code>ComObject</code> or <code>ComValue</code>, the value is skipped.</li>
    <li>If the value has already been stringified, the value is skipped. This is intended to prevent infinite recursion, but currently causes <code>StringifyAll</code> to skip all subsequent encounters of an object after the first, not just problematic ones. I will implement a more flexible solution.</li>
    <li>If <code>MaxDepth</code> has been reached, the value is skipped.</li>
  </ul>
  If none of the above conditions cause <code>StringifyAll</code> to skip the object, <code>StringifyAll</code> then calls the <code>CallbackGeneral</code> function(s).
  <br>If none of the <code>CallbackGeneral</code> functions direct <code>StringifyAll</code> to skip the object, <code>Recurse</code> is called.
</ul>

### Calling the enumerator

One of the first actions within `Recurse` is `flag_enum := CheckEnum(Obj)`. `CheckEnum` is one of the following:

If `Options.EnumTypeMap.HasOwnProp('Default')`:
```ahk
if IsObject(Item := enumTypeMap.Get(Type(Obj))) {
    return Item(Obj)
} else {
    return Item
}
```
If `!Options.EnumTypeMap.HasOwnprop('Default')`:
```ahk
if enumTypeMap.Has(Type(Obj)) {
    if IsObject(Item := enumTypeMap.Get(Type(Obj))) {
        return Item(Obj)
    } else {
        return Item
    }
}
```
The return value should be 1, 2, or 0. `StringifyAll` then processes the properties as described above. `StringifyAll`'s behavior when calling the enumerator varies slightly depending on whether any properties were processed for the object.

If `StringifyAll` processed properties, and if `flag_enum` is `1` or `2`, `StringifyAll` adds the comma, newline, indentation, open quote, <a href="#itemprop">Options.ItemProp</a>, close quote, colon, space, and open square bracket to the output string. `OutStr .= ',' nl() ind() '"' itemProp '": ['`. (This is actually split into two function calls so the code looks different in the source file).

If `StringifyAll` did not process properties for the object, and if `flag_enum` is `1` or `2`, `StringifyAll` adds the open brace to the output string: `OutStr .= '['`

After handling the open bracket:
<ol type="1">
  <li><code>StringifyAll</code> increases the indent level by 1.</li>
  <li>If <code>Options.CondenseCharLimit</code> or the individual <code>Options.CondenseCharLimitEnum1</code> / <code>Options.CondenseCharLimitEnum2</code> are set, caches some values needed later to handle that option.</li>
  <li>Initializes a variable <code>count := 0</code>.</li>
  <li>Calls the enumerator, incrementing <code>count</code> for each item. How the output string is constructed varies if <code>flag_enum == 1</code> and <code>flag_enum == 2</code>, but the processing logic is the same. The main difference between the two, of course, is that there are two values to handle when calling the enumerator in 2-param mode. The following only applies when calling an enumerator in 2-param mode:</li>
  <ol type="i">
    <li>Prior to processing the value that is received by the second parameter, <code>StringifyAll</code> first processes the first parameter (<code>Key</code>):</li>
    <li>If <code>IsObject(Key)</code>: <code>StringifyAll</code> will not process an object that is received by the first parameter. Instead, it creates a placeholder string to use as the key: <code>Key := '"{ ' this.GetType(Key) ':' ObjPtr(Key) ' }"'</code>.</li>
    <li>If <code>!IsObject(Key)</code></li>
    <ul>
      <li><code>StringifyAll</code> processes the <code>Key</code> for escape sequences</li>
      <li>If <code>Options.QuoteNumericKeys</code> and <code>IsNumber(Key)</code>, or if <code>!IsNumber(Key)</code>, encloses it in double-quotes.</li>
    </ul>
  </ol>
</ol>
Then, the value is processed:
<ol start="5">
  <li>If <code>IsObject(Val)</code></li>
  <ul>
    <li>If the object has been processed before</li>
    <ul>
      <li>If <code>Options.Multiple</code></li>
      <ul>
        <li>Checks if the new object shares a parent-child relationship with the current object using <code>InStr('$.' controller.Path, '$.' ptrList.Get(ObjPtr(Val)).Path)</code>. This is comparing the string representation of the object path for the two objects. The leading "$." is just to ensure the two strings must match at the beginning of the string. Using this approach should be slightly more performant than <code>RegExMatch</code>, which matters when processing thousands of iterations. The reason this is an effective way to determine parent-child relationship is because, if they are parent-child, they will always share the same path up to the parent.</li>
        <ul>
          <li>If they are parent-child, skips the object printing the path instead.</li>
          <li>If not, proceeds to the next step.</li>
        </ul>
        <li>If <code>!Options.Multiple</code>, prints the placeholder and skips the object.</li>
      </ul>
    </ul>
    <li>If <code>depth >= maxDepth || Val is ComObject || Val is ComValue </code>, prints a placeholder string and skips the object.</li>
    <li>If <code>Options.CallbackGeneral</code>, iterates the callbacks. Processing behavior is described in the <a href="#callbackgeneral">CallbackGeneral</a> section.</li>
    <li>If <code>!Options.CallbackGeneral</code> or none of the callbacks directed <code>StringifyAll</code> to skip the object, <code>StringifyAll</code> proceeds through some initialization steps then calls <code>Recurse</code> with the object.</li>
    </ul>
  </ul>
  <li>If <code>!IsObject(Val)</code>, processes the value for escape sequences and encloses it in double quotes, then writes it to the output string.</li>
</ol>
After processing the enumerator, if <code>count == 0</code>, adds the closing bracket(s) to the output string. If <code>count > 0</code>, adds a newline, indentation, and the closing bracket to the output string.

## Changelog

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
