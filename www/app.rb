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

get '/stylesheet' do
  content_type "text/css"
  less :main, {
    :views => settings.root + "/style"
  }
end

# List Directory
get '/browse/*?' do |dir|
  @path = "/"+dir.to_s.strip

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
  @directories = []
  @files = []

  list(@path).each do |path|
    full_path = settings.file_root + path

    uri_path = URI::encode(path)
    uri_path = URI::encode(uri_path, '[]')

    if File.directory?(full_path)
      @directories.push \
        :uri => uri_path,
        :name => File.basename(path)
    else
      @files.push \
        :ext => File.extname(full_path),
        :uri => uri_path,
        :name => File.basename(path)
    end
  end

  if @directories.empty?
    erb :listing
  else
    erb :browse
  end
end

get '/users' do
  @users = User.all
  erb :users
end

get '/' do
  erb :index
end
