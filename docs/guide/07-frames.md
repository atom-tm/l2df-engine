# Animation (frames)

<pre class="lffs">
/* Holding attack and having enough mana points it will instantly switch to 330 frame. If attack isn't holding it will switch to "next".
&lt;frame&gt; 1 test
  pic: 10 wait: 5 next: 999
  hit_a: 330 mp: 55
  &lt;state&gt; 4050 &lt;/state&gt;
&lt;/frame&gt;
</pre>


## Basic frames

<table class="info-table">
<tr>
<th colspan="2">@{02-presets.md.LF__preset|LF2 preset}</th>
</tr>
<tr><td class="info-table-desc">Frame ID</td><td class="info-table-desc">Description</td></tr>
<tr>
<td class="state-num range">000 - 003</td>
<td class="state-desc">standing</td>
</tr>
<tr>
<td class="state-num range">005 - 008</td>
<td class="state-desc">walking</td>
</tr>
<tr>
<td class="state-num range">009 - 011</td>
<td class="state-desc">running</td>
</tr>
<tr>
<td class="state-num range">012 - 015</td>
<td class="state-desc">heavy_obj_walk</td>
</tr>
<tr>
<td class="state-num range">016 - 018</td>
<td class="state-desc">heavy_obj_run</td>
</tr>
<tr>
<td class="state-num range">019</td>
<td class="state-desc">heavy_stop_run</td>
</tr>
<tr>
<td class="state-num range">020 - 028</td>
<td class="state-desc">normal_weapon_atck</td>
</tr>
<tr>
<td class="state-num range">030 - 033</td>
<td class="state-desc">jump_weapon_atck</td>
</tr>
<tr>
<td class="state-num range">035 - 037</td>
<td class="state-desc">run_weapon_atck</td>
</tr>
<tr>
<td class="state-num range">040 - 043</td>
<td class="state-desc">dash_weapon_atck</td>
</tr>
<tr>
<td class="state-num range">045 - 047</td>
<td class="state-desc">light_weapon_thw</td>
</tr>
<tr>
<td class="state-num range">050 - 051</td>
<td class="state-desc">heavy_weapon_thw</td>
</tr>
<tr>
<td class="state-num range">052 - 054</td>
<td class="state-desc">sky_lgt_wp_thw</td>
</tr>
<tr>
<td class="state-num range">055 - 058</td>
<td class="state-desc">weapon_drink (unimplemented)</td>
</tr>
<tr>
<td class="state-num range">060 - 068</td>
<td class="state-desc">punch</td>
</tr>
<tr>
<td class="state-num range">070 - 073</td>
<td class="state-desc">super_punch</td>
</tr>
<tr>
<td class="state-num range">080 - 081</td>
<td class="state-desc">jump_attack</td>
</tr>
<tr>
<td class="state-num range">085 - 087</td>
<td class="state-desc">run_attack</td>
</tr>
<tr>
<td class="state-num range">090 - 091</td>
<td class="state-desc">dash_attack</td>
</tr>
<tr>
<td class="state-num range">095</td>
<td class="state-desc">dash_defend</td>
</tr>
<tr>
<td class="state-num range">100 - 101</td>
<td class="state-desc">rowing (from falling-frames)</td>
</tr>
<tr>
<td class="state-num range">102 - 109</td>
<td class="state-desc">rowing (rolling)</td>
</tr>
<tr>
<td class="state-num range">110 - 111</td>
<td class="state-desc">defend (111, if character is being hit)</td>
</tr>
<tr>
<td class="state-num range">112 - 114</td>
<td class="state-desc">broken_defend</td>
</tr>
<tr>
<td class="state-num range">115</td>
<td class="state-desc">picking_light</td>
</tr>
<tr>
<td class="state-num range">116 - 117</td>
<td class="state-desc">picking_heavy</td>
</tr>
<tr>
<td class="state-num range">120 - 121</td>
<td class="state-desc">catching</td>
</tr>
<tr>
<td class="state-num range">122 - 123</td>
<td class="state-desc">catching (punch)</td>
</tr>
<tr>
<td class="state-num range">130 - 144</td>
<td class="state-desc">picked_caught</td>
</tr>
<tr>
<td class="state-num range">180 - 191</td>
<td class="state-desc">falling (180-185 foward, 186-191 backward)</td>
</tr>
<tr>
<td class="state-num range">200 - 202</td>
<td class="state-desc">ice (unimplemented)</td>
</tr>
<tr>
<td class="state-num range">203 - 206</td>
<td class="state-desc">fire (203/4 & 205/6) (unimplemented)</td>
</tr>
<tr>
<td class="state-num range">207</td>
<td class="state-desc">tired (unimplemented)</td>
</tr>
<tr>
<td class="state-num range">210 - 212</td>
<td class="state-desc">jump</td>
</tr>
<tr>
<td class="state-num range">213</td>
<td class="state-desc">dash</td>
</tr>
<tr>
<td class="state-num range">214</td>
<td class="state-desc">dash (turned back)</td>
</tr>
<tr>
<td class="state-num range">215</td>
<td class="state-desc">crouch</td>
</tr>
<tr>
<td class="state-num range">216</td>
<td class="state-desc">dash</td>
</tr>
<tr>
<td class="state-num range">217</td>
<td class="state-desc">dash (turned back)</td>
</tr>
<tr>
<td class="state-num range">218</td>
<td class="state-desc">stop_running</td>
</tr>
<tr>
<td class="state-num range">219</td>
<td class="state-desc">crouch2 (out of lying)</td>
</tr>
<tr>
<td class="state-num range">220 - 229</td>
<td class="state-desc">injured</td>
</tr>
<tr>
<td class="state-num range">230 - 231</td>
<td class="state-desc">lying (0=stomach 1=back)</td>
</tr>
<tr>
<td class="state-num range">232 - 234</td>
<td class="state-desc">throw_lying_man</td>
</tr>
</table>