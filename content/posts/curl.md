---
title: "Ironing curl"
date: 2019-07-29T04:42:26+03:00
description: A wild `gopher://` appeared while I was browsing the web! Explore how exotic protocols from the past can bite modern applications.
slug: ironing-curl
author: lgian
tags:
- curl
- libcurl
- gopher
- ssrf
cover: "gopher.jpg"
draft: false
---

Before cutting to the chase, some background is necessary going forward. If the words:
gopher, SSRF, libcurl ring any bells, then feel free to skip the first section.

# Background

## Server-Side Request Forgery - SSRF

SSRF is a security vulnerability where an adversary can abuse a server's
functionality in order to access internal services and subsequently update/read resources
or leak information. Usually, the adversary provides (directly or indirectly) a
URL in order for the server to fetch information from.

In order to make this more concrete, consider for example a social network
that users can set their profile photo to an image that the server will
fetch from a user-supplied URL. The server will most likely use some kind of
HTTP client in order to fetch the image and store it. For the sake of simplicity
assume that the user has some kind of feedback about the "fetching" that's going
on, on the backend. Now, if the user supplies the following URL:

`http://localhost:22`

A TCP connection will be opened on the ***server's*** localhost interface and if that
succeeds, and HTTP request will be send through it. Since port 22 is usually
used for `SSH`, this will throw some kind of error back to the user since the
SSH handshake won't be successful. Then, if the user supplies the following URL:

`http://localhost:8081`

Assuming that no service is listening on port 8081, no TCP connection will be
opened and so the HTTP client will through an error stating that it couldn't
successfully open a TCP connection.

From the information leaked above a malicious user can figure out which ports are open and
potentially what service is running behind each port, based on the errors thrown
back (or in other cases the time it took to respond).

Although this might seem somewhat harmless, there are scenarios in which, this
vulnerability can be exploited with far worse payloads as we'll see below.

## Curl - libcurl

[cURL](https://curl.haxx.se/) is a software project that provides us with a
library, namely libcurl, and a command-line tool, curl, that's based on libcurl
for transferring data using various protocols. Bindings for libcurl exist in almost every language.
Due to curl's and libcurl's popularity, the impact of a potential security vulnerability
is vast and it affect many different projects based on them.

## Gopher

Gopher according to [wikipedia] is:

> An TCP/IP application layer protocol designed for distributing, searching, and
retrieving documents over the internet.

In short, it was used even before browsers were a thing, in order to browse the
web. For the purposes of this post, all we care about is that this protocol
opens up a TCP connection and throws in it everything we provide it with, in
the form of URL-encoded data in the URI. For instance,

`gopher://example.org:8080/_insert%20data%20here`

`insert data here` is going to be thrown into a TCP connection to `example.org` -
port 8080

# Exploiting gophers

Let's assume that the social network referenced above handles user-provided URLs
in order to fetch users' profile photos. Also, for simplicity, assume that a
[redis](https://en.wikipedia.org/wiki/Redis) instance is running on the same host as the backend of the
application, on port 6379. It turns out that, either directly (C code)
or indirectly (higher level language bindings for libcurl) libcurl is used to
handle the "fetching" functionality.

The developers have made sure that no protocols other than `http` or `https` is
used for security reasons. After some time in production, users
complain that their photo was not uploaded correctly although the content is
valid (jpg, below 2MB and so on) under the URL they provided. After some
debugging, developers figure out that the issue is that redirects are not being
followed by the "fetching" happening in the backend.

Developers look up libcurl's option that allows for following redirects, and
they stumble upon [CURLOPT_FOLLOWLOCATION](https://curl.haxx.se/libcurl/c/CURLOPT_FOLLOWLOCATION.html).
Sure enough, they enable this option and all works out well for both the users
and the developers.

What if a malicious user hosts a website that all it does is redirect to other
protocols. Oh well, what can one do with this? Could `gopher://` mentioned above
be used? I would bet it cannot, no way such an obscure and old protocol that
has not seen the light of day the past decade (or more) is allowed.

It turns out up until recently that was the case. As seen in [libcurl's source
code] the default *allowed* protocols are all protocols supported by libcurl except
for:

- file
- scp
- smb
- smbs

All of the above have been blacklisted over the years due to [security
issues](https://curl.haxx.se/docs/CVE-2009-0037.html)

Gopher is included in the allowed protocols. What this means is that in our
example application, an adversary can host a website that all it does is
redirect to the following URL:

`gopher://localhost:6379/_FLUSHALL`

What the backend of our service will do is handle the redirect, and happily
follow the `gopher://` scheme, open a TCP connection to the redis instance, and
issue the `FLUSHALL` command. It goes without saying what the impact of this
could be. For more info about exploitation for redis, refer to [this].

Similarly, ***any*** other TCP-based protocol can be abused, text-based or
binary (e.g. MySQL) to delete resources, update them, create new and so on.
Another example is deleting elasticsearch indices:

`gopher://elasticsearch.host:9200/_DELETE%20/some_index%20HTTP%2F1.0%0A`

# Ironing curl

The solution to this for our example is to set libcurl's
`CURLOPT_REDIR_PROTOCOLS` option, and define the allowed redirect protocols
there.

Although people have been starting to revive this protocol by hosting gopher
sites lately, questions arise:

- Do we *really* need such protocols in the general case? 
- How many of us actually use such protocols? 
- Should they be allowed *by default* by libcurl?

It turns out that curl developers agreed that this is not sane default
behaviour, and that exotic protocols such as `Gopher` should be explicitly allowed in
redirects. In this regard, a [PR was merged](https://github.com/curl/curl/pull/4094) only allowing `HTTP`, `HTTPS`
and `FTP` for redirects, by default.

### Side note

The issue where a user can supply a URL containing internal hosts, e.g.
localhost or IPs from the private IP range (10.0.0.0/8) is a quite difficult one
to solve as seen [here]. This is due to [RFC3986]'s URI definitions being
really complex and also covering many encodings. For instance:
`http://2130706433/` is `http://127.0.0.1` in decimal notation.

[wikipedia]: https://en.wikipedia.org/wiki/Gopher_(protocol)
[libcurl's source code]: https://github.com/curl/curl/blob/7e8f1916d6d90b6b2a68833846a52e1ea9dbb309/lib/url.c#L491
[this]: https://maxchadwick.xyz/blog/ssrf-exploits-against-redis
[RFC3986]: https://tools.ietf.org/html/rfc3986#section-3.2.2
[here]: https://github.com/swisskyrepo/PayloadsAllTheThings/tree/master/Server%20Side%20Request%20Forgery#bypassing-filters
