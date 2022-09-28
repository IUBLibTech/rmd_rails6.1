let adder_event_target = null;

function hookAiContextMenu() {
    $('.adder').contextmenu(function(event) {
        showMenu(event);
        adder_event_target = event.target;
        return false;
    });
    $('#addPersonButton').click(addPerson);
    $('#add_person_button').click(addPerson);
    $('#addWorkButton').click(addWork);
    $('#add_work_button').click(addWork);
    $('#adder_close').click(function() {
        hideOverlay();
    });
}
function showMenu(e) {
    let el = $('.aiJsonMenu');
    if (el.is(':visible')) {
        el.toggle();
    }
    el.css({
        left:  e.pageX,
        top:   e.pageY
    }).toggle();
}
function hideMenu() {
    let el = $('.aiJsonMenu');
    if (el.is(':visible')) {
        el.toggle();
    }
}

function hookMassAssigners() {
    $('.mass_interviewer').click(function() {
        let p_id = $(this).attr('data-performance-id');
        $('ul[data-performance-id='+p_id+']').find('.interviewer_checkbox').prop('checked', true)
    });
    $('.mass_interviewee').click(function() {
        let p_id = $(this).attr('data-performance-id');
        $('ul[data-performance-id='+p_id+']').find('.interviewee_checkbox').prop('checked', true)
    });
    $('.mass_conductor').click(function() {
        let p_id = $(this).attr('data-performance-id');
        $('ul[data-performance-id='+p_id+']').find('.conductor_checkbox').prop('checked', true)
    });
    $('.mass_performer').click(function() {
        let p_id = $(this).attr('data-performance-id');
        $('ul[data-performance-id='+p_id+']').find('.performer_checkbox').prop('checked', true)
    });
}

