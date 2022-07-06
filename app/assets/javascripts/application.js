// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
// require turbolinks
//= require jquery-ui
//= require jquery_nested_form
//= require sweetalert2
//= require_tree .
//= require_tree ./jquery-hoverIntent-1.10.0

$(document).ready(function() {
   $(".decodeURI").on("paste", function(e) {
       e.preventDefault();
       var unencoded = decodeURIComponent(e.originalEvent.clipboardData.getData('text'));
       $(this).val(unencoded);
   });
});
//Override the default confirm dialog by rails
$.rails.allowAction = function(link){
    if (link.data("confirm") == undefined){
        return true;
    }
    $.rails.showConfirmationDialog(link);
    return false;
}
//User click confirm button
$.rails.confirmed = function(link){
    link.data("confirm", null);
    link.trigger("click.rails");
}
//Display the confirmation dialog
$.rails.showConfirmationDialog = function(link){
    var message = link.data("confirm");
    swal({
            title: message,
            type: 'warning',
            confirmButtonText: 'Sure',
            confirmButtonColor: '#2acbb3',
            showCancelButton: true
        },
        function(isConfirm){
            if (isConfirm) {
                $.rails.confirmed(link);
            } else  {
                swal.close();
            }
        });
}

function showLoad(jqSelector, scale) {
    jqSelector.after("<div class='loader right' style='zoom: %{scale}; -moz-transform: scale(%{scale})'></div>");
}
function hideLoader(jqSelector) {
    jqSelector.find('.loader').remove();
}

function hookEdtfValidation() {
    $('.edtf').on('input', edtfValidate)
}

function edtfValidate(e) {
    let val = $(this).val();
    let good = validEdtfDate(val)
    if (good) {
        $(this).removeClass("badEdtf");
    } else {
        $(this).addClass('badEdtf');
    }
}

function hookFullDateValidation() {
    $('.full_date').on('input', function() {
        let val = $(this).val();
        if (val.length === 0 || validFullDate(val)) {
            $(this).removeClass('badFullDate');
        } else {
            $(this).addClass('badFullDate');
        }
    });
}

function hookYearValidation() {
    $('.year').on('input',function() {
        let val = $(this).val();
        if (val.length === 0 || validYear(val)) {
            $(this).removeClass("badYear");
        } else {
            $(this).addClass('badYear');
        }
    })
}

function hookUrlValidator() {
    $('.urlValidator').on('input',function() {
        let val = $(this).val();
        if (val.length === 0 || validURL(val)) {
            $(this).removeClass("badUrl");
        } else {
            $(this).addClass('badUrl');
        }
    });
}

function hookHMSValidator(ancestor) {
    ancestor.find('.hms_validator').on('input', function() {
        let time = $(this).val();
        if (time.length === 0 || validHMS(time)) {
            $(this).removeClass('badHms')
        } else {
            $(this).addClass('badHms');
        }
    });
}

// function hookFullOrYearEDTF() {
//     $('.edtf_year_or_date').on('input', function() {
//         let val = $(this).val();
//         let year = validEdtfYear(val);
//         let date = validEdtfDate(val);
//         if (date || year) {
//             $(this).removeClass('badEdtf');
//         } else {
//             $(this).addClass('badEdtf');
//         }
//     });
// }

function validHMS(string) {
    return string.match(/(?:[01]\d|2[0123]):(?:[012345]\d):(?:[012345]\d)/);
}

function validEdtfDate(str) {
    return validEdtfYYYY(str) || validEdtfYYYYMM(str) || validEdtfYYYYMMDD(str)
}

function validEdtfYYYY(str) {
    let pattern = /^\d{4}[~?]?$/
    return str === undefined || str.length === 0 || !!pattern.test(str)
}
function validEdtfYYYYMM(str) {
    let pattern = /^\d{4}\/(0[1-9]{1}|1[0-2]{1})[~?]?$/
    return str === undefined || str.length === 0 || !!pattern.test(str)
}function validEdtfYYYYMMDD(str) {
    let pattern = /^\d{4}\/(0[1-9]{1}|1[0-2]{1})\/(0[1-9]{1}|[1-2]{1}[0-9]{1}|3[0-1]{1})[~?]?$/
    return str === undefined || str.length == 0 || !!pattern.test(str)
}



function validURL(str) {
    let pattern = /^(?:(?:https?|ftp):\/\/)?(?:(?!(?:10|127)(?:\.\d{1,3}){3})(?!(?:169\.254|192\.168)(?:\.\d{1,3}){2})(?!172\.(?:1[6-9]|2\d|3[0-1])(?:\.\d{1,3}){2})(?:[1-9]\d?|1\d\d|2[01]\d|22[0-3])(?:\.(?:1?\d{1,2}|2[0-4]\d|25[0-5])){2}(?:\.(?:[1-9]\d?|1\d\d|2[0-4]\d|25[0-4]))|(?:(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)(?:\.(?:[a-z\u00a1-\uffff0-9]-*)*[a-z\u00a1-\uffff0-9]+)*(?:\.(?:[a-z\u00a1-\uffff]{2,})))(?::\d{2,5})?(?:\/\S*)?/
    return str === undefined || !!pattern.test(str) || str.length == 0;
}

// FIXME
// function validFullOrYearEDTF(str) {
//     return validEdtfYear(str) || validEdtfDate(str);
// }

function validFullDate(date) {
    let dateformat = /^(0?[1-9]|1[012])[\/\-](0?[1-9]|[12][0-9]|3[01])[\/\-]\d{4}$/;
    return date.match(dateformat)
}

function validYear(year) {
    let yearFormat = /^[0-9]{4}$/
    return year.match(yearFormat);
}

function reloadPage() {
    $("#main_content").remove();
    $(".load_animation").css("display", "block");
    $(".load_animation > h4").css("display", "block");
    $(".loader").css("display", "block");
    location.reload();
}