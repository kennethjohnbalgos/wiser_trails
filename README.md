# WiserTrails

Audit Trails in Harmony

## Requirements

_Audit Trails_ only support Rails 3.x and 4.0 with **Active Record**.

## Setup

### Gem Installation

You can do normal gem installation for `wiser_trails`:

    gem install wiser_trails

or in your Gemfile:

```ruby
gem 'wiser_trails'
```

### Database

**(ActiveRecord only)** Generate a migration for trails and migrate the database (in your Rails project):

    rails g wiser_trails:migration
    rake db:migrate

## Usage

### Monitoring CRUD Actions

To record the Create, Update, and Delete actions, include `WiserTrails::Model` and add `trail_it` to the model you want to keep track of:

```ruby
class Notes < ActiveRecord::Base
  include WiserTrails::Model
  trail_it
end
```

If you want to automatically send the owner of the trail, include `WiserTrails::StoreController` to your `application_controller.rb`:

```ruby
class ApplicationController < ActionController::Base
  include WiserTrails::StoreController
end
```

Then you can specify the `owner` of the trail:

```ruby
class Notes < ActiveRecord::Base
  include WiserTrails::Model
  trail_it owner: ->(controller, model) { controller && controller.current_user }
end
```

Or even the `account` if you're having a multi-account structure:

```ruby
class Notes < ActiveRecord::Base
  include WiserTrails::Model
  trail_it
    owner: ->(controller, model) { controller && controller.current\_user },
    account: ->(controller, model) { controller && controller.current\_account }
end
```

### Monitoring Custom Actions

To record custom actions, you can manually trigger the `create_activity` method on the model record:

```ruby
@note.create_activity(key: 'note.published', owner: current_user)
```

Or even the `account` if you're having a multi-account structure:

```ruby
@note.create_activity(key: 'note.published', owner: current_user, account: current_account)
```

## Fetching Trails

### Query for the WiserTrails::Activity model
To get the trails them you simply query the `WiserTrails::Activity` model in your controllers:

```ruby
def index
  @trails = WiserTrails::Activity.order('id DESC')
end
```

Or with account:

```ruby
def index
  @trails = WiserTrails::Activity.where(account: current_account)
end
```

### Getting the objects

You can get the `owner`, `account`, and the `trackable` objects from the `WiserTrails::Activity`:

```ruby
def show
  @trail = WiserTrails::Activity.find(params[:id])
  # @trail.owner => current_user object
  # @trail.account => current_account object
  # @trail.trackable => Note object
end
```

You can also get the new trackable value by calling `new_value`:

```ruby
def show
  @trail = WiserTrails::Activity.find(params[:id])
  # @trail.new_value => exact Note attributes after the trail was recorded
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Support
Open an issue in https://github.com/kennethjohnbalgos/wiser_trails if you need further support or want to report a bug.

## License

The MIT License (MIT) Copyright (c) <year> <copyright holders>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
