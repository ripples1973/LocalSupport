require 'webmock/cucumber'
require 'uri-handler'

Given /^I delete "(.*?)" charity$/ do |name|
  org = Organization.find_by_name name
  page.driver.submit :delete, "/organizations/#{org.id}", {}
end

Then /^I should not see an edit button for "(.*?)" charity$/ do |name|
  org = Organization.find_by_name name
  expect(page).not_to have_link :href => edit_organization_path(org.id)
end

Then /^show me the page$/ do
  save_and_open_page
end

Given /^PENDING/ do
  pending
end

Given /^I press "(.*?)"$/ do |button|
  click_button(button)
end

When /^I search for "(.*?)"$/ do |text|
  fill_in 'q', with: text
  click_button 'Search'
end

Given /^I fill in the new charity page validly$/ do
  stub_request_with_address("64 pinner road")
  fill_in 'organization_address', :with => '64 pinner road'
  fill_in 'organization_name', :with => 'Friendly charity'
end

Then /^the contact information should be available$/ do
   steps %Q{
    When I follow "Contact"
    Then I should see "Contact Info Email us: contact@voluntaryactionharrow.org.uk Phone Us: 020 8861 5894 Write to Us: The Lodge, 64 Pinner Road, Harrow, Middlesex, HA1 4HZ Find Us: On Social Media (Click Here)"
   }
end
Then /^the about us should be available$/ do
  steps %Q{
    When I follow "About Us"
    Then I should see "About Us Supporting groups in Harrow We are a not-for-profit workers co-operative who support people and not-for-profit organisations to make a difference in their local community by: Working with local people and groups to identify local needs and develop appropriate action. Providing a range of services that help organisations to succeed. Supporting and encouraging the growth of co-operative movement. How do we support? Find out here (VAH in a nutshell) What is a Workers Co-operative? A workers co-operative is a business owned and democratically controlled by their employee members using co-operative principles. They are an attractive and increasingly relevant alternative to traditional investor owned models of enterprise. (Click here for more details)"
  }
end
Given /^I update "(.*?)" charity address to be "(.*?)"( when Google is indisposed)?$/ do |name, address, indisposed|
  steps %Q{
    Given I am on the charity page for "#{name}"
    And I follow "Edit"
    And I edit the charity address to be "#{address}" #{indisposed ? 'when Google is indisposed':''}
    And I press "Update Organization"
  }
end

Given /^I have created a new organization$/ do
  steps %Q{
    Given I am on the home page
    And I follow "New Organization"
    And I fill in the new charity page validly
    And I press "Create Organization"
   }
end

Given /^I furtively update "(.*?)" charity address to be "(.*?)"$/ do |name, address|
  steps %Q{
    Given I am furtively on the edit charity page for "#{name}"
    And I edit the charity address to be "#{address}"
    And I press "Update Organization"
  }
end

When /^I edit the charity address to be "(.*?)"$/ do |address|
  stub_request_with_address(address)
  fill_in('organization_address',:with => address)
end


And /^"(.*?)" charity address is "(.*?)"$/ do |name, address|
  org = Organization.find_by_name(name)
  expect(org.address).to eq(address)
end

Then /^I should see "(.*?)" before "(.*?)"$/ do |name1,name2|
  str = page.body
  assert str.index(name1) < str.index(name2)
end

Then /^I should see the donation_info URL for "(.*?)"$/ do |name1|
  org1 = Organization.find_by_name(name1)
  page.should have_link "Donate to #{org1.name} now!", :href => org1.donation_info
end

Then /^I should not see the donation_info URL for "(.*?)"$/ do |name1|
  org1 = Organization.find_by_name(name1)
  page.should_not have_link "Donate to #{org1.name} now!"
  page.should have_content "We don't yet have any donation link for them."
end

Then /^the donation_info URL for "(.*?)" should refer to "(.*?)"$/ do |name, href|
  expect(page).to have_link "Donate to #{name} now!", :href => href
end

And /^the search box should contain "(.*?)"$/ do |arg1|
  expect(page).to have_xpath("//input[@id='q' and @value='#{arg1}']")
