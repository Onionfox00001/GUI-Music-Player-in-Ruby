require 'rubygems'
require 'gosu'


TOP_COLOR = Gosu::Color.new(0xFF1EB1FA)
BOTTOM_COLOR = Gosu::Color.new(0xFF1D4DB5)

module ZOrder
  BACKGROUND, PLAYER, UI = *0..2
end

module Genre
  POP, CLASSIC, JAZZ, ROCK = *1..4
end

GENRE_NAMES = ['Null', 'Pop', 'Hip-hop', 'Rock', 'Jazz']

class ArtWork
	attr_accessor :bmp
	def initialize (file)
		@bmp = Gosu::Image.new(file)
	end
end

class Track
  attr_accessor :tra_key, :name, :location
    def initialize (tra_key, name, location)
      @tra_key = tra_key
      @name = name
      @location = location
     end
end

class Album
  attr_accessor :pri_key, :title, :artist,:artwork, :genre, :tracks
  def initialize (pri_key, title, artist,artwork, genre, tracks)
    @pri_key = pri_key
    @title = title
	@artist = artist
	@artwork = artwork
    @genre = genre
    @tracks = tracks
   end
end

class Song
	attr_accessor :song
	def initialize (file)
		@song = Gosu::Song.new(file)
	end
end

class MusicPlayerMain < Gosu::Window

	def initialize
	    super 800, 600
			self.caption = "Music Player"
			@locs = [60,60]
			@font = Gosu::Font.new(30)
			@a = 0
			@t = 0
	end

	def load_album()
			def read_track (music_file, i)
				track_key = i
				track_name = music_file.gets
				track_location = music_file.gets.chomp
				track = Track.new(track_key, track_name, track_location)
				return track
			end

			def read_tracks music_file
				count = music_file.gets.to_i
				tracks = Array.new()
				i = 0
				while i < count
					track = read_track(music_file, i+1)
					tracks << track
					i = i + 1
				end
				tracks
			end

			def read_album(music_file, i)
				album_pri_key = i
				album_title = music_file.gets.chomp
				album_artist = music_file.gets
				album_artwork = music_file.gets.chomp
				album_genre = music_file.gets.to_i
				album_tracks = read_tracks(music_file)
				album = Album.new(album_pri_key, album_title, album_artist,album_artwork, album_genre, album_tracks)
				return album
			end

			def read_albums(music_file)
				count = music_file.gets.to_i
				albums = Array.new()
				i = 0
					while i < count
						album = read_album(music_file, i+1)
						albums << album

						i = i + 1
					end
				return albums
			end

			music_file = File.new("music_file.txt", "r")
			albums = read_albums(music_file)
			return albums
		end


	def needs_cursor?; true; end


	#This function display the albums covers 
	def draw_albums(albums)
		# Load the original images
		bmp1 = Gosu::Image.new(albums[0].artwork)
		bmp2 = Gosu::Image.new(albums[1].artwork)
		bmp3 = Gosu::Image.new(albums[2].artwork)
		bmp4 = Gosu::Image.new(albums[3].artwork)
	  
		# Define the desired width and height for the scaled images
		scaled_width = 150
		scaled_height = 150
	  
		# Draw the scaled images at their respective positions
		bmp1.draw(50, 50, ZOrder::PLAYER, scaled_width.to_f / bmp1.width, scaled_height.to_f / bmp1.height)
		bmp2.draw(50, 300, ZOrder::PLAYER, scaled_width.to_f / bmp2.width, scaled_height.to_f / bmp2.height)
		bmp3.draw(250, 50, ZOrder::PLAYER, scaled_width.to_f / bmp3.width, scaled_height.to_f / bmp3.height)
		bmp4.draw(250, 300, ZOrder::PLAYER, scaled_width.to_f / bmp4.width, scaled_height.to_f / bmp4.height)
	  end

	#This function displays the buttons
	def draw_button()
		@bmp = Gosu::Image.new("image/play.png")
		@bmp.draw(50, 480, z = ZOrder::UI)

		@bmp = Gosu::Image.new("image/pause.png")
		@bmp.draw(150, 480, z = ZOrder::UI)

		@bmp = Gosu::Image.new("image/next.png")
		@bmp.draw(250, 480, z = ZOrder::UI)
	end

	# The background of the music player
	def draw_background
		draw_quad(
			0, 0, Gosu::Color.new(0xFF0072BB),   
			0, 600, Gosu::Color.new(0xFF1EB1FA),  
			800, 0, Gosu::Color.new(0xFF004C87),  
			800, 600, Gosu::Color.new(0xFF1D4DB5),
			ZOrder::BACKGROUND
		)
	end

	def draw_text(a)
		albums = load_album()
	end

	# This function helps display the current playing track 
	def draw
		albums = load_album()
		x = 500
		y = 0
		draw_albums(albums)
		draw_button()
		draw_background()
	
		if @song
		  tracks = albums[@a - 1].tracks
		  current_track = tracks[@t - 1].name
		  @font.draw("Currently playing:", x, y + 50 * @t, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK) #Print the current playing track
		  @font.draw("#{current_track}", x, y + 50 * @t + 30, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK)
		else
		  i = 0
		  while i < albums.length
			@font.draw("#{albums[i].title}", x, y += 100, ZOrder::UI, 1.0, 1.0, Gosu::Color::BLACK) #Print the track are being played
			i += 1
		  end
		end
	  end
	
	
	def playTrack(t, a)
		albums = load_album()
		i = 0
		while i < albums.length
			if (albums[i].pri_key == a)
				tracks = albums[i].tracks
				j = 0
						while j< tracks.length
								if (tracks[j].tra_key == t)
									@song = Gosu::Song.new(tracks[j].location)
									@song.play(false)
								end
								j+=1
						end
			end
			i+=1
		end
 end

 def update()
	if (@song)
		if (!@song.playing?)
			@t+=1
		end
	end
 end
 	# This function is to notice the areas that the mouse is cliking
	def area_clicked(mouse_x, mouse_y)
		if ((mouse_x >50 && mouse_x < 201)&& (mouse_y > 50 && mouse_y < 201 ))# x album
			@a = 1
			@t = 1
			playTrack(@t, @a)
		end
		if ((mouse_x > 50 && mouse_x < 210) && (mouse_y > 310 && mouse_y <470))# - R - album
			@a = 2
			@t = 1
			playTrack(@t, @a)
		end
		if ((mouse_x > 310 && mouse_x < 470) && (mouse_y > 50 && mouse_y <210))# ME album
			@a = 3
			@t = 1
			playTrack(@t, @a)
		end
		if ((mouse_x > 310 && mouse_x < 470) && (mouse_y > 310 && mouse_y <470))# Lalisa album
			@a = 4
			@t = 1
			playTrack(@t, @a)
		end
		
		if ((mouse_x >250 && mouse_x < 375)&& (mouse_y > 500 && mouse_y < 625 ))# next track button 
			if (@t == nil)
				@t = 1
			end
			@t += 1
			playTrack(@t, @a)
		end
		if ((mouse_x >50 && mouse_x < 175)&& (mouse_y > 500 && mouse_y < 625 ))# play button 
			@song.play
		end
		if ((mouse_x >150 && mouse_x < 275)&& (mouse_y > 500 && mouse_y < 625 ))# pause button 
			@song.pause
		end	
 end

	def button_down(id)
		case id
			when Gosu::MsLeft
				@locs = [mouse_x, mouse_y]
				area_clicked(mouse_x, mouse_y)
	    end
	end
end
MusicPlayerMain.new.show if __FILE__ == $0
