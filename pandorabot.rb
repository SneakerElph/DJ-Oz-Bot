#This bot is a really janky way to play some pandora tuneskis with your bros on Discord


require 'discordrb'
require './config.rb'
require './functions.rb'


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

$bot.command(:stop) do |event|7y6t54
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

#RUN THE BOT
$bot.run
