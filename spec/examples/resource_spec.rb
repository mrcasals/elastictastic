require File.expand_path('../spec_helper', __FILE__)

describe Elastictastic::Resource do
  describe '::mapping' do
    let(:mapping) { Post.mapping }
    let(:properties) { mapping['post']['properties'] }

    it 'should set basic field' do
      properties.should have_key('title')
    end

    it 'should default type to string' do
      properties['title']['type'].should == 'string'
    end

    it 'should force date format as date_time_no_millis' do
      properties['published_at']['format'].should == 'date_time_no_millis'
    end

    it 'should accept options' do
      properties['comments_count']['type'].should == 'integer'
    end

    it 'should set up multifield' do
      properties['tags'].should == {
        'type' => 'multi_field',
        'fields' => {
          'tags' => { 'type' => 'string', 'index' => 'analyzed' },
          'non_analyzed' => { 'type' => 'string', 'index' => 'not_analyzed' }
        }
      }
    end

    it 'should map embedded object fields' do
      properties['author']['properties']['id']['type'].should == 'integer'
    end
  end

  describe '#to_elasticsearch_doc' do
    let(:post) { Post.new }
    let(:doc) { post.to_elasticsearch_doc }

    it 'should return scalar properties' do
      post.title = 'You know, for search.'
      doc['title'].should == 'You know, for search.'
    end

    it 'should serialize dates to integers' do
      time = Time.now
      post.published_at = time
      doc['published_at'].should == (time.to_f * 1000).to_i
    end

    it 'should serialize an array of dates' do
      time1, time2 = Time.now, Time.now + 60
      post.published_at = [time1, time2]
      doc['published_at'].should ==
        [(time1.to_f * 1000).to_i, (time2.to_f * 1000).to_i]
    end

    it 'should not include unset values' do
      doc.should_not have_key('title')
    end

    it 'should have embedded object properties' do
      post.author = Author.new
      post.author.name = 'Smedley Butler'
      doc['author']['name'].should == 'Smedley Butler'
    end

    it 'should embed properties of arrays of embedded objects' do
      authors = [Author.new, Author.new]
      post.author = authors
      authors[0].name = 'Smedley Butler'
      authors[1].name = 'Harry S Truman'
      doc['author'].should == [
        { 'name' => 'Smedley Butler' },
        { 'name' => 'Harry S Truman' }
      ]
    end

    it 'should ignore missing embedded docs' do
      doc.should_not have_key('author')
    end
  end

  describe 'attributes' do
    it 'should raise TypeError if improper type passed to embed setter' do
      lambda { Post.new.author = Post.new }.should raise_error(TypeError)
    end
  end
end
