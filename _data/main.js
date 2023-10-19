// main.js

// Global variable to keep track of the current search engine index
let currentSystemIndex = 0;

// Function to reshuffle the array of systems
function reshuffleSystems(systemsArray) {
    for (let i = systemsArray.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [systemsArray[i], systemsArray[j]] = [systemsArray[j], systemsArray[i]]; // Swap
    }
    updateButtonLabels();
}

// Function to handle the search action
function handleSearch(engineUrl) {
    console.log("in handleSearch");
    const searchBar = document.getElementById('search-bar');
    const query = searchBar.value;
    if (query) {
        const searchUrl = engineUrl + encodeURIComponent(query);
        window.open(searchUrl, '_blank'); // Open the search results in a new tab
    }
}

// Function to update the visual state of buttons
function updateButtonStyles() {
    const allButtons = document.querySelectorAll('#search-systems-container button');

    allButtons.forEach((button, index) => {
        if (index < currentSystemIndex) {
            button.className = 'btn btn-dark btn-block'; // Already clicked systems, dark grey
        } else if (index === currentSystemIndex) {
            button.className = 'btn btn-secondary btn-block'; // Next engine to be clicked, grey
        } else {
            button.className = 'btn btn-light btn-block'; // Rest of the systems, light grey
        }
    });
}

// Function to create buttons for each search engine
function populateSearchSystems(systems) {
    const container = document.getElementById('search-systems-container');
    container.innerHTML = ''; // Clear the previous buttons if any

    systems.forEach((engine, index) => {
        // ... [the existing code inside your loop that creates buttons] ...
    });
}

// Function to update the labels on the buttons based on their state
function updateButtonLabels() {
    const allButtons = document.querySelectorAll('#search-systems-container button');
    allButtons.forEach((button, index) => {
        const statusLabel = button.querySelector('.status-label');

        if (index < currentSystemIndex) {
            // This space intentionally left blank as the 'Searched at...' text is already set on click
        } else if (index === currentSystemIndex) {
            statusLabel.textContent = 'Next to be searched...';
        } else {
            statusLabel.textContent = 'To be searched...';
        }
    });
}

// Function to reset and repopulate the search systems
function resetSearchSystems() {
    reshuffleSystems(searchSystems); // Reshuffle the array
    populateSearchSystems(searchSystems); // Repopulate the buttons
    updateButtonStyles(); // Update buttons' visual states
}

// This function will run once the HTML is loaded
window.onload = function () {
    const searchBar = document.getElementById('search-bar');
    searchBar.addEventListener('keypress', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            const allButtons = document.querySelectorAll('#search-systems-container button');
            if (currentSystemIndex < allButtons.length) {
                allButtons[currentSystemIndex].click();
            }
        }
    });

    // Event listener for the reshuffle button
    document.getElementById('reshuffle-button').addEventListener('click', function () {
        resetSearchSystems();
    });

    // Call functions to set the initial state
    resetSearchSystems();
};
