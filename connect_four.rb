class Game #:nodoc:
  def initialize
    @arr2 = [['z','z','z','z','z','z'],
             ['z','z','z','z','z','z'],
             ['z','z','z','z','z','z'],
             [], [], [], [], [], [], [],
             ['z','z','z','z','z','z'],
             ['z','z','z','z','z','z'],
             ['z','z','z','z','z','z']]
    @value1 = 'xxxx'
    @value2 = 'oooo'
    @player_win = 0
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
    (3..9).each do |key|
      if @arr2[key].length > 3
        break if include_chip? @arr2[key]
      end
    end
  end

  def validation_vertical?
    (3..9).each do |key|
      row = []
      (3..9).each { |key2| row << fill_cell(@arr2[key2][key], 'z') }
      break if include_chip? row
    end
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

  def move(number, turn)
    return @arr2[number] << 'x' unless (turn % 2).zero?
    @arr2[number] << 'o'
  end

  def current_player_win?
    return true until @wo_won.empty?
    false
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