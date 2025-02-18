class String
  def match_pattern?(pattern)
    return true if pattern == '*'

    regex = pattern
            .gsub('*', '.*')
            .gsub(/\A(?!\^)/, '^')
            .gsub(/(?<!\$)\z/, '$')

    !!(self =~ /#{regex}/)
  end
end
