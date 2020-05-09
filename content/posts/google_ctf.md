---
title: "Google CTF: Beginner's Quest - JS Safe (moved from Medium at last)"
date: 2020-05-09T13:05:14+03:00
draft: true
---

Hey!
I'm going to talk about this Google's CTF for 2018 and more specifically about the 
"JS Safe" challenge. This year, as requested by the [community](https://security.googleblog.com/2018/05/google-ctf-2018-is-here.html), there was a whole 
class of challenges for newcomers to security. This class was called "beginner's quest"
and it followed the "quest" type of CTF, where each challenge gives you the ability to 
move to the next one, until you reach the end.

{{< figure src="/ctf.png" title="Beginner's Quest" caption="Beginner's Quest" >}}

In this scenario you're given an [HTML file](https://gist.github.com/linosgian/144ef2c8a984168479331f9c0642b8c3) that contains a mechanism that
protects a secret. If we open the html file in our favorite text editor (that'll
be VIM for me), we are greeted with a comment that states:

> Advertisement: Looking for a hand-crafted, browser based virtual safe to store
> your most interesting secrets? Look no further, you have found it. You can
> order your own by sending a mail to js_safe@example.com. When ordering, please
> specify the password you'd like to use to open and close the safe and the
> content you'd like to store. We'll hand craft a unique safe just for you, that
> only works with your password of choice and contains your secret. (We promise
> we won't peek when handling your data.)

If we fire up our browser we can see an animated box and an input field that asks for the password.

{{< figure src="/ctf2.png" title="A failed password input" caption="A failed password input" >}}


Let's go back to the [source code](https://gist.github.com/linosgian/144ef2c8a984168479331f9c0642b8c3) and start observing how our input reaches the
function that decrypts the secret, where the secret comes from, whether it
connects to some backend to send the password and receive the plaintext and so
on. We start by observing the basic workflow of the so called JS safe, we
mention a few things about the workflow:

1. The secret is hardcoded into the source code as a Uint8Array
2. The algorithm used for encryption is AES-CBC and the IV is also given (kind of irrelevant for the challenge but it's noteworthy)
3. The password is first checked against the following regex: `/^CTF{([0–9a-zA-Z_@!?-]+)}$/`
4. All we have to do in order to get to the "granted" section of the code is for the password to adhere to the regex above and for the `x` function to return false ( aka 0 ) given the value within `CTF{value}`.

After the above observations we have a clear view of what we have at hand, and
what we need to achieve. Let's start by backtracing where our input password is
used and see if we can figure out how it influences the decryption algorithm.

First thing we stumble upon in the "x" function is a long string called `code`
that contains a sequence of seemingly random characters. Then an object called
`env` is initialized with several named properties, anonymous functions and our
password converted to an Uint8Array. After that we notice that what the function
returns is the inverted value of `env.h`.

The main body of the function is a for
loop that runs over the code string, and changes the properties of our `env`
object. Let's try to analyze what the loop does:

1. Runs over the `code` string with a step of 4 characters at a time
2. Extracts 4 characters from `code` and uses 4 variables (`lhs`, `fn`, `arg1`, `arg2`) to store them respectively.
3. Uses those characters as indices for the env object
4. Calls functions based on those indices
5. Updates the state of `env`


Now that we have a better understanding of what the code does we could go down
the rabbit hole and try understand every bit of it. Instead, we will follow the
golden rule of reversing: we will try to spend as little time as possible
understanding what the code does, in order to get what we need. In other words,
we will avoid trying to understand parts of the code unless we absolutely need
to. What we will do is try to find where our input is influencing the algorithm.

The only part of the function that mentions our input is the property g of env.
Let's write some javascript that will output to the console the contents of the
four variables (`env[lhs]`, `env[fn]`, `env[arg1]`, `env[arg2]`) if `arg1` or `arg2` is
equal to `g`, because that would mean that our input is being used.

That can be achieved by adding the following lines above the try/catch statement:

```
if (arg1 == 'g' || arg2 == 'g'){
   console.log(i);
   console.log(lhs, fn, arg1, arg2);
   console.log(env[lhs], env[fn], env[arg1], env[arg2]);
   console.log(env[fn](env[arg1], env[arg2]));
}
```

If we give the following input: `CTF{AAAA}` ( I used several A's because it's
easy to spot them in an Uint8Array as their value will be 65, which is their
ASCII value in decimal ), the output is the following:

```
876
ѷ ј Ѳ g
ƒ Array() { [native code] } "sha-256" Uint8Array(4) [65, 65, 65, 65]
["sha-256", Uint8Array(4)]
```

Our input (four A's) is bundled with the string "sha-256" and converted to a
single Array. The result is stored in env[ѷ], so we can track where this
character is given as input (arg1, arg2). We change the if statement above to
track ѷ and we get the following result:

```
880
Ѹ ј ѭ ѷ
ƒ Array() { [native code] } SubtleCrypto {} (2) ["sha-256", Uint8Array(4)]
[SubtleCrypto, Array(2)]
```

Okay, what we have here is the output we got on the last loop, and a
SubtleCrypto object put in another Array. We can assume that our input is being
put through the SHA-256 hash function, but lets follow that env[Ѹ] value.

```
884
ѹ b Ѱ Ѹ
(x,y) => Function.constructor.apply.apply(x, y) ƒ digest() { [native code] } (2) [SubtleCrypto, Array(2)]
Promise {<pending>}
```

We see that the function "digest" is called with the Array: [SubtleCrypto,
Array[2]], where the contents of Array[2] are: "sha-256" and our four A's.
Following the same methodology:

```
940
Ѿ ѽ ѹ ш
ƒ Uint8Array() { [native code] } ArrayBuffer(32) {} "x"
Uint8Array(32) [99, 193, 221, 149, 31, 254, 223, 111, 127, 217, 104, 173, 78, 250, 57, 184, 237, 88, 79, 22, 47, 70, 231, 21, 17, 78, 225, 132, 248, 222, 146, 1]
```

So what we have as a result is the digest of our password ( we notice that the
length of that Uint8Array is exactly 32 bytes, the length of a SHA256 hash ).


By continuing to follow the variables and function calls, we end up with the following python-based pseudocode:

```
hash = sha256(password)
xor_const = [230, 104, 96, 84, 111, 24 ,205, 187, 205, 134 ,179, 94, 24,181,37,191,252,103,247,114,198,80,206,223,227,255,122,0,38,250,29,238]
intermediate = []
final = 0
# XOR each byte of the hash with a byte from the xor_const
for i, c in enumerate(hash):
  intermediate += c ^ xor_const[i]
# OR all bytes of the previous result
for c in intermediate:
  final =| c
```

The above "final" variable is the returned value: `env.h`. As we mentioned at the
start, we need this value to be 0, so that `!env.h` is true. What we need
essentially is for all bytes in the "intermediate" list to be equal to 0 because
if even one bit of a byte in that list is equal to 1 then the final result won't
be 0. Therefore we need the result of all XOR operations in the first loop to be
equal 0. If we XOR any value with itself we get exactly 0. At this point, we
understand that `xor_const`, contains the hash of the password we need to input.
Hence, all we have to do is take these Uint8 values and convert them to hex so
we can check if this sha256 hash exists in some rainbow table for the sha256
algorithm. The hex value of the `xor_const` hash is:

```
E66860546F18CDBBCD86B35E18B525BFFC67F772C650CEDFE3FF7A0026FA1DEE
```

If we look up this sha256 hash, we get the following:

{{< figure src="/ctf3.png" title="solved!" caption="solved!" >}}

And finally:

{{< figure src="/ctf4.png" title="solved!" caption="solved!" >}}

The decrypted secret is in fact the URL for the next challenge.
P.S: We can safely assume that the function calls before the first (and only)
usage of our password was setting up all objects (e.g. SubtleCrypto),
constructing several strings (e.g. "sha-256") and so on. Again, we did not have
to really delve into that since we got what we needed.
