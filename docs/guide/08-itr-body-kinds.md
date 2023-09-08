# Collision detection (kinds)

To enable collisions on objects they should have @{l2df.class.component.collision|Collision} component added. <br />
This component looks for colliders (hitboxes) in @{l2df.class.entity.data|entity's data} and adds them for collision processing.
Collisions detection is handled by @{l2df.manager.physix|Physics} manager during each `update` stage.

By default there are 2 types of colliders available: bodies and its.


## Body

**Body** is a block responsible for "body" collider of the object. In other words it makes the object to have a physical
body which can interact with other bodies in the game world. Except that it can also interact with "itrs" -
special type of colliders also known as "triggers". <br />
Each object's frame can have multiple bodies.


## Itr

**Itr** is a block which defines triggers on the object. Each itr can trigger specific event / script called "kind". <br />
Each object's frame can have multiple itrs.

*Most often, the "body" block is used in conjunction with the "itr" block of an enemy object to switch the owner to damage frames*


## Kinds

This section has not finished yet.


#### Attacks and damage types

```
|- Normal hit -
|-> forward

|- Strong hit -
|-> forward
|-> up
|-> down
```


## Blocks syntax and description

<table class="info-table">
<tr>
<th colspan="2">&lt;body&gt;</th>
</tr>

<tr>
<td colspan="2" class="block-descr">Block sets position and size of the hitbox responsible for character's "body". This one interacts with `&lt;itr&gt;` during collision.</td>
</tr>

<tr>
<td class="state-num">kind</td>
<td class="state-desc">Trigger name (list)</td>
</tr>
<tr>
<td class="state-num">x</td>
<td class="state-desc">X axis offset of the hitbox relative to object's X position</td>
</tr>
<tr>
<td class="state-num">y</td>
<td class="state-desc">Y axis offset of the hitbox relative to object's Y position</td>
</tr>
<tr>
<td class="state-num">z</td>
<td class="state-desc">Z axis offset of the hitbox relative to object's Z position</td>
</tr>
<tr>
<td class="state-num">w</td>
<td class="state-desc">Width of the hitbox</td>
</tr>
<tr>
<td class="state-num">h</td>
<td class="state-desc">Height of the hitbox</td>
</tr>
<tr>
<td colspan="2"  class="state-desc">
<pre class="lffs">
&lt;body&gt; kind: 0  x: 0  y: 0  w: 1  h: 1 &lt;/body&gt;
</pre>
</td>
</tr>
</table>

<table class="info-table">
<tr>
<th colspan="2">&lt;itr&gt;</th>
</tr>
<tr>
<td colspan="2" class="block-descr">Block sets position and size of the hitbox responsible for character's "interaction". Most of time it will be used for attacks. This one interacts with `&lt;body&gt;` during collision.</td>
</tr>
<tr>
<td class="state-num">kind</td>
<td class="state-desc">Trigger name (list)</td>
</tr>
<tr>
<td class="state-num">x</td>
<td class="state-desc">X axis offset of the hitbox relative to object's X position</td>
</tr>
<tr>
<td class="state-num">y</td>
<td class="state-desc">Y axis offset of the hitbox relative to object's Y position</td>
</tr>
<tr>
<td class="state-num">z</td>
<td class="state-desc">Z axis offset of the hitbox relative to object's Z position</td>
</tr>
<tr>
<td class="state-num">w</td>
<td class="state-desc">Width of the hitbox</td>
</tr>
<tr>
<td class="state-num">h</td>
<td class="state-desc">Height of the hitbox</td>
</tr>
<tr>
<td class="state-num">dvx</td>
<td class="state-desc">Instant object acceleration along X axis</td>
</tr>
<tr>
<td class="state-num">dvy</td>
<td class="state-desc">Instant object acceleration along Y axis</td>
</tr>
<tr>
<td class="state-num">dvz</td>
<td class="state-desc">Instant object acceleration along Z axis</td>
</tr>
<td colspan="2"  class="state-desc">
<pre class="lffs">
&lt;itr&gt; kind: 0  x: 0  y: 0  w: 1  h: 1 &lt;/itr&gt;
</pre>
</td>
</table>