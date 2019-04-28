$(document).ready(function(){

$(".dc-code").each(function(index, el) {
var dc_code = $(this).html()
dc_code = dc_code
.replace(/</g, "&#60;")
.replace(/>/g, "&#62;")
.replace(/(&#60;frame&#62;)\s([0-9]+)\s([^\s]+| |\n)/gi,"<span class='tags'>$1</span> <span class='frame-num'>$2</span> <span class='frame-name'>$3</span>")
.replace(/(&#60;frame_end&#62;|&#60;bmp_begin&#62;|&#60;bmp_end&#62;)/, "<span class='tags'>$1</span>")
.replace(/(pic|state|wait|next|dvx|dvy|dvz|x|y|z|dx|dy|dz|centerx|centery|centerz|type|chase|w|h|effect|injury|fall|bdefend|arest|vrest|zwidth|hit_a|hit_j|hit_d|hit_g|hit_Fa|hit_Fj|hit_Da|hit_Dj|hit_Ua|hit_Uj|facing):\s([-,0-9]+)/gi, "<span class='key-words'>$1:</span> <span class='value'>$2</span>")
.replace(/(kind|oid|action|mp|framea):\s([-,0-9]+)/gi, "<span class='key-words2'>$1:</span> <span class='value'>$2</span>")
.replace(/bdy:/g, "<span class='bdy'>bdy:</span>")
.replace(/bdy_end:/g, "<span class='bdy'>bdy_end:</span>")
.replace(/itr:/g, "<span class='itr'>itr:</span>")
.replace(/itr_end:/g, "<span class='itr'>itr_end:</span>")
.replace(/opoint:/g, "<span class='opoint'>opoint:</span>")
.replace(/opoint_end:/g, "<span class='opoint'>opoint_end:</span>")
.replace(/wpoint:/g, "<span class='wpoint'>wpoint:</span>")
.replace(/wpoint_end:/g, "<span class='wpoint'>wpoint_end:</span>")
.replace(/mpoint:/g, "<span class='mpoint'>mpoint:</span>")
.replace(/mpoint_end:/g, "<span class='mpoint'>mpoint_end:</span>")
.replace(/\/\*([^\n]+)/gi, "<div class='comment'>$1</div>")
;
$(this).replaceWith('<pre class="dc-code">'+ dc_code +'</pre>');
});

});