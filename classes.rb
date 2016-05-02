

class Song
    def initialize(name, artist, length, filename, origin)
      @name = name
      @artist = artist
      @length = length
      @filename = filename
      @origin = origin
    end
    def play(event)
      $bot.game=("#{@name} by #{@artist}")
      voicebot = $bot.voice_connect($current_voice_channel)
      event.respond "Now Playing: #{@name} by #{@artist}"
      event.voice.play_file(@filename)
    end
end
