function cmLoadAll() {
    ajaxItems(
        './avalon_items/ajax/cm_all',
        "<p>An error occurred generating the Avalon Item list: All Items</p><br><p>Status: :jqXHR.status, Error: <i>:errorThrown</i></p>",
        '#cm_all_badge');
}
// function cmLoadDefaultAccess() {
//     ajaxItems('./avalon_items/ajax/cm_iu_default_only_items',
//         "<p>An error occurred generating the Avalon Item list: IU Default</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
//         '#cm_default_badge'
//         );
// }
// function cmLoadWaitingOnCL() {
//     ajaxItems('./avalon_items/ajax/cm_waiting_on_cl',
//         "<p>An error occurred generating the Avalon Item list: Review Requested</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
//         '#cm_review_badge'
//     );
// }
// function cmLoadWaitingOnSelf() {
//     ajaxItems('./avalon_items/ajax/cm_waiting_on_self',
//         "<p>An error occurred generating the Avalon Item list: Responses</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
//         '#cm_responses_badge'
//     );
// }
// function cmLoadAccessDetermined() {
//     ajaxItems('./avalon_items/ajax/cm_access_determined',
//         "<p>An error occurred generating the Avalon Item list: Access Determined</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
//         '#cm_determined_badge'
//     );
// }

function clLoadAll() {
    ajaxItems('./avalon_items/ajax/cl_all',
        "<p>An error occurred generating the Avalon Item list: All</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
        '#cl_all_badge'
    );
}
function clLoadInitial() {
    ajaxItems('./avalon_items/ajax/cl_initial_review',
        "<p>An error occurred generating the Avalon Item list: Initial Review</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
        '#cl_initial_badge'
    );
}
function clLoadWaitingOnCM() {
    ajaxItems('./avalon_items/ajax/cl_waiting_on_cm',
        "<p>An error occurred generating the Avalon Item list: Needs Information</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
        '#cl_waiting_on_cm_badge'
    );
}
function clLoadWaitingOnSelf() {
    ajaxItems('./avalon_items/ajax/cl_waiting_on_self',
        "<p>An error occurred generating the Avalon Item list: Responses</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
        '#cl_waiting_on_self_badge'
    );
}
function clLoadAccessDetermined() {
		ajaxItems('./avalon_items/ajax/cl_access_determined',
			"<p>An error occurred generating the Avalon Item list: Responses</p><br><p>Status: :jqXHR.status Error: <i>:errorThrown</i></p>",
			'#cl_determined_badge'
		);
}

/**
 * function for calling the ajax to render a list of Avalon Items.
 * @param url which Ajax function to call
 * @param errorMsg what to display in the event of an error, it can contain html. This string should contain both
 * ":jqXHR.status" and ":errorThrown" to allow for inserting call specific details of the error. For instance:
 * "<p>An error occurred generating the Avalon Item list: All Items</p><br><p>Status: :jqXHR.status, Error: <i>:errorThrown</p>"
 * @param badgeSelector the jquery selector that sets the primary filter badge
 */
function ajaxItems(url, errorMsg, badgeSelector) {
    $.ajax({
        url: url,
        method: "GET",
        success: function(response) {
            $("#results_table_div").html(response);
            hookTableSort('avalon_items_table');
            setPrimaryBadge($(badgeSelector));

        },
        error: function(jqXHR, textStatus, errorThrown) {
            swal({
                icon: 'error',
                title: 'Ajax Error',
                html: errorMsg.replace(':jqXHR.status', jqXHR.status).replace(":errorThrown", errorThrown)
            })
        }
    });
}

function setPrimaryBadge(primaryBadge) {
    setCmAllBadge(primaryBadge[0] === $('#cm_all_badge')[0] || primaryBadge[0] === $('#cl_all_badge')[0]);
    setCmDefaultBadge(primaryBadge[0] === $('#cm_default_badge')[0] || primaryBadge[0] === $('#cl_initial_badge')[0]);
    setCmResponsesBadge(primaryBadge[0] === $('#cm_responses_badge')[0] || primaryBadge[0] === $('#cl_waiting_on_self_badge')[0]);
    setCmReviewBadge(primaryBadge[0] === $('#cm_review_badge')[0] || primaryBadge[0] === $('#cl_waiting_on_cm_badge')[0]);
    setCmDeterminedBadge(primaryBadge[0] === $('#cm_determined_badge')[0]);
}

function setCmAllBadge(primary) {
    // this badge needs to be handled differently because, rivet designers... the "default" badge gets its style
    // from class .rvt-badge, whereas all others get theirs from class rvt-badge--<something><- maybe 'secondary'> AND
    // also have class .rvt-badge... not the best, consistent implementation
    if (primary) {
        $('#cm_all_badge').removeClass('rvt-badge--secondary');
        $('#cl_all_badge').removeClass('rvt-badge--secondary');
    } else {
        $('#cm_all_badge').addClass('rvt-badge--secondary');
        $('#cl_all_badge').addClass('rvt-badge--secondary');
    }
}
function setCmDefaultBadge(primary) {
    let first, second;
    if (primary) {
        second = 'rvt-badge--info';
        first = 'rvt-badge--info-secondary';
    } else {
        second = 'rvt-badge--info-secondary';
        first = 'rvt-badge--info';
    }
    $('#cm_default_badge').switchClass(first, second);
    $('#cl_initial_badge').switchClass(first, second);
}
function setCmReviewBadge(primary) {
    let first, second;
    if (primary) {
        first = 'rvt-badge--warning-secondary';
        second = 'rvt-badge--warning';
    } else {
        first = 'rvt-badge--warning';
        second = 'rvt-badge--warning-secondary';
    }
    $('#cm_review_badge').switchClass(first, second);
    $('#cl_waiting_on_cm_badge').switchClass(first, second);
}
function setCmResponsesBadge(primary) {
    let first, second;
    if (primary) {
        first = 'rvt-badge--danger-secondary';
        second = 'rvt-badge--danger';
    } else {
        first = 'rvt-badge--danger';
        second = 'rvt-badge--danger-secondary';
    }
    $('#cm_responses_badge').switchClass(first, second);
    $('#cl_waiting_on_self_badge').switchClass(first, second);
}
function setCmDeterminedBadge(primary) {
    let first, second;
    if (primary) {
        first = 'rvt-badge--success-secondary';
        second = 'rvt-badge--success';
    } else {
        first = 'rvt-badge--success';
        second = 'rvt-badge--success-secondary';
    }
    $('#cm_determined_badge').switchClass(first, second);
}

function setClAllBadge(primary) {
    // this badge needs to be handled differently because, rivet designers... the "default" badge gets its style
    // from class .rvt-badge, whereas all others get theirs from class rvt-badge--<something><- maybe 'secondary'> AND
    // also have class .rvt-badge... not the best, consistent implementation
    if (primary) {
        $('#cl_all_badge').removeClass('rvt-badge--secondary');
    } else {
        $('#cl_all_badge').addClass('rvt-badge--secondary')
    }
}
function setClInitialBadge(primary) {
    let first, second;
    if (primary) {
        first = 'rvt-badge--info-secondary';
        second = 'rvt-badge--info';
    } else {
        first = 'rvt-badge--info';
        second = 'rvt-badge--info-secondary';
    }
    $('#cl_initial_badge').switchClass(first, second);
}