end

Then /^I should( not)? see the no results message$/ do |negate| 
  expectation_method = negate ? :not_to : :to
  expect(page).send(expectation_method, have_content("Sorry, it seems we don't quite have what you are looking for."))
end

Then /^I should not see any address or telephone information for "([^"]*?)" and "([^"]*?)"$/ do |name1, name2|
  org1 = Organization.find_by_name(name1)
  org2 = Organization.find_by_name(name2)
  page.should_not have_content org1.telephone
  page.should_not have_content org1.address
  page.should_not have_content org2.telephone
  page.should_not have_content org2.address
end

Given /^I update the "(.*?)"$/ do |name|
  org1 = Organization.find_by_name(name)
  org1.address = "84 pinner road"
  org1.save!
end


When /^(?:|I )follow "([^"]*)"$/ do |link|
    click_link(link)
end

Then /^I should not see any address or telephone information for "([^"]*?)"$/ do |name1|
  org1 = Organization.find_by_name(name1)
  page.should_not have_content org1.telephone
  page.should_not have_content org1.address
end

Then /^I should not see any edit or delete links$/ do
  page.should_not have_link "Edit"
  page.should_not have_link "Destroy"
end

Then /^I should not see any edit link for "([^"]*?)"$/ do |name1|
  page.should_not have_link "Edit"
end

Then /^I should see a link with text "([^"]*?)"$/ do |link|
  page.should have_link link
end

Then /^I should not see a link with text "([^"]*?)"$/ do |link|
  page.should_not have_link link
end

Then /^I should not see "(.*?)"$/ do |text|
  page.should_not have_content text
end

Then /^I should( not)? see a new organizations link/ do  |negate|
  #page.should_not have_link "New Organization", :href => new_organization_path
  #page.should_not have_selector('a').with_attribute href: new_organization_path
  expectation_method = negate ? :not_to : :to
  expect(page).send(expectation_method, have_xpath("//a[@href='#{new_organization_path}']"))
end

Then /^I should see "((?:(?!before|").)+)"$/ do |text|
  page.should have_content text
end

# this could be DRYed out (next three methods)
Then /^I should see contact details for "([^"]*?)"$/ do |text|
  check_contact_details text
end

Then /^I should see contact details for "([^"]*?)" and "(.*?)"$/ do |text1, text2|
  check_contact_details text1
  check_contact_details text2
end

Then /^I should see contact details for "([^"]*?)", "([^"]*?)" and "(.*?)"$/ do |text1, text2, text3|
  check_contact_details text1
  check_contact_details text2
  check_contact_details text3
end

Given /^I edit the charity address to be "(.*?)" when Google is indisposed$/ do |address|
  body = %Q({
"results" : [],
"status" : "OVER_QUERY_LIMIT"
})
  stub_request_with_address(address, body)
  fill_in('organization_address', :with => address)
end

Then /^I should not see the unable to save organization error$/ do
  page.should_not have_content "1 error prohibited this organization from being saved:"
end

Then /^the address for "(.*?)" should be "(.*?)"$/ do |name, address|
  Organization.find_by_name(name).address.should == address
end

def check_contact_details(name)
  org = Organization.find_by_name(name)
  page.should have_link name, :href => organization_path(org.id)
  page.should have_content org.description.truncate(128,:omission=>' ...')
end

Then /^I should be on the sign up page$/ do
  current_path.should == new_user_registration_path
end

Then /^I should be on the organizations index page$/ do
  current_path.should == organizations_path
end

Then /^I should be on the charity workers page$/ do
  current_path.should == users_path
end

When /^I fill in "(.*?)" with "(.*?)"$/ do |field, value|
  fill_in(field, :with => value)
end

Given /^I create "(.*?)" org$/ do |name|
  page.driver.submit :post, "/organizations", :organization => {:name => name}
end

Then /^"(.*?)" org should not exist$/ do |name|
  expect(Organization.find_by_name name).to be_nil
end

Then /^I debug$/ do
  breakpoint
  0
end
