# Game logic (states)

## States

...


## Basic states

#### Shortcut description

<div class="text-block">
<table class="state-control" style="display: inline-block;">
<tr><td class="state-control-desc state-num">Key</td><td class="state-control-desc" style="text-align: left;">Action</td></tr>
<tr><td class="state-num"><b>A</b></td><td style="text-align: left;">Press key "Attack"</td></tr>
<tr><td class="state-num"><b>J</b></td><td style="text-align: left;">Press key "Jump"</td></tr>
<tr><td class="state-num"><b>D</b></td><td style="text-align: left;">Press key "Defence"</td></tr>
<tr><td class="state-num"><b>S</b></td><td style="text-align: left;">Press key "Special"</td></tr>
<tr><td class="state-num"><b>↑</b></td><td style="text-align: left;">Press key "Up"</td></tr>
<tr><td class="state-num"><b>↓</b></td><td style="text-align: left;">Press key "Down"</td></tr>
<tr><td class="state-num"><b>←</b></td><td style="text-align: left;">Press key "Back"</td></tr>
<tr><td class="state-num"><b>→</b></td><td style="text-align: left;">Press key "Forward"</td></tr>
<tr><td class="state-num"><b>⇄</b></td><td style="text-align: left;">Press key "Left" or "Right"</td></tr>
<tr><td class="state-num"><b>✶</b></td><td style="text-align: left;">Press key "Left", "Right", "Up" or "Down"</td></tr>
</table>
<table class="state-control" style="display: inline-block;">
<tr><td class="state-control-desc state-num">Key</td><td class="state-control-desc" style="text-align: left;">Action</td></tr>
<tr><td class="state-num"><b>A+</b></td><td style="text-align: left;">Double key press "Attack"</td></tr>
<tr><td class="state-num"><b>J+</b></td><td style="text-align: left;">Double key press "Jump"</td></tr>
<tr><td class="state-num"><b>D+</b></td><td style="text-align: left;">Double key press "Defence"</td></tr>
<tr><td class="state-num"><b>S+</b></td><td style="text-align: left;">Double key press "Special"</td></tr>
<tr><td class="state-num"><b>↑+</b></td><td style="text-align: left;">Double key press "Up"</td></tr>
<tr><td class="state-num"><b>↓+</b></td><td style="text-align: left;">Double key press "Down"</td></tr>
<tr><td class="state-num"><b>←+</b></td><td style="text-align: left;">Double key press "Back"</td></tr>
<tr><td class="state-num"><b>→+</b></td><td style="text-align: left;">Double key press "Forward"</td></tr>
<tr><td class="state-num"><b>⇄+</b></td><td style="text-align: left;">Double key press "Left" or "Right"</td></tr>
<tr><td class="state-num"><b>✶+</b></td><td style="text-align: left;">Double key press "Left", "Right", "Up" or "Down"</td></tr>
</table>
<table class="state-control" style="display: inline-block;">
<tr><td class="state-control-desc state-num">Key</td><td class="state-control-desc" style="text-align: left;">Action</td></tr>
<tr><td class="state-num"><b>A*</b></td><td style="text-align: left;">Hold key "Attack"</td></tr>
<tr><td class="state-num"><b>J*</b></td><td style="text-align: left;">Hold key "Jump"</td></tr>
<tr><td class="state-num"><b>D*</b></td><td style="text-align: left;">Hold key "Defence"</td></tr>
<tr><td class="state-num"><b>S*</b></td><td style="text-align: left;">Hold key "Special"</td></tr>
<tr><td class="state-num"><b>↑*</b></td><td style="text-align: left;">Hold key "Up"</td></tr>
<tr><td class="state-num"><b>↓*</b></td><td style="text-align: left;">Hold key "Down"</td></tr>
<tr><td class="state-num"><b>←*</b></td><td style="text-align: left;">Hold key "Back"</td></tr>
<tr><td class="state-num"><b>→*</b></td><td style="text-align: left;">Hold key "Forward"</td></tr>
<tr><td class="state-num"><b>⇄*</b></td><td style="text-align: left;">Hold key "Left" or "Right"</td></tr>
<tr><td class="state-num"><b>✶*</b></td><td style="text-align: left;">Hold key "Left", "Right", "Up" or "Down"</td></tr>
</table>
</div>

