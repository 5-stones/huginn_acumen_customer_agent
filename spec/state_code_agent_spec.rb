require 'rails_helper'
require 'huginn_agent/spec_helper'

spec_folder = File.expand_path(File.dirname(__FILE__))



describe Agents::StateCodeAgent do
  before(:each) do
    @valid_options = Agents::StateCodeAgent.new.default_options
    @checker = Agents::StateCodeAgent.new(:name => "StateCodeAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end
end
