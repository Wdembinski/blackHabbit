class StaticpagesController < ApplicationController
  def login
  	render file: 'app/assets/templates/login.html'
  end

  def about
  end

  def donate
  end

  def contact
  end
end
