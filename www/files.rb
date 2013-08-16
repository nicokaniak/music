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

# Download
get '/download/*' do |dir|
  @path = dir.to_s.strip

  headers "X-Accel-Redirect" => "/files/#{@path}"

  "Sending #{@path}"
end


