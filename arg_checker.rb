# Class that checks the file argument provided by user.
class ArgsChecker
  @stack = []
  @map = {}

  def check_args(arr)
    if arr.count < 1
      run_repl
    else
      check_array_arguments(arr)
      read_file(arr)
    end
  end

  def read_file(arr)
    all_files = curr = []
    arr.each do |file_name|
      if File.file?(file_name)
        curr = File.readlines(file_name)
        all_files.push(curr)
      else
        puts 'File does not exist with given path.'
      end
    end
    all_files
  end

  def check_array_arguments(input)
    input.each do |file|
      if file.split('.')[1] != 'rpn'
        puts 'Supplied file does not have the .rpn extension!'
        abort
      end
    end
  end

  def define_variable(input)
    @map = {} if @map.nil?
    items = input[2..input.length - 1]
    @map[input[1]] = do_math(items)
  end

  def check_first_element(input)
    if %w[LET PRINT QUIT].include?(input[0])
      if input[0] == 'QUIT'
        exit!
      elsif input[0] == 'LET'
        define_variable(input)
      else
        do_math(input[1..input.length - 1])
      end
      true
    end
  end

  def handle_input(input)
    @stack = []
    input = input.split(' ')
    do_math(input) unless check_first_element(input)
    puts @stack
  end

  def do_math(input)
    input.each do |i|
      if %w[+ - * /].include?(i)
        handle_operators(i)
      else
        @stack.push(i)
      end
    end
  end

  def handle_operators(opt)
    operands = init_operands
    operands[2] = operands[1].send opt, operands[0]
    @stack.push(operands[2])
  end

  def init_operands
    a = @stack.pop.to_i
    b = @stack.pop.to_i
    c = 0
    [a, b, c]
  end

  def run_repl
    @stack = [] if @stack.nil?
    repl = lambda { |prompt|
      print prompt
      handle_input(gets.chomp!)
    }
    loop do
      repl['> ']
    end
  end
end
