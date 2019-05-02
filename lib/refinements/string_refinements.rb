module StringRefinements
  refine String do
    def cgi_escape
      return if nil?
      CGI.escape self
    end
  end
end
