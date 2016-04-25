require 'discordrb'

def play_newest_file(event)
	filelist = Dir.entries('.')
  #get those damn things out of here
  	filelist.delete(".")
  	filelist.delete("..")
  #let's figure out which file is newest in here, since that's the song that pianobarfly is likely currently playing
	 sorted_list = filelist.sort_by {|filename| File.ctime(filename)}
  #This list is backwards, sort the other way plz!
  	sorted_list.reverse!
  	file_to_play = sorted_list[0]
  #create the all-powerful VOICEBOT
	 voicebot = $bot.voice_connect($current_voice_channel)
  #show me the list because I don't trust you did it correctly
	 puts sorted_list
  #Set the "Now Playing" part of the bot to be the filename with any underscores replaced with spaces
  #Hopefully we don't play songs/artists with actual underscores in their names or SHIT WILL GET CRAZY INACCURATE YO
	 $bot.game=(file_to_play.gsub(".m4a" , "").gsub("_", " "))
  #tell the server we're doing something
	 event.respond "Now Playing: **#{file_to_play.gsub(".m4a", "").gsub("_", " ")}**"
  #AW YEAH PLAY IT BABYYYYYYYYYYYYY
  	event.voice.play_file(file_to_play)
    File.delete(file_to_play)
  #afterwards remove what's currently being played.
	 $bot.game=("Nothing.")
end

def start_pianobarfly(event)
  Dir.chdir("#{$root_dir}")
  $pianobarfly = IO.popen("pianobarfly", 'r+')
  event.respond "Starting Pianobarfly..."
end

def stop_pianobarfly(event)
  $pianobarfly.print 'q'
  event.respond "Pianobarfly stopped."
end

def change_station(event)
  puts "#{$pianobarfly.readlines}"
  $pianobarfly.print 's'
end

def write_pianobar_config()
  File.delete("pianobarconfig")
    pianobarflyconfigfile = File.new("pianobarconfig", "w+")
      pianobarflyconfigfile.puts("user = #{ENV['pandora_username']}")
      pianobarflyconfigfile.puts("password = #{ENV['pandora_password']}")
      pianobarflyconfigfile.puts("audio_format = #{ENV['pandora_audio_format']}")
      pianobarflyconfigfile.puts("autostart_station = #{ENV['pandora_station_id']}")
      pianobarflyconfigfile.puts("tls_fingerprint = #{ENV['pandora_tls_fingerprint']}")
      pianobarflyconfigfile.puts("audio_file_name = #{ENV['pandora_audio_file_name']}")
  pianobarflyconfigfile.close
end
