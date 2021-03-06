require 'spec_helper'
require_relative '../../../lib/event_cal/calendar'

require 'active_support/core_ext'

describe ::EventCal::Event do
  let(:event) { ::EventCal::Event.new(Date.parse('2013-01-01')) }

  describe '#held_on' do
    subject { event.held_on }
    it { should == Date.parse('2013-01-01') }
  end

  describe '.all' do
    subject { ::EventCal::Event.all }
    it { should be_a_kind_of Array }
  end

  describe '.fetch_events' do
    subject { ::EventCal::Event.fetch_events(calendar) }
    let(:start_on) { Date.parse('2013-01-01') }
    let(:end_on) { Date.parse('2013-01-31') }
    let(:calendar) { ::EventCal::Calendar.new() }
    before do
      calendar.stub(:start_on => start_on)
      calendar.stub(:end_on => end_on)
      ::EventCal::Event.stub(:all).and_return {
        [ ::EventCal::Event.new(Date.parse('2013-01-08')),
          ::EventCal::Event.new(Date.parse('2013-01-18')),
          ::EventCal::Event.new(Date.parse('2013-02-02')),
          ::EventCal::Event.new(Date.parse('2013-02-03')),
          ::EventCal::Event.new(Date.parse('2013-02-08'))
        ]
      }
    end
    it { should have(2).items }
  end
end
