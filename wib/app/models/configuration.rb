class Configuration
  attr_writer :id, :board, :profile, :filesystem, :packages, :preconfig
  attr_reader :id, :board, :profile, :filesystem, :packages, :preconfig

  def initialize
    @board = nil
	@profile = nil
    @filesystem = nil
	@preconfig = nil
    @packages = Array.new
    @id = sprintf("%X", (Time.new.to_i.to_s + rand(999).to_s).to_i)
  end
end
