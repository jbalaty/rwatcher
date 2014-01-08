require 'mechanize'


class HttpTool
  def initialize
    @agent = Mechanize.new
  end

  def get(url)
    @agent.get(url)
  end
end