function validatePerson(event) {
    if ($('#person_last_name').val().length === 0 && $('#person_company_name').val().length === 0) {
        event.preventDefault();
        swal.fire({
            title: "Missing Required Fields",
            text: "You must specify a Last Name for a Person, or Company Name for and Entity",
            icon: "warning"
        })
    } else {
        showOverlay();
    }
}
function hookPeopleAutocompleteB() {
    $('.autocomplete').autocomplete({
        minLength: 2,
        source: function(request, response) {
            let el = $('#autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            let url = "../people/ajax/autocomplete";
            $.ajax({
                url: url,
                dataType: "json",
                data: {
                    term: request.term,
                },
                success: function(data, x, y) {
                    if (data.length > 0) {
                        response(data)
                    } else {
                        debugger;
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    swal({
                        title: 'Ajax Error',
                        text: 'An error occurred while auto-completing the Last Name field. If this problem persists, please contact Sherri Michaels or Andrew Albrecht.'
                    });
                }
            });
        },
        change: function(event, ui) {
            console.log("CHANGE!")
        },
        close: function(event, ui) {
            console.log("CLOSE")
        },
        open: function() {
            console.log("OPEN");
            clearPersonForm();
        },
        focus: function (event, person) {
            $('#ac_full_name').text(person.item.label);
            $('#ac_dob').text(person.item.date_of_birth_edtf);
            $('#ac_dod').text(person.item.date_of_death_edtf);
            $('#ac_pob').text(person.item.place_of_birth);
            $('#ac_aka').text(person.item.aka);
            $('#ac_auth').text(person.item.authority_source);
            $('#ac_auth_url').text(person.item.authority_source_url);
            $('#ac_notes').text(person.item.notes);

            let el = $('#autocomplete_summary');
            if (el.is(":hidden")) {
                el.toggle();
            }
            return false;
        },
        select: function (event, person) {
            let el = $('#autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            setPerson(person.item.id, false);
        },
        response: function(event, ui) {
            console.log("RESPONSE");
        }
    });
}

function hookPeopleAutocomplete() {
    // autocomplete for the person last name field
    $('.autocomplete').autocomplete({
        minLength: 2,
        source: function(request, response) {
            let el = $('#autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            let url = "../people/ajax/autocomplete";
            $.ajax({
                url: url,
                dataType: "json",
                data: {
                    term: request.term,
                },
                success: function(data, x, y) {
                    if (data.length > 0) {
                        response(data)
                    } else {
                        debugger;
                    }
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    swal({
                        title: 'Ajax Error',
                        text: 'An error occurred while auto-completing the Last Name field. If this problem persists, please contact Sherri Michaels or Andrew Albrecht.'
                    });
                }
            });
        },
        close: function(event, ui) {

        },
        open: function() {
            clearPersonForm();
        },
        focus: function (event, person) {
            $('#ac_full_name').text(person.item.label);
            $('#ac_dob').text(person.item.date_of_birth_edtf);
            $('#ac_dod').text(person.item.date_of_death_edtf);
            $('#ac_pob').text(person.item.place_of_birth);
            $('#ac_aka').text(person.item.aka);
            $('#ac_auth').text(person.item.authority_source);
            $('#ac_auth_url').text(person.item.authority_source_url);
            $('#ac_notes').text(person.item.notes);

            let el = $('#autocomplete_summary');
            if (el.is(":hidden")) {
                el.toggle();
            }
            return false;
        },
        select: function (event, person) {
            let el = $('#autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            setPerson(person.item.id, false);
        }
    });
    $('#person_last_name').focusout(function(event) {
        let el = $('#autocomplete_summary');
        if (el.is(":visible")) {
            el.toggle();
        }
    }).focusin(function(event) {
        $(this).autocomplete("search");
        return false;
    })
    // autocomplete for the Company Name field
    $('.autocomplete_company').autocomplete({
        minLength: 2,
        source: function(request, response) {
            let el = $('#autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            let url = "../people/ajax/autocomplete_company";
            $.ajax({
                url: url,
                dataType: "json",
                data: {
                    term: request.term,
                },
                success: function(data) {
                    response(data)
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    swal({
                        title: 'Ajax Error',
                        text: 'An error occurred while auto-completing the Company Name field. If this problem persists, please contact Sherri Michaels or Andrew Albrecht.'
                    });
                }
            });
        }, open: function() {
            clearPersonForm();
        },
        focus: function (event, person) {
            $('#ac_company_name').text(person.item.label);
            $('#ac_nat').text(person.item.entity_nationality);
            $('#ac_company_aka').text(person.item.aka);
            $('#ac_company_auth').text(person.item.authority_source);
            $('#ac_company_auth_url').text(person.item.authority_source_url);
            $('#ac_company_notes').text(person.item.notes);

            let el = $('#autocomplete_company_summary');
            if (el.is(":hidden")) {
                el.toggle();
            }
            return false;
        },
        select: function (event, person) {
            let el = $('#autocomplete_company_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            setPerson(person.item.id, false);
            return false;
        }
    });
    $('autocomplete_company').focusout(function(event) {
        let el = $('#autocomplete_comapny_summary');
        if (el.is(":visible")) {
            el.toggle();
        }
    }).focusin(function(event) {
        $(this).autocomplete("search");
        return false;
    });
}

function addPerson(e) {
    hideMenu();
    if (overlayOnscreen()) {
        Swal.fire({
            title: 'Discard Edits?',
            text: "The Add Person/Work form is currently open. If you continue, your new/edited data will be lost. Are you sure you want to continue?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            confirmButtonText: 'Yes',
            cancelBUttonText: 'No'
        }).then((result) => {
            if (result.value) {
                addPersonForm(e);
            }
        })
    } else {
        addPersonForm(e)
    }
}
function addPersonForm(e) {
    let text = getTextSelection(e);
    if (e===null || e.target === $('#add_person_button')[0]) {
        // no-op
    } else if (text === null || text.length === 0) {
        text = adder_event_target.textContent;
    }
    $.ajax({
        url: "./"+avalon_item_id+"/ajax_people_adder",
        data: {text: text},
        success: function(result) {
            let el = $( "#adder_overlay" );
            $('#adder_content').html(result);
            $('.peopleButtonAdderCancel').click(function(){
                hideOverlay();
            });
            $('.peopleButtonAdderCreate').click(function(event) {
                validatePerson(event);
            });
            if (!overlayOnscreen()) {
                showOverlay();
            }
            hookPeopleAutocomplete();
            hookPeopleEntity();
            hookMassAssigners();
            hookEdtfValidation();
        },
        error: function(xhr, status, error) {
            swal.fire({
                icon: '',
                title: "Ajax Error trying to get the 'adder' Form",
                text: xhr.responseText
            })
        }
    })
}

/** Sets the Person right slide menu to a specific person */
function setPerson(person_id, warn) {
    hideMenu();
    if (overlayOnscreen() && warn) {
        Swal.fire({
            title: 'Discard Edits?',
            text: "The Add Person/Work form is currently open. If you continue, your new/edited data will be lost. Are you sure you want to continue?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        }).then((result) => {
            if (result.value) {
                setPersonForm(person_id);
            }
        })
    } else {
        setPersonForm(person_id);
    }
}
// used to determine if a person has been selected from autocomplete suggestions (see clearPersonForm for uses)
let person_autocompleted = false;
function setPersonForm(person_id) {
    $.ajax({
        url: "./"+avalon_item_id+"/ajax_people_setter/"+person_id,
        success: function(result) {
            let el = $( "#adder_overlay" );
            $('#adder_content').html(result);
            $(".readonlyable").attr("readonly", true);
            $('.peopleButtonAdderCancel').click(function(){
                hideOverlay();
            });
            $('.peopleButtonAdderCreate').click(function(event) {
                validatePerson(event)
            });
            if (! overlayOnscreen()) {
                showOverlay();
            }
            hookPeopleAutocomplete();
            hookPeopleEntity();
            hookMassAssigners();
            hookEdtfValidation();
            person_autocompleted = true;
        },
        error: function(xhr, status, error) {
            swal.fire({
                icon: '',
                title: "Ajax Error trying to load a form for an existing Person/Entity",
                text: xhr.responseText
            })
        }
    })
}
/**
 * The person slide out form does double duty in both creating new people AND selection existing people from the last name
 * autocomplete input. It does this by initiating the form from the "Add Person" button which makes an AJAX call for the form.
 * It returns a form with the action equaling add_person (a new person). However, when an autocomplete selection
 * is made of an existing person, another AJAX call happens with the return being a prepopulated form with the form action
 * equaling set_person (setting an EXISTING person instead of add a new person). Because a user can decide to create
 * a new person AFTER selecting an autocompleted person, we need to be able to differentiate this use case from a set_person
 * action. The ajax_people_setter_post action in avalon_items_controller should use the absence of the person_id VALUE as the
 * indication that a new person should be created.
 */
function clearPersonForm() {
    $("#person_id").val("")
    $(".readonlyable").val("").attr("readonly", false);
    if (person_autocompleted) {
        $("#person_company_name").autocomplete("destroy").val("");
        $("#person_last_name").autocomplete("destroy").val("");
        person_autocompleted = false;
        hookPeopleAutocomplete();
    }
}



function hookPeopleEntity() {
    // based on initial state of the Person/Entity we need to hide/show the relevant attributes
    let el = $('#person_entity');
    if (el.is(":checked")) {
        showEntityAttributes();
    } else {
        showPersonAttributes();
    }
    el.click(function(e) {
        if ($(this).is(':checked')) {
            showEntityAttributes();
        } else {
            showPersonAttributes();
        }
    });
}
function showEntityAttributes() {
    $('.person_attributes').hide();
    $('.entity_attributes').show().css("display", "flex");
}
function showPersonAttributes() {
    $('.person_attributes').show();
    $('.entity_attributes').hide();
}

function validateWork(event) {
    if ($('#work_title').val().length === 0) {
        event.preventDefault();
        swal.fire({
            title: "Missing Required Fields",
            text: "You must specify a Title for a Work",
            icon: 'warning'
        })
    } else {
        showOverlay();
    }
}

function hookWorkAutocomplete() {
    $('.autocomplete').autocomplete({
        minLength: 2,
        source: function(request, response) {
            let el = $('#work_autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            let url = "../work/ajax/autocomplete_title";
            $.ajax({
                url: url,
                dataType: "json",
                data: {
                    term: request.term,
                },
                success: function(data) {
                    response(data)
                },
                error: function(jqXHR, textStatus, errorThrown) {
                    swal({
                        title: 'Ajax Error',
                        text: 'An error occurred while auto-completing a Work Title. If this problem persists, please contact Sherri Michaels or Andrew Albrecht.'
                    });
                }
            });
        },
        open: function() {
          clearWorkForm();
        },
        focus: function (event, work) {
            $("#ac_title").text(work.item.title);
            $("#ac_traditional").text(work.item.traditional);
            $("#ac_work_in_copyright").text(work.item.contemporary_work_in_copyright);
            $("#ac_restored_copyright").text(work.item.restored_copyright);
            $("#ac_alt_title").text(work.item.alternative_titles);
            $("#ac_pub_year").text(work.item.publication_date_edtf);
            $("#ac_auth").text(work.item.authority_source);
            $('#ac_notes').text(work.item.notes);
            $("#ac_access_determination").text(work.item.access_determination);
            $("#ac_enters_public_domain").text(work.item.copyright_end_date_edtf);
            $("#ac_auth_url").text(work.item.authority_source_url);
            $("#ac_copyright_renewed").text(work.item.copyright_renewed);
            let el = $('#work_autocomplete_summary');
            if (el.is(":hidden")) {
                el.toggle();
            }
            return false;
        },
        select: function (event, work) {
            let el = $('#work_autocomplete_summary');
            if (el.is(":visible")) {
                el.toggle();
            }
            setWork(work.item.id, false);
        }
    });
    $("#work_title").focus(function() {
       workTitleFocus();
    });
    $('#work_people_autocomplete').autocomplete({
	    minLength: 2,
	    source: function(request, response) {
		    let el = $('#work_people_autocomplete_summary');
		    if (el.is(":visible")) {
			    el.toggle();
		    }
		    let url = "../people/ajax/autocomplete";
		    $.ajax({
			    url: url,
			    dataType: "json",
			    data: {
				    term: request.term,
			    },
			    success: function(data) {
				    response(data)
			    },
			    error: function(jqXHR, textStatus, errorThrown) {
				    swal({
					    title: 'Ajax Error',
					    text: 'An error occurred while auto-completing the Last Name field. If this problem persists, please contact Sherri Michaels or Andrew Albrecht.'
				    });
			    }
		    });
	    },
	    focus: function (event, person) {
		    $('#ac_full_name').text(person.item.label);
		    $('#ac_dob').text(person.item.date_of_birth_edtf);
		    $('#ac_dod').text(person.item.date_of_death_edtf);
		    $('#ac_pob').text(person.item.place_of_birth);
		    $('#ac_aka').text(person.item.aka);
		    $('#ac_auth').text(person.item.authority_source);
		    $('#ac_auth_url').text(person.item.authority_source_url);
		    $('#ac_notes').text(person.item.notes);

		    let el = $('#autocomplete_work_person_summary');
		    if (el.is(":hidden")) {
			    el.toggle();
		    }
		    return false;
	    },
	    select: function (event, person) {
		    let el = $('#autocomplete_work_person_summary');
		    if (el.is(":visible")) {
			    el.toggle();
		    }
		    addWorkPerson(person.item);
		    $(this).val('');
		    return false;
	    }
    })
    $('#title').focusout(function(event) {
        let el = $('#work_autocomplete_summary');
        if (el.is(":visible")) {
            el.toggle();
        }
    }).focusin(function(event) {
        $(this).autocomplete("search");
        return false;
    });
}

/**
 * Not sure why this is necessary for works but not people...
 */
function workTitleFocus() {
    if (work_autocompleted) {
        clearWorkForm();
    }
}
/**
 * See the comments for clearPersonForm() for why this is necessary
 */
function clearWorkForm() {
    $("#work_id").val("");
    $(".readonlyable").val("").attr("readonly", false);
    if (work_autocompleted) {
        $("#work_title").autocomplete("destroy").val("");
        work_autocompleted = false;
        hookWorkAutocomplete();
    }
}


function addWork(e) {
    hideMenu();
    if (overlayOnscreen()) {
        Swal.fire({
            title: 'Discard Edits?',
            text: "The Add Person/Work form is currently open. If you continue, your new/edited data will be lost. Are you sure you want to continue?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            confirmButtonText: 'Yes',
            cancelButtonText: 'No'
        }).then((result) => {
            if (result.value) {
                addWorkForm(e);
            }
        })
    } else {
        addWorkForm(e)
    }
}
function addWorkForm(e) {
    let text = getTextSelection(e);
    if (e.target === $('#add_work_button')[0]) {
        // no-op
    } else if (text === null || text.length === 0) {
        text = adder_event_target.textContent;
    }
    $.ajax({
        url: "./"+avalon_item_id+"/ajax_work_adder",
        data: {text: text},
        success: function(result) {
            let el = $( "#adder_overlay" );
            $('#adder_content').html(result);
            $('.workButtonAdderCancel').click(function(){
                hideOverlay();
            });
            $('.workButtonAdderCreate').click(function(event){
                validateWork(event);
            });
            if (!overlayOnscreen()) {
                showOverlay();
            };
            hookWorkAutocomplete();
            hookEdtfValidation();
        },
        error: function(xhr, status, error) {
            swal.fire({
                icon: '',
                title: "Ajax Error trying to get the 'adder' Form",
                text: xhr.responseText
            })
        }
    })
}
function setWork(work_id, warn) {
    hideMenu();
    if (overlayOnscreen() && warn) {
        Swal.fire({
            title: 'Discard Edits?',
            text: "The Add Person/Work form is currently open. If you continue, your new/edited data will be lost. Are you sure you want to continue?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            confirmButtonText: 'Yes',
            cancelBUttonText: 'No'
        }).then((result) => {
            if (result.value) {
                setWorkForm(work_id);
            }
        })
    } else {
        setWorkForm(work_id);
    }
}
let work_autocompleted = false;
function setWorkForm(work_id) {
    $.ajax({
        url: "./"+avalon_item_id+"/ajax_work_setter/"+work_id,
        success: function(result) {
            let el = $( "#adder_overlay" );
            $('#adder_content').html(result);
            $(".readonlyable").attr("readonly", true);
            $('.workButtonAdderCancel').click(function(){
                hideOverlay();
            });
            $('.workButtonAdderCreate').click(function(event) {
                validateWork(event);
            });
            if (! overlayOnscreen()) {
                showOverlay();
            }
            hookWorkAutocomplete();
            hookWorkPeopleRemoval();
            hookEdtfValidation();
            work_autocompleted = true;
        },
        error: function(xhr, status, error) {
            swal.fire({
                icon: '',
                title: "Ajax Error trying to load a form for an existing Person/Entity",
                text: xhr.responseText
            })
        }
    })
}

function addWorkPerson(person) {
	let el = $('div.people');
	$.ajax({
		url: base_url + "/ajax/people/ajax_work_person_form",
		data: {"id": person.id},
		success: function (result) {
			$('#work_people_div').append(result);
			hookWorkPeopleRemoval();
		},
		error: function (xhr, status, error) {
			swal.fire({
				icon: '',
				title: "Ajax Error trying to add an Avalon Item Note",
				text: xhr.responseText
			});
		}
	});
}



function hookWorkPeopleRemoval() {
	$('.workPersonRemover').off('click').click(function(event) {
		$("#"+$(this).attr('data-remove-target')).remove();
	})
}

function overlayOnscreen() {
    let val = $('#adder_overlay').attr('data-animation-offscreen');
    return val === "false"
}

function hideOverlay() {
    let el = $('#adder_overlay');
    el.animate({left: "100%"}, 400);
    el.attr("data-animation-offscreen", "true");
    $('#main_content').animate({'max-width': '100%'}, 400);
}
function showOverlay() {
    let el = $('#adder_overlay');
    el.animate({left: "50%"}, 400);
    el.attr("data-animation-offscreen", "false");
    $('#main_content').animate({'max-width': '50%'}, 400);
}

function getTextSelection() {
    let textSelection = null;
    if (window.getSelection) {
        textSelection = window.getSelection().toString();
    } else if (document.selection && document.selection.type !== "Control") {
        textSelection = document.selection.createRange().text;
    }
    return textSelection;
}

function hookButtons() {
    hookEditRecordings();
    hookCreateEditPerformances();
    hookDeletePerformanceButtons();
    hookCreateTrackButtons();
    hookEditTrackButtons();
    hookDeleteTrackButtons();
    hookAvalonNoteButton();
    hookNewContractButton();
    hookEditContractButtons();
    hookRemoveContractButtons();
}
function hookNewContractButton() {
    $('.newContractButton').click( function() {
        $.ajax({
            url: '/contracts/ajax/new/'+avalon_item_id,
            method: 'GET',
            success: function(response) {
                Swal.fire({
                    title: 'New Agreement',
                    html: response,
                    showCancelButton: true,
                    onOpen: () => {
                        $('#contract_date_edtf_text').on('input', edtfValidate);
                    },
                    preConfirm: () => {
                        const avalon_item_id = $('#contract_avalon_item_id').val();
                        const contract_type = $("#contract_contract_type").val();
                        const date_edtf_text = $('#contract_date_edtf_text').val();
                        const perpetual = $('#contract_perpetual').val();
                        const contract_notes = $('#contract_notes').val();
                        if (contract_type !== "" && validEdtfDate(date_edtf_text) && perpetual !== "") {
                            return {contract_type: contract_type, date_edtf_text: date_edtf_text, perpetual: perpetual, notes: contract_notes, avalon_item_id: avalon_item_id}
                        } else {
                            $(".req").show();
                            return false;
                        }
                    }
                }).then((result) => {
                    if (result.value) {
                        $.ajax({
                            url: '/contracts/ajax/create',
                            method: 'POST',
                            data: {contract: result.value},
                            success: function (result) {
                                $('.contracts').prepend(result)
                                hookRemoveContractButtons();
                                hookEditContractButtons();
                                // increment the javascript number of legal_agreements for this Avalon Item
                                legal_agreements++;
                                legal_agreement_count++;
                            },
                            error: function (xhr, status, error) {
                                swal.fire({
                                    icon: '',
                                    title: "Ajax Error trying to create a new Agreement",
                                    text: xhr.responseText
                                })
                            }
                        })
                    }
                })
            },
            error: function (xhr, status, error) {
                swal.fire({
                    icon: '',
                    title: "Ajax Error trying to add a new Agreement",
                    text: xhr.responseText
                })
            }
        });
    });
}

function hookEditContractButtons() {
	$('.editContractButton').click(function() {
		let contract_id = $(this).attr('data-contract-id')
		$.ajax({
			url: '/contracts/ajax/edit/'+contract_id,
			method: "GET",
			success: function(response) {
				Swal.fire({
					title: 'Edit Agreement',
					html: response,
					showCancelButton: true,
					preConfirm: () => {
						const avalon_item_id = $('#contract_avalon_item_id').val()
						const contract_type = $("#contract_contract_type").val()
						const end_date = $('#contract_end_date').val();
						const perpetual = $('#contract_perpetual').val();
						const contract_notes = $('#contract_notes').val();
						return {contract_type: contract_type, end_date: end_date, perpetual: perpetual, notes: contract_notes, avalon_item_id: avalon_item_id}
					}
				}).then((result) => {
					if (result.value) {
						$.ajax({
							url: '/contracts/'+contract_id,
							method: 'PATCH',
							data: {contract: result.value},
							success: function (result) {
								$('div.contract[data-contract-id='+ contract_id+']').replaceWith(result);
								hookRemoveContractButtons();
								hookEditContractButtons();
							},
							error: function (xhr, status, error) {
								swal.fire({
									icon: '',
									title: "Ajax Error trying to create a new Agreement",
									text: xhr.responseText
								})
							}
						})
					}
				})
			},
			error: function(xhr, status, error) {
				swal.fire({
					icon: '',
					title: "Ajax Error trying to add a new Agreement",
					text: xhr.responseText
				})
			}
		})
	});
}
function hookRemoveContractButtons() {
	$('.deleteContractButton').click(function(event) {
		let contractId = $(this).attr('data-contract-id');
		Swal.fire({
			title: 'Confirm Agreement Delete',
			text: "Are you sure you want to permanently delete this Agreement?",
			icon: 'warning',
			showCancelButton: true,
			confirmButtonColor: '#006298',
			confirmButtonText: 'Delete'
		}).then((result) => {
			if (result.value) {
				$.ajax({
					url: '/contracts/' + contractId,
					method: 'DELETE',
					success: deleteContract(result, contractId),
					error: function (xhr, status, error) {
						swal.fire({
							icon: 'warning',
							title: "Ajax Error trying to delete Track",
							text: xhr.responseText
						})
					}
				})
			}
		});
	})
}
function deleteContract(result, contractId) {
    $('div.contract[data-contract-id='+contractId+']').remove();
    // decrement the javascript number of contracts
    legal_agreements--;
    legal_agreement_count--;
}
function hookAvalonNoteButton() {
    $('#avalon_item_note_button').click(function() {
        Swal.fire({
            title: 'Add Note',
            input: "textarea",
            showCancelButton: true,
        }).then((result) => {
            if (result.value) {
                $.ajax({
                    url: '../avalon_items/' + avalon_item_id +"/ajax_add_note",
                    method: 'POST',
                    data: {text: result.value},
                    success: function (result) {
                        $('#avalon_item_notes').html(result);
                        hookAvalonNoteButton();
                    },
                    error: function (xhr, status, error) {
                        swal.fire({
                            icon: '',
                            title: "Ajax Error trying to add an Avalon Item Note",
                            text: xhr.responseText
                        })
                    }
                })
            }
        })
    });
}
function hookAccessSelects() {
    $("#access").unbind("change").change(function() {
        selectReasonsDiv(true, true, true);
    });
    $('.performance_access_select').unbind("change").change(function() {
        let id = $(this).attr('data-performance-id');
        let val = $(this).find("option:selected").attr('value');
        ajaxPerformanceAccess(id, val);
    });
    $('.track_access_select').unbind("change").change(function() {
        let id = $(this).attr('data-track-id');
        let val = $(this).find("option:selected").attr('value');
        ajaxTrackAccess(id, val);
    });
}
function rehookButtons() {
    $(".editRecordingButton").unbind('click', editRecording).click(editRecording);
    $('.createPerformanceButton').unbind('click', loadNewPerformance).click(loadNewPerformance);
    $('.editPerformanceButton').unbind('click', loadEditPerformanceForm).click(loadEditPerformanceForm);
    $('.deletePerformanceButton').unbind('click', deletePerformance).click(deletePerformance);

    $('.createTrackButton').unbind('click', createNewTrack).click(createNewTrack);
    $('.editTrackButton').unbind('click', loadEditTrackForm).click(loadEditTrackForm);
    $('.deleteTrackButton').unbind('click', deleteTrack).click(deleteTrack);
    hookAccessSelects();
}
/** AJAX functionality for editing Recording metadata **/
function hookEditRecordings() {
    $(".editRecordingButton").click(editRecording);
}
function hookCreateEditPerformances() {
    $('.createPerformanceButton').click(loadNewPerformance);
    $('.editPerformanceButton').click(loadEditPerformanceForm);
}
function hookDeletePerformanceButtons() {
    $('.deletePerformanceButton').click(deletePerformance)
}
function deletePerformance(event) {
    let track_count = $(event.target).closest('.perf_div').find('.track_div').length;
    if (track_count === 0) {
        Swal.fire({
            title: 'Confirm Performance Delete',
            text: "Are you sure you want to permanently delete this Performance?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonColor: '#006298',
            confirmButtonText: 'Delete'
        }).then((result) => {
            if (result.value) {
                let performanceId = $(event.target).attr('data-performance-id');
                $.ajax({
                    url: '../performances/' + performanceId,
                    method: 'DELETE',
                    success: function (result) {
                        $('.perf_div[data-performance-id=' + performanceId + ']').remove();
                        loadCalcedAccess();
                    },
                    error: function (xhr, status, error) {
                        swal.fire({
                            icon: '',
                            title: "Ajax Error trying to delete Performance",
                            text: xhr.responseText
                        })
                    }
                })
            }
        })
    } else {
        swal.fire({
            title: "Cannot Delete Performance",
            text: "Performances with Tracks cannot be deleted. You must first delete all tracks.",
            icon: 'warning',
        })
    }
}
function editRecording(event) {
    loadEditRecordingForm($(event.target).attr('data-recording-id'));
}
function loadEditRecordingForm(recordingId) {
    $.ajax({
        url: '../recordings/ajax/edit/'+recordingId,
        success: function(result) {
            $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(result);
            $('.recordingEditCancelButton[data-recording-id='+recordingId+']').click(function() {
                cancelRecordingEdit(recordingId);
            });
            $('form#edit_recording_'+recordingId).on("ajax:success", function(e, data, status, xhr) {
                submitRecordingEditResponse(recordingId, e, data, status, xhr);
            });
            rehookButtons();
            hookEdtfValidation();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "loadEditRecordingForm: Ajax Error calling: /recordings/ajax/edit/"+recordingId,
                text: error
            })
        }
    })
}
function cancelRecordingEdit(recordingId) {
    $.ajax({
        url: '../recordings/ajax/show/'+recordingId,
        success: function(result) {
            $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(result);
            rehookButtons();
            rehookAccordion();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /recordings/ajax/edit/"+recordingId,
                text: error
            })
        }
    });
}
function submitRecordingEditResponse(recordingId, e, data, status, xhr) {
    $(".recording_div[data-recording-id="+recordingId+"]").replaceWith(xhr.responseText);
    structure_modified = true;
    rehookButtons();
    rehookAccordion();
    loadCalcedAccess();
}
/** END AJAX functionality for editing Recordings **/

/** AJAX functionality for Editing/Creating Performances */
function loadNewPerformance(event) {
    loadNewPerformanceForm($(event.target).attr('data-recording-id'));
}
function loadNewPerformanceForm(recordingId) {
    $.ajax({
        url: '../performances/ajax/new/'+recordingId,
        success: function(result) {
            let h2 = $('.performances[data-recording-id='+recordingId+']').children().first().after(result);
            let newForm = h2.next();
            $('form.new_performance').on("ajax:success", function(e, data, status, xhr) {
                submitNewPerformanceResponse(recordingId, e, data, status, xhr);
            });
            newForm.find('.performanceCreateCancelButton').click(function() {
                newForm.remove();
            });
            hookEdtfValidation();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+recordingId,
                text: error
            })
        }
    })
}
function submitNewPerformanceResponse(recordingId, e, data, status, xhr) {
    $(e.target).parent().replaceWith(xhr.responseText);
    rehookButtons();
    rehookAccordion();
    loadCalcedAccess();
}
function loadEditPerformanceForm(event) {
    let performanceId = event.target.getAttribute('data-performance-id');
    $.ajax({
        url: '../performances/ajax/edit/'+performanceId,
        success: function(result) {
            $(".perf_div[data-performance-id="+performanceId+"]").replaceWith(result);
            $(".performanceEditCancelButton[data-performance-id="+performanceId+"]").click(function(){
                cancelPerformanceEdit(performanceId);
            });
            $('form#edit_performance_'+performanceId).on("ajax:success", function(e, data, status, xhr) {
                submitPerformanceEditResponse(performanceId, e, data, status, xhr);
            });
            hookEdtfValidation();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+performanceId,
                text: error
            })
        }
    })
}
function cancelPerformanceEdit(performanceId) {
    $.ajax({
        url: '../performances/ajax/show/'+performanceId,
        success: function(result) {
            $(".performance_div[data-performance-id="+performanceId+"]").replaceWith(result);
            $(".editPerformanceButton[data-performance-id="+performanceId+"]").click(loadEditPerformanceForm);
            rehookAccordion();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+performanceId,
                text: error
            })
        }
    });
}
function submitPerformanceEditResponse(performanceId, e, data, status, xhr) {
    $(".edit_performance_div[data-performance-id="+performanceId+"]").replaceWith(xhr.responseText);
    rehookButtons();
    rehookAccordion();
    loadCalcedAccess();
}
/** END AJAX functionality for editing Performances */

