ALDO Middleman Customizations
==================================
A wrapper around [Middleman][] for ALDO's customizations.

Installation
------------
Add this line to the Gemfile:

```ruby
gem 'middleman-aldo', github: 'aldogroup/middleman-aldo'
```

And then run:

```shell
$ bundle
```


Usage
-----
To generate a new site, follow the instructions in the [Middleman docs][]. Then add the following line to your `config.rb`:

```ruby
activate :aldo
```

Almost all other Middleman options may be removed from the `config.rb`.

Now just run:

```shell
$ middleman server
```

and you are off running!


Contributing
------------
1. [Fork it](https://github.com/aldogroup/middleman-aldo/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request


[Middleman]: http://middlemanapp.com/
[Middleman docs]: http://middlemanapp.com/basics/getting-started/
[middleman-syntax]: http://github.com/middleman/middleman-syntax/
