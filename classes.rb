

class Song
  attr_accessor :name, :artist, :length, :filename, :origin
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
      @fullfilename = Dir["#{@filename}*"]
      event.respond "Now Playing: #{@name} by #{@artist}. Filename: #{@fullfilename[0]}"
      event.voice.play_file(@fullfilename[0])
    end
end

class Playlist
  attr_accessor :entries
  def initialize
    @entries = Array.new
  end
  def play(event)
    voicebot = $bot.voice_connect($current_voice_channel)
    for entry in @entries do
      entry.play(event)
      @entries.delete_at(0)
    end
  end
end
