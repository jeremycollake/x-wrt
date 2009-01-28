class HelpController < ApplicationController

  layout "help"

  def step1
    @title = "Device Selection"
  end

  def step2
  end

  def step3
    @title = "Filesystem Selection"
  end

  def step4
    @title = "Package Preselections"
  end
  
  def step5
    @title = "Finetuning your package selection"
  end

end
