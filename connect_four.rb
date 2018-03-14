class Game #:nodoc:
  def initialize
    @matrix = []
    @step = 1
    @switch = 0
    @switch_diagonal = 0
    @arr = []
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

  def move
    loop do
      if @step == @matrix_height * @matrix_width
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
      number += (@side_matrix_width - 1)
      write_to_matrix(number)
      puts @switch_diagonal
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

    # generate value for enable method validation_vertical ...
    @switch = @chips_to_win * 2 - 1
    (0..@chips_to_win).each { |value| @switch_diagonal += value }

    # generate value for side matrix
    @side_matrix_width = @matrix_height - @chips_to_win
    puts @side_matrix_width
    if @side_matrix_width < 0
      @side_matrix_width = 0
    else
      (0..@side_matrix_width - 1).each do |key|
        @matrix[key] = []
        (0..@matrix_height).each { |key2| @matrix[key][key2] = 'z' }
      end
      (@side_matrix_width..@side_matrix_width + @matrix_width - 1).each { |key| @matrix[key] = [] }
      (@side_matrix_width + @matrix_width..@matrix_width + 2 * @side_matrix_width - 1).each do |key|
        @matrix[key] = []
        (0..@matrix_height).each { |key2| @matrix[key][key2] = 'z' }
      end
    end
    (0..@matrix_width).each { |key| @arr[key] = 0 }
  end

  # checks if there is a necessary amount of chips inside the array
  def include_chip?(arr)
    if arr.join.include? @value1
      true
    elsif arr.join.include? @value2
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

  # validation work if the number of moves is enough to win
  # and the required number of chips can fit horizontal.
  def win_by_horizontal?
    if @step > @switch && @matrix_height >= @chips_to_win
      (@side_matrix_width..@matrix_width + @side_matrix_width).each do |key|
        if @matrix[key].length >= @chips_to_win
          return true if include_chip? @matrix[key]
        end
      end
    end
    false
  end

  # validation work if the number of moves is enough to win
  def win_by_vertical?
    if @step > @switch
      (0..@matrix_height).each do |key|
        row = []
        (@side_matrix_width..@matrix_width + @side_matrix_width).each do |key2|
          row << fill_cell(@matrix[key2][key], 'z')
        end
        return true if include_chip? row
      end
    end
    false
  end

  # validation work if the number of moves is enough to win
  # and the required number of chips can fit diagonally.
  def win_by_diagonal?
    if @step >= @switch_diagonal && @matrix_height >= @chips_to_win
      return true if win_by_diagonal_left? || win_by_diagonal_right?
    end
    false
  end

  def win_by_diagonal_left?
    (0..@matrix_width + @side_matrix_width - @chips_to_win).each do |index|
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
    (@side_matrix_width + @chips_to_win - 1..@matrix_width + 2 * @side_matrix_width - 1).to_a.reverse.each do |index|
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
    return true if win_by_horizontal? || win_by_vertical? || win_by_diagonal?
    false
  end

  # show matrix for user
  def show_matrix
    (0..@matrix_height - 1).to_a.reverse.each do |key|
      print '|'
      (@side_matrix_width..@matrix_width + @side_matrix_width - 1).each do |key2|
        print fill_cell(@matrix[key2][key], ' '), '|'
      end
      print "\n"
    end
  end
end

game = Game.new
game.generate_game
game.move