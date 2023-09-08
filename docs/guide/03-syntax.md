# Data syntax

L2DF uses its own XML-like syntax named LFFS. The reasons for that are:
1. It's more flexible for our needs and has some specific features for ease-of-use.
2. DC-code familar coders may find it really powerful and can dive into it really fast.
3. It is easy to extend.

See @{l2df.class.parser.lffs2|LffsParser} for advanced use.


## Syntax definition

In general the whole LFFS-file consists of two types of blocks and properties.
Also there are support for one-line comments via `#` symbol at the beginning.

#### Object block

<pre class="lffs">
[name:type] argument1 argument2 argument3 # there are can be any number of arguments
  # there are goes other properties and blocks
[/name:type] # name:type in the closing tag is optional
</pre>

- `name` is any string consisting of latin characters, `_` underscore and numbers without whitespaces;
- `type` is optional and is used to determine factory-specific type for @{l2df.manager.factory.create|object creation} from this data code.
- `argumentN` can be string, number or float. These arguments will be added in array-space of the created object (Lua @{table}).

This block will create new object block inside parent block at specified by `name` key.

#### Array block

<pre class="lffs">
&lt;name:type&gt; argument1 argument2 argument3 # there are can be any number of arguments
  # there are goes other properties and blocks
&lt;/name:type&gt; # name:type in the closing tag is optional
</pre>

`name`, `type` and arguments are same as in object block.
The difference between this and object blocks is that this will create an array of objects inside parent block at
pluralized (!) by `name` key. By pluralization we mean this type of convertion:

- `tiger` &xrarr; `tigers`
- `class` &xrarr; `classes`

So all array blocks with the same `name` are combined together in one array at parent's object inside pluralized `name` key!

#### Properties

<pre class="lffs">
property_name: string
also_string_property: "in quotes to support whitespaces"
number: 1000
float: 9.8
array_of_numbers: 1 2 3 4 # will create an array of 4 number elements
mixed_types_array: string1 108.002 "quoted string" # array of 3 elements with mixed types

[car]
	@plain
	manufacturer: "Nissan" mileage: 822
	speed: 53.5 # m / h
[/car]
</pre>

Properties could be either inside or outside blocks.

Just to clarify the understanding the whole content of the LFFS file are one anonymous object block.
So if you're writing property outside any block you may think of it as writing in global anonymous block.


## LF2 data code comparison

#### Characters

1. `bmp_begin / bmp_end` tags were removed (but their content is still remain)
2. All data-keys from `bmp_begin / bmp_end` without ":" symbol should now have it
3. \*.bmp files should be replaced with \*.png
4. It is better to start frames from 1, not 0
5. `file(0-100):` &xrarr; &lt;sprite&gt;
6. Inside file property `row` &xrarr; x
7. Inside file property `col` &xrarr; y
8. &lt;frame_end&gt; &xrarr; &lt;/frame&gt;
9. &lt;frame&gt; 1 `-->` **name** `<--` should be empty for non-cycling animations except the first one frame use them correctly for name-based animation indexing
10. Inside frame `wpoint:` &xrarr; &lt;wpoint&gt;
11. Inside frame `bdy:` &xrarr; &lt;body&gt;
12. Inside frame `itr:` &xrarr; &lt;itr&gt;
13. Inside frame `state:` X &xrarr; &lt;state&gt; X &lt;/state&gt;
14. Inside frame `cpoint:` &xrarr; &lt;cpoint&gt;
15. Backslash '\' should be replaced with forward slash '/' for all path-containing properties


## Frame example

<pre class="lffs">
&lt;frame&gt; 1 test
  pic: 10 wait: 5 next: 999 hit_a: 330 mp: 55
  &lt;state&gt; 4050 &lt;/state&gt;
&lt;/frame&gt;
</pre>


## Scene example

<pre class="lffs">
&lt;node:scene&gt;
	@plain
	&lt;node:image&gt;
		&lt;sprite&gt; "resources/sprites/UI/CS0.png" w: 1280 h: 720 &lt;/sprite&gt;
		scaleX: 0.5 scaleY: 0.5
	&lt;/node:image&gt;
	&lt;node:object&gt;
		&lt;body&gt; x: 0 y: 0 z: 0 w: 1024 h: 32 l: 1024 &lt;/body&gt;
		static: true
	&lt;/node:object&gt;
	&lt;node:object&gt;
		&lt;body&gt; x: 0 y: -1024 z: 0 w: 1024 h: 1184 l: 170 &lt;/body&gt;
		static: true
	&lt;/node:object&gt;
&lt;/node:scene&gt;
</pre>


## Dat files <span class="label">deprecated</span>

See @{l2df.class.parser.dat|DatParser}.


```
[section1]
parameter1: value
parameter2: { value1, value2, value3 }
object: [
    parameter1: value
    parameter2: { value1, value2 }
    object: [
        parameter1: value
    ]
]
```


## Write your own parser

See @{l2df.class.parser|BasicParser}.