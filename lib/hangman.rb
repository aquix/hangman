require_relative "./hangman/version.rb"
require 'pry'

module Hangman
  class Game
    def initialize
      @word = nil
      @guessed = nil
      @tries = 15
      @tried_letters = []
    end

    def start
      print_greeting
      make_word

      while @tries > 0
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
        @tries -= 1
      end

      if win?
        puts "Congratulations! You win! Your've guessed word '#{@word.join}'"
      else
        puts "You don't do it :( It was '#{@word.join}'"
      end
    end

    private

    def make_word
      words = File.readlines('words.txt').map(&:strip).select do |word|
        word.length.between? 5, 7
      end

      @word = words.sample.split(//)
      make_guessed_cells(@word.length)
    end

    def make_guessed_cells(length)
      @guessed = Array.new(length) { '_' }
    end

    def guess_letter(guess_letter)
      @is_current_letter_guessed = false
      @word.each_with_index do |letter, i|
        if letter.casecmp(guess_letter) == 0
          @guessed[i] = letter
          @is_current_letter_guessed = true
        end
      end
      @tried_letters << guess_letter.downcase
    end

    def was_this_letter?(letter)
      @tried_letters.include? letter.downcase
    end

    def win?
      !@guessed.include? '_'
    end

    def print_greeting
      puts 'Hello to Hangman game'
      puts 'Computer will make a word and yout task'\
        'is to guess it from 15 tries'
      puts 'Good luck!'
    end

    def print_step_invitation
      puts "\nYou have #{@tries} tries"
      print_word
      puts "Used letters: #{@tried_letters}"
      puts 'Your letter, please'
    end

    def print_word
      puts "Word: #{@guessed.join}"
    end

    def print_letter_feedback
      if @is_current_letter_guessed
        puts 'Good! Continue the same way!'
      else
        puts 'Sorry! Not your day :('
      end
    end

    def get_user_guess
      gets.chomp[0]
    end
  end
end
