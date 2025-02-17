require 'spec_helper'
require 'tempfile'

RSpec.describe RedisRuby::RDB::Parser do
  let(:temp_file) { Tempfile.new(['test', '.rdb']) }
  let(:writer) { RedisRuby::RDB::Writer.new(temp_file.path) }
  let(:parser) { described_class.new(temp_file.path) }

  after do
    temp_file.close
    temp_file.unlink
  end

  describe '#parse' do
    context 'when RDB file contains metadata' do
      let(:test_data) { {} } # Empty data, only metadata will be written

      before do
        writer.write_rdb(test_data)
      end

      it 'reads the metadata correctly' do
        parser.parse
        expect(parser.instance_variable_get(:@metadata)).to include('redis-ver' => '6.0.16')
      end
    end

    context 'when RDB file contains string data' do
      let(:test_data) { { 'test' => { value: 'value' } } }

      before do
        writer.write_rdb(test_data)
        puts "Test data: #{test_data.inspect}"
      end

      it 'parses string values correctly' do
        result = parser.parse
        puts "Parser result: #{result.inspect}"
        expect(result).to eq(test_data)
      end
    end

    context 'when RDB file contains data with expiration' do
      let(:test_data) { { 'test' => { value: 'value', xp: 1_234_567_890 } } }

      before do
        writer.write_rdb(test_data)
      end

      it 'parses expiry timestamp correctly' do
        expect(parser.parse).to eq(test_data)
      end
    end

    context 'when RDB file contains mixed data types' do
      let(:test_data) do
        {
          'string' => { value: 'hello' },
          'string_with_expiry' => { value: 'world', xp: 1_234_567_890 }
        }
      end

      before do
        writer.write_rdb(test_data)
      end

      it 'parses all data types correctly' do
        expect(parser.parse).to eq(test_data)
      end
    end
  end
end
