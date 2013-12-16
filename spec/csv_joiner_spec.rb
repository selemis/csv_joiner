require_relative '../bin/csv_joiner'

describe CsvJoiner do

  before do
    @list = Array.new
    @list << %w(1 2 3 4 5 6 7 8).join(';')
    @list << %w(1 12 3 14 5 16 7 18).join(';')

    @list1 = Array.new
    @list1 << %w(1 2 3 4 5 6).join(';')
    @list1 << %w(7 8 9 10 11 12).join(';')
    @list1 << %w(13 14 15 16 17 18).join(';')
    @list1 << %w(19 20 21 22 23 24).join(';')

    @list2 = Array.new
    @list2 << %w(1 3 5 7 9).join(';')
    @list2 << %w(1 1 1 1 1 1).join(';')
    @list2 << %w(13 15 2 2 2).join(';')

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

    list1 = @list1
    cols1 = [1, 3]
    indexed_list1 = @joiner.instance_eval do
      extract_index(list1, cols1)
    end

    list2 = @list2
    cols2 = [1, 2]
    indexed_list2 = @joiner.instance_eval do
      extract_index(list2, cols2)
    end

    @joiner.instance_eval do
      compare_indexed_lists(indexed_list1, indexed_list2)[0]
    end
        [
            %w(1 2 3 4 5 6).join(';'),
            %w(13 14 15 16 17 18).join(';')
        ]

    @joiner.compare_indexed_lists(indexed_list2, indexed_list1)[0].should ==
        [
            %w(1 3 5 7 9).join(';'),
            %w(13 15 2 2 2).join(';')
        ]

  end

  it 'compares two indexed lists based on the index and returns as different lines the whole line of the first list ' do

    list1 = @list1
    cols1 = [1, 3]
    indexed_list1 = @joiner.instance_eval do
      extract_index(list1, cols1)
    end

    list2 = @list2
    cols2 = [1, 2]
    indexed_list2 = @joiner.instance_eval do
      extract_index(list2, cols2)
    end

    @joiner.compare_indexed_lists(indexed_list1, indexed_list2)[1].should ==
        [
            %w(7 8 9 10 11 12).join(';'),
            %w(19 20 21 22 23 24).join(';')
        ]

    @joiner.compare_indexed_lists(indexed_list2, indexed_list1)[1].should ==
        [
            %w(1 1 1 1 1 1).join(';')
        ]

  end

  it 'loads a csv file to an array'

end