require 'colorize'

class Piece
  DOWN_DIRS = [
    [1, 1],
    [1, -1]
  ]

  UP_DIRS = [
    [-1, 1],
    [-1, -1]
  ]

  attr_accessor :pos, :king, :dir, :board
  attr_reader :color

  def initialize(pos, color, board, dir)
    @pos = pos

    unless String.colors.include?(color) && ![:white, :black, :light_black].include?(color)
      raise "color invalid"
    end
    @color = color

    @board = board
    @dir = dir
    @king = false
  end

  def valid_moves
    slide_moves + jump_moves
  end

  def render
    symbol.colorize(color)
  end

  def inspect
    "Position: #{pos}, Color: #{color}, King: #{king}"
  end

  def jump_moves
    moves = []

    single_jumps(pos).each do |dir|
      moves << [pos, add_2_dir(pos, dir)]
    end

    moves
  end

  # returns an array of arrays of two-position move sequences
  def slide_moves
    dirs = (@dir == :up ? UP_DIRS : DOWN_DIRS)
    dirs = DOWN_DIRS + UP_DIRS if king

    dirs.each_with_object([]) do |dir, moves|
      new_square = add_dir(pos, dir)
      unless !@board.on_board?(new_square) || @board[*new_square]
        moves << [pos, new_square]
      end
    end
  end

  protected

  def enemy?(piece)
    piece.dir != dir
  end

  # returns either an array of possible directions or [] if no jump is possible
  def single_jumps(pos)
    poss_dir = []
    jumpable = (@dir == :up ? UP_DIRS : DOWN_DIRS)
    jumpable = DOWN_DIRS + UP_DIRS if king

    jumpable.each do |dir|
      jumped_pos = add_dir(pos, dir)
      new_pos = add_2_dir(pos, dir)
      if @board.on_board?(new_pos)
        enemy = @board[*jumped_pos]

        poss_dir << dir if (
          enemy &&
          enemy?(enemy) &&
          new_pos.all? { |i| (0..7).include?(i) } &&
          !@board[*new_pos]
          )
      end
    end

    poss_dir
  end

  def do_single_jump(pos, dir)
    jumped_pos = add_dir(pos, dir)
    new_pos = add_2_dir(pos, dir)

    @board[*pos] = nil
    @board[*jumped_pos] = nil
    @board[*new_pos] = self
    self.pos = new_pos
  end

  private

  def symbol
    king ? ' ☣ ' : ' ⚙ '
  end

  def add_dir(pos, dir)
    pos.zip(dir).map { |a| a[0] + a[1] }
  end

  def add_2_dir(pos, dir)
    pos.zip(dir).map { |a| a[0] + 2 * a[1] }
  end
end
