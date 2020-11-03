// Add a copy-button to all pre elements with highlighted code inside
(function(){
    var COPY_ICON = '<svg xmlns="http://www.w3.org/2000/svg" width="1792" height="1792" viewBox="0 0 1792 1792" fill="currentColor" stroke="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M1696 384q40 0 68 28t28 68v1216q0 40-28 68t-68 28h-960q-40 0-68-28t-28-68v-288h-544q-40 0-68-28t-28-68v-672q0-40 20-88t48-76l408-408q28-28 76-48t88-20h416q40 0 68 28t28 68v328q68-40 128-40h416zm-544 213l-299 299h299v-299zm-640-384l-299 299h299v-299zm196 647l316-316v-416h-384v416q0 40-28 68t-68 28h-416v640h512v-256q0-40 20-88t48-76zm956 804v-1152h-384v416q0 40-28 68t-68 28h-416v640h896z"/>'
    // Get the elements.
    var pre = document.getElementsByTagName('pre');
    for (var i = 0; i < pre.length; i++) {
        // Check whether this is a highlightjs code block
        var isCode = /language-|hljs/.test(pre[i].children[0].className)
        if ( isCode ) {
            var button = document.createElement('button');
            button.className = 'copy-button';
            button.title = 'Copy to clipboard';
            button.setAttribute('aria-label', 'Copy to clipboard');
            var div = document.createElement('div');
            div.innerHTML = COPY_ICON;
            button.appendChild(div.firstChild)
            pre[i].appendChild(button);
        }
    };

    var clipboard = new ClipboardJS('.copy-button', {
        target: function(trigger) {
            return trigger.previousElementSibling;
        }
    });

    clipboard.on('success', function(event) {
        event.clearSelection();
    })

})();
