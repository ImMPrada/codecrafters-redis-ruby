require 'spec_helper'

describe String do
  describe '#match_pattern?' do
    subject(:execute) { string.match_pattern?(pattern) }

    let(:string) { 'test' }

    context 'when the pattern is *' do
      let(:pattern) { '*' }

      it 'returns true' do
        expect(execute).to be true
      end
    end

    context 'when the pattern is te*' do
      let(:pattern) { 'te*' }

      it 'returns true' do
        expect(execute).to be true
      end
    end

    context 'when the pattern is *st' do
      let(:pattern) { '*st' }

      it 'returns true' do
        expect(execute).to be true
      end
    end

    context 'when the pattern is *es*' do
      let(:pattern) { '*es*' }

      it 'returns true' do
        expect(execute).to be true
      end
    end

    context 'when the pattern is te*st' do
      let(:pattern) { 'te*st' }

      it 'returns true' do
        expect(execute).to be true
      end
    end

    context 'when the pattern is *f' do
      let(:pattern) { '*f' }

      it 'returns false' do
        expect(execute).to be false
      end
    end

    context 'when the pattern is f*' do
      let(:pattern) { 'f*' }

      it 'returns false' do
        expect(execute).to be false
      end
    end

    context 'when the pattern is *of*' do
      let(:pattern) { '*of*' }

      it 'returns false' do
        expect(execute).to be false
      end
    end

    context 'when the pattern is f*p' do
      let(:pattern) { 'f*p' }

      it 'returns false' do
        expect(execute).to be false
      end
    end
  end
end
