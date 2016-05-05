require 'discordrb'
require 'youtube-dl.rb'
require 'yt'

$playlist = Array.new

def play_newest_file(event, directory)
	filelist = Dir.entries("#{$root_dir}/#{directory}")
  #get those damn things out of here
  	filelist.delete(".")
  	filelist.delete("..")
		filelist.delete(".DS_Store")
  #let's figure out which file is newest in here, since that's the song that pianobarfly is likely currently playing
	 sorted_list = filelist.sort_by {|filename| File.ctime("#{$root_dir}/#{directory}/#{filename}")}
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
  	event.voice.play_file("#{$root_dir}/#{directory}/#{file_to_play}")
    #File.delete(file_to_play)
  #afterwards remove what's currently being played.
	 $bot.game=("Nothing.")
end

def start_pianobarfly(event)
	#check if pianobarfly is in our current folder
	Dir.chdir("#{$root_dir}")
	filelist = Dir.entries ('.')
	if filelist.include?('pianobarfly')
		puts "found Pianobarfly in current directory"
		write_pianobar_config()
		$pianobarfly = IO.popen("./pianobarfly", 'r+')
		event.respond "Starting Pianobarfly..."
	else
		puts "didn't find Pianobarfly in current directory, playing from \$PATH"
		write_pianobar_config()
	  $pianobarfly = IO.popen("pianobarfly", 'r+')
	  event.respond "Starting Pianobarfly..."
	end
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
  #File.delete("pianobarconfig")
    pianobarflyconfigfile = File.new("#{Dir.home}/.config/pianobarfly/config", "w+")
      pianobarflyconfigfile.puts("user = #{ENV['pandora_username']}")
      pianobarflyconfigfile.puts("password = #{ENV['pandora_password']}")
      pianobarflyconfigfile.puts("audio_format = #{ENV['pandora_audio_format']}")
      pianobarflyconfigfile.puts("autostart_station = #{ENV['pandora_station_id']}")
      pianobarflyconfigfile.puts("tls_fingerprint = #{ENV['pandora_tls_fingerprint']}")
      pianobarflyconfigfile.puts("audio_file_name = #{ENV['pandora_audio_file_name']}")
  pianobarflyconfigfile.close
end
def download_youtube(url)
	Dir.chdir("#{$root_dir}/playlist")
	youtubefilename = url.gsub("https://www.youtube.com/watch?v=", "")
	YoutubeDL.download url, output: "#{youtubefilename}"
	add_to_playlist("#{youtubefilename}")
end

def add_to_playlist(file)
	$playlist.push(file)
	#event.respond "#{$playlist}"
end

def play_playlist(event)
	Dir.chdir("#{$root_dir}/playlist")
	$playlistplaying = true
	until $playlistplaying == false do
		isfull = check_playlist_folder(event)
		if isfull == true
			play_newest_file(event)
			else
			$playlistplaying = false
		end
	end
end

def check_playlist_folder(event)
	playlist = Dir.entries("#{$root_dir}/playlist")
	playlist.delete(".")
	playlist.delete("..")
	playlist.delete(".DS_Store")
	if playlist.empty? == false
		puts "folder has stuff!"
		return true
	else
		puts "folder doesn't have stuff!"
		return false
	end
end

def youtube_to_object(url)
	#Dir.chdir ("#{$root_dir}/playlist")
	youtubeVideo = Yt::Video.new url: url
	videoid = url.gsub("https://www.youtube.com/watch?v=", "")
	YoutubeDL.download url, output: "#{$root_dir}/playlist/#{videoid}"
	filename = Dir["#{$root_dir}/playlist/#{videoid}*"]
	$songObject = Song.new("#{youtubeVideo.title}", "artist", "#{Time.at(youtubeVideo.duration).utc.strftime("%M:%S")}", "#{filename[0]}", "youtube")
	$playlist.entries.push($songObject)
end
