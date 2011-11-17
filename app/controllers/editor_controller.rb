class EditorController < ApplicationController
  def index

  end

  def save
    render :json => {
      :error => '2',
      :msg => "Couldn't write to file: $path"
    }
  end

  def browse
    Dir.chdir File.join(Rails.root, "app", "assets")
    if not params['dir'].empty?
      parent = File.dirname(params['dir'])
    else
      parent = false
    end

    files = []
    case params[:type]
    when 'images'
      Dir.chdir 'images'
      files = Dir.glob '*.{png,gif,jpg,jpeg}'
      files = files.map do |file|
        File.join 'assets', file
      end
    when 'scripts'
      Dir.chdir File.join('javascripts', params['dir'])
      files = Dir.glob '*.{js,js.coffee}'
      dirs = Dir.glob('*').select do |dir|
        File.directory?(dir)
      end
    end
    render :json => {
      :parent => parent,
      :dirs => dirs,
      :files => files
    }
  end

  def glob
    if params[:glob].kind_of?(Array)
      globs = params[:glob]
    else
      globs = [params[:glob]]
    end
    
    Dir.chdir File.join(Rails.root, "app", "assets", 'javascripts')
    files = []
    globs.each do |glob|
      files += Dir.glob(glob)
    end
    
    render :json => files
  end
end
