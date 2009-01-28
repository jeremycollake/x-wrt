class ConfigController < ApplicationController
  layout 'wib'

  before_filter :get_config

  def index
    if params[:from]
      from = params[:from].to_i
      if params[:commit] == 'Back'
        to = from - 1
      else
        to = from + 1
      end
      case from
        when 0
          @config.board = nil
          @config.packages = Array.new
          @config.filesystem = nil
          @config.profile = nil
        when 1
          if params[:config] && params[:config][:board]
            if @config.board
              board = Board.find(@config.board)
              @config.packages = Array.new
            end
            @config.board = params[:config][:board].to_i
          elsif to > from
            flash[:notice] = "Please select a target system."
            to = 1
          end
        when 2
          if params[:config] && params[:config][:filesystem]
            @config.filesystem = params[:config][:filesystem].to_i
          elsif to > from
            flash[:notice] = "Please select a filesystem."
            to = 2
          end
        when 3
          if params[:profile]
            if @config.profile
              profile = Profile.find(@config.profile)
              for package in profile.packages
                @config.packages.delete(package.id)
              end
            end
            profile = Profile.find(params[:profile].to_i)
            @config.profile = profile.id
            for package in profile.packages
              @config.packages << package.id
            end
          elsif to > from
            flash[:notice] = "Please select a target profile"
            to = 3
          end
        when 4
          if (params[:oldcat])
            save_packages(params[:oldcat],params[:packages])
          end
	when 5
	  save_preconfig()
      end
    else
      to = 0
    end
    if to >= 0 and to <= 6
      redirect_to :action => "step#{to}"
    end
  end

  def step0
    @step = 0
  end

  def step1
    boards = Board.find(:all)
    @boards = Array.new
    for board in boards
      @boards.push(board)
    end
    @boards.sort! { |x,y| x.name <=> y.name }
    @step = 1
  end

  def step2
    if @config and @config.board
      board = Board.find(@config.board)
      fs = Filesystem.find(:all)
      @filesystems = Array.new
      for f in fs
        if f.boards.include?(board)
          @filesystems.push(f)
        end
      end
      @step = 2
    else 
      redirect_to :action => "step0"
    end
  end

  def step3
    if @config and @config.filesystem
      board = Board.find(@config.board)
      @profiles = board.profiles
      @step = 3
    else
      redirect_to :action => "step0"
    end
  end

  def step4
    if @config and @config.profile
      @categories = Category.find(:all)
      @step = 4
      resolve_dependencies()
    else
      redirect_to :action => "step0"
    end
  end

  def step5
    @step = 5
    if @config and @config.packages.length > 0
      fetch_preconfig()
    else
      redirect_to :action => "step0" 
    end
  end

  def step6
    if @config and @config.packages.length > 0
      @step = 6
      resolve_dependencies()
    else
      redirect_to :action => "step0" 
    end
  end

  def packages
    if (params[:oldcat])
      save_packages(params[:oldcat],params[:packages])
    end
    if (params[:category] and params[:category] != 'none')
      board = Board.find(@config.board)
      @category = Category.find(params[:category].to_i)
      @packages = board.packages
      @packages.delete_if { |x| x.category_id != @category.id }
      @packages = @packages.sort {|x,y| x.name <=> y.name}
    end
    render(:partial => "packages")
  end
  
  def create_image 
    @step = 5
    build_dir = "#{RAILS_ROOT}/tmp/build.#{@config.id}"
    ticket_dir = "#{RAILS_ROOT}/tmp/tickets"
    @queued = 0
    for dir in [ build_dir, ticket_dir ]
      if !FileTest.directory?(dir)
        Dir.mkdir(dir)
      end
    end

    if File.exists?("#{build_dir}/command.sh")
      @queued = queue_place()
    end

    board = Board.find(@config.board)
    filesystem = Filesystem.find(@config.filesystem)
    ids = @config.packages.join(',')
    packages = Package.find(:all, :conditions => "id in (#{ids})")
    @packages = Array.new
    @packages.push("base-files-#{board.name}-#{board.kernel}")
    @packages.push("kernel")
    for package in packages
      @packages.push(package.name)
    end

    f = File.new("#{board.path}/.preconfig-#{@config.id}", "w")
    f.write(@config.preconfig.join("\n"))
    f.close

    f = File.new("#{build_dir}/command.sh", "w");
    command = "(cd #{RAILS_ROOT} && \
    	rm -rf tmp/files.#{@config.id} && \
        cp -fpR #{board.path}/build_#{board.arch}/* tmp/build.#{@config.id} && \
	cp #{board.path}/.config #{board.path}/.config1 && \
	( grep -v '^CONFIG_UCI_PRECONFIG' #{board.path}/.config1; cat #{board.path}/.preconfig-#{@config.id} ) > #{board.path}/.config && \
	rm -f #{board.path}/.config1 #{board.path}/.preconfig-#{@config.id} && \
        make -C #{board.path} image \
                BUILD_DIR=\"$PWD/tmp/build.#{@config.id}\" \
                BUILD_PACKAGES='#{@packages.join(' ')}' \
                BIN_DIR=\"$PWD/tmp/files.#{@config.id}\" \
                V=99 && \
        rm -rf tmp/build.#{@config.id}; \
    ) 2>&1 >& tmp/build.#{@config.id}.log && rm -f tmp/build.#{@config.id}.log"

    f.write(command)
    f.close
    if @queued <= 0
      ticket = `(cd #{RAILS_ROOT}; ./qrunner.pl add tmp/build.#{@config.id}/command.sh)`
      f = File.new("#{RAILS_ROOT}/tmp/tickets/#{@config.id}", "w")
      f.write(ticket);
      f.close
      @queued = queue_place()
    end
    @timeout = 8000
