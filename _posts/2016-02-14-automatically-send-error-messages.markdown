---
layout: post
title:  "Automatically Send Error Messages in Rails Application"
date:   2016-02-14 10:43:14 -0500
comments: true
#image: /assets/images/posts/google-logo.png
categories: [tech, rails]
tags: [rails, logs, messages]
---

###### The first thing to send an email from within a Rails application is generate a mailer infrastructure:
{% highlight ruby %}
$ rails generate mailer Notification
{% endhighlight %}

###### Then open app /mailers/notification.rb and insert the following block:
{% highlight ruby %}
  class Notification < ActionMailer::Base
    default from: "RDYD App Error <error@rd-yd.com>"

    def error_message(exception, trace, params, env, sent_on = Time.now)
      @sent_on = sent_on,
      @exception = exception,
      @trace = trace,
      @params = params,
      @env = env

      mail(
        to: 'your_email@your_domain.com',
        subject: "Error message: #{env['REQUEST_URI']}",
      )
    end

  end
{% endhighlight %}

###### Any error that occur while running a rails application are sent to ActionController::Base#log_error method, so now that we've already set up and email we can modified this method and have to send an email. Open app/controller/application_controller.rb and modified like this:
{% highlight ruby %}
# error message notifications
rescue_from Exception do |exception|
  Notification.error_message(exception,
    exception.backtrace,
    session,
    params,
    request.env).deliver
  raise exception
end
{% endhighlight %}

###### Finally we need to create a template for the email:
{% highlight ruby %}
$ vim app/views/notification/error_message.text.erb
{% endhighlight %}

{% highlight ruby %}
Time: <%= Time.now %>
Message: <%= @exception.message %>
Location: <%= @env['REQUEST_URI'] %>
Action: <%= @params.delete('action') %>
Controller: <%= @params.delete('controller') %>
Query: <%= @env['QUERY_STRING'] %>
Method: <%= @env['REQUEST_METHOD'] %>
Agent: <%= @env['HTTP_USER_AGENT'] %>

Params
<% @params.each do |key, val| %>
  *<%= key %>: <%= val.to_yaml %>
<% end %>

Environment
<% @env.each do |key, val| %>
  *<%= key %>: <%= val %>
<% end %>

Backtrace
<%= @trace.to_a.join("\n") %>
{% endhighlight %}

Ref: Ruby Cookbook - Recipes for Object-Oriented Scripting
