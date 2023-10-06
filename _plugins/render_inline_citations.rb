require 'bibtex'
require 'citeproc'
require 'csl/styles'

module Jekyll
  class RenderInlineCitations
    BIB_FILE = '_bibliography/references.bib'.freeze
    BIBLIOGRAPHY = BibTeX.open(BIB_FILE)
    PROCESSOR = begin
      citeproc = BIBLIOGRAPHY.to_citeproc
      processor = CiteProc::Processor.new(style: 'apa', format: 'html')
      processor.import(citeproc)
      processor
    end

    def self.render_citations(text)
      citation_regex = /\{%\s*cite(-inline)?\s*(.*?)\s*%\}/
      
      text.gsub!(citation_regex) do |match|
        inline = Regexp.last_match(1)
        keys = Regexp.last_match(2).split

        citation = keys.map { |key| PROCESSOR.render :citation, id: key }
                      .join("; ")
                      .gsub(/[()]/, "")

        if inline
          author, year = citation.split(", ")
          "<span class=\"citation\">#{author} (#{year})</span>"
        else
          "<span class=\"citation\">(#{citation})</span>"
        end
      end

      text
    end
  end
end
