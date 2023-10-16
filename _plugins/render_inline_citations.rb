require 'bibtex'
require 'citeproc'
require 'csl/styles'
require 'logger'  # Require logger for better debugging messages.

module Jekyll
  class RenderInlineCitations
    # Initialize a new logger that logs to the console, for easy observation.
    LOGGER = Logger.new(STDOUT)
    # Set the logger's level to WARN, meaning it will only log warnings and more severe messages.
    LOGGER.level = Logger::WARN

    BIB_FILE = '_bibliography/references.bib'.freeze
    BIBLIOGRAPHY = BibTeX.open(BIB_FILE)
    PROCESSOR = begin
      LOGGER.debug("Starting to create the processor...")  # Insight into processor initiation.
      citeproc = BIBLIOGRAPHY.to_citeproc
      processor = CiteProc::Processor.new(style: 'apa', format: 'html')
      processor.import(citeproc)
      LOGGER.debug("Processor created successfully!")  # Confirmation that processor is ready.
      processor
    rescue => e  # Catch any exception that occurs during the process.
      LOGGER.error("There was an error while creating the processor: #{e.message}")
      nil  # Return nil from the block after an exception.
    end

    def self.render_citations(text)
      # Return the text as is if text is nil or the processor is nil.
      return text if text.nil? || PROCESSOR.nil?
      LOGGER.debug("Processing the text for citations...")  # Notify that the processing has started.
      citation_regex = /\{%\s*cite(-inline)?\s*(.*?)\s*%\}/
      
      text.gsub!(citation_regex) do |match|
        LOGGER.debug("Found a citation match: #{match}")  # Log each match found.
        inline = Regexp.last_match(1)
        keys = Regexp.last_match(2).split

        citation = keys.map { |key| 
          LOGGER.debug("Rendering citation for key: #{key}")  # Understanding which key is being processed.
          PROCESSOR.render :citation, id: key 
        }.join("; ").gsub(/[()]/, "")

        if inline
          author, year = citation.split(", ")
          LOGGER.debug("Inline citation rendered for #{author}, #{year}")  # Insight into the inline citation.
          "<span class=\"citation\">#{author} (#{year})</span>"
        else
          LOGGER.debug("Standard citation rendered: #{citation}")  # Standard citation creation insight.
          "<span class=\"citation\">(#{citation})</span>"
        end
      end

      LOGGER.debug("Citations rendering completed.")  # The end of the process.
      text  # The transformed text is returned as the method result.
    end
  end
end
