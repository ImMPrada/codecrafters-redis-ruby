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
    context 'when RDB file is empty' do
      before do
        writer.write_rdb({})
      end

      it 'returns an empty hash' do
        expect(parser.parse).to eq({})
      end
    end

    context 'when RDB file contains string data' do
      let(:test_data) { { 'test' => { value: 'value' } } }

      before do
        writer.write_rdb(test_data)
      end

      it 'parses string values correctly' do
        expect(parser.parse).to eq(test_data)
      end
    end

    context 'when RDB file contains data with expiration' do
      let(:expiry_ms) { 1_234_567_890 }
      let(:test_data) { { 'test' => { value: 'value', xp: expiry_ms } } }

      before do
        writer.write_rdb(test_data)
      end

      it 'parses expiry timestamp correctly' do
        expect(parser.parse).to eq(test_data)
      end
    end

    context 'when RDB file contains integer data' do
      describe 'small integers (INT8)' do
        let(:test_data) { { 'small_num' => { value: 42 } } }

        before do
          writer.write_rdb(test_data)
        end

        it 'parses INT8 values correctly' do
          expect(parser.parse).to eq(test_data)
        end
      end

      describe 'medium integers (INT16)' do
        let(:test_data) { { 'medium_num' => { value: 1000 } } }

        before do
          writer.write_rdb(test_data)
        end

        it 'parses INT16 values correctly' do
          expect(parser.parse).to eq(test_data)
        end
      end

      describe 'large integers (INT32)' do
        let(:test_data) { { 'large_num' => { value: 100_000 } } }

        before do
          writer.write_rdb(test_data)
        end

        it 'parses INT32 values correctly' do
          expect(parser.parse).to eq(test_data)
        end
      end

      describe 'very large integers' do
        let(:huge_number) { 9_223_372_036_854_775_807 }
        let(:test_data) { { 'huge_num' => { value: huge_number.to_s } } }

        before do
          writer.write_rdb(test_data)
        end

        it 'parses huge integers as strings' do
          expect(parser.parse).to eq(test_data)
        end
      end
    end

    context 'when RDB file contains mixed data types' do
      let(:test_data) do
        {
          'string' => { value: 'hello' },
          'string_with_expiry' => { value: 'world', xp: 1_234_567_890 },
          'small_int' => { value: 42 },
          'medium_int' => { value: 1000 },
          'large_int' => { value: 100_000 },
          'huge_int' => { value: '9223372036854775807' }
        }
      end

      before do
        writer.write_rdb(test_data)
      end

      it 'parses all data types correctly' do
        expect(parser.parse).to eq(test_data)
      end
    end

    context 'with invalid RDB file' do
      before do
        temp_file.write('INVALID')
        temp_file.rewind
      end

      it 'raises an error' do
        expect { parser.parse }.to raise_error('Invalid RDB file format')
      end
    end
  end
end 