# Itrs, bodies and kinds

## Body

**Body** is a block responsible for "body" collider of the object. In other words it makes the object to have a physical
body which can interact with other bodies in the game world. Except that it can also interact with "itrs" -
special type of colliders also known as "triggers". <br />
Currently we support only one body per object's frame.

## Itr

**Itr** is a block which defines triggers on the object. Each itr can trigger specific event / script called "kind". <br />
Each object's frame can have multiple itrs - leads to very funny use-cases.

*Most often, the "body" block is used in conjunction with the "itr" block of an enemy object to switch the owner to damage frames*


## Kinds

This section has not finished yet.


## Blocks syntax and description

<table class="info-table">
<tr>
<th colspan="2">body:</th>
</tr>

<tr>
<td colspan="2" class="block-descr">Блок задаёт координаты и размеры хитбокса, ответственного за "тело" персонажа, с которым будут взаимодейстовать хитбоксы itr</td>
</tr>

<tr>
<td class="state-num">kind</td>
<td class="state-desc">Тип</td>
</tr>
<tr>
<td class="state-num">x</td>
<td class="state-desc">Точка отсчета по координате x</td>
</tr>
<tr>
<td class="state-num">y</td>
<td class="state-desc">Точка отсчета по координате y</td>
</tr>
<tr>
<td class="state-num">w</td>
<td class="state-desc">Ширина хитбокса</td>
</tr>
<tr>
<td class="state-num">h</td>
<td class="state-desc">Высота хитбокса</td>
</tr>
<tr>
<td colspan="2"  class="state-desc">
<pre class="dc-code">
body: { kind: 0  x: 0  y: 0  w: 1  h: 1 }
</pre>
</td>
</tr>
</table>

<table class="info-table">
<tr>
<th colspan="2">itr:</th>
</tr>
<tr>
<td colspan="2" class="block-descr">Блок задаёт координаты и размеры хитбокса, ответственного за "взаимодействие" персонажа (чаще всего за удар). Данный хитбокс будет взаимодействовать с хитбоксами типа bdy при столкновении</td>
</tr>
<tr>
<td class="state-num">kind</td>
<td class="state-desc">Тип (<a href="">список</a>)</td>
</tr>
<tr>
<td class="state-num">x</td>
<td class="state-desc">Точка отсчета по оси x</td>
</tr>
<tr>
<td class="state-num">y</td>
<td class="state-desc">Точка отсчета по оси y</td>
</tr>
<tr>
<td class="state-num">z</td>
<td class="state-desc">
<div class="engine">PDK</div> Смещение хитбокса по оси z (значения больше нуля - вниз, меньше - назад)
</td>
</tr>
<tr>
<td class="state-num">w</td>
<td class="state-desc">Ширина хитбокса</td>
</tr>
<tr>
<td class="state-num">h</td>
<td class="state-desc">Высота хитбокса</td>
</tr>
<tr>
<td class="state-num">zwidth</td>
<td class="state-desc">Ширина хитбокса по оси z</td>
</tr>
<tr>
<td class="state-num">dvx</td>
<td class="state-desc">Придание атакуемому ускорения по оси x</td>
</tr>
<tr>
<td class="state-num">dvy</td>
<td class="state-desc">Придание атакуемому ускорения по оси y</td>
</tr>
<tr>
<td class="state-num">dvz</td>
<td class="state-desc">Придание атакуемому ускорения по оси z</td>
</tr>
<tr>
<td class="state-num">h</td>
<td class="state-desc">Высота хитбокса</td>
</tr>
</table>