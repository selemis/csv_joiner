require_relative '../bin/csv_joiner'

describe CsvJoiner do

  before do
    @list = Array.new
    @list << %w(1 2 3 4 5 6 7 8).join(';')
    @list << %w(1 12 3 14 5 16 7 18).join(';')

    @list1 = Array.new
    @list1 << %w(1 4 6 8 10 12 14 16).join(';')
    @list1 << %w(4 8 1 2 3 4 5 6 7).join(';')
    @list1 << %w(1 2 3).join(';')
    @list1 << %w(3 2 1).join(';')

    @list2 = Array.new
    @list2 << %w(4 8 12 13 14 15 16 17).join(';')
    @list2 << %w(4 1 2 3 1).join(';')
    @list2 << %w(1 4 0 0 0 0 0).join(';')

    @joiner = CsvJoiner.new
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
    expected = {
        '1~4' => '1;2;3;4;5;6;7;8',
        '1~14' => '1;12;3;14;5;16;7;18'
    }

    actual = @joiner.instance_eval do
      extract_index(list, cols)
    end

    actual.should == expected
  end

  it 'joins two lists'

  it 'loads a csv file to an array'


end