<table class="info-table">
<tr>
<th colspan="2">@{02-presets.md.LF__preset|LF2 preset}</th>
</tr>
<tr><td class="info-table-desc">ID</td><td class="info-table-desc">Description</td></tr>
<tr>
<td class="state-num">0</td>
<td class="state-desc">
<b>Standing</b><br>
Idle character animation. Awaiting for player action.
<table class="state-control">
<tr>
<td class="state-control-desc">Key</td>
<td class="state-control-desc">Transition</td>
</tr>
<tr>
<td><b>✶*</b></td>
<td>Walking</td>
</tr>
<tr>
<td><b>⇄+</b></td>
<td>Running</td>
</tr>
<tr>
<td><b>A</b></td>
<td>Battle stance</td>
</tr>
<tr>
<td><b>J</b></td>
<td>Jump</td>
</tr>
<tr>
<td><b>D</b></td>
<td>Defence</td>
</tr>
</table>
При длительном нахождении в состоянии покоя, персонаж переходит в кадры "анимации".
</td>
</tr>
<tr>
<td class="state-num">1</td>
<td class="state-desc">
<b>Walking</b><br>
Персонаж передвигается, последовательно изменяя спрайт ходьбы, согласно установленному счетчику. 
<table class="state-control">
<tr>
<td class="state-control-desc">Key</td>
<td class="state-control-desc">Transition</td>
</tr>
<tr>
<td><b>✶*</b></td>
<td>Выбор направления ходьбы</td>
</tr>
<tr>
<td><b>⇄+</b></td>
<td>Бег</td>
</tr>
<tr>
<td><b>A</b></td>
<td>Боевая стойка</td>
</tr>
<tr>
<td><b>J</b></td>
<td>Подготовка к прыжку</td>
</tr>
<tr>
<td><b>D</b></td>
<td>Защитная стойка</td>
</tr>
</table>
</td>
</tr>
<tr>
<td class="state-num">2</td>
<td class="state-desc">
<b>Running</b><br>
Персонаж передвигается бегом, последовательно изменяя спрайт бега, согласно установленному счетчику. При окончании удержания клавиш "продолжения бега" персонаж переходит в кадры "остановки бега".
<table class="state-control">
<tr>
<td class="state-control-desc">Key</td>
<td class="state-control-desc">Transition</td>
</tr>
<tr>
<td><b>⇄*</b></td>
<td>Продолжение бега</td>
</tr>
<tr>
<td><b>A</b></td>
<td>Сильная атака</td>
</tr>
<tr>
<td><b>J</b></td>
<td>Jump вперед</td>
</tr>
<tr>
<td><b>D</b></td>
<td>Рывок вперед</td>
</tr>
</table>
Если скорость бега превышает 25, при начале бега появляется визуальный эффект "speedup".
</td>
</tr>
<tr>
<td class="state-num">3</td>
<td class="state-desc">
<b>Подготовка к прыжку</b><br>
Персонаж приседает и готовится к прыжку.
<table class="state-control">
<tr>
<td class="state-control-desc">Key</td>
<td class="state-control-desc">Transition</td>
</tr>
<tr>
<td><b>→*</b></td>
<td>Jump вперед</td>
</tr>
<tr>
<td><b>←*</b></td>
<td>Jump назад</td>
</tr>
<tr>
<td><b>S</b></td>
<td>Рывок вверх</td>
</tr>
<tr>
<td><b>S→*</b></td>
<td>Рывок вверх и вперед</td>
</tr>
<tr>
<td><b>S←*</b></td>
<td>Рывок вверх и назад</td>
</tr>
</table>
Если клавиши не нажимаются и не удерживаются, просиходит обычный "прыжок" вверх.
</td>
</tr>
<tr>
<td class="state-num">4</td>
<td class="state-desc">
<b>Jump</b><br>
Персонаж приобретает положительную скорость, которая указывается в стейте переменными dvx,dvy,dvz и движется вверх, постепенно скорость уменьшается. При достижении нулевой скорости, персонаж переходит в кадры "стойки в воздухе" и начинает падение.<br>
Если стартовая скорость выше определенного значения, вызывается эффект "jerk_up".
</td>
</tr>
<tr>
<td class="state-num">5</td>
<td class="state-desc">
<b>Стойка в воздухе</b><br>
Персонаж находится в воздухе в состоянии свободного падения. При достижении земли, переходит в кадры "приземления", обнуляя скорость по оси Y.
<table class="state-control">
<tr>
<td class="state-control-desc">Key</td>
<td class="state-control-desc">Transition</td>
</tr>
<tr>
<td><b>A</b></td>
<td>Attack в воздухе</td>
</tr>
<tr>
<td><b>S↓*</b></td>
<td>Рывок вниз</td>
</tr>
</table>
</td>
</tr>
<tr>
<td class="state-num">6</td>
<td class="state-desc">
<b>Landing</b><br>
Персонаж находится в состоянии отката после прыжка.
<table class="state-control">
<tr>
<td class="state-control-desc">Key</td>
<td class="state-control-desc">Transition</td>
</tr>
<tr>
<td><b>S→*</b></td>
<td>Рывок вперед</td>
</tr>
<tr>
<td><b>S←*</b></td>
<td>Рывок назад</td>
</tr>
<tr>
<td><b>A</b></td>
<td>Сильная атака</td>
</tr>
</table>
</td>
</tr>
<tr>
<tr>
<td class="state-num">0</td>
<td class="state-desc">
<b>Standing</b>
<br> При нажатии клавиш направления переходит в кадры ходьбы.
<br> При двойном нажатии клавиш вправо \ влево переходит в кадры бега.
<br> При нажатии атаки переходит в кадр 60 or 65 (выбирается случайно).
<br> При нажатии прыжка переходит в кадр 210.
<br> При нажатии блока переходит в кадр 110.
<br> Если находится в воздухе, переходит в кадр 212.
</td>
</tr>
<tr>
<td class="state-num">1</td>
<td class="state-desc">

