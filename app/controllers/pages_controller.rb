class PagesController < ApplicationController
  
  skip_before_filter :require_login, only: [:home]

  def home
  end

end