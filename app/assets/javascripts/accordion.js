function hookAccordion() {
    let acc = document.getElementsByClassName("accordion");
    let i;
    for (i = 0; i < acc.length; i++) {
        let el = acc[i];
        acc[i].addEventListener("click", handleAccordionToggle);
    }
}

function rehookAccordion() {
    let acc = document.getElementsByClassName("accordion");
    let i;
    for (i = 0; i < acc.length; i++) {
        acc[i].removeEventListener("click", handleAccordionToggle);
    }
    hookAccordion();
}
function handleAccordionToggle(event) {
    let el = event.target;
    let on = el.classList.contains('active');
    el.classList.toggle("active");
    let panel = el.nextElementSibling;
    if (on) {
        $(el).attr('aria-expanded', false);
        panel.style.display = 'none';
    } else {
        $(el).attr('aria-expanded', true);
        panel.style.display = "block";
    }
}
