require "zipruby"
require "base64"

def list(dir)
  files = Dir.entries("#{settings.file_root + dir}").sort do |a, b|
    a.downcase <=> b.downcase
  end

  return files.select do |filename|
    filename[0] != "."
  end.map do |filename|
    dir + "/" + filename
  end
end

def full(path)
  settings.file_root + path
end
# View File
get '/view/*' do |dir|
  @path = "/"+dir.to_s.strip

  TagLib::MPEG::File.open(full(@path)) do |file|
    cover = file.id3v2_tag.frame_list('APIC').first
    if cover
      @image = "data:#{cover.mime_type};base64,#{Base64.encode64 cover.picture}"
    end
  end

  TagLib::FileRef.open(full(@path)) do |fileref|
    unless fileref.null?
      tags = fileref.tag

      puts(tags.methods.inspect)
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
  @path = "/"+dir.to_s.strip

  tempnam = (Tempfile.new 'zip').path

  Zip::Archive.open(tempnam) do |archive|
    list(@path).each do |path|
      full_path = full(path)
      if not File.directory?(full_path)
        archive.add_buffer(File.basename(full_path), File.read(full_path));
      end
    end
  end

  return "X"
  send_file tempnam,
    :filename => File.basename(@path)+".zip"
end

# Download
get '/download/*' do |dir|
  @path = "/"+dir.to_s.strip

  content_type File.extname(@path)

  # nginx optimisation
  # headers "X-Accel-Redirect" => "/files#{@path}"
  # Set disposition

  send_file full(@path),
    :filename => File.basename(@path)
end

# Play
get '/play/*' do |dir|
  @path = "/"+dir.to_s.strip

  content_type File.extname(@path)

  # nginx optimisation
  # headers "X-Accel-Redirect" => "/files#{@path}"

  send_file full(@path),
    :filename => File.basename(@path),
    :disposition => :inline
end
