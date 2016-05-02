#This bot is a really janky way to play some pandora tuneskis with your bros on Discord


require 'discordrb'
require './config.rb'
require './functions.rb'
require './classes.rb'


$root_dir=Dir.pwd
$current_voice_channel = ENV['current_voice_channel']
$bot = Discordrb::Commands::CommandBot.new token: ENV['discord_token'], application_id: ENV['application_id'], prefix: ENV['prefix']

$bot.command(:channels) do |event|
	 event.respond 'Pong! Check these channels and ID\'s'
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
	nil
end

$bot.command(:playnewest) do |event|
	$songplaying = true
	Dir.chdir("#{$root_dir}/mp3")
	until $songplaying == false do
			play_newest_file(event)
		end
end

$bot.command(:startpandora) do |event|
	start_pianobarfly(event)
end

$bot.command(:botrename) do |event|
	$bot.profile.username = ENV['pandorabot_name']
	event.respond "Bot's name is now #{$bot.profile.username}"
	nil
end

$bot.command(:stoppandora) do |event|
	stop_pianobarfly(event)
	$songplaying == false
end

$bot.command(:pandora) do |event|
	start_pianobarfly(event)
	sleep 5
	$songplaying = true
	Dir.chdir("#{$root_dir}/mp3")
	until $songplaying == false do
		play_newest_file(event)
	end
end

$bot.command(:changestation) do |event|
	change_station(event)
end

$bot.command(:writeconfig) do |event|
	write_pianobar_config()
end

$bot.command(:youtube) do |event, text|
	download_youtube(text)
end

$bot.command(:playplaylist) do |event|
	Dir.chdir("#{$root_dir}/mp3")
	play_playlist(event)
end

$bot.command(:playmusic) do |event|
	#check if there's stuff in playlist folder
	#if not, start pianobarfly and play pandora
	#after every song check playlist folder again


	$musicplaying = true
	until $musicplaying == false
		isfull = check_playlist_folder(event)
		if isfull == true
			play_playlist(event)
		else
			 start_pianobarfly(event)
			 sleep 5
			 $songplaying = true
			 Dir.chdir("#{$root_dir}/mp3")
			 until $songplaying == false do
				 play_newest_file(event)
			 end
	 	end
	end
end

$bot.command(:youtubeobject) do |event, text|
	youtube_to_object(text)
end
$bot.command(:playobject) do |event|
	$songObject.play(event)
end
	puts "Invite URL = #{$bot.invite_url}"

#RUN THE BOT
$bot.run
