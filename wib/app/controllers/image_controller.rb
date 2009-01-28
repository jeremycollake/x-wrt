class ImageController < ApplicationController

  def get
    filename = params[:id]
    path = "public/images/"
    if File.exist?(path + filename)
      send_file(path + filename)
    else
      send_file(path + "transparent.png")
    end
  end

end
