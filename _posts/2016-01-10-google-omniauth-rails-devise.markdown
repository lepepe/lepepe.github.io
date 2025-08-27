---
layout: post
title:  "Google Authentication with Devise in Rails Application"
date:   2016-01-10 16:43:14 -0500
comments: true
#image: /assets/images/posts/google-logo.png
categories: [tech]
tags: [ruby-on-rails, omniauth, google]
---

In this post I'll explain how to integrate google omniauth with Devise in Rails.

###### Step 1: Add Gems to Gemfile
{% highlight ruby %}
# Gemfile:

gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'

# Run bundle to install the gems
$ bundle install
{% endhighlight %}

###### Step 2: Add Column for Omniauth & UID
{% highlight ruby %}
$ rails g migration AddOmniauthToUsers omniauth:string uid:string

# Then run migration
$ rake db:migrate
{% endhighlight %}

###### Step 3: Go to the User model and add the **:omniauthable** module
{% highlight ruby %}
# app/model/user.rb

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable,
         :rememberable, :trackable, :validatable, :omniauthable
end
{% endhighlight %}

###### Step 4: Create a Project in google to get “Client key” and “Client Secret key”
[https://console.developers.google.com/](https://console.developers.google.com/)

###### Step 5: Modify the devise initializers and add this block around line 240
{% highlight ruby %}
# config/initializers/devise.rb

require 'omniauth-google-oauth2'
config.omniauth :google_oauth2,
  "APP_ID",
  "APP_SECRET",
  { access_type: "offline", approval_prompt: "" }

# Add hd: if want users login only for specific domain:
# Ex. { access_type: "offline", approval_prompt: "", hd: "vertilux.com" }
{% endhighlight %}

###### Step 6: Modify devise login block and routes.rb and add the folowing lines
{% highlight ruby %}
# app/views/devise/registrations/new.html.erb
<%= link_to "Sign in with Google", user_omniauth_authorize_path(:google_oauth2) %>

# config/routes.rb
devise_for :users, :controllers => { : omniauth_callbacks => "omniauth_callbacks" }
{% endhighlight %}

###### Step 7: Create omniauth_callbacks_controller.rb controller
{% highlight ruby %}
# app/controllers/omniauth_callbacks_controller.rb

class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user)
      if @user.persisted?
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
        sign_in_and_redirect @user, :event => :authentication
      else
        session["devise.google_data"] = request.env["omniauth.auth"]
        redirect_to new_user_registration_url
      end
  end
end
{% endhighlight %}

###### Step 8: Finally update user model and add the following block
{% highlight ruby %}
# app/model/user.rb

def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:omniauth => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name: data["name"],
          omniauth:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          password: Devise.friendly_token[0,20],
        )
      end
   end
end
{% endhighlight %}
