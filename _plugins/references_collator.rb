require 'nokogiri'

module Jekyll
  class ReferencesCollator

    Jekyll::Hooks.register [:pages, :posts], :post_render do |doc|
      # Early return if not an HTML document.
      next unless doc.output_ext == '.html'

      # puts "Starting the reference collation process for #{doc.url}..."

      # Parse the HTML content using Nokogiri.
      parsed_doc = Nokogiri::HTML(doc.output)

      # Find all divs with the id="refs".
      refs_divs = parsed_doc.css('div#refs')

      # Only proceed if more than one div is found.
      if refs_divs.length > 1
        puts "Found #{refs_divs.length} reference div(s) on #{doc.url}."

        # Extract, collect and deduplicate inner divs.
        collected_refs = []
        refs_divs.each do |refs_div|
          refs_div.css('div').each do |ref_div|
            unless collected_refs.any? { |c_ref| c_ref['id'] == ref_div['id'] }
              collected_refs << ref_div
            end
          end
          refs_div.remove
        end

        # Sort the collected refs by their id.
        sorted_refs = collected_refs.sort_by { |ref_div| ref_div['id'] }

        # Create a new container div and insert the sorted refs into it.
        container = Nokogiri::XML::Node.new "div", parsed_doc
        container['id'] = 'refs'
        container['class'] = 'references hanging-indent'
        container['role'] = 'doc-bibliography'
        sorted_refs.each { |ref_div| container.add_child(ref_div) }

        # Insert the new container at the end of the page
        parsed_doc.css('body').first.add_child(container)

        # Update the document's output.
        doc.output = parsed_doc.to_html

        puts "Reference collation process completed for #{doc.url}."
      # else
        # puts "No references or 1 `refs` div found on #{doc.url}."

      end
    end
  end
end
