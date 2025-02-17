require 'spec_helper'
require 'fileutils'

RSpec.describe RedisRuby::RDB::Manager do
  let(:test_dir) { 'tmp/test' }
  let(:test_filename) { 'dump.rdb' }
  let(:test_path) { File.join(test_dir, test_filename) }
  let(:manager) { described_class.new(test_dir, test_filename) }

  before do
    FileUtils.mkdir_p(test_dir)
  end

  after do
    FileUtils.rm_rf(test_dir)
  end

  describe '#load_database' do
    context 'when RDB file does not exist' do
      it 'returns an empty hash' do
        expect(manager.load_database).to eq({})
      end
    end

    context 'when RDB file exists' do
      let(:test_data) do
        {
          'key1' => { value: 'value1' },
          'key2' => { value: 'value2' }
        }
      end

      before do
        manager.save_database(test_data)
      end

      it 'loads the database from the file' do
        expect(manager.load_database).to eq(test_data)
      end
    end
  end

  describe '#save_database' do
    let(:test_data) do
      {
        'test_key' => { value: 'test_value' }
      }
    end

    it 'saves the database to a file' do
      manager.save_database(test_data)
      expect(File.exist?(test_path)).to be true
      expect(manager.load_database).to eq(test_data)
    end

    context 'with expiry time' do
      let(:test_data) do
        {
          'test_key' => { value: 'test_value', xp: (Time.now.to_f * 1000).to_i }
        }
      end

      it 'saves and loads the database with expiry time' do
        manager.save_database(test_data)
        expect(File.exist?(test_path)).to be true
        expect(manager.load_database).to eq(test_data)
      end
    end
  end
end
