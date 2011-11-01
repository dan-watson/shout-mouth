class Hash
  def has_keys?(to_find = [])
    to_find.each do |item|
      return false unless self.has_key?(item)
    end
    true
  end

  def except(*blacklist)
    {}.tap do |h|
      (keys - blacklist).each { |k| h[k] = self[k] }
    end
  end
end
