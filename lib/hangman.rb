require_relative './hangman/version.rb'
require_relative './game_state.rb'
require_relative './save_manager.rb'
require 'pry'
require 'yaml'

module Hangman
  class Game
    def initialize
      @state = GameState.new
    end

    def start
      print_greeting
      choose_game

      while @state.tries > 0
        print_step_invitation

        user_letter = nil
        loop do
          user_letter = get_user_guess
          break unless was_this_letter? user_letter
          puts "You've entered this letter yet. Try again"
        end

        guess_letter(user_letter)
        break if win?
        print_letter_feedback
        @state.tries -= 1
      end

      if win?
        puts "Congratulations! You win! Your've guessed word '#{@state.word.join}'"
      else
        puts "You don't do it :( It was '#{@state.word.join}'"
      end
    end

    private

    def choose_game
      puts '1. Start new game'
      puts '2. Load save'

      user_choice = gets.chomp[0].to_i

      if user_choice == 1
        make_word
      elsif user_choice == 2
        puts 'Enter file name:'
        user_input = gets.chomp
        begin
          @state = SaveManager.load(user_input)
        rescue
          puts 'Incorrect filename! New game started'
          make_word
        end
      end
    end

    def make_word
      words = File.readlines('words.txt').map(&:strip).select do |word|
        word.length.between? 5, 12
      end

      @state.word = words.sample.split(//)
      make_guessed_cells(@state.word.length)
    end

    def make_guessed_cells(length)
      @state.guessed = Array.new(length) { '_' }
    end

    def guess_letter(guess_letter)
      @is_current_letter_guessed = false
      @state.word.each_with_index do |letter, i|
        if letter.casecmp(guess_letter) == 0
          @state.guessed[i] = letter
          @is_current_letter_guessed = true
        end
      end
      @state.tried_letters << guess_letter.downcase
    end

    def was_this_letter?(letter)
      @state.tried_letters.include? letter.downcase
    end

    def win?
      !@state.guessed.include? '_'
    end

    def print_greeting
      puts 'Hello to Hangman game'
      puts 'Computer will make a word and yout task'\
        'is to guess it from 15 tries'
      puts 'Good luck!'
    end

    def print_step_invitation
      puts "\nYou have #{@state.tries} tries"
      print_word
      puts "Used letters: #{@state.tried_letters}"
      puts 'Your letter, please'
    end

    def print_word
      puts "Word: #{@state.guessed.join}"
    end

    def print_letter_feedback
      if @is_current_letter_guessed
        puts 'Good! Continue the same way!'
      else
        puts 'Sorry! Not your day :('
      end
    end

    def get_user_guess
      user_input = nil

      loop do
        user_input = gets.chomp
        break unless user_input.start_with? '-save'

        begin
          SaveManager.save user_input.split(' ').last, @state
          puts 'Game saved! Continue guessing:'
        rescue
          puts 'Error! Use -save <filename> to save game'
        end
      end

      user_input[0]
    end
  end
end
