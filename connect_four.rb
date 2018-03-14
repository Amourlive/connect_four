class Game #:nodoc:
  def initialize
    @arr2 = []
    @step = 0
    @player_win = 0
    @switch = 0
    @switch_diagonal = 0
    # Sets the matrix size constraint
    @limitation_value_min = 3
    @limitation_value_max = 100
  end

  # sets the conditions for the game, matrix size, validation conditions
  def generate_game
    puts "Enter the width of the matrix (#{@limitation_value_min} <= number < = #{@limitation_value_max})"
    @matrix_width = gets_valid_params @limitation_value_min, @limitation_value_max

    puts "Enter the height of the matrix (#{@limitation_value_min} <= number < = #{@limitation_value_max})"
    @matrix_height = gets_valid_params @limitation_value_min, @limitation_value_max

    puts "Enter the number of connected chips to win (#{@limitation_value_min} <= number < = #{@matrix_width})"
    @chips_to_win = gets_valid_params @limitation_value_min, @matrix_width

    generate_params
  end

  def move(number)
    return @arr2[number] << 'x' unless (@step % 2).zero?
    @arr2[number] << 'o'
  end

  private

  # takes parameters from the user and checks them for validity
  # after which it returns value parameters
  def gets_valid_params(valid1, valid2)
    loop do
      number = gets.to_i
      if number < valid1 || number > valid2
        puts 'Enter valid number'
        redo
      end
      return number
    end
  end

  def generate_params
    # generate value for method include_chip?
    @value1 = 'x' * @chips_to_win
    @value2 = 'o' * @chips_to_win
    # generate value for enable method validation_vertical ...
    @switch = @chips_to_win * 2 - 1
    (0..@chips_to_win).each { |value| @switch_diagonal += value }
    # generate value for side matrix
    @side_matrix_width = @matrix_height - @chips_to_win
  end

  # checks if there is a necessary amount of chips inside the array
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

  # return cell if not empty or filler
  def fill_cell(cell, filler)
    return filler if cell.nil?
    cell
  end

  def validation_horizontal?
    if @step > @switch && @matrix_height >= @chips_to_win
      (@side_matrix_width..@matrix_width + @side_matrix_width).each do |key|
        if @arr2[key].length >= @chips_to_win
          return true if include_chip? @arr2[key]
        end
      end
    end
    false
  end

  def validation_vertical?
    if @step > @switch
      (0..@matrix_height).each do |key|
        row = []
        (@side_matrix_width..@matrix_width + @side_matrix_width).each do |key2|
          row << fill_cell(@arr2[key2][key], 'z')
        end
        return true if include_chip? row
      end
    end
    false
  end

  def validation_diagonal?
    if @step > @switch_diagonal && @matrix_height >= @chips_to_win
      return true if validation_diagonal_left? || validation_diagonal_right?
    end
    false
  end

  def validation_diagonal_left?
    (@side_matrix_width..@matrix_width + @side_matrix_width).each do |index|
      diagonal = []
      (0..@matrix_height).each do |key|
        key2 = index + key
        diagonal << fill_cell(@arr2[key2][key], 'z')
      end
      return true if include_chip? diagonal
    end
    false
  end

  def validation_diagonal_right?
    (@side_matrix_width..@matrix_width + @side_matrix_width).to_a.reverse.each do |index|
      diagonal = []
      (0..@matrix_height).each do |key|
        key2 = index - key
        diagonal << fill_cell(@arr2[key2][key], 'z')
      end
      return true if include_chip? diagonal
    end
    false
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
game.generate_game