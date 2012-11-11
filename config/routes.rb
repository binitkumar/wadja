require 'grape'

Wadja::Application.routes.draw do
  
  mount Wadja::API => "/"

end