/** AJAX functionality for CL/CM review comments history */
// function hookRequestReviewButton() {
//     $('#mark_needs_reviewed').click('');
// }

// function hookReviewCommentSlide() {
//     $('#mark_needs_reviewed').hoverIntent(function() {
//         let toggle = $('.toggle');
//         if ( !toggle.is(":animated") ) {
//             if (toggle.is(":visible")) {
//                 toggle.slideUp(200);
//             } else {
//                 toggle.slideDown(200)
//             }
//         }
//     });
// }
/** END AJAX functionality for CL/CM review comments history */
/** AJAX functionality for Tracks */
function hookCreateTrackButtons() {
    $('.createTrackButton').click(createNewTrack);
}
function createNewTrack(event) {
    let performanceId = $(event.target).attr('data-performance-id');
    $.ajax({
        url: '../tracks/ajax/new/'+performanceId,
        success: function(result) {
            let h2 = $('.tracks[data-performance-id='+performanceId+']').children().first().after(result);
            let newForm = h2.next();
            hookHMSValidator(newForm);
            $('form.new_track').on("ajax:success", function(e, data, status, xhr) {
                submitNewTrackResponse(performanceId, e, data, status, xhr);
            });
            newForm.find('.trackCreateCancelButton').click(function() {
                newForm.remove();
            });
            hookEdtfValidation();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /performances/ajax/edit/"+performanceId,
                text: error
            })
        }
    })
}
function submitNewTrackResponse(performanceId, event, data, status, xhr) {
	if (status === "success") {
      let target = $(event.target);
      let parent = target.parent();
      parent.append(xhr.responseText);
      target.remove();
      rehookButtons();
      hookAccessSelects();
	    loadCalcedAccess();
      // disabled Performance button
      parent.closest('.perf_div').find('.deletePerformanceButton').addClass('rvt-disabled-button').removeClass('rvt-button')
  } else {

	}
}
function hookEditTrackButtons() {
    $('.editTrackButton').click(loadEditTrackForm);
}
function loadEditTrackForm(event) {
    let trackId = $(event.target).attr('data-track-id');
    $.ajax({
        url: '../tracks/ajax/edit/'+trackId,
        success: function(result) {
            $(".track_div[data-track-id="+trackId+"]").replaceWith(result);
            $(".trackEditCancelButton[data-track-id="+trackId+"]").click(function(){
                cancelTrackEdit(trackId);
            });
            $('form#edit_track_'+trackId).on("ajax:success", function(e, data, status, xhr) {
                submitTrackEditResponse(trackId, e, data, status, xhr);
            })
            hookEdtfValidation();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /tracks/ajax/edit/"+trackId,
                text: error
            })
        }
    })
}
function submitTrackEditResponse(trackId, event, data, status, xhr) {
  if (status === "success") {
    $(event.target).replaceWith(xhr.responseText);
    rehookButtons();
    rehookAccordion();
    loadCalcedAccess();
  } else {

  }
}
function cancelTrackEdit(trackId) {
    $.ajax({
        url: '../tracks/'+trackId,
        success: function(result) {
            $("#edit_track_"+trackId).replaceWith(result);
            $(".editTrackButton[data-track-id="+trackId+"]").click(loadEditTrackForm);
            rehookAccordion();
            rehookButtons();
        },
        error: function(xhr,status,error) {
            swal.fire({
                icon: 'error',
                title: "Ajax Error calling: /tracks/ajax/show/"+trackId,
                text: error
            })
        }
    })
}

