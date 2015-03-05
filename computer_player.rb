class ComputerPlayer
  attr_reader :color, :name
  attr_writer :game
  attr_accessor :direction, :cursor_pos

  def initialize
    @name = generate_name
    @color = generate_color
  end

  def get_move
    sleep(0.5)
    move = @game.board.valid_moves(@direction).sample
    @current_space = move[1]
    move
  end

  def get_to_space
    @game.board[*@current_space].jump_moves.sample
  end

  private

  def generate_name
    ['paziterite', 'a', 'b', 'c', 'd', 'e'].sample
  end

  def generate_color
    nil
  end
end
