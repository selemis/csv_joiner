require_relative '../bin/csv_joiner'

def extract_index(list, cols)
  @joiner.instance_eval do
    extract_index(list, cols)
  end
end

def get_file(filename)
  File.join(File.dirname(__FILE__), 'files', filename)
end

describe CsvJoiner do

  before do
    @list = [%w(1 2 3 4 5 6 7 8).join(';'),
             %w(1 12 3 14 5 16 7 18).join(';')]

    @list1 = [%w(1 2 3 4 5 6).join(';'),
              %w(7 8 9 10 11 12).join(';'),
              %w(13 14 15 16 17 18).join(';'),
              %w(19 20 21 22 23 24).join(';')]

    @list2 = [%w(1 3 5 7 9).join(';'),
              %w(1 1 1 1 1 1).join(';'),
              %w(13 15 2 2 2).join(';')]

    @joiner = CsvJoiner.new

    @file_path_output = File.join(File.dirname(__FILE__), 'files', 'd.csv')
    File.delete(@file_path_output) if File.exist?(@file_path_output)
  end

  it 'extracts a join key from the line' do
    line = @list[1]
    cols = [1, 4]

    key = @joiner.instance_eval do
      extract_key(line: line, cols: cols)
    end

    key.should == %w(1 14)
  end

  it 'extracts a Hash from the loaded Array with key the join part and value the whole line' do
    list = @list
    cols = [1, 4]

    actual = @joiner.instance_eval do
      extract_index(list, cols)
    end

    expected = {
        '1~4' => '1;2;3;4;5;6;7;8',
        '1~14' => '1;12;3;14;5;16;7;18'
    }

    actual.should == expected
  end

  it 'compares two indexed lists based on the index and returns as common lines the whole line of the first list ' do

    @joiner.common_lines(
        extract_index(@list1, [1, 3]),
        extract_index(@list2, [1, 2])
    ).should == [%w(1 2 3 4 5 6).join(';'),
                 %w(13 14 15 16 17 18).join(';')]

    @joiner.common_lines(
        extract_index(@list2, [1, 2]),
        extract_index(@list1, [1, 3])
    ).should == [%w(1 3 5 7 9).join(';'), %w(13 15 2 2 2).join(';')]

  end

  it 'compares two indexed lists based on the index and returns as different lines the whole line of the first list ' do

    @joiner.diff_lines(
        extract_index(@list1, [1, 3]),
        extract_index(@list2, [1, 2])
    ).should == [%w(7 8 9 10 11 12).join(';'),
                 %w(19 20 21 22 23 24).join(';')]

    @joiner.diff_lines(
        extract_index(@list2, [1, 2]),
        extract_index(@list1, [1, 3])
    ).should == [%w(1 1 1 1 1 1).join(';')]

  end

  it 'shows both lines after join' do
    @joiner.join({data1: @list1,
                  data2: @list2,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 2 3 4 5 6 1 3 5 7 9).join(';'),
                 %w(13 14 15 16 17 18 13 15 2 2 2).join(';')]
  end

  it 'shows list1 lines after join' do
    @joiner.join({list: :first,
                  data1: @list1,
                  data2: @list2,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 2 3 4 5 6).join(';'),
                 %w(13 14 15 16 17 18).join(';')]
  end

  it 'shows list2 lines after join' do
    @joiner.join({list: :second,
                  data1: @list1,
                  data2: @list2,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 3 5 7 9).join(';'),
                 %w(13 15 2 2 2).join(';')]
  end

  it 'loads a csv file to an array' do
    file_path = get_file 'a.csv'
    lines = @joiner.instance_eval do
      read_file(file_path)
    end
    lines.should == @list1
  end

  it 'writes a list to a file' do
    file_path = get_file 'c.csv'
    list = @list1
    @joiner.instance_eval do
      write_list(list, file_path)
    end
  end

  it 'shows both lines after joining two files' do
    @joiner.join(
        {file1: get_file('a.csv'),
         file2: get_file('b.csv'),
         output_file: @file_path_output,
         cols1: [1, 3],
         cols2: [1, 2]}
    ).should == [%w(1 2 3 4 5 6 1 3 5 7 9).join(';'),
                 %w(13 14 15 16 17 18 13 15 2 2 2).join(';')]
  end

  it 'shows file1 lines after joining two files' do
    @joiner.join({list: :first,
                  file1: get_file('a.csv'),
                  file2: get_file('b.csv'),
                  output_file: @file_path_output,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 2 3 4 5 6).join(';'),
                 %w(13 14 15 16 17 18).join(';')]
  end

  it 'shows file2 lines after joining two files' do
    @joiner.join({list: :second,
                  file1: get_file('a.csv'),
                  file2: get_file('b.csv'),
                  output_file: @file_path_output,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 3 5 7 9).join(';'),
                 %w(13 15 2 2 2).join(';')]
  end

  it 'counts the number of file arguments in the options hash' do
    num = @joiner.instance_eval do
      count_num_of_file_arguments(
          {file1: 'some_file_1',
           file2: 'some_file_2',
           data1: 'some_data_1',
           cols1: [1, 3],
           file3: 'some_file_3',
           data2: 'some_data_2'}
      )
    end
    num.should == 3
  end

  it 'counts the number of data arguments in the options hash' do
    num = @joiner.instance_eval do
      count_num_of_data_arguments(
          {file1: 'some_file_1',
           file2: 'some_file_2',
           data1: 'some_data_1',
           cols1: [1, 3],
           file3: 'some_file_3',
           data2: 'some_data_2'}
      )
    end
    num.should == 2
  end

  it 'counts the number of column arguments in the options hash' do
    num = @joiner.instance_eval do
      count_num_of_cols_arguments(
          {file1: 'some_file_1',
           file2: 'some_file_2',
           data1: 'some_data_1',
           cols1: [1, 3],
           file3: 'some_file_3',
           data2: 'some_data_2'}
      )
    end
    num.should == 1
  end

  it 'converts extracts all arguments to their positions (data sources) and columns' do
    file1 = get_file 'a.csv'
    file3 = get_file 'b.csv'
    options = {
        file1: file1,
        file3: file3,
        data2: 'some_data_2',
        cols1: [1, 7],
        data4: 'some_data_4',
        data5: 'some_data_5',
        cols2: [1],
        cols3: [1, 3],
        cols4: [1, 4],
        cols5: [1, 5]
    }

    data_sources = @joiner.instance_eval do
      extract_data_sources(
          options
      )
    end

    data_sources.count.should == 5
    data_sources.should include(
                            '1'.to_sym => File.open(file1).readlines.map!{|e| e.chomp},
                            '2'.to_sym => 'some_data_2',
                            '3'.to_sym => File.open(file3).readlines.map!{|e| e.chomp},
                            '4'.to_sym => 'some_data_4',
                            '5'.to_sym => 'some_data_5',
                        )

    columns = @joiner.instance_eval do
      extract_column_arguments(
          options
      )
    end

    columns.count.should == 5
    columns.should include(
                       '1'.to_sym => [1, 7],
                       '2'.to_sym => [1],
                       '3'.to_sym => [1, 3],
                       '4'.to_sym => [1, 4],
                       '5'.to_sym => [1, 5],
                   )
  end

  it 'extracts file arguments' do
    result = Hash.new
    file1 = get_file 'a.csv'
    file3 = get_file 'b.csv'
    options = {
        file1: file1,
        file3: file3,
        data2: 'some_data_2',
        cols1: [1, 7],
        data4: 'some_data_4',
        data5: 'some_data_5',
        cols2: [1],
        cols3: [1, 3],
        cols4: [1, 4],
        cols5: [1, 5]
    }

    @joiner.instance_eval do
      extract_file_arguments(result, options)
    end

    result.count.should == 2
    result.should include(
                            '1'.to_sym => File.open(file1).readlines.map!{|e| e.chomp},
                            '3'.to_sym => File.open(file3).readlines.map!{|e| e.chomp},
                        )

  end

  it 'parses the options hash'

  #def try(arr)
  #  result = []
  #  arr.each_with_index do |el, ind|
  #    result << arr.slice(ind, 2) if arr.slice(ind, 2).count > 1
  #  end
  #  p result
  #  puts 'done'
  #end
  #
  #try ["a", "b"]
  #
  #try ["a", "b", "c"]
  #
  #try ["a", "b", "c", "d"]

end