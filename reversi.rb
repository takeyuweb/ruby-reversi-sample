# frozen_string_literal: true
require_relative 'board'

board = Board.new
puts board.to_s

until board.gameover?
  candidate_positions = board.candidate_positions
  next_position = candidate_positions[rand(candidate_positions.size)]
  x = next_position[0]
  y = next_position[1]
  puts "Player #{board.current_turn} put on (#{x}, #{y})."
  board.put(x: x, y: y)
  puts board.to_s
  puts "Dark #{board.dark_count} : Light #{board.light_count}"
  puts '-' * (board.size * 2 + 1)
end

puts "Player #{board.winner} won."
