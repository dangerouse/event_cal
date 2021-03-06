require 'spec_helper'
require_relative '../../lib/event_cal/calendar'
require_relative '../../lib/event_cal/calendar_helper'

describe ::EventCal::CalendarHelper do
  describe '#wday_class_for(date)' do
    subject { helper.wday_class_for(date) }
    let(:sunday) { Date.parse('2012-12-30') }
    let(:saturday) { Date.parse('2012-12-29') }
    let(:monday) { Date.parse('2013-01-01') }

    context 'sunday' do
      let(:date) { sunday }
      it { should == 'sunday' }
    end

    context 'saturday' do
      let(:date) { saturday }
      it { should == 'saturday' }
    end

    context 'monday' do
      let(:date) { monday }
      it { should be_nil }
    end
  end

  describe '#hightlight_classes' do
    subject { helper.hightlight_classes(date, calendar) }
    let(:date) { Date.parse('2013-01-01') }
    let(:calendar) { ::EventCal::Calendar.new(date) }
    before do
      class HolidayEvent < ::EventCal::Event
        def self.all
          [self.new(Date.parse('2013-01-01'))]
        end
      end
    end
    describe 'event related classes' do
      context 'when it has events on the day' do
        it { should include 'has_events' }
        it { should include 'holiday_event' }
      end
      context 'when it donesnt have events on the day' do
        let(:date) { Date.parse('2013-01-02') }
        it { should_not include 'has_events' }
        it { should_not include 'holiday_event' }
      end
    end
    describe 'today class' do
      after { Timecop.return }
      it 'doesnt have today for not today date' do
        should_not include 'today'
      end
      it 'has today class for today date' do
        Timecop.travel(date)
        should include 'today'
      end
    end
  end

  describe '#render_monthly' do
    subject { render_monthly(calendar) }
    let(:calendar) { ::EventCal::Calendar.new(Date.parse('2013-01-01')) }
    before do
      class HolidayEvent < ::EventCal::Event
        def self.all
          []
        end
      end

      class Birthday < ::EventCal::Event
        def self.all
          []
        end
      end
    end
    it { should =~ /<div class='calendar monthly'/ }
  end
end
