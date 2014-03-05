require 'builder'

module Sitemaper
  class ContentOverflowError < StandardError; end

  class SitemapFile
    attr_accessor :file_path, :items_count, :items_content, :reserved_content, :bytesize
    
    def initialize(file_path)
      @file_path = file_path
      @items_count = 0
      @items_content = ''
      @reserved_content = build_reserved_content
      @bytesize = @reserved_content.bytesize
    end

    def content
      @reserved_content.gsub /(<\/\w+?>)$/, "#{@items_content}\\1"
    end

    def add(options)
      item_str = build_item_xml(options).target!
      @bytesize += item_str.bytesize
      @items_count += 1

      if !overflow?
        @items_content << item_str
      else
        @bytesize -= item_str.bytesize
        @items_count -= 1
        nil 
      end
    end

    def generate!
      if !overflow?
        File.open(@file_path, 'w') { |file| file.write content }
        @file_path
      else
        nil
      end
    end

    private

    def overflow?
      @bytesize > 10 * 1024 * 1024 || @items_count > 50000
    end

    def build_reserved_content
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") { |urlset| urlset }
      xml.target!
    end

    def build_item_xml(options)
      xml = Builder::XmlMarkup.new
      xml.url do |url|
        url.loc options[:loc]
        url.lastmod options[:lastmod]
        url.changefreq(options[:changefreq] || 'weekly')
        url.priority(options[:priority] || 0.5)
      end

      xml
    end
  end
end
