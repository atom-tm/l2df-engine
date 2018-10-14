Love2d Fighting
---
Небольшой движок для игр в жанре Beat 'em up и fighting на основе фреймворка Love2d.

###Информация

####Opoint {

*Opoint* - блок отвечающий за создание объектов. Располагается в блоке *<frame>* персонажа, поддерживает многоразовое использование.

*Все opoint блоки обрабатываются во время первого тика каждого кадра.*

> **id** - id призываемого объекта

> **action** - кадр в котором появляется объект

> **action_random** - случайное смещение кадров

> **x**, **y**, **z** - положение призываемого объекта по осям x, y, z, относительно положения призывающего объекта

> **x_random**, **y_random**, **z_random** - случайное смещение по осям, относительно положения призываемого объекта

> **facing** - направление взгляда призываемого объекта, относительно призывающего

> **count** - количество призываемых объектов в одной точке

####}