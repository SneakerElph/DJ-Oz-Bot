#This bot is a really janky way to play some pandora tuneskis with your bros on Discord


require 'discordrb'
require './config.rb'
require './classes.rb'
require 'yt'
require 'youtube-dl.rb'

def youtube_to_object(event, url)
	youtubeVideo = Yt::Video.new url: url
	videoid = url.gsub("https://www.youtube.com/watch?v=", "")
	event.respond "Downloading #{youtubeVideo.title}"
	YoutubeDL.download url, output: "#{$root_dir}/playlist/#{youtubeVideo.title}"
	filename = Dir["#{$root_dir}/playlist/#{youtubeVideo.title}*"]
	songObject = Song.new("#{youtubeVideo.title}", "artist", "#{youtubeVideo.duration}".to_i, "#{filename[0]}", "youtube", "#{event.author.name}")
	$playlist.add(songObject)
	time_until_played = $playlist.length_unplayed - songObject.length
end

Yt.configuration.api_key = youtubeAPIKey
$root_dir=Dir.pwd
$current_voice_channel = ENV['current_voice_channel']
$bot = Discordrb::Commands::CommandBot.new token: ENV['discord_token'], application_id: ENV['application_id'], prefix: ENV['prefix']
$pandora = Pandora.new
$playlist = Playlist.new
$botvolume = 0.5

$bot.command(:channels) do |event|
	 event.respond 'Check these channels and ID\'s'
	 server_channels = event.server.channels
	 for i in server_channels
		 event.respond "#{i.name}: #{i.id}'"
	 end
	 nil
end

$bot.command(:pause) do |event|
	event.voice.pause
	nil
end

$bot.command(:resume) do |event|
	event.voice.continue
	nil
end

$bot.command(:stop) do |event|
	event.voice.stop_playing
	$songplaying = false
	$musicplaying = false
	if $pandora.running == true
		$pandora.stop(event)
		$pandora.running = false
		$pandora.playing = false
	end
	$bot.game=("Nothing.")
	nil
end

$bot.command(:startpandora) do |event|
	$pandora.writeconfig(event)
	$pandora.start(event)
	nil
end

$bot.command(:playpandora) do |event|
	if $pandora.running == true
		$pandora.play(event)
	else
		event.respond "Pianobarfly isn't running. Something went wrong. You probably didn't start it."
	end
end

$bot.command(:botrename) do |event|
	$bot.profile.username = ENV['pandorabot_name']
	event.respond "Bot's name is now #{$bot.profile.username}"
	nil
end

$bot.command(:stoppandora) do |event|
	$pandora.stop(event)
end

$bot.command(:playpandora) do |event|
	start_pianobarfly(event)
	sleep 5
	$songplaying = true
	Dir.chdir("#{$root_dir}/mp3")
	until $songplaying == false do
		play_newest_file(event)
	end
end

$bot.command(:playmusic) do |event|
	#check if there's stuff in playlist folder
	#if not, start pianobarfly and play pandora
	#after every song check playlist folder again
if $musicplaying == true
	event.respond "Music is already playing."
	break
end
	$musicplaying = true
	until $musicplaying == false
		if $playlist.empty == false
				$playlist.play(event)
		else
				event.respond "Nothing Queued,"
				$pandora = Pandora.new
				$pandora.writeconfig(event)
				 $pandora.start(event)
				 sleep 5
				 $pandora.playing = true
				 until $pandora.playing == false do
					 $pandora.play(event)
					 if $playlist.empty == false
						 $pandora.stop(event)
						 $pandora.playing = false
					 end
				 end
		 	end
		end
end

$bot.command(:addsong) do |event, text|
	$voicebot = $bot.voice_connect($current_voice_channel)
	time_until_played = youtube_to_object(event, text)
	event.respond "Added **#{$playlist.entries.last.name} [#{Time.at($playlist.entries.last.length).utc.strftime("%M:%S")}]** to playlist. Time until played: **#{Time.at(time_until_played - $voicebot.stream_time.to_i).utc.strftime("%M:%S")}**"
end

$bot.command(:playsong) do |event|
	$playlist.play(event)
	nil
end

$bot.command(:playlist) do |event|
	message = ""
	if $playlist.entries.empty?
		event.respond "Nothing in the list."
	else
			for e in $playlist.entries do
				if e.played == true
					message = message + "*#{e.name} - [#{Time.at(e.length).utc.strftime("%M:%S")}] - Requested by* ***#{e.requester}***\n"
				else
					message = message + "#{e.name} - **[#{Time.at(e.length).utc.strftime("%M:%S")}]** - Requested by **#{e.requester}**\n"
				end
			end
		event.respond "#{message}\n**Total time left to play: #{Time.at($playlist.length_unplayed - $voicebot.stream_time.to_i).utc.strftime("%M:%S")}**"
	end
	nil
end
$bot.command(:clear) do |event|
		$playlist.clear
		event.respond "Playlist cleared."
end

puts "Invite URL = #{$bot.invite_url}"
#$bot.game=("Nothing.")
#RUN THE BOT
$bot.run
