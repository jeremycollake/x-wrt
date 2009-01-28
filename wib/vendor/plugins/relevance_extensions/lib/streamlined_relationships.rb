# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
#
# The Streamlined module is the top-level container module for all Streamlined code.
module Streamlined
  # The Relationships module is for adding custom reflection and Streamlined-specific
  # functionality to the ActiveRecord relationship infrastructure.
  module Relationships
    # Common functionality for relationship types.  
    class Base
      attr_reader :fields
      attr_reader :association
      
      # When creating a relationship manager, specify the list of fields that will be 
      # rendered at runtime.
      def initialize(fields = nil)
        @fields = fields
      end
      
      
      def logger
        ActiveRecord::Base.logger
      end
      
      # Returns the string representation used to create JavaScript IDs for this relationship type.
      def id_fragment
        return Inflector.demodulize(self.class.name)
      end
      
      # Returns the path to the partial that will be used to render this relationship type.
      def partial
        mod = self.class.name.split("::")[-2]
        "/streamlined/relationships/#{mod.downcase}/#{Inflector.underscore(Inflector.demodulize(self.class.name))}"
      end
      
    end
    
    class Association
      attr_reader :underlying_association
      attr_reader :view_def
      attr_reader :summary_def
      
      def initialize(assoc, view, summary)
        @underlying_association = assoc
        @view_def = view
        @summary_def = summary
      end
      
      def logger
        ActiveRecord::Base.logger
      end
      
      def associables        
        return [Class.class_eval(@underlying_association.class_name)] unless @underlying_association.options[:polymorphic]
        results = []
        ObjectSpace.each_object(Class) do |klass|
          results << klass if klass.ancestors.include?(ActiveRecord::Base) && klass.reflect_on_all_associations.collect {|a| a.options[:as]}.include?(@underlying_association.name)
        end
        return results
      end
    end
    
    # The Views module is for classes that represent expanded views of a relationship.  
    module Views
      # Factory method for creating a relationship View given the name of a view.
      def self.create_relationship(sym, options = nil)
        Class.class_eval(Inflector.camelize(sym.to_s)).new options
      end  
      
      # Renders an Ajax-enabled table, with add/edit/delete capabilities.
      class InsetTable < Streamlined::Relationships::Base
        
      end
      
      # Renders an Ajax-enabled checkbox list for managing which items belong to the collection.
      class Membership < Streamlined::Relationships::Base
        
      end
      
      # Like Membership, but lists all possibles from multiple polymorphic associables
      class PolymorphicMembership < Streamlined::Relationships::Base
        
      end
      
      # Renders an Ajax-enabled table in a JavaScript window.
      class Window < Streamlined::Relationships::Base
        def partial
          "/streamlined/relationships/views/inset_table"
        end
      end
      
      # Renders a select box with all possible values plus "unassigned". Used for n-to-one relationships.
      class Select < Streamlined::Relationships::Base
        
      end
      
      # Like Select, but lists all possibles from multiple polymorphic associables
      class PolymorphicSelect < Streamlined::Relationships::Base
        
      end
      
      # Like Membership, but with two distinct groups of checkboxes and an autofilter field
      class FilterSelect < Streamlined::Relationships::Base
      
        def render_on_update(page, rel_name, id)
          page.replace_html "rel_#{rel_name}_#{id}_unselected", :partial => '/streamlined/relationships/views/filter_select/unselected_items'
          page.replace_html "rel_#{rel_name}_#{id}_selected", :partial => '/streamlined/relationships/views/filter_select/selected_items'
        end
      end
      
      # Suppresses rendering of the expanded relationship view.
      class None < Streamlined::Relationships::Base
        def partial
          nil
        end
      end
    end
    
    # The Summaries module is for classes that represent summary or in-line views of a relationship.
    module Summaries
      
      # Factory method for creating a relationship Summary given the name of a summary.
      def self.create_summary(sym, options = nil)
        if options
          Class.class_eval(Inflector.camelize(sym.to_s)).new options
        else
          Class.class_eval(Inflector.camelize(sym.to_s)).new
        end
      end
      
      # Renders a count of the total number of members of this collection.
      class Count < Streamlined::Relationships::Base
        
      end
      
      # Renders a list of values, as defined by the #fields attribute.  For each member of the collection, renders those 
      # fields in a concatenated string.
      class List < Streamlined::Relationships::Base

      end
      
      # Renders the sum of a given attribute of the related models.  The field is specified as the single member of the #fields attribute.
      class Sum < Streamlined::Relationships::Base

      end
      
      # Renders the streamlined_name of the other end of the relationship.  Used for n-to-one relationships.
      class Name < Streamlined::Relationships::Base
        
      end
      
      # Suppresses in-line relationship rendering.
      class None < Streamlined::Relationships::Base
      end
    end
  end
end

        
