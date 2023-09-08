if (window.NodeList && !NodeList.prototype.forEach) {
    NodeList.prototype.forEach = function (callback, thisArg) {
        thisArg = thisArg || window;
        for (var i = 0; i < this.length; i++) {
            callback.call(thisArg, this[i], i, this);
        }
    };
}

document.querySelectorAll('.dc-code').forEach(function(code) {
    code.innerHTML = code.innerHTML
    .replace(/(&lt;\/[^\s]+&gt;)/gi, '<span class="tags">$1</span>')
    .replace(/(&lt;[^\s\/]+&gt;)/gi, '<span class="tags">$1</span>') // <span class="tag-num">$2</span> <span class="tag-name">$3</span>
    .replace(/(?<=\s|^)(pic|res|scaleX|scaleY|scaleZ|state|wait|next|dvx|dvy|dvz|x|y|z|dx|dy|dz|centerX|centerY|centerZ|type|chase|w|h|l|effect|injury|fall|bdefend|arest|vrest|zwidth|hit_a|hit_j|hit_d|hit_g|hit_Fa|hit_Fj|hit_Da|hit_Dj|hit_Ua|hit_Uj|facing):\s*([-,.0-9]+|"[^"]+")/gi, '<span class="key-words">$1:</span> <span class="value">$2</span>')
    .replace(/(?<=\s|^)(kind|oid|static|action|mp|framea):\s*([-,.0-9]+|true|false)/gi, '<span class="key-words2">$1:</span> <span class="value">$2</span>')
    .replace(/(?<=\s|^)body:/g, '<span class="bdy">body:</span>')
    .replace(/(?<=\s|^)bdy_end:/g, '<span class="bdy">bdy_end:</span>')
    .replace(/(?<=\s|^)itr:/g, '<span class="itr">itr:</span>')
    .replace(/(?<=\s|^)itr_end:/g, '<span class="itr">itr_end:</span>')
    .replace(/(?<=\s|^)sprites:/g, '<span class="opoint">sprites:</span>')
    .replace(/(?<=\s|^)opoint:/g, '<span class="opoint">opoint:</span>')
    .replace(/(?<=\s|^)opoint_end:/g, '<span class="opoint">opoint_end:</span>')
    .replace(/(?<=\s|^)wpoint:/g, '<span class="wpoint">wpoint:</span>')
    .replace(/(?<=\s|^)wpoint_end:/g, '<span class="wpoint">wpoint_end:</span>')
    .replace(/(?<=\s|^)mpoint:/g, '<span class="mpoint">mpoint:</span>')
    .replace(/(?<=\s|^)mpoint_end:/g, '<span class="mpoint">mpoint_end:</span>')
    .replace(/\/\*([^\n]+)/gi, '<div class="comment">$1</div>')
    ;
});

document.querySelectorAll('.lffs').forEach(function(code) {
    code.innerHTML = code.innerHTML
    .replace(/(?<![#]\s*)(?<=\s|^)([^\[\/;\s]+?):(\s*)([-,.0-9]+|"[^"]+"|[^\s]+)/gi, '<span class="key-words">$1:</span>$2<span class="value">$3</span>')
    .replace(/(&lt;\/?)([^\s:]+:?)([^\s]+?)?(&gt;)/gi, '<span class="tags">$1$2<span class="tag-type">$3</span>$4</span>')
    .replace(/(\[\/?)([^\s:]+:?)([^\s]+?)?(\])/gi, '<span class="tags">$1$2<span class="tag-type">$3</span>$4</span>')
    // .replace(/(&lt;[^\s\/]+&gt;)/gi, '<span class="tags">$1</span>') // <span class="tag-num">$2</span> <span class="tag-name">$3</span>
    // .replace(/(?<=\s|^)(?<!&lt;|\[)(kind|oid|static|action|mp|framea):\s*([-,.0-9]+|true|false)/gi, '<span class="key-words2">$1:</span> <span class="value">$2</span>')
    // .replace(/body:/g, '<span class="bdy">body:</span>')
    // .replace(/itr:/g, '<span class="itr">itr:</span>')
    // .replace(/sprites:/g, '<span class="opoint">sprites:</span>')
    // .replace(/opoint:/g, '<span class="opoint">opoint:</span>')
    // .replace(/wpoint:/g, '<span class="wpoint">wpoint:</span>')
    // .replace(/mpoint:/g, '<span class="mpoint">mpoint:</span>')
    .replace(/(\#[^\n]+)/gi, '<div class="comment2">$1</div>')
    .replace(/\/\*([^\n]+)/gi, '<div class="comment">$1</div>')
    ;
});