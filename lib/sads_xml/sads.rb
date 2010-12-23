require 'builder'

# Examples
#<?xml version="1.0" encoding="UTF-8"?>
#<page version="2.0" xmlns:meta="http://whoisd.eyeline.com/sads/meta">
#  <title id="">DPC Mobile: Search by Person</title>
#  <div>Please enter name of Person</div>
#  <navigation id="">
#    <link accesskey="*" pageId="search_by_person_submit"></link>
#  </navigation>
#</page>
#
#<?xml version="1.0" encoding="UTF-8"?>
#<page version="2.0" xmlns:meta="http://whoisd.eyeline.com/sads/meta">
#<title id="">DPC Mobile: Search by Person</title>
#  <div>
#    <input navigationId="submit" name="name_of_person" title="Please enter name of Person" />
#  </div> 
#  <navigation id="submit">
#    <link accesskey="1" pageId="search_by_person_submit">Ok</link> 
#  </navigation> 
#</page>

module SadsXml
  class Sads
    attr_accessor :title, :message, :navigations, :inputs, :submit_page, :sms_message

    def initialize
      @title = ''
      @inputs = []
      @navigations = { :default => [] }
    end

    def submit_page=(page_link)
      page_link.gsub!(/^\/dpc_mobile\//, '') unless page_link.match(/\.html$/)
      @submit_page = page_link
    end

    def ussd_length
      counter = 0
      counter += @title.length + 2 unless @title.blank?
      counter += @message.length + 1 unless @message.blank?
      counter += @sms_message.length + 1 unless @sms_message.blank?

      @navigations.each do |key, links|
        links.each do |link|
          counter += link[:title].length + link[:accesskey].length + 2
        end
      end

      @inputs.each do |input|
        counter += input[:title].length + 2
      end

      counter -= 1
      return counter
    end

    def one_ussd_message
      ussd_length <= 160
    end

    def one_ussd_message_characters_left
      160 - ussd_length
    end

    def add_navigation(link, navigation_id = :default)
      @navigations[navigation_id] = [] if @navigations[navigation_id].nil?

      # workaround for SADS Absolute Path
      link[:pageId].gsub!(/^\/dpc_mobile\//, '') unless link[:pageId].match(/\.html$/)

      @navigations[navigation_id]<< link
    end

    def add_input(input)
      @inputs<< input
    end

    def to_sads
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.page :version => "2.0", "xmlns:meta" => "http://whoisd.eyeline.com/sads/meta" do
        xml.title @title, :id => ''
        xml.div @message unless message.blank?
        xml.div @sms_message, :type => 'sms' unless sms_message.blank?

        if @inputs.any?
          xml.div do
            @inputs.each do |input|
              xml.input input
            end
          end
        end

        navigations.each do |key,links|
          if links.any?
            xml.navigation :id => (key == :default ? nil : key.to_s) do
              links.each do |link| xml.link link[:title], link.except(:title) end
            end
          end # eo if links.any?

          if @inputs.any?
            xml.navigation :id => 'submit' do
              xml.link :accesskey => '1', :pageId => @submit_page
            end
          end
        end
      end
    end

  end
end

