module Jekyll

  class GenerateSearchRightsPages < Generator
    def generate(site)
      puts "         Generating SearchRightsPages..."
      
      if site.data && site.data['evaluations'].is_a?(Hash)
        categories = {} # This will store unique categories and their criteria

        site.data['evaluations'].each do |filename, evaluation_file|
          evaluation_file['evaluations'].each do |criteria|
            # puts "           Generating: #{criteria['criteria']}"
            site.pages << CriteriaPage.new(site, site.source, "criteria", criteria, site.data['systems'], evaluation_file)

            # Populating the categories hash
            category = evaluation_file['category']
            if categories[category]
              categories[category][:criteria_list].push(criteria)
            else
              categories[category] = { category_slug: evaluation_file['category_slug'], purpose: evaluation_file['purpose'], details: evaluation_file['details'], criteria_list: [criteria] }
            end
          end
        end

        # Generating the category pages
        categories.each do |category, data|
          # puts "           Generating: #{category}"
          site.pages << CategoryPage.new(site, site.source, "categories", category, data[:category_slug], data[:purpose], data[:details], data[:criteria_list])
        end

        # Generating the system pages
        if site.data['systems'].is_a?(Array)
          site.data['systems'].each do |system|
            site.pages << SystemPage.new(site, site.source, "systems", system)
          end
        end
      end
    end
  end
    
  class CriteriaPage < Page
    def initialize(site, base, dir, criteria, systems, evaluation_file)
      @site = site
      @base = base
      @dir  = dir

      # Use criteria_slug if it exists, otherwise shorten and clean the criteria'
      if criteria['criteria_slug']
      @name = "#{criteria['criteria_slug']}.html"
      else
      @name = "#{shorten_and_clean_criteria(criteria['criteria'])}.html"
      end

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts/'), 'criteria_page.html')

      criteria_url = "/criteria/#{@name}"

      # Add the URL back to the criteria data
      criteria['url'] = criteria_url
      criteria['criteria_details'] = Jekyll::RenderInlineCitations.render_citations(criteria['criteria_details'])

      # Define properties to access in the criteria_page layout
      self.data['category'] = evaluation_file["category"]
      self.data['category_url'] = evaluation_file["category_slug"]
      self.data['criteria'] = criteria      
      self.data['systems'] = systems
      self.data['description'] = criteria['og_description']
      self.data['image'] = criteria['og_image']
      self.data['image_alt'] = criteria['og_image_alt']

      # Set the title
      self.data['title'] = "Criteria: " + criteria['criteria']
      
      # Set the date
      if criteria['criteria_last_update']
      self.data['date'] = criteria['criteria_last_update']
      else
      self.data['date'] = Time.now.strftime("%Y-%m-%d")
      end
    end

    private

    def shorten_and_clean_criteria(criteria)
      # Clean and shorten the criteria
      cleaned = criteria.gsub(/[?()"@\[\]]/,'').gsub(/\s+/, '-').downcase

      # Remove and / from the criteria
      cleaned = cleaned.gsub(/\//, '-')

      # If you want to limit to a certain length, you can use:
      cleaned = cleaned[0..30] # Limit to 30 characters
      cleaned
    end
  end 

  class CategoryPage < Page
    def initialize(site, base, dir, category, slug, purpose, details, criteria_list)
      @site = site
      @base = base
      @dir  = dir
      puts "           Generating: #{category} with #{slug}"
      if slug
      @name = "#{slug}.html"
      else
      @name = "#{shorten_and_clean_criteria(category)}.html"
      end

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts/'), 'category_page.html')

      # Set the title
      self.data['title'] = "Category: " + category
      
      # Use render_inline_citations.rb to process 'details'
      self.data['details'] = Jekyll::RenderInlineCitations.render_citations(details)

      # Define properties to access in the category_page layout
      self.data['category'] = category
      self.data['purpose'] = purpose
      self.data['criteria_list'] = criteria_list
      
    end
    # The following methods are private and can only be called within this class
    private


    def shorten_and_clean_criteria(criteria)
      cleaned = criteria.gsub(/[?()"@\[\]]/,'').gsub(/\s+/, '-').downcase

      # Remove and / from the criteria
      cleaned = cleaned.gsub(/\//, '-')

      # If you want to limit to a certain length, you can use:
      cleaned = cleaned[0..30] # Limit to 30 characters
      cleaned
    end
  end

  class SystemPage < Page
    def initialize(site, base, dir, system)
      @site = site
      @base = base
      @dir  = dir
      @name = "#{system['slug']}.html"

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts/'), 'system_page.html')

      # Set the title
      self.data['title'] = system['name']

      # Define properties to access in the system_page layout
      self.data['system'] = system
    end
  end
end
