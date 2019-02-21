// from data.js
var tableData = data;

var fbtn = d3.select('#filter-btn');
var cbtn = d3.select('#clear-btn');

function renderTable(tblData) {
    var tbody = d3.select("tbody");

    tblData.forEach(drow => {
        // Append one table row `tr` for each weather report object
        var trow = tbody.append('tr');
        Object.values(drow).forEach(v => {
            // Append 1 cell per UFO report value
            // (datetime, city, state, country, shape, durationMinutes, comments)
            trow.append('td').text(v);
        });
    })
}

function applyFilters() {
    var fltrData = tableData;

    // Get the input values
    var inDate = d3.select("#datetime").property("value");
    var inCity = d3.select("#city").property("value");
    var inState = d3.select("#state").property("value");
    var inCountry = d3.select("#country").property("value");
    var inShape = d3.select("#shape").property("value");

    // filter the data by date
    if (inDate !== '') fltrData = fltrData.filter(x => x.datetime === inDate);
    // filter the data by city
    if (inCity !== '') fltrData = fltrData.filter(x => x.city === inCity);
    // filter the data by state
    if (inState !== '') fltrData = fltrData.filter(x => x.state === inState);
    // filter the data by country
    if (inCountry !== '') fltrData = fltrData.filter(x => x.country === inCountry);
    // filter the data by shape
    if (inShape !== '') fltrData = fltrData.filter(x => x.shape === inShape);

    return fltrData;
}

function filterTable() {

    // Prevent the page from refreshing
    d3.event.preventDefault();

    // get filtered table data
    var fData = applyFilters();

    // Remove existing table body and add new empty table body
    d3.select("tbody").remove();
    d3.select("#ufo-table").append('tbody');

    // render the filtered table data
    renderTable(fData);
}

function clearFilter() {

    // Prevent the page from refreshing
    d3.event.preventDefault();

    // Clear the input values
    d3.select("#datetime").property("value", '');
    d3.select("#city").property("value", '');
    d3.select("#state").property("value", '');
    d3.select("#country").property("value", '');
    d3.select("#shape").property("value", '');

    // Remove existing table body and add new empty table body
    d3.select("tbody").remove();
    d3.select("#ufo-table").append('tbody');

    // render the original table data
    renderTable(tableData);
}

// Click handler for the filter button
fbtn.on("click", filterTable);

// Click handler for the clear button
cbtn.on("click", clearFilter);

// render the original table data
renderTable(tableData);
