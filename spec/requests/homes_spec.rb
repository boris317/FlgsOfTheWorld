require 'spec_helper'

describe "Homes" do
  describe "GET /homes" do
    it "should contain the text 'Hello World!'" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      visit '/'
      page.should have_content("Hello World!")      
    end
  end
end
