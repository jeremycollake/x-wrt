# Streamlined
# (c) 2005-6 Relevance, LLC. (www.relevancellc.com)
# Streamlined is freely distributable under the terms of an MIT-style license.
# For details, see http://streamlined.relevancellc.com
require "#{RAILS_ROOT}/app/controllers/application"
class StreamlinedController < ApplicationController
  before_filter :page_options

  require_dependencies :ui, Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].collect {|f| f.gsub(".rb", "")}
  depend_on :ui, Dir["#{RAILS_ROOT}/app/streamlined/*.rb"].collect {|f| f.gsub(".rb", "")}
  
  # When the controller is created, it establishes variables for help in 
  # rendering the generic views.  The following instance variables are 
  # available for all views:
  # * model_name   : The name of the model class being managed
  # * model        : The class itself
  # * model_symbol : The symbolized version of the model name
  # * model_ui     : The StreamlinedUI class that parallels the model
  # * model_table  : The table name of the model
  # * model_underscore : The underscored, lowercased name of the model
  # * managed_views : An array of names of rhtml templates that Streamlined uses
  # * managed_partials : An array of names of partials that Streamlined uses
  def initialize
    @model_name ||= Inflector.singularize(self.class.name.chomp("Controller"))
    @model = Class.class_eval(@model_name)
    @model_symbol = Inflector.underscore(@model_name).to_sym
    @model_ui = Class.class_eval(@model_name + "UI")
    @model_table = Inflector.tableize(@model_name)
    @model_underscore = Inflector.underscore(@model_name)
    @page_title = "Manage #{@model_name.pluralize}"
    @managed_views = ['list']
    @managed_partials = ['list', 'edit', 'show', 'new', 'form']
    logger.info("MODEL NAME: #{@model_name}")
    logger.info("MODEL: #{@model.inspect}")
  end

   def index
     list
     render :action => 'list'
   end

   # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
   verify :method => :post, :only => [ :destroy, :create, :update ],
          :redirect_to => { :action => :list }

   # Creates the list of items of the managed Model class. Default behavior
   # creates an Ajax-enabled table view that paginates in groups of 10.  The 
   # resulting view will use Prototype and XHR to allow the user to page
   # through the model instances.  
   #
   # If the URL includes the <code>atom=true</code> querystring variable, the
   # action will instead render the Atom feed of all items found for this 
   # model.
   #
   # If the request came via XHR, the action will render just the list partial,
   # not the entire list view.
   def list
     options = {:per_page => 10}
     options.merge! order_options
     if @page_options.filter?
       options.merge! :conditions=>@model.conditions_by_like(@page_options.filter)
     end
     if params[:atom]
       models = @model.find(:all, :conditions=>@model.conditions_by_like(@page_options.filter))
       @streamlined_items = models
     else
       model_pages, models = paginate Inflector.pluralize(@model_class).downcase.to_sym, options
       self.instance_variable_set("@#{Inflector.underscore(@model_name)}_pages", model_pages)
       self.instance_variable_set("@#{Inflector.tableize(@model_name)}", models)
       @streamlined_items = models
       @streamlined_item_pages = model_pages
     end
     render :partial => render_path('list') if request.xhr?
     render :template => 'streamlined/atom' if params[:atom]
   end

   # Opens the search view.  The default is a criteria query view.
   def search
     set_instance(@model.new)
     render(:partial => render_path('search'))
   end
   
   # Executes the search.  The default behavior is to create 
   # a criteria instance of the model being searched and execute
   # the find_by_criteria method on the Model class.
   def find
     set_instance(@model.new(params[@model_symbol]))
     @results = @model.find_by_criteria(get_instance)
     render(:partial => render_path('results'))
   end

   # Renders the Show view for a given instance.
   def show
     set_instance(@model.find(params[:id]))
      if request.xhr? && params[:from_window]
        @id = get_instance.id
        @con_name = controller_name
        render :update do |page|
          page.replace_html "show_win_#{@id}_content", :partial => render_path('show', :partial => true, :con_name => @con_name)
        end
      else
        render(:partial => render_path('show'))
      end
   end

   # Opens the model form for creating a new instance of the
   # given Model class.
   def new
     set_instance(@model.new)
     if request.xhr? && params[:from_window]
         @id = get_instance.id
         @con_name = controller_name
         render :update do |page|
           page.replace_html "show_win_new_content", :partial => render_path('new', :partial => true, :con_name => @con_name)
         end
     else
       render(:partial => render_path('new'))
     end
   end

   # Uses the values from the rendered form to create a new
   # instance of the model.  If the instance was successfully saved,
   # render the #show view.  If the save was unsuccessful, re-render
   # the #new view so that errors can be fixed.
   def create
     set_instance(@model.new(params[@model_symbol]))
     if get_instance.save
       if request.xhr? && params[:from_window]
         @id = get_instance.id
         @con_name = controller_name
         render :update do |page|
           page.replace_html "show_win_new_content", :partial => render_path('show', :partial => true, :con_name => @con_name)
         end
       else
         flash[:notice] = "#{@model_name} was successfully created."
         redirect_to :action => 'show', :id => get_instance, :layout => 'streamlined_window'
       end   
     else
       @id = get_instance.id
       @con_name = controller_name
       render :update do |page|
         page.replace_html "show_win_new_content", :partial => render_path('new', :partial => true, :con_name => @con_name)
       end
     end
   end

   # Opens the model form for editing an existing instance.
   def edit
     set_instance(@model.find(params[:id]))
      if request.xhr? && params[:from_window]
          @id = get_instance.id
          @con_name = controller_name
          render :update do |page|
            page.replace_html "show_win_#{@id}_content", :partial => render_path('edit', :partial => true, :con_name => @con_name)
          end
      else
        render(:partial => render_path('edit'))
      end
   end

   # Uses the values from the rendered form to update an existing
   # instance of the model.  If the instance was successfully saved,
   # render the #show view.  If the save was unsuccessful, re-render
   # the #edit view so that errors can be fixed.
   def update
     set_instance(@model.find(params[:id]))
      if get_instance.update_attributes(params[@model_symbol])
        if request.xhr? && params[:from_window]
          @id = get_instance.id
          @con_name = controller_name
          render :update do |page|
            page.replace_html "show_win_#{@id}_content", :partial => render_path('show', :partial => true, :con_name => @con_name)
          end         
        else
          flash[:notice] = "#{@model_name} was successfully updated."
          redirect_to :action => 'show', :id => get_instance, :layout => 'streamlined_window'
        end
      else
        @id = get_instance.id
        @con_name = controller_name
        render :update do |page|
          page.replace_html "show_win_#{@id}_content", :partial => render_path('edit', :partial => true, :con_name => @con_name)
        end
      end
   end

   # Deletes a given instance of the model class and re-renders the #list view.
   def destroy
     @model.find(params[:id]).destroy
     redirect_to :action => 'list'
   end

   # Renders the current scoped list of model instances as an XML document.  For example,
   # if the user is just looking at the #list view, it will render all the existing instances
   # of the Model.  However, if the user has used the filter to narrow the list, export_to_xml
   # will only render the current filter set to XML.
   def export_to_xml
     @headers["Content-Type"] = "text/xml"
     @headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(@model_name)}_#{Time.now.strftime('%Y%m%d')}.xml\""
     render(:text => @model.find_by_like(@page_options.filter).to_xml)
   end
   
   # Renders the current scoped list of model instances as a CSV document.  For example,
   # if the user is just looking at the #list view, it will render all the existing instances
   # of the Model.  However, if the user has used the filter to narrow the list, export_to_csv
   # will only render the current filter set to CSV.
   def export_to_csv
     @headers["Content-Type"] = "text/csv"
     @headers["Content-Disposition"] = "attachment; filename=\"#{Inflector.tableize(@model_name)}_#{Time.now.strftime('%Y%m%d')}.csv\""
     render(:text => @model.find_by_like(@page_options.filter).to_csv({:include_header => true}))
   end

   # Opens the relationship +view+ for a given relationship on the Model.  This means
   # replacing the +summary+ view with the expanded +view+, as defined in streamlined_ui 
   # and streamlined_relationships.
   def expand_relationship
     set_instance(@model.find(params[:id]))
     rel_type = get_rel_open(params[:relationship])
     @relationship_name = params[:relationship]
     @root = get_instance
     set_items_and_all_items(rel_type)
     render(:partial => rel_type.view_def.partial)
   end
   
   # Closes the expanded relationship +view+ and replaces it with the +summary+ view, 
   # as defined in streamlined_ui and streamlined_relationships.
   def close_relationship
     set_instance(@model.find(params[:id]))
     rel_type = get_rel_closed(params[:relationship])
     relationship_name = params[:relationship]
     # klass = Class.class_eval(params[:klass])
