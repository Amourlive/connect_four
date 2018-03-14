class Game #:nodoc:
  def initialize
    @arr2 = []
    @step = 0
    @player_win = 0
    @side_matrix_length = 3
    # Sets the minimum size constraint on the matrix generator
    # and chips connect to win
    @limitation_value = 3
  end

  def generate_game
    loop do
      puts "Enter the width of the matrix (number => #{@limitation_value})"
      number = gets.to_i
      redo if number < @limitation_value
      @matrix_length = number
      puts "Enter the height of the matrix (number => #{@limitation_value})"
      number = gets.to_i
      redo if number < @limitation_value
      @matrix_height = number
      puts "Enter the number of connected chips to win (number => #{@limitation_value})"
      number = gets.to_i
      redo if number < @limitation_value
      @chips_to_win = number
      break
    end
  end

  def generate_params
    # generate value for include_chip method
    @value1 = 'x' * @chips_to_win
    @value2 = 'o' * @chips_to_win
    # generate value for to enable validation
    @switch = @chips_to_win * 2 - 1
    (0..@chips_to_win).each { |value| @switch_diagonal += value }
  end

  def include_chip?(arr)
    if arr.join.include? @value1
      @player_win = 1
      true
    elsif arr.join.include? @value2
      @player_win = 2
      true
    else
      false
    end
  end

  def cell_empty?(cell)
    return true if cell.nil?
    false
  end

  def fill_cell(cell, filler)
    return filler if cell_empty?(cell)
    cell
  end

  def validation_horizontal?
    if @step > 6
      (3..9).each do |key|
        if @arr2[key].length > 3
          return true if include_chip? @arr2[key]
        end
      end
    end
    false
  end

  def validation_vertical?
    if @step > 6
      (3..9).each do |key|
        row = []
        (3..9).each { |key2| row << fill_cell(@arr2[key2][key], 'z') }
        return true if include_chip? row
      end
    end
    false
  end

  def validation_diagonal_left?(range, inspection_height)
    range.each do |index|
      diagonal = []
      (0..inspection_height).each do |key|
        key2 = index + key
        diagonal << fill_cell(@arr2[key2][key], 'z')
      end
      return true if include_chip? diagonal
    end
    false
  end

  def validation_diagonal_right?(range, inspection_height)
    range.to_a.reverse.each do |index|
      diagonal = []
      (0..inspection_height).each do |key|
        key2 = index - key
        diagonal << fill_cell(@arr2[key2][key], 'z')
      end
      return true if include_chip? diagonal
    end
    false
  end

  def move(number)
    return @arr2[number] << 'x' unless (@turn % 2).zero?
    @arr2[number] << 'o'
  end

  def current_player_win?
  end

  def output_wo_win
    puts @wo_won
  end

  def output_arr
    (0..5).to_a.reverse.each do |key|
      print '|'
      (3..9).each { |key2| print fill_cell(@arr2[key2][key], ' '), '|' }
      print "\n"
    end
  end
end

game = Game.new
turn = 0
arr = [0, 0, 0, 0, 0, 0, 0]
loop do
  if (turn % 2).zero?
    puts 'Second player makes a move'
  else
    puts 'First player makes a move'
  end
  puts 'Enter number of the column(from 1 to 7)'
  number = gets.to_i
  if number < 1 || number > 7
    puts 'Enter a valid number'
    redo
  else
    if arr[number - 1] == 6
      puts 'Column is full, select another column'
      redo
    else
      arr[number - 1] += 1
    end
  end
  turn += 1
  if turn == 43
    puts 'Draw'
    break
  end
  number += 2
  game.move(number, turn)
  if turn > 6
    game.horizontal
    game.vertical
  end
  if turn > 9 && turn < 15
    game.diagonal_left (3..6),3
    game.diagonal_right (6..9),3
  end
  if turn > 14 && turn < 20
    game.diagonal_left (2..6),4
    game.diagonal_right (6..10),4
  end
  if turn > 19
    game.diagonal_left (1..6),5
    game.diagonal_right (6..11), 5
  end
  puts turn
  game.output_arr
  if game.current_player_win?
    game.output_wo_win
    break
  end
end