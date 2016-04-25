#This bot is a really janky way to play some pandora tuneskis with your bros on Discord


require 'discordrb'
require './config.rb'
require './functions.rb'


$current_voice_channel = ENV['current_voice_channel']
$bot = Discordrb::Commands::CommandBot.new token: ENV['discord_token'], application_id: ENV['application_id'], prefix: ENV['prefix']

$bot.command(:ping) do |event|
	 username = event.user.name
	 m = event.respond 'Pong! Check these channels and ID\'s'
	 puts (username)
	 server_channels = event.server.channels
	 for i in server_channels
		 event.respond "#{i.name}: #{i.id}'"
	 end
	 #m.edit "Pong! User ID is #{username}."
	 nil
end

$bot.command(:play) do |event|
	file = "piano2.wav"
	voicebot = $bot.voice_connect($current_voice_channel)
	event.respond "Aw shit I'm playing #{file} motherfucker"
	event.voice.play_io(open(file))
	voicebot.destroy
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

$bot.command(:pandora) do |event|
	$songplaying = true
	until $songplaying == false do
			play_newest_file(event)
		end
end

$bot.command(:botrename) do |event|
	$bot.profile.username = ENV['pandorabot_name']
	event.respond "Bot's name is now #{$bot.profile.username}"
	nil
end

Dir.chdir('mp3')

#RUN THE BOT
$bot.run