<b>Walking</b>
<br> При удержании клавиш направления персонаж движется, циклично повторяя кадры, отведённые под ходьбу.
<br> Если клавиши направления отпущены, персонаж переходит в кадр 0.
<br> Переходы по нажатию атаки \ прыжка \ блока, аналогично стойке.
</td>
</tr>
<tr>
<td class="state-num">2</td>
<td class="state-desc">
<b>Running</b>
<br> Цикличное проигрывание кадров бега.
<br> При нажатии клавиши, противоположной направлению бега происходит переход в кадр 218.
<br> Возможность перемежения по оси Z клавишами вверх \ вниз.
<br> При нажатии удара переходит в кадр 85.
<br> При нажатии прыжка переходит в кадр 213 or 216 (выбирается клавишами влево \ вправо).
<br> При нажатии блока переходит в кадр 102.
</td>
</tr>
<tr>
<td class="state-num">3</td>
<td class="state-desc">Эффект</td>
</tr>
</table>

<table class="info-table">
<tr>
<th colspan="2">PDK</th>
</tr>
<tr>
<td class="state-num">20 | 21</td>
<td class="state-desc">

<b>Невидимость</b>
Стейты делают персонажа невидимым на время равное wait. 
В стадиях персонаж становится полупрозначным. 
<br>
<br>state: 20 - учитывает клонов
<br>state: 21 - не учитывает клонов
<br><br>Нельзя использовать next 999, иначе будет эффект next 1000
</td>
</tr>
<tr>
<td class="state-num">4xxx</td>
<td class="state-desc">

