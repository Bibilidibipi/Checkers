require_relative 'keypress'

class HumanPlayer
  attr_reader :color, :name
  attr_writer :game
  attr_accessor :direction, :cursor_pos

  def initialize(name, color = nil)
    @name = name
    @color = color
    @cursor_pos = [3, 4]
  end

  def get_move
    [get_from_space, get_to_space]
  end

  def get_to_space
    @request = "Select the square would you like to move to next"
    puts @request

    square = get_square.dup
    @game.board.display(@cursor_pos)

    square
  end

  private

  def get_from_space
    @request = "#{@name}, using the arrow keys, please select the square "\
               "you would like to move from, and then press space."
    puts @request

    square = get_square.dup
    @game.board.display(@cursor_pos)

    square
  end

  def get_square
    loop do
      key = get_single_key
      return @cursor_pos if key == :return
      new_pos = add_dir(@cursor_pos, key)

      # clamps cursor_pos
      @cursor_pos[0] = [0, new_pos[0], 7].sort[1]
      @cursor_pos[1] = [0, new_pos[1], 7].sort[1]

      update_cursor
      @cursor_pos
    end
  end

  def slide?(move)
    (move[0][0] - move[1][0]).abs == 1
  end

  def jump_from(move)
    start_pos = move[1]
    @game.board[*start_pos].jump_moves
  end

  def update_cursor
    @game.board.display(@cursor_pos)
    puts @request
  end

  def add_dir(pos, dir)
    pos.zip(dir).map { |a| a[0] + a[1] }
  end
end
