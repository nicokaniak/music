require './config'
require 'sinatra'
require 'bcrypt'
require 'taglib'
require 'open-uri'

require './auth'
require './system'
require './files'

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

configure do
  mime_type :flac, 'audio/flac'
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
  list(@path).each do |x|
    next if x[0, 1] == '.'

    full_path = settings.file_root + '/' + @path + '/' + x

    uri_path = URI::encode(@path + '/' + x)
    uri_path = URI::encode(uri_path, '[]')

    if File.directory?(full_path)
      @directories << "\n<li class=\"dir\">" +
        "<a href=\"/browse/#{uri_path}\">#{x}</a>" +
        " (<a href=\"/zip/#{uri_path}\">zip</a>)" +
        "</li>"
    else
      ext = File.extname(full_path)
      @files << "\n<li class=\"file-#{ ext[1..ext.length-1]}\"><a href=\"/download/#{uri_path}\">#{x}</a></li>"
    end
  end

  erb :browse
end

get '/users' do
  @users = User.all
  erb :users
end

get '/' do
  erb :index
end
