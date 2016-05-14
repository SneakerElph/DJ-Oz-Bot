class Song
  attr_accessor :name, :artist, :length, :filename, :origin, :requester, :played
    def initialize(name, artist, length, filename, origin, requester)
      @name = name
      @artist = artist
      @length = length
      @filename = filename
      @origin = origin
      @requester = requester
      @played = false
    end

    def play(event)
      $bot.game=("#{@name} by #{@artist}")
      voicebot = $bot.voice_connect($current_voice_channel)
      voicebot.volume = $botvolume
      #event.respond "Now Playing: #{@name} [#{Time.at(@length).utc.strftime("%M:%S")}]. Filename: #{@filename}"
      event.respond "Now Playing: **#{@name}**. Requested by **#{@requester}**"
      event.voice.play_file("#{@filename}")
    end

    def delete(event)
      File.delete("#{@filename}")
      puts "deleting #{@filename}"
    end

end

class Playlist
  attr_accessor :entries
  def initialize
    @entries = Array.new
  end

  def play(event)
    #voicebot = $bot.voice_connect($current_voice_channel)
    for entry in @entries do
      if entry.played == false
        entry.play(event)
        entry.played = true
      end
      #entry.delete(event)
      #@entries.delete_at(0)
    end
  end

  def add(song)
    @entries.push(song)
  end

  def empty
    for entry in @entries do
      if entry.played == false
        return false
        break
      end
    end
  end

  def length_unplayed
    length = 0
    for entry in @entries do
      if entry.played == false
        length = length + entry.length
      end
    end
    return length
  end

  def length_total
    length = 0
    for entry in @entries do
      legnth = length + entry.length
    end

    return length
  end

  def clear
      @entries.clear
  end
end

class Pandora
  attr_accessor :name, :artist, :running, :playing, :currentfilename, :user, :station_id,
  def initialize()
    @name = name #name of the song currently playing
    @artist = artist #name of artist currently playing
    @running = nil #Is Pianobarfly running? True or False
    @playing = nil #Is a song currently being played? True or False
    @currentfilename = nil #filename of what's currently being played.
    @user = ENV['pandora_username'] #pandora user name. Found in config.rb
    @password = ENV['pandora_password'] #pandora password. Found in config.rb
    @audio_format = ENV['pandora_audio_format'] #pandora audio format. Found in config.rb
    @station_id = ENV['pandora_station_id'] #station that will be played Found in config.rb
    @tls_fingerprint = ENV['pandora_tls_fingerprint'] #TLS fingerprint. Also in config.rb
    @audio_filename = ENV['pandora_audio_file_name'] #The format the audio files will be named in. Used for scraping @name and @artist
  end

  def play(event)
    #@playing = true
    #until @playing == false
      filelist = Dir.entries("#{$root_dir}/mp3")
      #get those damn things out of here
      	filelist.delete(".")
      	filelist.delete("..")
    		filelist.delete(".DS_Store")
      #let's figure out which file is newest in here, since that's the song that pianobarfly is likely currently playing
    	 sorted_list = filelist.sort_by {|filename| File.ctime("#{$root_dir}/mp3/#{filename}")}
      #This list is backwards, sort the other way plz!
      	sorted_list.reverse!
      	@currentfilename = sorted_list[0]
      #create the all-powerful VOICEBOT
    	 voicebot = $bot.voice_connect($current_voice_channel)
       voicebot.volume = $botvolume
      #show me the list because I don't trust you did it correctly
    	 puts sorted_list
      #Set the "Now Playing" part of the bot to be the filename with any underscores replaced with spaces
      #Hopefully we don't play songs/artists with actual underscores in their names or SHIT WILL GET CRAZY INACCURATE YO
    	 $bot.game=(@currentfilename.gsub(".m4a" , "").gsub("_", " "))
      #tell the server we're doing something
    	 event.respond "Now Playing: **#{@currentfilename.gsub(".m4a", "").gsub("_", " ")}** on Pandora Radio"
      #AW YEAH PLAY IT BABYYYYYYYYYYYYY
      	event.voice.play_file("#{$root_dir}/mp3/#{@currentfilename}")
        File.delete("#{$root_dir}/mp3/#{@currentfilename}")
      #afterwards remove what's currently being played.
    	 $bot.game=("Nothing.")
     #end
  end

  def start(event)
    #check if pianobarfly is in our current folder
  	Dir.chdir("#{$root_dir}")
  	filelist = Dir.entries ('.')
  	if filelist.include?('pianobarfly')
  		puts "found Pianobarfly in current directory"
  		#@writeconfig(event)
  		@pianobarfly = IO.popen("./pianobarfly", 'r+')
  		event.respond "Starting Pandora..."
  	else
  		puts "didn't find Pianobarfly in current directory, playing from \$PATH"
  		#@writeconfig(event)
  	  @pianobarfly = IO.popen("pianobarfly", 'r+')
  	  event.respond "Starting Pandora..."
  	end
    @running = true
  end
  def stop(event)
      @playing = false
      @running = false
      event.voice.stop_playing
      @pianobarfly.print 'q'
  end

  def pause_pianobarfly
    @pianobarfly.print 'S'
  end

  def resume_pianobarfly
    @pianobarfly.print 'P'
  end

  def writeconfig(event)
    pianobarflyconfigfile = File.new("#{Dir.home}/.config/pianobarfly/config", "w+")
      pianobarflyconfigfile.puts("user = #{@user}")
      pianobarflyconfigfile.puts("password = #{@password}")
      pianobarflyconfigfile.puts("audio_format = #{@audio_format}")
      pianobarflyconfigfile.puts("autostart_station = #{@station_id}")
      pianobarflyconfigfile.puts("tls_fingerprint = #{@tls_fingerprint}")
      pianobarflyconfigfile.puts("audio_file_name = #{@audio_filename}")
    pianobarflyconfigfile.close
    puts "wrote Pianobarfly config"
  end

  def skip
    @pianobarfly.print 'n'
    puts "Skipping Pandora song..."
  end
end
