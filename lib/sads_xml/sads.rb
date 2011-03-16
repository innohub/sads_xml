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
    attr_accessor :title, :messages, :navigations, :inputs, :submit_page, :sms_message

    DEFAULTS = {
      :navigation => {
        :type => 'nav'
      }
    }

    def initialize
      @title = ''
      @inputs = []
      @navigations = { :default => [] }
      @messages = {}
    end

    def message=(message)
      self.set_message(:default, message)
    end

    def submit_page=(page_link)
      # workaround for SADS Absolute Path
      #page_link.gsub!(/^\/yp_mobile\//, '') unless page_link.match(/\.html$/)
      @submit_page = page_link
    end

    def ussd_length
      counter = 0
      counter += @title.length + 2 unless @title.blank?

      @messages.each do |key, message|
        counter += message.length + 1 unless message.blank?
      end

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
      #link[:pageId].gsub!(/^\/yp_mobile\//, '') unless link[:pageId].match(/\.html$/)

      @navigations[navigation_id]<< DEFAULTS[:navigation].merge(link)
    end

    def set_message(id, message)
      @messages[id.to_sym] = message
    end

    def add_input(input)
      @inputs<< input
    end

    def to_sads
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.page :version => "2.0", "xmlns:meta" => "http://whoisd.eyeline.com/sads/meta" do
        xml.title @title, :id => ''

        @messages.each do |key, message|
          object_hash = {}
          object_hash[:id] = key.to_s unless key == :default

          xml.div message, object_hash
        end

        xml.div @sms_message, :type => 'sms' unless sms_message.blank?

        if @inputs.any?
          xml.div do
            @inputs.each do |input|
              xml.input input
            end
          end
        end

        navigations.each do |key, links|
          if links.any?
            object_hash = {}
            object_hash[:id] = key.to_s unless key == :default

            xml.navigation object_hash do
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