<b>Удержание клавиш</b>
<br>
Удерживаемая клавиша указывается с помощью: hit_a: yyy, hit_j: yyy or hit_d: yyy
<br><br>
ххx - время в wait перед переходом
<br>yyy - кадр, куда будет совершен переход
<br>zzz - число маны
<br><br>
Если удержание отпущено раньше времени - происходит переход в кадр указанный в next  
<br>Если есть указанное число маны в "mp:", то переход будет произведен мгновенно.
<pre class="dc-code">
/*При удержании атаки и достаточном количестве маны будет совершён мгновенный переход в 330 кадр. Если атака не удерживается, переход будет совершён в next.
<frame> 300 
pic: 10 wait: 5 next: 999 state: 4050 hit_a: 330 mp: 55
<frame_end>
</pre>
</td>
</tr>
<tr>
<td class="state-num">6xxx</td>
<td class="state-desc">
<b>Удержание клавиш</b>
<br>
Удерживаемая клавиша указывается с помощью: hit_a: yyy, hit_j: yyy or hit_d: yyy
<br>
<br>
ххx - время в wait перед переходом
<br>yyy - кадр, куда будет совершен переход
<br><br>
Если удержание отпущено раньше времени - происходит переход в кадр указанный в next
<pre class="dc-code">
/*При удержании атаки будет совершён переход в 110 кадр. Если атака не удерживается, переход будет совершён в next.
<frame> 100 
pic: 25 state: 6090 hit_a: 110 wait: 5 next: 101 
<frame_end>
</pre>
</td>
</tr>
<tr>
<td class="state-num">5xxyy</td>
<td class="state-desc">

<b>Создание эффекта землетрясения.</b>
<br>
<br>хх - отклонения фонового уровня по координате Х 
<br>уу - отклонения фонового уровня по координате У
<br>state: 55050 - сбрасывает все отклонения 
<br>
<br>Число 50 следует считать как 0, в то время как значения от 0 до 49 - это отклонения в минус, а от 51 до 99 - в плюс (аналогичный метод используется в перемещении снарядов по оси Z через hit_j: в оригинальном LF2, например в снарядах Davis).
</td>
</tr>
<tr>
<td class="state-num">10000<br><=><br>29999</td>
<td class="state-desc"><b>Работа со слоями</b><br> 
Чем выше значение - тем первее план у объекта.</td>
</tr>
<tr>
<td class="state-num">1xxxyyy</td>
<td class="state-desc">

<b>Условный переход</b> при определенном количестве здоровья
<br>
<br>xxx - требуемый для перехода порог здровья 
<br>yyy - кадр, куда персонаж попадает, если условие <u>не выполняется</u> 
<br>если условие выполняется, персонаж переходит в next
</td>
</tr>
</table>

<table class="info-table">
<tr>
<th colspan="2">Neora</th>
</tr>
<tr>
<td class="state-num">30 | 31</td>
<td class="state-desc">
<b>Поворот</b>
<br>Управление направлением взгляда объекта.
<br>
<br>state: 30 - объект разворачивается строго влево
<br>state: 31 - объект разворачивается строго вправо
</td>
</tr>
<tr>
<td class="state-num">9ххх</td>
<td class="state-desc">
<b>Условный переход</b>
При срабатывании атакующего itr на цель, атакующий персонаж or объект совершит переход в кадр xxx, где xxx может быть от 0 до 799 (значение не больше лимита кадров).
</td>
</tr>
<tr>
<td class="state-num">2xxxyyy</td>
<td class="state-desc">
<b>Проверка на ману</b>
<br>Это лишь проверка, мана стейтом не отнимается.
<br>
<br>xxx - число маны, которое вы собираетесь отнять. 
<br>Если маны хватает переход происходит согласно next.
<br>Если маны не хватает, происходит переход в yyy.
</td>
</tr>
<tr>
<td class="state-num">3xxyzzz</td>
<td class="state-desc">
<b>Остановка времени</b>
<br>
<br>xx - вероятность срабатывания (1-99%, 00 - 100%)
<br>y - тип остановки времени
<br> zzz - время действя
<br>
<br>Типы остановки времени:
<br> 0 - останавливает всё, кроме атакующего
<br> 1 - останавливает всё, кроме персонажей и объектов с командой атакующего
<br> 2 - останавливает все объекты, кроме персонажей
</td>
</tr>
</table>

<table class="info-table">
<tr>
<th colspan="2">Neora-Atom</th>
</tr>
<tr>
<td class="state-num">0</td>
<td class="state-desc">Эффект</td>
</tr>
<tr>
<td class="state-num">1</td>
<td class="state-desc">Эффект</td>
</tr>
<tr>
<td class="state-num">2</td>
<td class="state-desc">Эффект</td>
</tr>
<tr>
<td class="state-num">3</td>
<td class="state-desc">Эффект</td>
</tr>
</table>