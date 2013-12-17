require_relative '../bin/csv_joiner'

def extract_index(list, cols)
  @joiner.instance_eval do
    extract_index(list, cols)
  end
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
    file_path = File.join(File.dirname(__FILE__), 'files', 'a.csv')
    lines = @joiner.instance_eval do
      read_file(file_path)
    end
    lines.should == @list1
  end

  it 'writes a list to a file' do
    file_path = File.join(File.dirname(__FILE__), 'files', 'c.csv')
    list = @list1
    @joiner.instance_eval do
      write_list(list, file_path)
    end
  end

  it 'shows both lines after joining two files'  do

    file_path_a = File.join(File.dirname(__FILE__), 'files', 'a.csv')
    file_path_b = File.join(File.dirname(__FILE__), 'files', 'b.csv')

    @joiner.join({file1: file_path_a,
                  file2: file_path_b,
                  output_file: @file_path_output,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 2 3 4 5 6 1 3 5 7 9).join(';'),
                 %w(13 14 15 16 17 18 13 15 2 2 2).join(';')]

  end

  it 'shows file1 lines after joining two files' do
    file_path_a = File.join(File.dirname(__FILE__), 'files', 'a.csv')
    file_path_b = File.join(File.dirname(__FILE__), 'files', 'b.csv')

    @joiner.join({list: :first,
                  file1: file_path_a,
                  file2: file_path_b,
                  output_file: @file_path_output,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 2 3 4 5 6).join(';'),
                 %w(13 14 15 16 17 18).join(';')]
  end

  it 'shows file2 lines after joining two files' do
    file_path_a = File.join(File.dirname(__FILE__), 'files', 'a.csv')
    file_path_b = File.join(File.dirname(__FILE__), 'files', 'b.csv')

    @joiner.join({list: :second,
                  file1: file_path_a,
                  file2: file_path_b,
                  output_file: @file_path_output,
                  cols1: [1, 3],
                  cols2: [1, 2]}
    ).should == [%w(1 3 5 7 9).join(';'),
                 %w(13 15 2 2 2).join(';')]
  end

end