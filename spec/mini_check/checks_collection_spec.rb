require_relative '../helper'

shared_examples_for 'checks collection' do
  it{ is_expected.to respond_to(:to_hash) }
  it{ is_expected.to respond_to(:healthy?) }
  it{ is_expected.to respond_to(:<<) }
  it{ is_expected.to respond_to(:run) }
end

describe MiniCheck::ChecksCollection do
  it_behaves_like 'checks collection'

  let(:check_hash){ {healthy: true} }
  let(:check){ build_check(name: 'my_check') }

  def build_check args = {}
    stubs = {healthy?: true, to_hash: check_hash, run: true}
    @name_counter ||= 0
    stubs[:name] = "name_#{@name_counter += 1}"
    stubs.merge! args

    double(stubs[:name], stubs)
  end

  describe 'to_hash' do
    it 'uses the name as key' do
      subject << check_1 = build_check
      subject << check_2 = build_check

      expected_hash = {
        check_1.name => check_hash,
        check_2.name => check_hash,
      }

      expect(subject.to_hash).to eq(expected_hash)
    end
  end

  describe 'healthy?' do
    it 'is true when all are true' do
      subject << build_check(healthy?: true)
      subject << build_check(healthy?: true)
      subject << build_check(healthy?: true)

      expect(subject.healthy?).to eq(true)
    end

    it 'is true when one is false' do
      subject << build_check(healthy?: true)
      subject << build_check(healthy?: false)
      subject << build_check(healthy?: true)

      expect(subject.healthy?).to eq(false)
    end
  end

  describe 'run' do
    it 'runs each of the checks' do
      subject << check

      expect(check).to receive(:run)
      subject.run
    end
  end

  describe 'register' do
    it 'adds a new check to the collection' do
      name = 'asd'
      block = proc{}

      expect(MiniCheck::Check).to receive(:new).with(name, &block).and_return(check)
      subject.register(name, &block)
      expect(subject.last).to be(check)
    end
  end
end

