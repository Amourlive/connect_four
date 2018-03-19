class Game #:nodoc:
  # Sets the matrix size constraint
  MATRIX_SIZE_MIN = 3
  MATRIX_SIZE_MAX = 65
  # Standard setting
  MATRIX_WIDTH = 6
  MATRIX_HEIGHT = 7
  CHIPS_TO_WIN = 4
  def initialize
    @step = 1
  end

  # sets the conditions for the game, matrix size, validation conditions
  def game_setup
    puts 'Use the default settings? (y/n)'
    setting = gets.chomp
    if setting == 'n'
      enter_the('width of the matrix')
      @matrix_width = gets_valid_params
      enter_the('height of the matrix')
      @matrix_height = gets_valid_params
      enter_the('number of connected chips to win', MATRIX_SIZE_MIN, @matrix_width)
      @chips_to_win = gets_valid_params MATRIX_SIZE_MIN, @matrix_width
    else
      @matrix_width = MATRIX_WIDTH
      @matrix_height = MATRIX_HEIGHT
      @chips_to_win =  CHIPS_TO_WIN
    end
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
      number += @side_matrix_width - 1
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
      unless number.between?(valid1, valid2)
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
    # generate value for matrix
    @side_matrix_width = @matrix_height - @chips_to_win
    @side_matrix_width = 0 if @side_matrix_width < 0
    @range_visible_width = (@side_matrix_width..@side_matrix_width + @matrix_width - 1)
    @range_height_matrix = (0..@matrix_height - 1)
    # generate matrix
    if @side_matrix_width.zero?
      @matrix = Array.new(@matrix_width, [])
    else
      arr_z = Array.new(@matrix_height, 'z')
      @matrix = Array.new(@matrix_width + 2 * @side_matrix_width, arr_z)
      @range_visible_width.each { |key| @matrix[key] = [] }
    end
    @arr = Array.new(@matrix_width, 0)
    # generate value for show_matrix (use in .format)
    @cell_size = @matrix_width.to_s.length
    # generate value for enable method win_by_vertical ...
    @switch = @chips_to_win * 2 - 1
    @switch_diagonal = 0
    (0..@chips_to_win).each { |value| @switch_diagonal += value }
    @range_side_left = (0..@matrix_width + @side_matrix_width - @chips_to_win)
    @range_side_right = (@side_matrix_width - 1 + @chips_to_win..@matrix_width - 1 + 2 * @side_matrix_width).to_a.reverse
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

  # block with checks the fulfillment of the conditions of victory
  ######################################################################

  def win_by_horizontal?
    if @step >= @switch && @matrix_height >= @chips_to_win
      @range_visible_width.each do |key|
        return true if include_chip? @matrix[key]
      end
    end
    false
  end

  # checks the fulfillment of the conditions of victory
  def win_by_vertical?
    if @step >= @switch
      @range_height_matrix.each do |key|
        row = []
        @range_visible_width.each do |key2|
          row << @matrix[key2][key] || 'z'
        end
        return true if include_chip? row
      end
    end
    false
  end

  def win_by_diagonal?(range)
    if @step >= @switch_diagonal && @matrix_height >= @chips_to_win
      range.each do |index|
        diagonal = []
        @range_height_matrix.each do |key|
          key2 = yield(index, key)
          diagonal << @matrix[key2][key] || 'z'
        end
        return true if include_chip? diagonal
      end
    end
    false
  end

  def current_player_win?
    win_by_horizontal? || win_by_vertical? ||
      win_by_diagonal?(@range_side_left) { |index, key| index + key } ||
      win_by_diagonal?(@range_side_right) { |index, key| index - key }
  end

  ######################################################################

  # show matrix for user
  def show_matrix
    @range_height_matrix.to_a.reverse.each do |key|
      print '|'
      @range_visible_width.each do |key2|
        print format("%#{@cell_size}s", @matrix[key2][key]), '|'
      end
      print " #{key}\n"
    end
    printf '|'
    (1..@matrix_width).each do |index|
      print format("%#{@cell_size}i|", index)
    end
    print "\n"
  end
end

game = Game.new
game.game_setup
game.move
