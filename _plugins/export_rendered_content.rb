require 'json'
require 'nokogiri'

module Jekyll
  class ExportRenderedContent < Generator
    safe true
    priority :lowest

    def generate(site)
      # Make sure the site is built
      Jekyll::Hooks.register :site, :post_write do |site|
        # Create an array to hold the content of each page
        contents = []
        # puts "         Running ExportRenderedContent..."
        # Loop through each page in the _site directory
        Dir["_site/**/*.html"].each do |file_path|
          # Read the HTML content of the page
          html_content = File.read(file_path)
          
          # Parse the HTML using Nokogiri
          doc = Nokogiri::HTML(html_content)
          
          # Remove script and style elements
          doc.search('script, style').remove
          
          # Get the text content of the page, stripping out the HTML
          text_content = doc.text.strip

          # Remove newline characters and replace them with spaces
          text_content = text_content.gsub(/\n/, ' ')

          # Collapse multiple spaces to a single space
          text_content = text_content.gsub(/\s+/, ' ')
          
          # Add to contents array
          contents << {
            "path" => file_path.sub("_site/", ""),
            "content" => text_content
          }
        end

        # Write to a JSON file
        File.open("_site/rendered_content.json", "w") do |f|
          # puts "         Writing rendered content to '_site/rendered_content.json'..."
          f.write(JSON.pretty_generate(contents))
        end

        # Write to the original item_index.json
        File.open("_site/assets/item_index.json", "r+") do |f|
        item_index = JSON.parse(f.read)

        # Debug: Print the first item in item_index to verify it's reading correctly
        # puts "First item in item_index: #{item_index.first}"

        contents.each do |content|
            # Debug: Print each content path being processed

            item = item_index.find { |i| i['url'] == "/#{content['path']}" }  # Note: 'url' is used here to match with 'path'

            # Debug: Print if an item was found in item_index that matches the content path
            # puts "Matching item found: #{item}" if item

            item['content'] = content['content'] if item
        end

        # Debug: Print the first item in item_index after modification to check if the content was updated
        # puts "First item in item_index after update: #{item_index.first}"

        # Function to update item_index.json at a given path
        def update_item_index(item_index, path)
            File.open(path, "w") do |f|
                f.write(JSON.pretty_generate(item_index))
            end
        end

        # Write to the original item_index.json in _site
        update_item_index(item_index, "_site/assets/item_index.json")
        end

      end
    end
  end
end

