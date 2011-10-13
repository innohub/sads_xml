module SadsXml
  module ControllerAdditions
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def enable_sads
        send :include, InstanceMethods

        skip_before_filter :verify_authenticity_token
        around_filter :process_sads_request
      end
    end

    module InstanceMethods

      def process_sads_request
        setup_sads_request
        yield

        # Check ActionController::Responder
        # This doesn't work for now, see how to implement this
        # for DRYing the methods in the controller
        # respond_with_sads
      end

      def setup_sads_request
        # Get WHOISD Parameters
        if params[:format] == 'sads'
          @whoisd = {}
          request.headers.each {|k,v| @whoisd[k] = v if k.match(/^HTTP_WHOISD/) }
          logger.info "  WHOISD: #{@whoisd.inspect}"
        end

        # The code below tries to emulate a SADS request
        # this assumes that both are blank
        if params[:format] == 'html'
          params[:abonent] = '639990000000' if params[:abonent].nil?
          params[:protocol] = 'ussd' if params[:protocol].nil?
        end

        @sads = Sads.new
      end

      def respond_with_sads
        respond_to do |format|
          format.html { render :template => 'sads_xml/sads', :layout => 'sads_xml' }
          format.sads { render :xml => @sads.to_sads }
        end
      end

    end
  end
end

if defined? ActionController
  ActionController::Base.class_eval do
    include SadsXml::ControllerAdditions
  end
end
