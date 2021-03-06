require 'list_spider'

DOWNLOAD_DIR = 'coolshell/'.freeze

@next_list = []

def parse_index_item(e)
  content = File.read(e.local_path)
  doc = Nokogiri::HTML(content)
  list_group = doc.css('h2.entry-title')
  link_list = list_group.css('a')

  link_list.each do |link|
    href = link['href']
    local_path = DOWNLOAD_DIR + link.content + '.html'
    # or you can save them to database for later use
    @next_list << TaskStruct.new(href, local_path)
  end
end

task_list = []
task_list << TaskStruct.new(
  'https://coolshell.cn/',
  DOWNLOAD_DIR + 'index.html',
  parse_method: method(:parse_index_item)
)

ListSpider.get_list(task_list)
ListSpider.get_list(@next_list, max: 60)
