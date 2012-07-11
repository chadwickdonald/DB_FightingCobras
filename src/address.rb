class Address
  def initialize(location)
    @location = location
  end

  def google_s
    return @location.split(' ').join('+')
  end

  def to_s
    @location
  end
end