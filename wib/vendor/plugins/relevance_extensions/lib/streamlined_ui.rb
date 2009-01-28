require 'module_extensions'
# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
module Streamlined
# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
#
# Base class for the model-specific declarative UI controller classes.  Each Model class 
# will have a parallel class in the app/streamlined directory for managing the views.
# For example, if your application has two models, <tt>User</tt> and <tt>Role</tt> (in <tt>app/models/user.rb</tt> and <tt>role.rb)</tt>, 
# your Streamlined application would also have <tt>app/streamlined/user.rb</tt> and <tt>role.rb</tt>, containing the classes
# <tt>UserUI</tt> and <tt>RoleUI</tt>.  
  class UI
    class << self
      
      def reset_subclasses
        ObjectSpace.each_object(Class) do |klass|
          if klass.ancestors[1..-1].include?(Streamlined::UI)
            ActionController::Base.logger.debug "resetting streamlined class #{klass}"
         	  klass.instance_variables.each do |var|
         	    klass.send(:remove_instance_variable, var)
        	 	end
        	 	klass.instance_methods(false).each do |m|
        	 	  klass.send :undef_method, m
        	 	end
        	 end
         end
      end
      	 	
       def logger
         ActionController::Base.logger
       end
       
       # The default model name is the name of this class minus the "UI" suffix.
       def default_model
          Object.const_get(self.name.chomp("UI"))
       end
       
       # Used as either an attribute reader or writer. If called with no arguments,
       # returns the model name (or the default model name). If passed a single argument,
       # assigns that to the @model instance variable.
       def model(*args)
         case args.length
         when 0
           @model || default_model
         when 1
           @model = Object.const_get(args[0].to_s.classify)
         else
           raise "Too many args to model"
         end
       end

       # Used to define the default relationship declarations for each relationship in the model.
       # n-to-many relationships default to the :membership view and the :count summary
       # n-to-one relationships default to the :select view and the :name summary
       def define_association(assoc, options = {})
         case assoc.macro
         when :has_one, :belongs_to
           if assoc.options[:polymorphic]
             return {:view => :polymorphic_select, :summary => :name}.merge(options)
           else
             return {:view => :select, :summary => :name}.merge(options)
           end
         when :has_many, :has_and_belongs_to_many
           if assoc.options[:polymorphic]
             return {:view => :polymorphic_membership, :summary => :count}.merge(options)
           else
             return {:view => :membership, :summary => :count}.merge(options)
           end           
         end
       end
       
       # Used to define the columns that should be visible to the user at runtime.  There 
       # are two options: 
       # * <b>:include</b> : an array of columns to include, override the default exclusions.
       # * <b>:exclude</b> : an array of columns to exlude, adds to the default exclusions.
       # By default, user_columns excludes:
       # * any field whose name ends in "_at" (Rails-managed timestamp field)
       # * any field whose name ends in "_on" (Rails-managed timestamp field)
       # * any field whose name ends in "_id" (foreign key)
       # * the "position" field (Rails-managed ordering column)
       # * the "lock_version" field (Rails-managed optimistic concurrency)
       # * the "password_hash" field (if using a hashed-password strategy)
       def user_columns(options = {})
         initialize_user_columns
         
         excludes = options[:exclude]
         if excludes
           excludes = excludes.map &:to_s 
           @user_columns.reject! {|col| excludes.include? col.name}
         end
         
         includes = options[:include]
          if includes
             includes = includes.map &:to_s
             includes.reject! {|name| (@user_columns.collect {|col| col.name}).include? name }
             @user_columns.concat model.columns.select {|col| includes.include? col.name }
             @user_columns.concat calculated_columns.select {|col| includes.include? col.name }
          end
          @user_columns
       end
       
       # Used to return the currently defined user_columns collection.
       def user_columns_for_display
          @user_columns || initialize_user_columns
       end
       
       # Used to override the default declarative values for a specific relationship.  Example usage:
       # <tt>relationship :books, :view => :inset_table, :summary => :list, :fields => [:title, :author]</tt>
       # Shows the list of all related books inline as [title]:[author]
       # When expanded, uses an inset table to show the books.
       def relationship(rel, opts = {})
         ensure_options_parity(opts)
         initialize_relationships unless @relationships
         options = self.define_association(model.reflect_on_association(rel), opts)
         @relationships[rel] = Streamlined::Relationships::Association.new(model.reflect_on_association(rel), Streamlined::Relationships::Views.create_relationship(options[:view], options[:view_fields]), Streamlined::Relationships::Summaries.create_summary(options[:summary], options[:fields]))         
       end
       
       # Given a relationship name, returns the View class representing it.
       def view_def(rel)
         opts = self.relationships[rel.to_sym]
         Streamlined::Relationships::Views.create_relationship(opts[:view], opts[:view_fields])
       end
       
       # Given a relationship name, returns the Summary class representing it.
       def summary_def(rel)
         opts = self.relationships[rel.to_sym]
         Streamlined::Relationships::Summaries.create_summary(opts[:summary], opts[:fields])
       end
       
       # Return list of all known relationships.
       def relationships
         
         if @relationships && @relationships != {}
         
           @relationships 
         else
         
           initialize_relationships
           
           return @relationships
         end
       end
       
       def all_columns
         model.columns + calculated_columns
        end

        def calculated_columns(*args)
         case args.length
         when 0
           @calculated_columns || []
         else
           @calculated_columns = []
           args.each { |a| @calculated_columns << Streamlined::Column.new(a) }
         end
        end
       
       private
       
       # Causes all relationships to be initialized to default values
       def initialize_relationships
         @relationships = {}
           self.default_model.reflect_on_all_associations.each do |assoc|
              relationship(assoc.name.to_sym, self.define_association(assoc)) unless @relationships[assoc.name.to_sym]
           end
         @relationships

       end
       
       # Intializes the user_columns using a regex match to eliminate the unneeded columns from the Model's default columns collection.
       def initialize_user_columns
        @user_columns = model.columns.reject {|d| d.name.match /(_at|_on|position|lock_version|_id|password_hash|id)$/ }
       end
       
       # Enforce parity of options on any relationship declaration.
       # * use of the :list summary requires a :fields declaration
       def ensure_options_parity(options)
        
        return if options == nil || options = {}
        raise ArgumentError, "Error in #{self.name} : Cannot specify *:summary => :list* without also specifying the :fields option (#{options.inspect})" if options[:summary] && options[:summary] == :list && !options[:fields]
       end
       
     end
  end
  
   class Column
     attr_accessor :name, :human_name

     def initialize(sym)
       @name = sym.to_s
       @human_name = sym.to_s.humanize
     end

   end
end

# if you have a better idea please tell stu at relevancellc dot com ...
unless defined? Streamlined::DISPATCHER_WRAPPED
  ActionController::Base.logger.debug "Aspecting Rails Dispatcher for Streamlined"
  (class <<Dispatcher; self; end).wrap_method :reset_application! do |m, *args|
    Streamlined::UI.reset_subclasses
    m.call(*args)
  end
  Streamlined::DISPATCHER_WRAPPED = true
end
