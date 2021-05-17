function request(url, callback, type) {
    type = type ? type : 'GET'

    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = (function(myxhr) {
        return function() {
            if ( myxhr.readyState === 4 ) callback(myxhr)
        }
    })(xhr);
    xhr.open(type, url, true);
    xhr.send('');
}
