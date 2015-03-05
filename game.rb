# need to make kinging end turn










require_relative 'board'
require_relative 'human_player'
require_relative 'computer_player'

class Game
  attr_reader :board
  attr_writer :move_over

  def initialize(player1, player2)
    @player1, @player2 = player1, player2
    @current_player = player1

    @board = Board.new({ color1: player1.color, color2: player2.color })
  end

  def play
    until won?
      @board.display(@current_player.cursor_pos)

      move = nil

      until move && @board.valid_moves(@current_player.direction).include?(move)
        move = @current_player.get_move
      end
      @board.do_move(move)
      @board.display(@current_player.cursor_pos)

      unless @board.slide?(move)
        until @board[*move[1]].jump_moves.empty?
          move = [move[1], @current_player.get_to_space]
          @board.do_move(move)
          @board.display(@current_player.cursor_pos)
        end
      end

      switch_player
    end

    @board.display(@current_player.cursor_pos)
    switch_player
    puts "#{@current_player.name} wins!"
  end

  def won?
    @board.all_pieces_of(@current_player.direction).empty? ||
    @board.all_pieces_of(@current_player.direction).all? { |piece| piece.valid_moves.empty? }
  end

  def switch_player
    @current_player = (@current_player == @player1 ? @player2 : @player1)
  end
end

if __FILE__ == $PROGRAM_NAME
  jezebel = ComputerPlayer.new
  #brunellus = ComputerPlayer.new
  #jezebel = HumanPlayer.new('Jezebel', :yellow)
  brunellus = HumanPlayer.new('Brunellus')
  jezebel.direction = :down
  brunellus.direction = :up

  game = Game.new(jezebel, brunellus)
  jezebel.game = game
  brunellus.game = game

  # game.board.do_move([[2, 1], [3, 2]])
  # game.board.do_move([[5, 4], [4, 3]])
  # game.board.do_move([[3, 2], [5, 4]])
  # game.board.do_move([[5, 6], [4, 7]])
  # game.board.do_move([[2, 3], [3, 2]])
  # game.board.do_move([[6, 5], [4, 3], [2, 1]])
  game.play

end
