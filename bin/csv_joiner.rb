class CsvJoiner

  # Compare 2 text files line by line.
  # It returns new arrays.
  # The first has the common lines.
  # of the two files(comparing with the key).
  # The second has the lines that are missing from file2lines.
  def compare_files(file1lines, file2lines)
    common_lines = []
    diff_lines = []
    file1lines.each do |k, v|
      unless file2lines.include?(k)
        diff_lines << v
      else
        common_lines << v
      end
    end
    return common_lines, diff_lines
  end

  private

  def extract_index(list, cols)
    index = Hash.new
    list.each do |line|
      index[extract_key(line: line, cols: cols).join('~')] = line
    end
    index
  end

  def extract_key(options = {})
    data_split = options[:line].split(';')
    key = Array.new
    options[:cols].sort.each do |cn|
      key << data_split[cn-1]
    end
    key
  end

end