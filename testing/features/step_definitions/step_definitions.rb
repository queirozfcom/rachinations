Given(/^I am at the start of the program$/) do
  pending
end

And(/^I create an empty diagram named "([^"]*)"$/) do |arg|
  d=Diagram.new "empty"
end

Then(/^I should be able to ask the name and receive "([^"]*)"$/) do |arg|
  d.name.should == "empty"
end