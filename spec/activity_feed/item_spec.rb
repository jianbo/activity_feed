require 'spec_helper'
require 'active_support/core_ext/date_time/conversions'

describe ActivityFeed::Item do
  describe '#update_item' do
    describe 'without aggregation' do
      it 'should correctly build an activity feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.update_item('david', 1, Time.now.to_i)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
      end
    end

    describe 'with aggregation' do
      it 'should correctly build an activity feed with an aggregate activity_feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_false
        ActivityFeed.update_item('david', 1, Time.now.to_i, true)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_true
      end
    end
  end

  describe '#add_item' do
    describe 'without aggregation' do
      it 'should correctly build an activity feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.add_item('david', 1, Time.now.to_i)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
      end
    end
  end

  describe '#aggregate_item' do
    it 'should correctly add an item into an aggregate activity feed' do
      ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
      ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_false
      ActivityFeed.aggregate_item('david', 1, Time.now.to_i)
      ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
      ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_true
    end
  end

  describe '#remove_item' do
    describe 'without aggregation' do
      it 'should remove an item from an activity feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should eql(0)
        ActivityFeed.update_item('david', 1, Time.now.to_i)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should eql(1)
        ActivityFeed.remove_item('david', 1)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should eql(0)
      end
    end

    describe 'with aggregation' do
      it 'should remove an item from an activity feed and the aggregate feed' do
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_false
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_false
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should eql(0)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true)).should eql(0)
        ActivityFeed.update_item('david', 1, Time.now.to_i, true)
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david')).should be_true
        ActivityFeed.redis.exists(ActivityFeed.feed_key('david', true)).should be_true
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should eql(1)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true)).should eql(1)
        ActivityFeed.remove_item('david', 1)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david')).should eql(0)
        ActivityFeed.redis.zcard(ActivityFeed.feed_key('david', true)).should eql(0)
      end
    end
  end

  describe '#check_item?' do
    describe 'without aggregation' do
      it 'should return whether or not an item exists in the feed' do
        ActivityFeed.aggregate = false
        ActivityFeed.check_item?('david', 1).should be_false
        ActivityFeed.add_item('david', 1, Time.now.to_i)
        ActivityFeed.check_item?('david', 1).should be_true
      end
    end

    describe 'with aggregation' do
      it 'should return whether or not an item exists in the feed' do
        ActivityFeed.aggregate = true
        ActivityFeed.check_item?('david', 1, true).should be_false
        ActivityFeed.add_item('david', 1, Time.now.to_i)
        ActivityFeed.check_item?('david', 1, true).should be_true
      end
    end
  end
end