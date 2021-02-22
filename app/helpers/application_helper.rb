module ApplicationHelper
  def markdown(text)
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, no_intra_emphasis: true, lax_spacing: true, highlight: true, hard_wrap: true)
    renderer.render(text).html_safe
  end
end
