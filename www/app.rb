require './config'
require 'sinatra'
require 'bcrypt'
require 'taglib'

require './auth'

# Set utf-8 for outgoing
before do
  headers "Content-Type" => "text/html; charset=utf-8"
end

# Helpers
helpers do
  def site_title
    'music.submarin.es'
  end
end

# Select File
get '/view/*' do |dir|
  @path = dir.to_s.strip

  TagLib::FileRef.open("#{settings.file_root + '/' + @path}") do |fileref|
    unless fileref.null?
      tags = fileref.tag

      @artist = tags.artist
      @album = tags.album
      @year = tags.year

      @track = tags.track
      @title = tags.title

      prop = fileref.audio_properties
      @length = prop.length
    end
  end
  erb :view
end


# List Directory
get '/browse/*?' do |dir|

  # Build Path from URL parameters
  @path = dir.to_s.strip

  # Path to the Parent of the directory
  @parent = File.dirname(@path)

  # Generate breadcrumb style links from the path
  @breadcrumb = [] # Array to store the links

  paths = @path.split('/')
  paths.each_with_index do |item, index|
    @breadcrumb[index] = {
      "caption" => item
    }
    if index < paths.length-1
      @breadcrumb[index]["href"] = "/browse/#{paths[0..index].join('/')}"
    end
  end

  # Get a list of files and directories in the current directory
  @directories = ""
  @files = ""
  Dir.foreach("#{settings.file_root + '/' + @path}") do |x|
    next if x[0, 1] == '.'

    full_path = settings.file_root + '/' + @path + '/' + x

    if File.directory?(full_path)
      @directories << "\n<li class=\"dir\"><a href=\"/browse/#{@path + '/' + x}\">#{x}</a></li>"
    else
      ext = File.extname(full_path)
      @files << "\n<li class=\"file-#{ ext[1..ext.length-1]}\"><a href=\"/view/#{@path + '/' + x}\">#{x}</a></li>"
    end
  end

  erb :browse
end

get '/users' do
  @users = User.all
  erb :users
end

post '/update/' + settings.update_token do
  exec 'git pull origin master'
  Process::exit 0
end

get '/' do
  erb :index
end
