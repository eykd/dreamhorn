$ = require('zepto');
_ = require('lodash');

/*
From https://gist.github.com/nikolowry/2639732262ddd8407be6
*/

//outerWidth && outerHeight
_.forEach(['width', 'height'], function(dimension) {
    var offset, Dimension = dimension.replace(/./, function(m) { return m[0].toUpperCase() });
    $.fn['outer' + Dimension] = function(margin) {
        var elem = this;
        if (elem) {
            var size = elem[dimension]();
            var sides = {'width': ['left', 'right'], 'height': ['top', 'bottom']};

            sides[dimension].forEach(function(side) {
                if (margin) size += parseInt(elem.css('margin-' + side), 10);
            });

            return size;
        } else {
            return null;
        }
    };
});
