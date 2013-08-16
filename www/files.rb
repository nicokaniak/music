require "zipruby"

def list(dir)
  Dir.entries("#{settings.file_root + '/' + dir}").sort do |a, b|
    a.downcase <=> b.downcase
  end
end

# View File
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

# Zipped download
get '/zip/*' do |dir|
  @path = dir.to_s.strip

  tempnam = (Tempfile.new 'zip').path

  Zip::Archive.open(tempnam) do |archive|
    list(@path).each do |x|
      next if x[0, 1] == '.'

      full_path = settings.file_root + '/' + @path + '/' + x

      if not File.directory?(full_path)
        archive.add_buffer(File.basename(full_path), File.read(full_path));
      end
    end
  end

  send_file tempnam,
    :filename => File.basename(@path)+".zip"
end

# Download
get '/download/*' do |dir|
  @path = dir.to_s.strip

  content_type File.extname(@path)
  headers "X-Accel-Redirect" => "/files/#{@path}"

  "Sending #{@path}"
end


