#https://mixkit.co/free-sound-effects/game/
#https://opengameart.org
#https://www.youtube.com/watch?v=2UVhYHBT_1o&list=WL&index=8
#https://stock.adobe.com/au/images/pixel-art-tileset-2d-dungeon-steel-wall-texture-assets-for-game-steel-concrete-seamless-with-blue-dark-background/549909898
#https://github.com/Jakeabeast/Snaeky/blob/main/README.md
#https://www.fontspace.com/popular/fonts?p=2

require 'ruby2d'




set fps_cap: 10

eating_sound = Sound.new('./media/eat.wav')
lose_sound = Sound.new('./media/game_over.wav')
game_sound = Sound.new('./media/game_song.wav')
game_win = Sound.new('./media/game_win.wav')


SQUARE_SIZE = 20
SQUARE_WIDTH = Window.width / SQUARE_SIZE
SQUARE_HEIGHT = Window.height / SQUARE_SIZE


module ZOrder
  BACKGROUND, GAME, PLAYER, TEXT = [10, 20, 30, 40]
end


class Snake
	attr_accessor :direction

	def initialize
		@positions = [[2,0], [2,1], [2,2], [2,3]]
		@direction = 'down'
		@growing = false
		
		@head_rotation = 0

	end

	def draw
		i = 0
		while i < @positions.length
		  position = @positions[i]
		  Image.new('./media/snake_body.jpg', x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE,z:ZOrder::PLAYER)
		  i += 1
		end
		Image.new('./media/snake_head.png', x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE, rotate: @head_rotation, z:(ZOrder::PLAYER + 1))
	end

	def move
		if !@growing
			@positions.shift #remove first part of the snake
		end

		case @direction
		when 'down'
			@positions.push(new_coords(head[0], head[1] + 1))
			@head_rotation = 180
		when 'up'
			@positions.push(new_coords(head[0], head[1] - 1))
			@head_rotation = 0
		when 'left'
			@positions.push(new_coords(head[0] - 1, head[1]))
			@head_rotation = 270
		when 'right'
			@positions.push(new_coords(head[0] + 1, head[1]))
			@head_rotation = 90
		end

		@growing = false

	end

	

	def can_change_direction_to?(new_direction)
		case @direction
		when 'up'
			new_direction != 'down'
		when 'down'
			new_direction != 'up'
		when 'left'
			new_direction != 'right'
		when 'right'
			new_direction != 'left'
		end
	end

	
	def x
		head[0]
	end

	def y
		head[1]
	end

	def head
		@positions.last
	end

	def grow 
		@growing = true
	end

	def hit_itself?
		@positions.uniq.length != @positions.length
		#to remove the duplicate, so if theres duplicate that means hit itself
	end

	def new_coords(x, y) #hit the end
    	[x % SQUARE_WIDTH, y % SQUARE_HEIGHT]
  	end
end



class Wall
  attr_accessor :positions

  def initialize
    @positions = []
    
    while true
	  # Choose a random starting point for the wall
	  start_x = rand(SQUARE_WIDTH - 4) # Leave some space for the wall
	  start_y = rand(SQUARE_HEIGHT - 4) # Leave some space for the wall
	  #So we can draw the whole wall if its down the bottom

	  # Check if the starting point is too close to the snake's starting point
	  if (start_x - 2).abs >= 5 || (start_y.abs - 2) >= 5 


	    # Decide whether to create a vertical or horizontal wall
	    if rand < 0.5 #This method generates a random floating-point number between 0.0 (inclusive) and 1.0 (exclusive).
	      # Create a horizontal wall
	      i = 0
	      while i < 5
	        @positions << [start_x + i, start_y] #Creates 5 walls to the right
	        i += 1
	      end
	    else
	      # Create a vertical wall
	      i = 0
	      while i < 5
	        @positions << [start_x, start_y + i] #Creates 5 walls downward
	        i += 1
	      end
	    end
	    break

	  end
	end

  end

	def draw
	i = 0
	  	while i < @positions.length
			position = @positions[i]
		    Image.new('./media/mudstone.jpg', x: position[0] * SQUARE_SIZE, y: position[1] * SQUARE_SIZE, z:ZOrder::GAME)	    
		    i += 1
		end
	end

end


