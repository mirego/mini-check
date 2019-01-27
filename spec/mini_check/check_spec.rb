require_relative '../helper'

shared_examples_for 'check' do
  it{ is_expected.to respond_to(:to_hash) }
  it{ is_expected.to respond_to(:name) }
  it{ is_expected.to respond_to(:healthy?) }
  it{ is_expected.to respond_to(:run) }
end

describe MiniCheck::Check do
  subject{ MiniCheck::Check.new name: name, action: action }
  let(:name){ 'my_check' }
  let(:action){ proc{ true } }
  let(:exception){ Exception.new('My message') }

  it_behaves_like 'check'

  describe 'initialize' do
    it 'allows passing attributes as a hash' do
      check = MiniCheck::Check.new name: name, action: action
      expect(check.name).to eq(name)
      expect(check.action).to eq(action)
    end

    it 'allows building by name and proc' do
      check = MiniCheck::Check.new(name, &action)

      expect(check.name).to eq(name)
      expect(check.action).to eq(action)
    end
  end

  describe 'run' do
    it 'calls the action' do
      expect(action).to receive(:call)
      subject.run
    end

    context 'when the action returns an object (success)' do
      before :each do
        allow(action).to receive(:call).and_return(Object.new)
      end

      it 'sets the healthy? to true' do
        subject.healthy = nil
        subject.run
        expect(subject.healthy?).to eq(true)
      end

      it 'blanks the exception' do
        subject.exception = Exception.new
        subject.run
        expect(subject.exception).to be_nil
      end
    end

    context 'when the action returns false' do
      before :each do
        allow(action).to receive(:call).and_return(false)
      end

      it 'sets the healthy? to false' do
        subject.healthy = true
        subject.run
        expect(subject.healthy?).to eq(false)
      end

      it 'blanks the exception' do
        subject.exception = Exception.new
        subject.run
        expect(subject.exception).to be_nil
      end
    end

    context 'when the action raises an exception' do
      before :each do
        allow(action).to receive(:call).and_raise(exception)
      end

      it 'sets the healthy? to false' do
        subject.healthy = true
        subject.run
        expect(subject.healthy?).to eq(false)
      end

      it 'sets the exception to the exception' do
        subject.exception = nil
        subject.run
        expect(subject.exception).to be(exception)
      end
    end
  end

  describe 'to_hash' do
    before do
      allow_any_instance_of(Benchmark::Tms).to receive(:real).and_return(1.0)
    end

    context 'when the run was successful' do
      before :each do
        allow(action).to receive(:call).and_return(Object.new)
      end

      it 'returns the basic healthy hash' do
        subject.run
        expect(subject.to_hash).to eq(healthy: true, time: 1.0)
      end
    end

    context 'when the action returns false' do
      before :each do
        allow(action).to receive(:call).and_return(false)
      end

      it 'returns the basic healthy hash' do
        subject.run
        expect(subject.to_hash).to eq(healthy: false, time: 1.0)
      end
    end

    context 'when the action raises an exception' do
      before :each do
        allow(exception).to receive(:backtrace).and_return ['a']
        allow(action).to receive(:call).and_raise(exception)
      end

      it 'returns the hash with error' do
        subject.run
        expect(subject.to_hash).to eq(
          {
            healthy: false,
            error: {
              message: exception.message,
              stack: exception.backtrace
            },
            time: 1.0
          }
        )
      end
    end
  end
end