#      @klass_ui = Class.class_eval(params[:klass] + "UI")
     relationship = get_instance.class.reflect_on_all_associations.select {|x| x.name == relationship_name.to_sym}[0]
     @root = get_instance
     render(:partial => rel_type.summary_def.partial, :locals => {:item => get_instance, :relationship => relationship, :fields => rel_type.summary_def.fields})
   end
   
   # Add new items to the given relationship collection. Used by the #membership view, as 
   # defined in streamlined_relationships.
   def update_relationship
     items = params[:item]
      set_instance(@model.find(params[:id]))
      rel_name = params[:rel_name].to_sym
      get_instance.send(rel_name).clear
      klass = Class.class_eval(params[:klass])
      @klass_ui = Class.class_eval(params[:klass] + "UI")     
      relationship = @model_ui.relationships[rel_name]
      items.each do |id, onoff|
        get_instance.send(rel_name).push(klass.find(id)) if onoff == 'on'
      end
      get_instance.save
      if relationship.view_def.respond_to?(:render_on_update)
        @relationship_name = rel_name
        @root = get_instance
        set_items_and_all_items(relationship, params[:filter])
        render :update do |page|
          relationship.view_def.render_on_update(page, rel_name, params[:id])
        end
      else
        render(:nothing => true)
      end
   end
   
   # Add new items to the given relationship collection. Used by the #membership view, as 
   # defined in streamlined_relationships.
   def update_n_to_one
    item = params[:item]
    set_instance(@model.find(params[:id]))
    rel_name = "#{params[:rel_name]}=".to_sym
    if item == 'nil' || item == nil
      get_instance.send(rel_name, nil)
    else
      item_parts = item.split("::")
      if item_parts.size == 1
        new_item = Class.class_eval(params[:klass]).find(item)
      else
        new_item = Class.class_eval(item_parts[1]).find(item_parts[0])
      end
      get_instance.send(rel_name, new_item)
    end
    get_instance.save
    render(:nothing)
   end
   
   protected
   
   # Overrides the default ActionPack version of #render.  First, attempts
   # to render the request the standard way.  If the render fails, then 
   # attempts to render the Streamlined generic view of the same request.  
   # The method must first check if the request is for one of the managed_views
   # or managed_partials established at initialization time.  If so, it is 
   # rendered from the /app/views/streamlined/generic_views folder.  If not, the
   # exception that was originally thrown is propogated to the outer scope.
   def render(options = nil, deprecated_status = nil, &block) #:doc:
    begin
      super(options, deprecated_status, &block)
    rescue ActionView::TemplateError => ex 
      raise ex
    rescue Exception => ex
      if options
        if options[:partial] && @managed_partials.include?(options[:partial])
          options[:partial] = "/streamlined/generic_views/#{options[:partial]}"
          super(options, deprecated_status, &block)
        elsif options[:action] && @managed_views.include?(options[:action])
          super(:template => "/streamlined/generic_views/#{options[:action]}")
        else
          raise ex
        end
      else
        view_name = default_template_name.split("/")[-1]
        super(:template => "/streamlined/generic_views/#{view_name}")
      end
    end
   end
   
   
   private 
   def page_options
     @page_options = PageOptions.new(params[:page_options])
   end

   # rewrite of rails method
   def paginator_and_collection_for(collection_id, options) #:nodoc:
     klass = @model
     # page  = @params[options[:parameter]]
     page = @page_options.page
     count = count_collection_for_pagination(klass, options)
     paginator = Paginator.new(self, count, options[:per_page], page)
     collection = find_collection_for_pagination(klass, options, paginator)

     return paginator, collection 
   end

   def order_options
     if @page_options.order?
       {:order => @page_options.order.downcase.split(",").map { |x| 
         x.tr(" ", "_")
       }.join(" ")}
     else
       # override to set a default column sort, e.g. :order=>"col ASC|DESC"
       {}
     end
   end
   
   def get_instance
    self.instance_variable_get("@#{Inflector.underscore(@model_name)}")
   end

   def set_instance(value)
    self.instance_variable_set("@#{Inflector.underscore(@model_name)}", value)
    @streamlined_item = value
   end
   
   def get_rel_open(rel_name)
    @model_ui.relationships[rel_name.to_sym]
   end
   
   def get_rel_closed(rel_name)
    @model_ui.relationships[rel_name.to_sym]
   end
   
   def render_path(template, options = {:partial => true, :con_name => nil})
      options[:con_name] ||= controller_name
      template_file = "_#{template}" if options[:partial]
      File.exist?(File.join(RAILS_ROOT, 'app', 'views', options[:con_name], template_file + ".rhtml")) ? template : "/streamlined/generic_views/#{template}"
   end
   
   def set_items_and_all_items(rel_type, item_filter = nil)
      logger.debug("SET_ITEMS_AND_ALL_ITEMS: #{item_filter}")
      @items = get_instance.send(@relationship_name)
      if rel_type.associables.size == 1
        @klass = Class.class_eval(params[:klass])
        @klass_ui = Class.class_eval(params[:klass] + "UI")
        if item_filter
          @all_items = @klass.find(:all, :conditions => @klass.conditions_by_like(item_filter))
        else            
          @all_items = @klass.find(:all)
        end
      else
        @all_items = {}
        rel_type.associables.each do |klass|
          if item_filter
            @all_items[klass.name] = klass.find(:all, :conditions => klass.conditions_by_like(item_filter))
          else
            @all_items[klass.name] = klass.find(:all)
          end
        end
      end
   end
end