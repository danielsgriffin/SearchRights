require 'minitest/autorun'
require_relative '../../_plugins/render_inline_citations.rb'

class TestRenderInlineCitations < Minitest::Test
  def setup
    @renderer = Jekyll::RenderInlineCitations
  end

  def test_render_citations
    text = "{% cite griffin2022search %}"
    expected_output = "<span class=\"citation\">(Griffin &amp; Lurie, 2022)</span>"
    assert_equal expected_output, @renderer.render_citations(text)
  end
  def test_render_multiple_citations
    text = "{% cite metaxa2021auditing lam2022end %}"
    expected_output = "<span class=\"citation\">(Metaxa et al., 2021; Lam et al., 2022)</span>"
    assert_equal expected_output, @renderer.render_citations(text)
  end
  def test_render_inline_citations
    text = "{% cite-inline zamfirescu-pereira2023johnny %}"
    expected_output = "<span class=\"citation\">Zamfirescu-Pereira et al. (2023)</span>"
    assert_equal expected_output, @renderer.render_citations(text)
  end
end