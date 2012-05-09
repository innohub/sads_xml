class Ussd::DefaultController < ApplicationController
  enable_sads

  def index
    @sads.title = "hello"

    respond_with_sads
  end
end
