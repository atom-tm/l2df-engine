# Syntax

See @{l2df.class.parser.lffs|LFFParser}.

## Frame example

<pre class="dc-code">
&lt;frame&gt; 1 test
  pic: 10 wait: 5 next: 999
  state: 4050 hit_a: 330 mp: 55
&lt;/frame&gt;
</pre>


## Scene example

<pre class="dc-code">
&lt;scene&gt;
	@plain
	&lt;image&gt;
		sprites: { res: "resources/sprites/UI/CS0.png" w: 1280 h: 720 }
		scaleX: 0.5 scaleY: 0.5
	&lt;/image&gt;
	&lt;object&gt;
		body: { x: 0 y: 0 z: 0 w: 1024 h: 32 l: 1024 }
		static: true
	&lt;/object&gt;
	&lt;object&gt;
		body: { x: 0 y: -1024 z: 0 w: 1024 h: 1184 l: 170 }
		static: true
	&lt;/object&gt;<br/>&lt;/scene&gt;</pre>


## Dat files

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