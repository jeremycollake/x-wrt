class PageOptions
  attr_accessor :filter, :page, :order, :counter
  def filter?
    !self.filter.blank?
  end
  def order?
    !self.order.blank?
  end
  def initialize(hash)
    if hash
      hash.each do |k,v|
        sym = "#{k}="
        self.send sym, v
      end
    end 
  end
end