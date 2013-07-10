require "minitest/autorun"
require "nokogiri/extractor"
require 'nokogiri'
module TestNokogiri; end

class TestNokogiri::TestExtractor < MiniTest::Spec
  def setup
    super
    po_xml_file = File.join(File.expand_path File.join(File.dirname(__FILE__), '..', 'files', 'po.xml'))
    @doc = Nokogiri::XML.parse(File.read(po_xml_file), po_xml_file)
    @doc.extractor!
  end

  def test_extract_element
    @doc.extract('name').must_equal 'Alice Smith'
  end

  def test_extract_many_elements
    names = @doc.extract_all('name')
    names.count.must_equal 2
    names.must_include 'Robert Smith'
  end

  def test_regex_filter
    last_name = @doc.extract('name', regexp: / (.*)/)
    last_name.must_equal 'Smith'
  end

  def test_attribute
    date = @doc.extract 'purchaseOrder', attr: :orderDate
    date.must_equal '1999-10-20'
  end
  def test_no_match
    @doc.extract('not_in_there').must_be_nil
  end

  def test_empty_element
      doc = Nokogiri::XML.parse('<this></this>')
      doc.extractor!
      doc.extract('this').must_equal ''
  end

  def test_no_regex_match
    @doc.extract('name', regexp: /Wowthere/).must_be_nil
  end

  def test_no_match_skips_block
    @doc.extract('name', regexp: /Wowthere/) {|t| 'should not get here'}.must_be_nil
    
  end
  def test_readme
  doc = Nokogiri::XML.parse('<this is="cool">that</this>')
  doc.extractor!

  doc.extract('this').must_equal 'that'

  doc.extract('this', attr: :is).must_equal 'cool'

  doc.extract('this', regexp: /th(.*)/).must_equal 'at'

  doc.extract('this') {|text| text.upcase}.must_equal 'THAT'

  end
end