#    if @error_code != 0
#      Notifier::deliver_error_message(@output[@output.rindex("\n"), @output.length])
#    end
#    @image_id = @config.id
    render(:partial => "waiting")
  end

  def wait_for_image
    @queued = queue_place()
    if (@queued > 0)
      render(:partial => "waiting")
    elsif (!File.exists?("#{RAILS_ROOT}/tmp/files.#{@config.id}"))
      @error = "Build failed!"
      render(:partial => "error")
    else
      @files = Array.new
      Dir.foreach("#{RAILS_ROOT}/tmp/files.#{@config.id}") { |x| @files.push(x) if x =~ /^openwrt-/ }
      render(:partial => "download")
    end
	    
  end

  def download
    filename = params[:filename]
    if (filename =~ /^openwrt-[a-z0-9_\.\-]+\.[\w\-]+$/)
      send_file("#{RAILS_ROOT}/tmp/files.#{@config.id}/#{filename}", :filename => filename)
    else
      @error = "Invalid Filename"
      render(:partial => "error")
    end
  end

  private

  def queue_place()
    ticket = `cat #{RAILS_ROOT}/tmp/tickets/#{@config.id}`
    ticket.chomp!
    queued = `(cd #{RAILS_ROOT}; ./qrunner.pl place #{ticket})`
    return queued.chomp.to_i
  end

  def fetch_preconfig()
    @preconfig = Array.new
    cfgs = Preconfig.find(:all)
    for cfg in cfgs
      pkg = cfg.package
      if (!@preconfig.include?(pkg) && @config.packages.include?(pkg.id))
	@preconfig.push(cfg.package)
      end
    end
  end

  def save_preconfig()
    fetch_preconfig()
    @config.preconfig = Array.new
    for pkg in @preconfig
      for cfg in pkg.preconfigs
	cfgid = cfg.configstr.gsub(/[\-\.]/, "_")
	# FIXME: add validation
	@config.preconfig.push("CONFIG_UCI_PRECONFIG_" + cfgid + "=\"" + (params["preconfig_#{cfgid}"] ? params["preconfig_#{cfgid}"].gsub(/[\$"\\'\n]/, "") : "") + "\"")
      end
    end
  end

  def save_packages(cat_id, pids)
    package_ids = Array.new
    if pids
      for id in pids
        package_ids << id.to_i
      end
    end
    category = Category.find(cat_id.to_i)
    packages = Package.find(:all, :conditions => ["category_id = ?", category.id]);
    for package in packages
      @config.packages.delete(package.id)
      if package_ids.include?(package.id)
        @config.packages << package.id
      end
    end
  end
 
  def resolve_dependencies()
    ids = @config.packages.join(',')
    packages = Package.find(:all, :conditions => "id in (#{ids})");
    for package in packages
      begin
        changed = 0
        for dependency in package.dependencies
          if !@config.packages.include?(dependency.id)
            @config.packages << dependency.id
            changed = 1
          end
        end
      end until changed == 0
    end
  end

  def get_config
    if @session['config']
      @config = @session['config']
    else
      @config = Configuration.new
      @session['config'] = @config
    end
  end
end
# vim:ts=8
