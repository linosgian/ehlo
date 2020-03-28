---
title: "Self host all the things | Part 1"
date: 2020-02-20T15:55:40+02:00
description: In an attempt to take some of my data back from the "cloud", I opted to self host a bunch of services. But why?
author: lgian
tags:
- self_hosting
- privacy
cover: "ccc.jpg"
draft: false
---

# What?

In an attempt to take (some) of my data back from the "cloud", and learn
something along the way, I decided to gather all my photos and my family's photos,
scattered around in old HDDs, flash drives or random "cloud" providers, and host
them on my own hardware at home.

# Why?

It seems that it might be too late to regain some control over what data is
being collected by big corporations, how that data is manipulated and resold. They
are usually used for targeted advertising, profiling, and often serve as the basis to
develop other products. As an example, a [story](https://www.theverge.com/2019/5/10/18564043/photo-storage-app-ever-facial-recognition-secretly-trained-ai) popped up a while ago
about a startup called `Ever.ai`, regarding a privacy violation. 
The company was providing "free" storage for
their users' photos. What they did not clearly state in their privacy policy was
that they used these photos to train a facial recognition model, which they sold
to anyone buying, like governments, military or banks.

As it turns out, this company even rebranded in an attempt to disassociate
themselves from the privacy violation, from `Ever AI` to `Paravision`, and they
continued to sell their facial recognition product.

>Historically, Chinese and Russian face recognition has been more accurate at recognizing global
faces than offerings from American companies. We believe that it is imperative for companies like
ours to do more to ensure the United States does not fall behind in the global marketplace.
Achieving the #1 rank in the world clearly shows that there is an American company capable of
competing with and beating any global competitor in the development of this critical AI technology,"
states Charlie Rice, CTO of Paravision.

[Source](https://www.biometricupdate.com/201908/ever-ai-rebrands-as-paravision-and-tops-nist-facial-biometrics-11-leaderboard)

Another prime example is Google Photos (and frankly any of Google's products).
I am not even going to start on the fact that photos are stored on someone
else's infrastructure and things can and will [go wrong](https://twitter.com/jonoberheide/status/1224525738268905477),
which is exactly what happened when Google was sending people's videos to random
users. I am talking about what they say in plain text in their terms of service:

>When you upload, submit, store, send or receive content to or through our Services, you give Google (and those we work with) a worldwide license to use, host, store, reproduce, modify, create derivative works (such as those resulting from translations, adaptations or other changes we make so that your content works better with our Services), communicate, publish, publicly perform, publicly display and distribute such content

[Source](https://policies.google.com/terms)

Unfortunately what I describe above, is the norm nowadays. We've ended up with a
bunch of corporations dictating the terms for how people express themselves, how
they are having fun, how they form their opinions on important matters.
They have created platforms that exploit humans'
need for exposure and validation from others. They provide people's daily dose
of endorphins when others like their post or retweet them.

Sadly, I don't think that people are not informed enough to care, they simply
turn to arguments like:

- I have nothing to hide
- I am okay with what they are doing, as long as I can use their services for free
- This is how things are, resistance is futile.
- Yeah, the situation is bad but oh well, what can ***I*** do? I am only a
    single user on the X platform.

# Disclaimer #1

I don't have the delusion that capitalism will fall if we get our
photos out of Google Photos, or frankly by doing anything software-related for
that matter. The issue I am trying to raise here is much bigger.
What I am trying to say is that people, time and time again forget the power they have,
and how it's becoming harder and harder to resist with social cohesion and not
as a sparse group of people that can easily get targeted and be marginalised.
IMHO this issue is true everywhere, ranging from getting control of our data online,
to speaking out when we see an injustice happening around us.

#### Part 2 contains the technical bits ↓
