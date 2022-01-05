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

function build_print_preview_url( url, api_key, username, password, print_job_id ) {
    const print_preview_url_template = "%1/api/jamex/v1_0/print_preview?api_key=%2&username=%3&password=%4&id=%5"
    return print_preview_url_template.arg(url).arg(api_key).arg(username).arg(password).arg(print_job_id);
}
