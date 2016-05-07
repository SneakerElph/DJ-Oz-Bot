#This bot is a really janky way to play some pandora tuneskis with your bros on Discord


require 'discordrb'
require './config.rb'
require './classes.rb'
require 'yt'
require 'youtube-dl.rb'

def youtube_to_object(event, url)
	youtubeVideo = Yt::Video.new url: url
	videoid = url.gsub("https://www.youtube.com/watch?v=", "")
	YoutubeDL.download url, output: "#{$root_dir}/playlist/#{videoid}"
	filename = Dir["#{$root_dir}/playlist/#{videoid}*"]
	songObject = Song.new("#{youtubeVideo.title}", "artist", "#{Time.at(youtubeVideo.duration).utc.strftime("%M:%S")}", "#{filename[0]}", "youtube", "#{event.author.name}")
	$playlist.add(songObject)
end

Yt.configuration.api_key = "AIzaSyBN1naP86mILKIrtuazW75JGB4wpS2nSMw"
$root_dir=Dir.pwd
$current_voice_channel = ENV['current_voice_channel']
$bot = Discordrb::Commands::CommandBot.new token: ENV['discord_token'], application_id: ENV['application_id'], prefix: ENV['prefix']
$pandora = Pandora.new
$playlist = Playlist.new

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

	$musicplaying = true
	until $musicplaying == false
		if $playlist.entries.empty? == false
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
					 if $playlist.entries.empty? == false
						 $pandora.stop(event)
						 $pandora.playing = false
					 end
				 end
		 	end
		end
end

$bot.command(:addsong) do |event, text|
	youtube_to_object(event, text)
	event.respond "#{$playlist.entries.last.name} [#{$playlist.entries.last.length}] to playlist."
end

$bot.command(:playsong) do |event|
	$playlist.play(event)
	nil
end

$bot.command(:playlist) do |event|
	if $playlist.entries.empty?
		event.respond "Nothing in the list."
	else
			for e in $playlist.entries do
				event.respond "#{e.name}"
			end
		end

	nil
end

puts "Invite URL = #{$bot.invite_url}"

#RUN THE BOT
$bot.run
