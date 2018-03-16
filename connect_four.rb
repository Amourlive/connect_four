class Game #:nodoc:
  # Sets the matrix size constraint
  MATRIX_SIZE_MIN = 3
  MATRIX_SIZE_MAX = 100
  def initialize
    @step = 1
  end

  # sets the conditions for the game, matrix size, validation conditions
  def generate_game
    enter_the('width of the matrix')
    @matrix_width = gets_valid_params

    enter_the('height of the matrix')
    @matrix_height = gets_valid_params

    enter_the('number of connected chips to win', MATRIX_SIZE_MIN, @matrix_width)
    @chips_to_win = gets_valid_params MATRIX_SIZE_MIN, @matrix_width
    generate_params
  end

  def move
    loop do
      if @step > @matrix_height * @matrix_width
        puts 'Draw'
        break
      end

      if (@step % 2).zero?
        puts 'Second player makes a move'
      else
        puts 'First player makes a move'
      end

      number = gets_valid_params 1, @matrix_width
      unless can_write_to_column?(number)
        puts 'Your column is full, choose another one!'
        redo
      end
      number += @side_matrix_width
      write_to_matrix(number)
      show_matrix
      if current_player_win?
        puts 'YOU WIN'
        break
      end
      @step += 1
    end
  end

  private

  # takes parameters from the user and checks them for validity
  # after which it returns value parameters

  def enter_the(value, valid1 = MATRIX_SIZE_MIN, valid2 = MATRIX_SIZE_MAX)
    puts "Enter the #{value} (#{valid1} <= number < = #{valid2})"
  end

  def gets_valid_params(valid1 = MATRIX_SIZE_MIN, valid2 = MATRIX_SIZE_MAX)
    loop do
      number = gets.to_i
      unless (valid1..valid2).cover?(number)
        puts 'Enter valid number'
        redo
      end
      return number
    end
  end

  # returns true if you can add a chip to the column
  def can_write_to_column?(number)
    return false if @arr[number - 1] == @matrix_height
    @arr[number - 1] += 1
    true
  end

  def write_to_matrix(number)
    return @matrix[number] << 'x' unless (@step % 2).zero?
    @matrix[number] << 'o'
  end

  def generate_params
    # generate value for method include_chip?
    @value1 = 'x' * @chips_to_win
    @value2 = 'o' * @chips_to_win

    # generate value for enable method win_by_vertical ...
    @switch = @chips_to_win * 2 - 1
    @switch_diagonal = 0
    (0..@chips_to_win).each { |value| @switch_diagonal += value }

    # generate value for side matrix
    @side_matrix_width = @matrix_height - @chips_to_win
    if @side_matrix_width < 0
      @side_matrix_width = 0
    else
      @side_matrix_width -= 1
      arr_z = Array.new(@matrix_height, 'z')
      @matrix = Array.new(@matrix_width + 2 * @side_matrix_width + 1, arr_z)
      (@side_matrix_width + 1..@side_matrix_width + @matrix_width).each { |key| @matrix[key] = [] }
    end
    @arr = Array.new(@matrix_width, 0)
  end

  # checks if there is a necessary amount of chips inside the array
  def include_chip?(arr)
    if arr.join.include? @value2
      true
    elsif arr.join.include? @value1
      true
    else
      false
    end
  end

  # return cell if not empty or filler
  def fill_cell(cell, filler)
    return filler if cell.nil?
    cell
  end

  # block with checks the fulfillment of the conditions of victory
  ######################################################################

  def win_by_horizontal?
    if @step >= @switch && @matrix_height >= @chips_to_win
      (@side_matrix_width..@matrix_width + @side_matrix_width).each do |key|
        return true if include_chip? @matrix[key]
      end
    end
    false
  end

  # checks the fulfillment of the conditions of victory
  def win_by_vertical?
    if @step >= @switch
      (0..@matrix_height - 1).each do |key|
        row = []
        (@side_matrix_width + 1..@matrix_width + @side_matrix_width).each do |key2|
          row << fill_cell(@matrix[key2][key], 'z')
        end
        return true if include_chip? row
      end
    end
    false
  end

  def win_by_diagonal?
    if @step >= @switch_diagonal && @matrix_height >= @chips_to_win
      return true if win_by_diagonal_left? || win_by_diagonal_right?
    end
    false
  end

  def win_by_diagonal_left?
    (0..@matrix_width + @side_matrix_width - @chips_to_win + 1).each do |index|
      diagonal = []
      (0..@matrix_height - 1).each do |key|
        key2 = index + key
        diagonal << fill_cell(@matrix[key2][key], 'z')
      end
      return true if include_chip? diagonal
    end
    false
  end

  def win_by_diagonal_right?
    (@side_matrix_width + @chips_to_win..@matrix_width + 2 * @side_matrix_width + 1).to_a.reverse.each do |index|
      diagonal = []
      (0..@matrix_height - 1).each do |key|
        key2 = index - key
        diagonal << fill_cell(@matrix[key2][key], 'z')
      end
      return true if include_chip? diagonal
    end
    false
  end

  def current_player_win?
    win_by_horizontal? || win_by_vertical? || win_by_diagonal?
  end

  ######################################################################

  # show matrix for user
  def show_matrix
    (0..@matrix_height - 1).to_a.reverse.each do |key|
      print '|'
      (@side_matrix_width + 1..@matrix_width + @side_matrix_width).each do |key2|
        print fill_cell(@matrix[key2][key], ' '), ' |'
      end
      print " #{key}\n"
    end
    print '|'
    (01..@matrix_width).each do |value|
      if value.to_s.length == 1
        print "0#{value}|"
      else
        print value, '|'
      end
    end
    print "\n"
  end
end

game = Game.new
game.generate_game
game.move
