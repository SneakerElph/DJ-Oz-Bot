#This bot is a really janky way to play some pandora tuneskis with your bros on Discord


require 'discordrb'
$current_voice_channel = 171156311231299585 #should move to config file
$bot = Discordrb::Commands::CommandBot.new token: 'MTcxMzY0ODY2MzgzMTUxMTA2.CfWbtw.YtPwpGO0FYqyd0tJEqKrpw2kV6A', application_id: 171364652884819968, prefix: '?' #should move all this to config file as well
def play_song(event)
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
	event.respond "Hell yeah let's play some **#{file_to_play.gsub(".m4a", "").gsub("_", " ")}** up in here"
#AW YEAH PLAY IT BABYYYYYYYYYYYYY
	#event.voice.play_io(open(file_to_play))
	event.voice.play_file(file_to_play)
	event.voice.stop_playing

#afterwards remove what's currently being played.
	$bot.game=("Nothing.")
end

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
			play_song(event)
		end
end

$bot.command(:botrename) do |event|
	$bot.profile.username = "Pandora"
	event.respond "Bot's name is now #{$bot.profile.username}"
	nil
end

Dir.chdir('mp3')

#RUN THE BOT
$bot.run
