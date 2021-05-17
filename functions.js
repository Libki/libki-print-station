function request(url, callback) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = (function(myxhr) {
        return function() {
            if ( myxhr.readyState === 4 ) callback(myxhr)
        }
    })(xhr);
    xhr.open('GET', url, true);
    xhr.send('');
}
