class GameState
  attr_accessor :word, :guessed, :tries, :tried_letters

  def initialize
    @word = nil
    @guessed = nil
    @tries = 15
    @tried_letters = []
  end
end
