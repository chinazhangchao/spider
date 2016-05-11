# list_spider

A url list spider based on em-http-request.

Many times we only need to spider by url list then parse them and spider again. This is for the purpose.

## Features
* Duplicate url filtering (based on local path, so you can custom your behavior).

* Convert to UTF-8 support.

* Increased spider support (don't spider exist).

* Customize concurrent number and interval between task.

* Http options support.

## Getting started

    gem install list_spider

## Use like this
```ruby
require 'list_spider'

DOWNLOAD_DIR = 'wangyin/'

$next_list = []

def parse_index_item(file_name, extra_data)
  content = File.read(file_name)
  doc = Nokogiri::HTML(content)
  list_group = doc.css("ul.list-group")
  link_list = list_group.css("a")

  link_list.each do |link|
    href = link['href']
    local_path = DOWNLOAD_DIR + link.content + ".html"
    #or you can save them to database for later use
    $next_list<< TaskStruct.new(href, local_path)
  end
end

task_list = []
task_list << TaskStruct.new('http://www.yinwang.org/', DOWNLOAD_DIR + 'index.html', parse_method: method(:parse_index_item))

ListSpider.get_list(task_list)
ListSpider.get_list($next_list, max: 60)

```

## Or in one step
```ruby
require 'list_spider'

DOWNLOAD_DIR = 'wangyin/'

def parse_index_item(file_name, extra_data)
  content = File.read(file_name)
  doc = Nokogiri::HTML(content)
  list_group = doc.css("ul.list-group")
  link_list = list_group.css("a")

  article_list = []
  link_list.each do |link|
    href = link['href']
    local_path = DOWNLOAD_DIR + link.content + ".html"
    article_list << TaskStruct.new(href, local_path)
  end
  ListSpider.add_task(article_list)
end

#get_one is a simple function for one taskstruct situation
ListSpider.get_one(TaskStruct.new('http://www.yinwang.org/', DOWNLOAD_DIR + 'index.html', parse_method: method(:parse_index_item)), max: 60)

```

## You can define parse method in four forms

```ruby
def parse_response(file_name)
  #...
end


# extra_data is passed by TaskStruct's extra_data param

def parse_response(file_name, extra_data)
  #...
end


# response_header is a EventMachine::HttpResponseHeader object
# you can use it like this:
# response_header.status
# response_header.cookie
# response_header['Last-Modified']

def parse_response(file_name, extra_data, response_header)
  response_header.status
  response_header['Last-Modified']

  #...
end

# req is a EventMachine::HttpClientOptions object
# you can use it like this:
# req.body
# req.headers
# req.uri
# req.host
# req.port
def parse_response(file_name, extra_data, response_header, req)
  puts req.body
  puts req.headers
  puts req.uri
  puts req.host
  puts req.port

  #...
end

```

## And there are many options you can use

```ruby
TaskStruct.new(href, local_path, http_method: :get, params: {}, extra_data: nil, parse_method: nil)
```

```ruby
#no concurrent limit (note: only use when list size is small)
ListSpider.get_list(down_list, inter_val: 0, max: ListSpider::NO_LIMIT_CONCURRENT)

#sleep random time, often used in site which limit spider
ListSpider.get_list(down_list, inter_val: ListSpider::RANDOM_TIME, max: 1)
```

###Options below will take effect in the whole program (set them before call get_list)

```ruby
#set proxy
ListSpider.set_proxy(proxy_addr, proxy_port, username: nil, password: nil)

#set http header
ListSpider.set_header_option(header_option)

#convert the file encoding to utf-8
ListSpider.conver_to_utf8 = false

#set connect timeout
ListSpider.connect_timeout = 2*60

#over write exist file
ListSpider.overwrite_exist = false

#set redirect depth
ListSpider.max_redirects = 10

#set random time range when use ListSpider::RANDOM_TIME
ListSpider.random_time_range = 3..10
```

## There is a util class to help delete unvalid file

```ruby
DeleteUnvalid.delete(CustomConfig::DIR + '*', size_threshold: 300)

#its params
DeleteUnvalid.delete(dir_pattern, size_threshold: 1000, cust_judge: nil)
```

### License

(MIT License) - Copyright (c) 2016 Charles Zhang
