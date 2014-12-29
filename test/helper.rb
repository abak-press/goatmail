$: << File.expand_path(File.join(File.dirname(__FILE__),'..','lib'))
require 'rack/test'
require 'minitest/autorun'
require 'minitest/spec'
require 'capybara'
require 'capybara/dsl'
require 'capybara/webkit'
require 'capybara/poltergeist'
require 'mail'
require 'goatmail'
if /^ruby/ =~ RUBY_DESCRIPTION && RUBY_VERSION >= '2.0'
  require 'minitest-power_assert'
end
if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

class MiniTest::Spec
  include Rack::Test::Methods
  include Capybara::DSL
  def app
    Goatmail::App
  end
end
class Minitest::SharedExamples < Module
  include Minitest::Spec::DSL
end

def tmp_dir
  @tmp_dir ||= File.expand_path('tmp', File.dirname(__FILE__))
end
def test_location
  @test_locatino ||= File.join(tmp_dir, 'goatmail')
end

Goatmail.location = test_location
Mail.defaults do
  delivery_method Goatmail::DeliveryMethod
end

MiniTest::Spec.after do
  FileUtils.rm_rf tmp_dir
end

Capybara.app = Goatmail::App
Capybara.default_driver = :webkit
Capybara.javascript_driver = :poltergeist
