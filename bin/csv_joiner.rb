class CsvJoiner

  def common_lines(indexed_list1, indexed_list2)
    indexed_list1.select{ |k,v| indexed_list2.include?(k)}.map{ |k,v| v}
  end

  def diff_lines(indexed_list1, indexed_list2)
    indexed_list1.select{ |k,v| !indexed_list2.include?(k)}.map{ |k,v| v}
  end

  private

  def extract_index(list, cols)
    index = list.map do |line|
      [extract_key(line: line, cols: cols).join('~'), line]
    end
    Hash[index]
  end

  def extract_key(options = {})
    data_split = options[:line].split(';')
    data_split.find_all
    key = Array.new
    options[:cols].sort.each do |cn|
      key << data_split[cn-1]
    end
    key
  end

end