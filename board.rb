require 'byebug'
require_relative 'piece'

class Board
  attr_accessor :cursor_pos

  def initialize(options = {})
    defaults = { pieces: true, color1: :cyan, color2: :red }
    options = defaults.merge(options.select{ |k, v| !v.nil? })

    @color1 = options[:color1]
    @color2 = options[:color2]

    @grid = Array.new(8) { Array.new(8) }
    initialize_pieces if options[:pieces]

    @cursor_pos = [-1, -1]
  end

  def [] (x, y)
    @grid[x][y]
  end

  def []=(x, y, value)
    @grid[x][y] = value
  end

  def initialize_pieces
    setup_pieces((0..2), @color2, :down)
    setup_pieces((5..7), @color1, :up)
  end

  def display(cursor)
    system 'clear'
    puts to_s(cursor)
  end

  def do_move(move)
    duped = move_dup(move)

    if slide?(move)
      do_slide_move(duped)
    else
      do_jump_move(duped)
    end
  end

  def move_dup(move)
    duped = Array.new { Array.new }

    move.length.times do |i|
      duped[i] = move[i].dup
      move[i].length.times do |j|
        duped[i][j] = move[i][j]
      end
    end

    duped
  end

  def deep_dup
    dup = Board.new(pieces: false, color1: @color1, color2: @color2)

    all_pieces.each do |piece|
      new_piece = Piece.new(piece.pos, piece.color, dup, piece.dir)
      new_piece.king = piece.king
      dup[*piece.pos] = new_piece
    end

    dup
  end

  def all_pieces
    @grid.flatten.compact
  end

  def all_pieces_of(dir)
    @grid.flatten.compact.select { |piece| piece.dir == dir }
  end

  def on_board?(pos)
    pos.all? { |i| i.between?(0, 7) }
  end

  def valid_moves(dir)
    jumps = jump_moves(dir)
    return jumps unless jumps.empty?
    slide_moves(dir)
  end

  def jump_moves(dir)
    jumps = []
    all_pieces_of(dir).each { |piece| jumps += piece.jump_moves }
    jumps
  end

  def slide_moves(dir)
    slides = []
    all_pieces_of(dir).each { |piece| slides += piece.slide_moves }
    slides
  end

  def slide?(move)
    (move[0][0] - move[1][0]).abs == 1
  end

  private

  def setup_pieces(range, color, direction)
    range.each do |i|
      (0..7).each do |j|
        self[i, j] = Piece.new([i, j], color, self, direction) if (i + j).odd?
      end
    end
  end

  def to_s(cursor)
    display_string = "\n"

    @grid.each_with_index do |row, i|
      row.each_with_index do |square, j|
        background_color = ((i + j).even? ? :white : :black)
        is_cursor = (cursor == [i, j] ? true : false)
        background_color = (is_cursor ? :green : background_color)
        display_string << ((
          square ? square.render : '   '
        ).colorize(background: background_color))
      end

      display_string << "\n"
    end

    display_string
  end

  def do_slide_move(move)
    piece = self[*move.shift]
    next_square = move.shift

    self[*next_square] = piece
    self[*piece.pos] = nil
    piece.pos = *next_square
    king_piece?(piece)
  end

  def do_jump_move(move)
    square = move.shift
    piece = self[*square]

    until move.empty? do
      next_pos = move.shift
      jumped = square.zip(next_pos).map { |a| (a[1] + a[0]) / 2 }
      self[*square] = nil
      self[*jumped] = nil
      square = next_pos
    end

    self[*next_pos] = piece
    piece.pos = *next_pos
    king_piece?(piece)
  end

  def king_piece?(piece)
    piece.king = true if piece.pos[0] == 7 && piece.dir == :down
    piece.king = true if piece.pos[0] == 0 && piece.dir == :up

    piece.king
  end
end
