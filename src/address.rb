class Address
  attr_reader :address
  def initialize(address)
    @address = address
  end

  def google_s
    return @address.split(' ').join('+')
  end
end