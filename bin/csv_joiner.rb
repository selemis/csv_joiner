class CsvJoiner

  attr_writer :separator

  def initialize
    @separator = ';'
  end

  def join(options = {})

    # Check in the future if I can join more than one files
    ds1 = config_data_source(options[:file1], options[:data1])
    ds2 = config_data_source(options[:file2], options[:data2])

    case options[:list]
      when :first
        output_data = common_lines_for_first_list(ds1, ds2, options)
      when :second
        output_data = common_lines_for_second_list(ds1, ds2, options)
      else
        output_data = all_lines(
            common_lines_for_first_list(ds1, ds2, options),
            common_lines_for_second_list(ds1, ds2, options)
        )
    end

    if options[:output_file]
      write_list(output_data, options[:output_file])
    end
    output_data

  end

  def common_lines(indexed_list1, indexed_list2)
    indexed_list1.select { |k, v| indexed_list2.include?(k) }.map { |k, v| v }
  end

  def diff_lines(indexed_list1, indexed_list2)
    indexed_list1.select { |k, v| !indexed_list2.include?(k) }.map { |k, v| v }
  end

  private

  def all_lines(cl1, cl2)
    all = []
    cl1.each_with_index do |el, ind|
      all << el + @separator + cl2[ind]
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
    File.open(file_path, "w") do |file|
      list.each do |el|
        file.puts el
      end
    end
  end

  def config_data_source(file, data)
    if file
      read_file(file)
    else
      data
    end
  end

end