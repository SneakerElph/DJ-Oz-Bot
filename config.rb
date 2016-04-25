#This config file sets up all of our stuff for PandoraBot!



#Your Discord bot token. I think it needs quotes around it.
ENV['discord_token'] = ''

#Your discord application ID
ENV['application_id'] = ''

#What prefix does this bot respond to for commands?
ENV['prefix'] = '!'

#the voice channel ID you want PandoraBot to connect to TO DO: add instructions on how to get this number.
ENV['current_voice_channel'] = ''

ENV['pandorabot_name'] = 'Pandora'

# So we're going to try something - writing the pianobarfly config file before launching it.
# This keeps all of our variables in one place. Perhaps in the future we can bundle
#pianobarfly with PandoraBot?

# Pretty self explanatory here.
ENV['pandora_username'] = ''
ENV['pandora_password'] = ''

# You can get this by going to Pandora.com, loading up the station you want to play,
#and copying the number at the end of the URL. It needs to be a station that is
#associated with the Pandora account you're logging in with.
ENV['pandora_station_id'] = ''

# Probs don't need to change this.
ENV['pandora_audio_format'] = 'mp3'

# Or this.
ENV['pandora_tls_fingerprint'] = '13CC51AC0C31CD96C55015C76914360F7AC41A00'
ENV['pandora_audio_file_name'] ='%title by %artist'
