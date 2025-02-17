require 'spec_helper'
require 'tempfile'

RSpec.describe RedisRuby::RDB::Writer do
  let(:temp_file) { Tempfile.new(['test', '.rdb']) }
  let(:writer) { described_class.new(temp_file.path) }
  # Read file content in binary mode to properly handle RDB format
  let(:content) { File.read(temp_file.path, mode: 'rb') }

  after do
    # Clean up temporary files after each test
    temp_file.close
    temp_file.unlink
  end

  describe '#write_rdb' do
    # Test basic RDB structure with empty data
    context 'when hash is empty' do
      before do
        writer.write_rdb({})
      end

      it 'writes the magic header' do
        expect(content[0..8]).to eq('REDIS0011')
      end

      it 'includes redis version key in metadata' do
        expect(content).to include('redis-ver')
      end

      it 'includes redis version value in metadata' do
        expect(content).to include('6.0.16')
      end

      it 'writes the EOF marker' do
        expect(content[-9]).to eq("\xFF".force_encoding('ASCII-8BIT'))
      end

      it 'writes the checksum' do
        expect(content[-8..]).to eq("\x00".force_encoding('ASCII-8BIT') * 8)
      end
    end

    # Test string value handling
    context 'when hash has string data' do
      let(:test_data) { { 'test' => { value: 'value' } } }

      before do
        writer.write_rdb(test_data)
      end

      it 'writes the database selector' do
        expect(content).to include("\xFE\x00".force_encoding('ASCII-8BIT'))
      end

      it 'writes the key' do
        expect(content).to include('test')
      end

      it 'writes the value' do
        expect(content).to include('value')
      end
    end

    # Test string value with expiration timestamp
    context 'when hash has string data with expiration' do
      let(:expiry_ms) { 1_234_567_890 }
      let(:test_data) { { 'test' => { value: 'value', xp: expiry_ms } } }
      # Convert expiry timestamp to binary format
      let(:expiry_bytes) { [expiry_ms].pack('Q>') }

      before do
        writer.write_rdb(test_data)
      end

      it 'writes the expiry marker' do
        expect(content).to include("\xFC".force_encoding('ASCII-8BIT'))
      end

      it 'writes the expiry timestamp' do
        expect(content).to include(expiry_bytes.force_encoding('ASCII-8BIT'))
      end

      it 'writes the value' do
        expect(content).to include('value')
      end
    end

    # Test integer encoding for different ranges
    context 'when hash has integer data' do
      # Test 8-bit integer encoding (-128 to 127)
      describe 'small integers (INT8)' do
        let(:test_data) { { 'small_num' => { value: 42 } } }
        let(:expected_encoding) { "\x00\x00*".force_encoding('ASCII-8BIT') }

        before do
          writer.write_rdb(test_data)
        end

        it 'uses INT8 encoding' do
          expect(content).to include(expected_encoding)
        end
      end

      # Test 16-bit integer encoding (-32768 to 32767)
      describe 'medium integers (INT16)' do
        let(:test_data) { { 'medium_num' => { value: 1000 } } }
        let(:expected_encoding) { "\x00\x01\x03\xE8".force_encoding('ASCII-8BIT') }

        before do
          writer.write_rdb(test_data)
        end

        it 'uses INT16 encoding' do
          expect(content).to include(expected_encoding)
        end
      end

      # Test 32-bit integer encoding (-2147483648 to 2147483647)
      describe 'large integers (INT32)' do
        let(:test_data) { { 'large_num' => { value: 100_000 } } }
        let(:expected_encoding) { "\x00\x02\x00\x01\x86\xA0".force_encoding('ASCII-8BIT') }

        before do
          writer.write_rdb(test_data)
        end

        it 'uses INT32 encoding' do
          expect(content).to include(expected_encoding)
        end
      end

      # Test handling of integers larger than 32 bits
      describe 'very large integers' do
        let(:huge_number) { 9_223_372_036_854_775_807 } # Max 64-bit integer
        let(:test_data) { { 'huge_num' => { value: huge_number } } }

        before do
          writer.write_rdb(test_data)
        end

        it 'stores as string' do
          expect(content).to include(huge_number.to_s)
        end
      end

      # Test integer with expiration timestamp
      describe 'integers with expiration' do
        let(:test_data) { { 'num_with_expiry' => { value: 42, xp: 1_234_567_890 } } }
        let(:expected_value_encoding) { "\x00\x00*".force_encoding('ASCII-8BIT') }
        let(:expected_expiry_marker) { "\xFC".force_encoding('ASCII-8BIT') }

        before do
          writer.write_rdb(test_data)
        end

        it 'writes the expiry marker' do
          expect(content).to include(expected_expiry_marker)
        end

        it 'writes the value with correct encoding' do
          expect(content).to include(expected_value_encoding)
        end
      end
    end

    # Test handling of multiple data types in a single RDB file
    context 'when hash has mixed data types' do
      let(:test_data) do
        {
          'string' => { value: 'hello' },
          'string_with_expiry' => { value: 'world', xp: 1_234_567_890 },
          'small_int' => { value: 42 },
          'medium_int' => { value: 1000 },
          'large_int' => { value: 100_000 },
          'huge_int' => { value: 9_223_372_036_854_775_807 }
        }
      end

      before do
        writer.write_rdb(test_data)
      end

      it 'writes plain string value' do
        expect(content).to include('hello')
      end

      it 'writes expiry marker for string with expiry' do
        expect(content).to include("\xFC".force_encoding('ASCII-8BIT'))
      end

      it 'writes string value with expiry' do
        expect(content).to include('world')
      end

      it 'writes small integer with correct encoding' do
        expect(content).to include("\x00\x00*".force_encoding('ASCII-8BIT'))
      end

      it 'writes medium integer with correct encoding' do
        expect(content).to include("\x00\x01\x03\xE8".force_encoding('ASCII-8BIT'))
      end

      it 'writes large integer with correct encoding' do
        expect(content).to include("\x00\x02\x00\x01\x86\xA0".force_encoding('ASCII-8BIT'))
      end

      it 'writes huge integer as string' do
        expect(content).to include('9223372036854775807')
      end
    end
  end
end
