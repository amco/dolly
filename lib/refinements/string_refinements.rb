module StringRefinements
  UNESCAPABLE_PATTERNS = [
      %r{_design/.+/_view/.+}
    ]

  refine String do
    #FROM ActiveModel::Name
    def underscore
      to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
    end

    def cgi_escape
      return if nil?
      return self unless escapable?
      return self
      CGI.escape self
    end

    def escapable?
      return false if self =~ /%/
      UNESCAPABLE_PATTERNS.none? do |pattern|
        self =~ pattern
      end
    end
  end
end
