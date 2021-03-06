# Check in the future if I can join more than one files
class CsvJoiner

  attr_writer :separator

  def initialize
    @separator = ';'
  end

  # This method joins two arrays based on keys extracted from columns of the arrays.
  # It takes an option hash.
  # If the hash key starts with data then it expects an array with data.
  # If the hash key starts with file, then it expects a file path of a csv file that it will be converted to an array
  # If the hash key start with cols, then it expects an array with numbers where each number corresponds to the column of the array that will be used to extract the key.
  # Each hash key is followed by a number that represents the order of the data structures (array) that the options are referred to
  # At the moment I support only two arrays or files but it can be generalized in the future
  # There is also a list option that can take the value :first or :second.
  # If the value is :first, then only the matched content of the first data structure will be in the final result.
  # If the value is :second, then only the matched content of the second data structure will be in the final result
  # Otherwise both data structures matched content will be shown.
  def join(options = {})
    data_sources = extract_data_sources(options)

    ds1 = data_sources['1'.to_sym]
    ds2 = data_sources['2'.to_sym]

    case options[:list]
      when :first
        output_data = common_lines_for_first_list(ds1, ds2, options)
      when :second
        output_data = common_lines_for_second_list(ds1, ds2, options)
      else
        output_data = all_lines(
            common_lines_for_first_list(ds1, ds2, options),
            common_lines_for_second_list(ds1, ds2, options),
            options
        )
    end

    if options[:output_file]
      write_list(output_data, options[:output_file])
    end

    if options[:diff_output_file]
      write_list(diff_lines(extract_index(ds1, options[:cols1]),
                            extract_index(ds2, options[:cols2])), options[:diff_output_file])
    end

    output_data

  end

  private

  def common_lines(indexed_list1, indexed_list2)
    indexed_list1.select { |k, v| indexed_list2.include?(k) }.map { |k, v| v }
  end

  def diff_lines(indexed_list1, indexed_list2)
    indexed_list1.select { |k, v| !indexed_list2.include?(k) }.map { |k, v| v }
  end

  def all_lines(cl1, cl2, options)

    all = []
    ei1 = extract_index(cl1, options[:cols1])
    ei2 = extract_index(cl2, options[:cols2])

    ei1.each_key do |key|
      all << ei1[key] + @separator + ei2[key]
    end

    all
  end

  def common_lines_for_first_list(list1, list2, options)
    common_lines(
        extract_index(list1, options[:cols1]),
        extract_index(list2, options[:cols2])
    )
  end

  def common_lines_for_second_list(list1, list2, options)
    common_lines(
        extract_index(list2, options[:cols2]),
        extract_index(list1, options[:cols1])
    )
  end

  def extract_index(list, cols)
    index = list.map do |line|
      [extract_key(line: line, cols: cols).join('~'), line]
    end
    Hash[index]
  end

  def extract_key(options = {})
    data_split = options[:line].split(';')
    key = Array.new
    options[:cols].sort.each do |cn|
      key << data_split[cn-1]
    end
    key
  end

  def read_file(file_path)
    File.open("#{file_path}", 'r:cp1253:utf-8') do |f|
      f.readlines.map { |line| line.chomp }
    end
  end

  def write_list(list, file_path)
    File.open(file_path, 'w') do |file|
      list.each do |el|
        file.puts el
      end
    end
  end

  def count_num_of_file_arguments(options)
    count_options_command(options, 'file')
  end

  def count_num_of_data_arguments(options)
    count_options_command(options, 'data')
  end

  def count_num_of_cols_arguments(options)
    count_options_command(options, 'cols')
  end

  def parse_options(options)
    return extract_data_sources(options), extract_column_arguments(options)
  end

  def extract_data_sources(options)
    data_sources = Hash.new
    extract_arguments(data_sources, options, 'data')
    extract_file_arguments(data_sources, options)
    data_sources
  end

  def extract_file_arguments(result, options)
    get_arguments(options, 'file').each do |arg|
      result[arg.to_s.split('file')[1].to_sym] = read_file(options[arg])
    end
  end

  def extract_column_arguments(options)
    columns = Hash.new
    extract_arguments(columns, options, 'cols')
    columns
  end

  def extract_arguments(result, options, argument)
    get_arguments(options, argument).each do |arg|
      result[arg.to_s.split(argument)[1].to_sym] = options[arg]
    end
  end

  def count_options_command(options, argument)
    get_arguments(options, argument).count
  end

  def get_arguments(options, argument)
    options.keys.select { |e| e.to_s.start_with?(argument) }.sort
  end

end