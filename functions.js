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
    const print_preview_url_template = "%1/api/printstation/v1_0/print_preview?api_key=%2&username=%3&password=%4&id=%5"
    return print_preview_url_template.arg(url).arg(api_key).arg(username).arg(password).arg(print_job_id);
}

function build_print_release_url( url, api_key, username, password, print_job_id ) {
    const print_release_url_template = "%1/api/printstation/v1_0/release_print_job/?api_key=%2&username=%3&password=%4&id=%5"
    return print_release_url_template.arg(url).arg(api_key).arg(username).arg(password).arg(print_job_id);
}

function build_print_cancel_url( url, api_key, username, password, print_job_id ) {
    const print_cancel_url_template = "%1/api/printstation/v1_0/cancel_print_job/?api_key=%2&username=%3&password=%4&id=%5"
    return print_cancel_url_template.arg(url).arg(api_key).arg(username).arg(password).arg(print_job_id);
}

function build_user_funds_available_url( url, api_key, username, password ) {
    const print_preview_url_template = "%1/api/printstation/v1_0/funds_available/?api_key=%2&username=%3&password=%4"
    return print_preview_url_template.arg(url).arg(api_key).arg(username).arg(password);
}

function build_add_user_funds_url( url, api_key, username, funds ) {
    const print_preview_url_template = "%1/api/public/user_funds/?api_key=%2&username=%3&funds=%4"
    return print_preview_url_template.arg(url).arg(api_key).arg(username).arg(funds);
}