class Game
	def initialize(snake, score, number_of_walls, level)
		@level = level
		@score = 0
		@finished = false
		@background_image = Image.new('./media/dungeon.jpg', z:ZOrder::BACKGROUND)
		@snake = snake
		@food_x = nil
		@food_y = nil
		@walls = []
		@score_to_win = score
		@number_of_walls = number_of_walls
		i = 0
		while i < @number_of_walls  # Repeat the following block until the counter reaches 20
		  @walls << Wall.new  # Create a new Wall object and add it to the array
		  i += 1  # Increment the counter
		end
		generate_food()
	end

	

	def draw
		@background_image.draw()

		i = 0
		while i < @walls.length
		  @walls[i].draw
		  i += 1
		end
		
		if !finished?
			Image.new(
			  './media/apple.png',
			  x:  @food_x * SQUARE_SIZE, y: @food_y * SQUARE_SIZE, #the square multiply to the pixel
			  z: 40
			)

			Text.new("Level: #{@level}. #{@score}/#{@score_to_win}", font: './media/pixel_font.ttf', color: "#82171f", x:10, y:10, z:ZOrder::TEXT, size: 20)
		else 
			if @score == @score_to_win
				Text.new("You win. Score: #{@score}. Press 'C' to continue", color: "#82171f", font: './media/pixel_font.ttf', x: 32, y:240, size: 33, z:ZOrder::TEXT)
			else
				Text.new("Game over. Score: #{@score}. Press 'R' to replay", color: "#82171f", font: './media/pixel_font.ttf', x: 20, y:240, size: 33, z:ZOrder::TEXT)
			end

		end
	end

	def snake_hit_food?(x, y)
		@food_x == x && @food_y == y
	end

	
	def snake_hit_wall?
	  i = 0
	  while i < @walls.length
	    wall = @walls[i]
	    if wall.positions.include?([@snake.x, @snake.y]) #When snake's head hits the wall
	      return true
	    end
	    i += 1
	  end
	  return false
	end
  	

	def record_hit
		@score +=1
		generate_food()
	end 

	def generate_food

	  while true
	    @food_x = rand(SQUARE_WIDTH)
	    @food_y = rand(SQUARE_HEIGHT)

	    # If the new food position is not inside a wall, break the loop
	    if !food_inside_wall?
	      break 
	    end
	  end

	end

	def food_inside_wall?
		i = 0
	   while i < @walls.length
		    wall = @walls[i] 
		    if wall.positions.include?([@food_x, @food_y]) #Food inside the walls
		      return true
		    end
		    i += 1
		end
		return false
	end


	def finish
		@finished = true
	end

	def finished?
		@finished
	end

	def win
		if @score == @score_to_win
			true
		else
			false
		end
	end



end


class Window

	
		eating_sound = Sound.new('./media/eat.wav')
		lose_sound = Sound.new('./media/game_over.wav')
		game_sound = Sound.new('./media/game_song.wav')
		game_win = Sound.new('./media/game_win.wav')

		score = 5
		number_of_walls = 10
		level = 1
		snake = Snake.new()
		game = Game.new(snake, score, number_of_walls, level)



		game_sound.loop = true
		game_sound.play()
		
	

	update do #update the framerate
		clear

		unless game.finished?

			snake.move
		end
		snake.draw
		game.draw

		if game.snake_hit_food?(snake.x, snake.y)
			game.record_hit
			snake.grow
			eating_sound.play
		end

		if game.win
			unless game.finished?
		      game.finish
		      game_sound.stop
		      game_win.play
		      
		    end
		end


		if game.snake_hit_wall?
		    unless game.finished?
		      game.finish
		      game_sound.stop
		      lose_sound.play
		    end
	 	end

		if snake.hit_itself?
		  unless game.finished? 
		    game.finish
		    game_sound.stop
		    lose_sound.play
		  end
		end
		
	end

	on :key_down do |event|
		case event.key
	  	when 'up', 'down', 'left', 'right'
	  		if snake.can_change_direction_to?(event.key)
	    		snake.direction = event.key
	    	end
	    when 'r'
	    snake = Snake.new()
	  
			game = Game.new(snake, score, number_of_walls, level)
			game_win.stop
			game_sound.stop
			game_sound.loop = true
			game_sound.play()
			when 'escape'
				close
		 	

		 	when 'c'
		 		# Only process 'c' key press if the game is won
	    if game.win
	      snake = Snake.new()
		    score = score + 5
		    number_of_walls = number_of_walls + 5
		    level  += 1
				game = Game.new(snake, score, number_of_walls, level)
				game_win.stop
				game_sound.stop
				game_sound.loop = true
				game_sound.play()
	    end

		 end




	end 	

end
show 