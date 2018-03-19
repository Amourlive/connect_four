class Game #:nodoc:
  # Sets the matrix size constraint

  OPTIONS = { matrix_min_size: 3,
              matrix_max_size: 65,
              matrix_standard_width: 6,
              matrix_standard_height: 7,
              standard_number_of_connection: 4 }.freeze

  PHRASES = { matrix_width: 'width of the matrix',
              matrix_height: 'height of the matrix',
              number_of_connection: 'number of connected chips to win',
              column_number: 'column number' }.freeze
  def initialize
    @step = 1
  end

  # sets the conditions for the game, matrix size, validation conditions
  def game_setup
    puts 'Use the default settings? (y - yes/n - no)'
    setting = gets.chomp
    if setting == 'n'
      game_option = {matrix_height: nil, matrix_width: nil, number_of_connection: nil }
      game_option.each_key { |key| game_option[key] = gets_params(PHRASES[key], valid2: (game_option[:matrix_width] || OPTIONS[:matrix_max_size]))}
    else
      game_option = { matrix_width: OPTIONS[:matrix_standard_width], matrix_height: OPTIONS[:matrix_standard_height], number_of_connection: OPTIONS[:standard_number_of_connection] }
    end
    generate_params(game_option)
  end

  def move
    loop do
      if @step > @option[:moves_to_draw]
        puts 'Draw'
        break
      end
      if (@step % 2).zero?
        puts 'Second player makes a move'
      else
        puts 'First player makes a move'
      end
      number = gets_params PHRASES[:column_number], valid1: 1, valid2: @option[:number_of_column]
      unless write_to_column(number)
        puts 'Your column is full, choose another one!'
        redo
      end
      show_matrix
      if current_player_win?
        puts 'YOU WIN'
        break
      end
      @step += 1
    end
  end

  private

  def gets_params(value, valid1: OPTIONS[:matrix_min_size], valid2: OPTIONS[:matrix_max_size])
    loop do
      puts "Enter the #{value} (#{valid1} <= number < = #{valid2})"
      number = gets.to_i
      unless number.between?(valid1, valid2)
        puts 'Enter valid number'
        redo
      end
      return number
    end
  end

  def write_to_column(number)
    return nil if @option[:counter][number] == @option[:column_size]
    @option[:counter][number - 1] += 1
    return @matrix[number + @option[:side_matrix_width] - 1] << 'o' if (@step % 2).zero?
    @matrix[number + @option[:side_matrix_width] - 1] << 'x'
  end

  def generate_params(matrix_width:, matrix_height:, number_of_connection:)
    # generate value for method include_chip?
    @reference = ['x' * number_of_connection, 'o' * number_of_connection]
    # generate value for matrix
    side_matrix_width = matrix_height - number_of_connection
    @range_visible_matrix = { width: (side_matrix_width..side_matrix_width + matrix_width - 1),
                              height: (0..matrix_height - 1) }
    @option = { cell_size: matrix_width.to_s.length,
                counter: Array.new(matrix_width, 0),
                moves_to_draw: matrix_width * matrix_height,
                side_matrix_width: side_matrix_width,
                number_of_column: matrix_width,
                column_size: matrix_height}
    @option[:diagonal_check_switch] = true if matrix_height >= number_of_connection
    # generate matrix
    if side_matrix_width.zero?
      @matrix = Array.new(matrix_width, [])
    else
      @matrix = Array.new(matrix_width + 2 * side_matrix_width, Array.new(matrix_height, 'z'))
      @range_visible_matrix[:width].each { |key| @matrix[key] = [] }
    end
    @range_diagonal_check = { left: (0..matrix_width + side_matrix_width - number_of_connection),
                              right: (side_matrix_width - 1 + number_of_connection..matrix_width - 1 + 2 * side_matrix_width).to_a.reverse }
  end

  def win_by_horizontal?
    @range_visible_matrix[:height].each do |key|
      row = []
      @range_visible_matrix[:width].each do |key2|
        row << @matrix[key2][key]
      end
      @range_visible_matrix[:width].each { |key| @reference.each { |reference| return true if row.join.include? reference }}
    end
    false
  end

  def win_by_vertical?
    return false unless @option[:diagonal_check_switch]
    @range_visible_matrix[:width].each { |key| @reference.each { |reference| return true if @matrix[key].join.include? reference }}
    false
  end

  def win_by_diagonal?(range)
    return false unless @option[:diagonal_check_switch]
    range.each do |index|
      diagonal = []
      @range_visible_matrix[:height].each do |key|
        key2 = yield(index, key)
        diagonal << (@matrix[key2][key] || 'z')
      end
      @range_visible_matrix[:width].each { |key| @reference.each { |reference| return true if diagonal.join.include? reference }}
    end
    false
  end

  def current_player_win?
    win_by_horizontal? || win_by_vertical? ||
      win_by_diagonal?(@range_diagonal_check[:left]) { |index, key| index + key } ||
      win_by_diagonal?(@range_diagonal_check[:right]) { |index, key| index - key }
  end

  def show_matrix
    @range_visible_matrix[:height].to_a.reverse.each do |key|
      print '|'
      @range_visible_matrix[:width].each do |key2|
        print format("%#{@option[:cell_size]}s", @matrix[key2][key]), '|'
      end
      print " #{key + 1}\n"
    end
    printf '|'
    1.upto(@option[:number_of_column]) { |i| print format("%#{@option[:cell_size]}i|", i) }
    print "\n"
  end
end

game = Game.new
game.game_setup
game.move