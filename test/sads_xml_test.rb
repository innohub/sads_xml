require 'test_helper'

class SadsXmlTest < ActiveSupport::TestCase
  def setup
    @sads = SadsXml::Sads.new
  end

  test "must have default title" do
    assert !@sads.title.nil?
  end

  test "must have default navigations" do
    assert_equal Array, @sads.navigations[:default].class
  end

  test "must be able to add new set of navigations" do
    @sads.add_navigation :title => 'Main Menu', :accesskey => "00", :pageId => '/'
    @sads.add_navigation :title => 'Back', :accesskey => "07", :pageId => '/'
    @sads.add_navigation :title => 'Next', :accesskey => "09", :pageId => '/'

    assert_equal Array, @sads.navigations[:default].class
    assert_equal 3, @sads.navigations[:default].length

    @sads.add_navigation({ :title => 'Food', :accesskey => '1', :pageId => 'food/' }, :categories)
    @sads.add_navigation({ :title => 'Shops', :accesskey => '2', :pageId => 'shops/' }, :categories)
    assert_equal Array, @sads.navigations[:categories].class
    assert_equal 2, @sads.navigations[:categories].length
  end

  test "xml must have id for the title attribute even if blank" do
    assert !@sads.to_sads.match(/<title id=""><\/title>/).nil?

    @sads.title = 'A Crappy Title'
    assert !@sads.to_sads.match(/<title id="">A Crappy Title<\/title>/).nil?
  end

  test "must render input elements" do
    @sads.add_input :navigationId => 'submit', :name => 'username', :title => 'Username'
    @sads.submit_page = 'search_by_person_submit'

    assert_equal true, (not @sads.submit_page.nil?)
    assert_equal 'search_by_person_submit', @sads.submit_page

    assert_equal Array, @sads.inputs.class
    assert_equal 1, @sads.inputs.length

    xml = @sads.to_sads

    assert !xml.match(/<navigation id="submit">/).nil?

    # Must find a way to verify codes below. XML Builder doesn't have order of creating the attributes
    # Research on this one please
    #assert !xml.match(/<input title="Username" navigationId="submit" name="username"\/>/).nil?
    #assert !xml.match(/<link pageId="search_by_person_submit" accesskey="1"\/>/).nil?
  end

  test "ussd_length must count the length of the message" do
    title = "This is title"
    message = "This is a message"

    @sads.title = title
    @sads.message = message
    @sads.add_navigation   :title => 'Main Menu', :accesskey => "00", :pageId => '/'
    @sads.add_navigation({ :title => 'Food',      :accesskey => '1',  :pageId => 'food/' },  :categories)
    @sads.add_navigation({ :title => 'Shops',     :accesskey => '2',  :pageId => 'shops/' }, :categories)

    assert_equal (title.length + 2) +
                  (message.length + 1) +
                  ('Main Menu'.length + "00".length + 2) +
                  ('Food'.length + "1".length + 2) + 
                  ('Shops'.length + "2".length + 2) - 1,
                 @sads.ussd_length

    @sads = SadsXml::Sads.new
    @sads.title = "DPC Mobile: Search by Person"
    @sads.add_input :navigationId => 'submit', :name => 'person_name', :title => 'Please enter name of Person'
    @sads.submit_page = 'whatever_path'

    assert_equal 58, @sads.ussd_length
  end

  test "must be able to add messages" do
    title = "This is title"
    message = "This is a message"

    @sads.title = title
    @sads.message = message
    @sads.set_message :bottom, "bottom message"

    xml = @sads.to_sads

    assert !xml.match(/bottom message/).nil?
    assert !xml.match(/<div>This is a message<\/div>/).nil?
  end

  test "must not render banners if banner_targets is empty" do
    xml = @sads.to_sads
    assert xml.match(/<meta:banner/).nil?
  end

  test "must render banners if banner_targets is not empty" do
    @sads.banner_targets<< "female"
    xml = @sads.to_sads
    assert !xml.match(/<meta:banner target="female"\/>/).nil?
  end

  test "must render banners within a div" do
    @sads.banner_targets<< ""
    xml = @sads.to_sads
    assert xml.match(/<meta:banner target="female"\/><\/div>/).nil?
  end

  test "must render bottom div only once" do
    @sads.set_message :bottom, "bottom message"
    @sads.banner_position = :bottom
    @sads.banner_targets<< ""

    xml = @sads.to_sads

    assert_equal 1, xml.scan(/<div id="bottom">/).size
  end

  test "must render top div only once" do
    @sads.set_message :top, "top message"
    @sads.banner_position = :top
    @sads.banner_targets<< ""

    xml = @sads.to_sads

    assert_equal 1, xml.scan(/<div id="top">/).size
  end

  test "must render br before banner when message for that position is available" do
    @sads.set_message :top, "top message"
    @sads.banner_position = :top
    @sads.banner_targets<< ""
    xml = @sads.to_sads

    assert !xml.match(/<br\/><br\/><meta:banner target=""\/>/).nil?
  end

  test "must render br before banner when message for that position is available (bottom)" do
    @sads.message = "This is the main content of the whole page."
    @sads.set_message :bottom, "bottom message"
    @sads.banner_position = :bottom
    @sads.banner_targets<< ""
    xml = @sads.to_sads

    puts xml

    assert !xml.match(/<br\/><br\/><meta:banner target=""\/>/).nil?
  end

  test "must not render (double) br before banner if message for that position is not avaialble" do
    @sads.message = "message"
    @sads.banner_position = :bottom
    @sads.banner_targets<< ""
    xml = @sads.to_sads

    assert xml.match(/<br\/><br\/><meta:banner target=""\/>/).nil?
    assert !xml.match(/<br\/><meta:banner target=""\/>/).nil?
  end
end
