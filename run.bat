@echo off 
if not exist presets\lf2\libs\l2df mklink /D presets\lf2\libs\l2df ..\..\..\src
set L2DF_NOCOLOR=1
love presets/lf2 --fused