require_relative 'init_errors'
# Methods for reading in rpn files.
class FileReader
  @stack = []
  @line_counter = 0
  @map = {}
  @error_data = []

  def init_values
    @map = {}
    @line_counter = 0
    @error_data = []
    all_files = curr = []
    vals = [all_files, curr]
    vals
  end

  def read_file(arr)
    vals = init_values
    arr.each do |file_name|
      if File.file?(file_name)
        vals[1] = File.readlines(file_name)
        vals[1].each(&:chomp!)
        vals[0].push(vals[1])
      else
        return 'INV'
      end
    end; vals[0]
  end

  def check_array_arguments(input)
    @error_data = []
    input.each do |file|
      return @error_data = [5, 0, -1] if (file[-3..-1] || file).strip != 'rpn'
    end
  end

  def parse_line(input)
    input.each do |element|
      a = element.length == 1 && element.match(/[A-Za-z]/)
      b = %w[+ - / * LET PRINT QUIT].include?(element.upcase)
      c = element.to_i.to_s == element
      @error_data = [4, element, @line_counter] unless a || b || c
      return 'INV' unless a || b || c
    end
  end

  def execute_rpn(file)
    file.each do |line|
      line.each do |inner|
        @stack = []
        @line_counter += 1
        inner = inner.split(' ')
        return @error_data if parse_line(inner).eql? 'INV'
        check_first_file_element(inner)
        return @error_data unless @error_data.empty?
      end
    end
  end

  def quit_branch(input)
    return 'INV' if input[0].upcase == 'QUIT'
  end

  def branches(input)
    quit_branch(input)
    val = define_variable(input) if input[0].upcase == 'LET'
    return 'INV' if val == 'INV'
  end

  def check_first_file_element(first_el)
    if first_el[0].upcase =~ /LET|PRINT|QUIT/
      val = branches(first_el)
      return 'INV' if val == 'INV'
      if first_el[0].upcase == 'PRINT'
        return 'INV' if do_math(first_el[1..first_el.length - 1]) == []
        @error_data = [3, @stack.length, @line_counter] if @stack.length > 1
        return 'INV' if @stack.length > 1
        puts @stack[0]
      end
    end
  end

  def define_variable(input)
    c = input[1].length == 1
    @error_data = [5, 0, @line_counter] unless c && input[1].match(/[a-zA-Z]/)
    return 'INV' unless c && input[1].match(/[a-zA-Z]/) || c
    @map = {} if @map.nil?
    val = do_math(input[2..input.length - 1])
    @error_data = [3, @stack.length, @line_counter] if @stack.length > 1
    return 'INV' if @stack.length > 1
    @map[input[1].upcase] = val[0] unless val.empty?
    return 'INV' if val.empty?
    @stack.clear
  end

  def do_more_math(input)
    if @map.key?(input.upcase)
      @stack.push(@map[input.upcase])
      true
    else
      @error_data = [1, input, @line_counter]
      false
    end
  end

  def do_math(input)
    input.each do |i|
      if %w[+ - * /].include?(i)
        return [] unless handle_operators(i)
      elsif i.length == 1 && i.match(/[a-zA-Z]/)
        return [] unless do_more_math(i)
      else
        @stack.push(i)
      end
    end
    @stack
  end

  def handle_operators(opt)
    operands = init_operands(opt)
    if operands.empty?
      false
    else
      operands[2] = operands[1].send opt, operands[0]
      @stack.push(operands[2])
      true
    end
  end

  def init_operands(opt)
    if @stack.length < 2
      @error_data = [2, opt, @line_counter]
      []
    else
      a = @stack.pop.to_i
      b = @stack.pop.to_i
      c = 0
      [a, b, c]
    end
  end
end
