require 'spec_helper'
require 'swiftfake/compiler_interface'

describe Swiftfake::CompilerInterface do
  describe '#generate_ast' do
    it 'returns the abstract syntax tree from the source file' do
      result = subject.generate_ast('spec/examples/BasicClass.swift')
      expect(result).to include('BasicClass', 'internal func')
    end
  end
end
