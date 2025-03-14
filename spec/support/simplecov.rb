require 'simplecov'

coverage_dir = 'coverage'

SimpleCov.coverage_dir(coverage_dir)

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'
  add_filter '/lib/'

  formatter SimpleCov::Formatter::SimpleFormatter
end
