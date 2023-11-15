document.addEventListener("DOMContentLoaded", function () {
    fetch('/assets/item_index.json')
        .then(response => response.json())
        .then(data => {

            let index; // Declare it here to make it accessible in both functions

            async function createFlexSearchIndex() {
                const docs = data; // Use data directly

                // Create FlexSearch index
                index = new FlexSearch.Index({
                    doc: {
                        id: "id",
                        field: ["title", "content"],
                    },
                    tokenize: "forward",
                    context: true,
                    threshold: 0,
                    resolution: 3,
                    depth: 3
                });

                // Add documents to the index one at a time
                for (let doc of docs) {
                    // ...skip ids: redirects-json, assets-main-css, 404-html, sitemap-xml, feed-xml, robots-txt.
                    if (doc["id"] !== "redirects-json" && doc["id"] !== "assets-main-css" && doc["id"] !== "404-html" && doc["id"] !== "sitemap-xml" && doc["id"] !== "feed-xml" && doc["id"] !== "robots-txt")
                        index.add(doc["id"], doc["title"] + " " + doc["content"]);
                }
            }

            createFlexSearchIndex().then(() => {
                // Test the search
                const results = index.search("query", suggest = true);
                // console.log(results);

                // Now that the index is created, setup the search input event listener
                const searchInput = document.getElementById('search-input');
                const searchResults = document.getElementById('search-results');
                searchInput.addEventListener('input', function () {
                    const query = this.value;
                    const results = index.search(query);
                    if (results.length > 0) {
                        searchResults.classList.remove('hidden');
                        searchResults.innerHTML = results.map(result => {
                            // Find the corresponding item in the store
                            const item = window.store.find(item => item.id === result);

                            // If the item is found, return the constructed anchor element
                            if (item) {
                                return `<a class="p-1" href="${item.url}">${item.title}</a>`;
                            }
                            // If the item is not found, you can return an empty string or a placeholder
                            return '';
                        }).join('');
                    } else if (query && query.length > 0) {
                        // If there is text in the search-input but there are no results, add a no-results message
                        searchResults.classList.remove('hidden');
                        searchResults.innerHTML = '<p class="m-1">No results found.</p>';
                    } else {
                        searchResults.classList.add('hidden');
                    }
                    // Ensure that the search results are anchor (<a>) elements inside an element with the id search-results
                    const searchResultLinks = document.querySelectorAll('#search-results a');
                    if (searchResultLinks.length > 0) {
                        searchResultLinks.forEach(link => {
                            link.addEventListener('click', function (e) {
                                e.preventDefault();
                                window.location.href = this.href;
                            });
                        });
                    }
                });
                const handleKeyDown = function (e) {
                    const results = document.querySelectorAll('#search-results a');
                    let currentIndex = Array.from(results).findIndex(result => result === document.activeElement);
                    switch (e.key) {
                        case 'j':
                            e.preventDefault(); // Prevent scrolling
                            if (currentIndex < results.length - 1) {
                                currentIndex++;
                                results[currentIndex].focus();
                                results[currentIndex].classList.add('hover');
                                if (currentIndex > 0) {
                                    results[currentIndex - 1].classList.remove('hover');
                                }
                            }
                            break;
                        case 'k':
                            e.preventDefault(); // Prevent scrolling
                            if (currentIndex > 0) {
                                currentIndex--;
                                results[currentIndex].focus();
                                results[currentIndex].classList.add('hover');
                                if (currentIndex < results.length - 1) {
                                    results[currentIndex + 1].classList.remove('hover');
                                }
                            }
                            break;
                        case 'Enter':
                            e.preventDefault(); // Prevent form submission
                            if (currentIndex >= 0 && currentIndex < results.length) {
                                window.location.href = results[currentIndex].href;
                            } else if (results.length > 0) {
                                results[0].focus();
                                results[0].classList.add('hover');
                            }
                            break;
                    }
                };
                searchInput.addEventListener('keydown', handleKeyDown);
                searchResults.addEventListener('keydown', handleKeyDown);
            });
        });


});

