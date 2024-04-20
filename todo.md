# BUGS

* Interseptor IN runs before guard bc it is written into the array AFTER interseptor, should make record for each token

# TODO

* Rewrite the engine. Now i know what i need. Just import needed functions directly, no need to rewrite them again
* Add middleware render
* Add pipe render
* Add autoimports
* Better way to work with cache. Hide it in @perun directory?
* Add dashboard and debbuger
* True module support
* Make better starting point scripts

# Post Scriptum

* I do not feel like writing in crystal, should use other one, like that i am writing
* Should use stuff i wrote for my database, just because they were written after those scripts, which have a plenty of bugs and performance issues
* Read more about zig's comptime abilities, should use them instead of engine inline writing as (it feels like) a better way
* Should compile perun's files as library just so others can use it separetly and i will be able to create full-stack framework without depending on Perun 