function hookDeleteTrackButtons() {
    $('.deleteTrackButton').click(deleteTrack)
}
function deleteTrack(event) {
  let perf_div = $(event.target).closest('.perf_div')
  let work_count = $(event.target).closest('.track_div').find('.work').length;
  let people_count = $(event.target).closest('.track_div').find('.person').length;
  if (work_count + people_count > 0) {
    swal.fire({
      title: "Cannot Delete Track",
      text: "Tracks with Works and/or People cannot be deleted. You must first remove all Work and People associations.",
      icon: 'warning',
    })
  } else {
    Swal.fire({
	    title: 'Confirm Track Delete',
	    text: "Are you sure you want to permanently delete this Track?",
	    icon: 'warning',
	    showCancelButton: true,
	    confirmButtonColor: '#006298',
	    confirmButtonText: 'Delete'
    }).then((result) => {
	    if (result.value) {
		    let trackId = $(event.target).attr('data-track-id');
		    $.ajax({
			    url: '../tracks/' + trackId,
			    method: 'DELETE',
			    success: function (result) {
				    $('.track_div[data-track-id=' + trackId + ']').remove();
				    // finally check to see if we can enable to the Performance delete button
				    let track_count = perf_div.find('.track_div').size()
				    if (track_count === 0) {
					    perf_div.find('button.deletePerformanceButton').removeClass('rvt-disabled-button').addClass('rvt-button');
				    }
				    loadCalcedAccess();
			    },
			    error: function (xhr, status, error) {
				    swal.fire({
					    icon: 'warning',
					    title: "Ajax Error trying to delete Track",
					    text: xhr.responseText
				    })
			    }
		    })
	    }
    });
  }
}

function loadCalcedAccess() {
	$.ajax({
		url: './ajax/calced_access_determination/'+avalon_item_id,
		method: 'GET',
		success: function(result) {
			$('#sys_acc').html(result);
		},
		error: function(xhr, status, error) {
			reloadPageWithError("An error occurred while trying to load the System Calculated Access Determination. Please contact Andrew Albrecht.")
		}
	})
}
function reloadPageWithError( msg="The Avalon Item will reload.", prompt) {
	if (prompt) {
		swal.fire({
			title: "Error",
			html: msg
		}).then(function() {
			$('body').fadeOut("400", function() {
				location.reload();
			});
		})
	} else {
		$('body').fadeOut("400", function() {
			location.reload();
		});
	}
}
