class HomeController < ApplicationController
  def home
    @recipes = Recipe.where("lower(data->>'title') LIKE '%#{params[:q].downcase}%'")
  end
end
