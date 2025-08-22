---
layout: post
title:  "How to Connect a Rails Application with MSSQL"
date:   2015-12-05 16:43:14 -0500
comments: true
categories: [tech, rails]
tags: [ruby-on-rails, mssql, databases]
---
First, we need to have installed unixodbc and freetds in our Linux server, in this case Ubuntu 14.04:
{% highlight ruby %}
$ sudo apt-get install unixodbc unixodbc-dev freetds-dev tdsodbc
{% endhighlight %}

###### And configure freetds:
{% highlight ruby %}
  $ sudo vim /etc/freetds/freetds.conf

  [SERVER]
    host = server ip address
    port = 1433
    tds version = 7.0
    # client charset = UTF-8 (optional)
{% endhighlight %}

###### Cause we need odbc, we need to configure odbc as follow:
{% highlight ruby %}
  $ sudo vim /etc/odbcinst.ini
    [FreeTDS]
    Description     = TDS driver (Sybase/MS SQL)
    Driver          = /usr/lib/odbc/libtdsodbc.so
    Setup           = /usr/lib/odbc/libtdsS.so
    CPTimeout       =
    CPReuse         =
    FileUsage       = 1
{% endhighlight %}

###### And then:
{% highlight ruby %}
  [SERVER] # same server name from freetds.conf
    Driver          = FreeTDS
    Description     = Conexion a Sql  con FreeTDS / ODBC
    Trace           = No
    Servername      = server ip address
    Database        = data base name
{% endhighlight %}

###### Now we can test our connection to the database:
{% highlight ruby %}
  $ sqsh -S SERVER -U USER -P PASSWORD
  $> use 'database'
  $> select col1, col2, col3 from table where col2='test'
  $> go # to exec the script
{% endhighlight %}

###### Now that we are able to access to MSSQL we have to add two gems to rail app Gemfile in order to acces from our application then reconfigure database.yml:
{% highlight ruby %}
#Gemfile
  # SQL server
  gem 'activerecord-sqlserver-adapter', '~> 4.2.4'
  gem 'tiny_tds', '~> 0.7.0'

#config/database.yml
  adapter: sqlserver
  database: database
  username: user
  password: password
  host: server ip address
{% endhighlight %}

###### Also if we want to connet to multiple databases the only thing we have to do is modify the database.yml to add our new MSSQL database and create a model to establish the connection:
{% highlight ruby %}
#config/database.yml
  development_sql:
    adapter: sqlserver
    database: database
    username: user
    password: password
    host: server ip address

#app/models/model_name
  class AccpacModel < ActiveRecord::Base
    establish_connection "#{Rails.env}_sql"

    self.table_name  = 'TABLE_NAME'
    self.primary_key = 'PRIMARY_KEY'
  end
{% endhighlight %}
