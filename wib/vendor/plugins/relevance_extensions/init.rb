# Include hook code here

begin
  require 'streamlined_relationships'
  require 'streamlined_ui'
  require 'streamlined_controller'
  Dir.new(File.join(File.dirname(__FILE__), 'lib')).each do |file|
    require(File.join(File.dirname(__FILE__), 'lib', file)) if /rb$/.match(file)
  end
rescue Exception => e
  ActionController::Base.logger.fatal e if ActionController::Base.logger
end