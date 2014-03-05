require 'sitemaper/sitemap_file'

describe Sitemaper::SitemapFile do
  subject(:sitemap_file) { Sitemaper::SitemapFile.new('/tmp/sitemap.xml') }
  let(:reserved_content) do
    '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"></urlset>'
  end
  let(:items_content) do
    '<url><loc>http://reyesyang.info</loc><lastmod>1988-2-29</lastmod><changefreq>weekly</changefreq><priority>0.5</priority></url>'
  end
  let(:content) do
    '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>http://reyesyang.info</loc><lastmod>1988-2-29</lastmod><changefreq>weekly</changefreq><priority>0.5</priority></url></urlset>'
  end

  let(:options) do
    {
      loc: 'http://reyesyang.info',
      lastmod: '1988-2-29'
    }
  end

  describe '#initialize' do
    its(:file_path) { should eq('/tmp/sitemap.xml') }
    its(:items_count) { should eq(0) }
    its(:items_content) { should eq('') }
    its(:reserved_content) { should eq(reserved_content) }
    its(:bytesize) { should eq(reserved_content.bytesize) }
  end

  describe '#content' do
    context 'items_content is blank' do
      it 'return reserved_content' do
        expect(sitemap_file.content).to eq(reserved_content)
      end
    end

    context 'items_content is not blank' do
      it 'return reserved_content with items_content' do
        sitemap_file.items_content = items_content
        expect(sitemap_file.content).to eq(content) 
      end
    end
  end

  describe '#add' do
    context 'fit limit' do
      it 'return items_content' do
        expect(sitemap_file.add(options)).to eq(items_content)
      end
    end

    context 'over limit' do
      it 'return nil when bytesize more than 10M' do
        subject.bytesize = 10 * 1024 * 1024
        expect(sitemap_file.add(options)).to be_nil
      end

      it 'return nil when items_count more than 50000' do
        subject.items_count = 50000
        expect(sitemap_file.add(options)).to be_nil
      end
    end
  end
  
  describe '#generate!' do
  end
end
