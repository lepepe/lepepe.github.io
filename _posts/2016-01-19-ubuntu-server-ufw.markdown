---
layout: post
title:  "Protect Ubuntu Server Against DOS Attacks with UFW"
date:   2016-01-19 16:43:14 -0500
comments: true
#image: /assets/images/posts/google-logo.png
categories: sysadmin
tags: [ubuntu, firewall, ufw]
---

UFW is the default firewall configuration tool for ubutnu. It was developed to ease iptables configuration.
By default the ufw is disabled, so the first thing we need to do is enable:

{% highlight ruby %}
$ sudo ufw enable
{% endhighlight %}

###### Then we can starting adding rules and open ports
{% highlight ruby %}
# SSH
$ sudo ufw allow 22

# HTTP
$ sudo ufw allow 80
{% endhighlight %}

###### Similarly, to close an open port
{% highlight ruby %}
$ sudo ufw deny 22

# To remove a rule just use delete followed by the rule
$ sudo ufw delete deny 22
{% endhighlight %}

###### After opening some ports and add rules we can check the ufw's status
{% highlight ruby %}
$ sudo ufw status
{% endhighlight %}

More details: [Ubutnu Server Guide](https://help.ubuntu.com/lts/serverguide/firewall.html#firewall-ufw)

The purpose of this post is configure UFW to prevent flood traffic or DoS.
The easy way to configure our firewall is modifying the rules with a text editor:
{% highlight ruby %}
sudo vim /etc/ufw/before.rules
{% endhighlight %}

###### Then add the following lines near to the *filter at the beginning:
{% highlight ruby %}
:ufw-http - [0:0]
:ufw-http-logdrop - [0:0]

EX:
*filter
:ufw-http - [0:0]
:ufw-http-logdrop - [0:0]

:ufw-before-input - [0:0]
:ufw-before-output - [0:0]
:ufw-before-forward - [0:0]
:ufw-not-local - [0:0]
{% endhighlight %}

###### Add these lines before COMMIT
{% highlight ruby %}
### start ###
# Enter rule
-A ufw-before-input -p tcp --dport 80 -j ufw-http
-A ufw-before-input -p tcp --dport 443 -j ufw-http

# Limit connections per Class C
-A ufw-http -p tcp --syn -m connlimit --connlimit-above 50 --connlimit-mask 24 -j ufw-http-logdrop

# Limit connections per IP
-A ufw-http -m state --state NEW -m recent --name conn_per_ip --set
-A ufw-http -m state --state NEW -m recent --name conn_per_ip --update --seconds 10 --hitcount 20 -j ufw-http-logdrop

# Limit packets per IP
-A ufw-http -m recent --name pack_per_ip --set
-A ufw-http -m recent --name pack_per_ip --update --seconds 1 --hitcount 20 -j ufw-http-logdrop

# Finally accept
-A ufw-http -j ACCEPT

# Log
-A ufw-http-logdrop -m limit --limit 3/min --limit-burst 10 -j LOG --log-prefix "[UFW HTTP DROP] "
-A ufw-http-logdrop -j DROP
### end ###
{% endhighlight %}

With the above rules we are limiting the connections per IP at 20 connections / 10 seconds / IP and
the packets to 20 packets / second / IP.

Finally we have to reload our firewall
{% highlight ruby %}
sudo ufw reload
{% endhighlight %}
