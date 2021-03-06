require 'spec_helper'
require 'active_support/core_ext'
require_relative '../../../lib/event_cal/calendar'

describe ::EventCal::Calendar do
  let(:calendar) { ::EventCal::Calendar.new(base_date) }
  let(:base_date) { Date.new(2013, 1, 1) }

  before do
    Timecop.travel(2013, 1, 1)
    reset_events
  end
  after { Timecop.return }

  def reset_events
    ::EventCal::Event.subclasses.each do |klass|
      klass.class_eval('def self.all; []; end')
    end
  end

  describe 'initializer' do
    subject { ::EventCal::Calendar.new() }
    it { should be_a_kind_of ::EventCal::Calendar }

    describe 'options for initializer' do
      describe 'setting owner' do
        context 'given a option hash' do
          subject { calendar.owner }
          let(:user) { FactoryGirl.build(:user) }
          let(:calendar) { ::EventCal::Calendar.new(owner: user) }
          it { should == user }
          specify { calendar.base_date.should == Date.today }
        end

        context 'given a date and option hash' do
          subject { calendar.owner }
          let(:user) { FactoryGirl.build(:user) }
          let(:calendar) { ::EventCal::Calendar.new(Date.today, owner: user) }
          it { should == user }
          specify { calendar.base_date.should == Date.today }
        end
      end

      context 'geven a invalid option' do
        it 'raises ArgumentError' do
          expect{ ::EventCal::Calendar.new('invalid argument') }.to raise_error(ArgumentError)
        end
      end
    end

    describe 'events options' do
      let(:options) { {} }
      let(:priority_options) { { priority_events: [HolidayEvent, Birthday] } }
      let(:only_options) { { only_events: [HolidayEvent] } }
      let(:except_options) { { except_events: [HolidayEvent] } }
      let(:calendar) { ::EventCal::Calendar.new(options) }

      before do
        class Birthday < ::EventCal::Event
          def self.all
            [ self.new(Date.new(2013, 1 ,8)),
              self.new(Date.new(2013, 1 ,18)),
              self.new(Date.new(2013, 2 ,2)),
              self.new(Date.new(2013, 2 ,3)),
              self.new(Date.new(2013, 2 ,8))
            ]
          end
        end
        class HolidayEvent < ::EventCal::Event
          def self.all
            [ self.new(Date.new(2013, 1 ,1)),
              self.new(Date.new(2013, 1 ,14))
            ]
          end
        end
        class SomeEvent < ::EventCal::Event
          def self.all
            [ self.new(Date.new(2013, 1 ,1)),
              self.new(Date.new(2013, 1 ,14))
            ]
          end
        end
      end

      describe 'order of events' do
        subject { calendar.events.first.class }
        let(:options) { priority_options }
        it { should == HolidayEvent }
        context 'opposit order' do
          let(:priority_options) { { priority_events: [Birthday, HolidayEvent] } }
          it { should == Birthday }
        end
      end

      describe 'limit events' do
        subject { calendar.events.map(&:class) }
        let(:options) { only_options }
        it { should include HolidayEvent }
        it { should_not include Birthday }
        it { should_not include SomeEvent }
      end

      describe 'exclude events' do
        subject { calendar.events.map(&:class) }
        let(:options) { except_options }
        it { should_not include HolidayEvent }
        it { should include Birthday }
        it { should include SomeEvent }
      end

      context 'combination of options' do
        context 'wrong one' do
          let(:options) { only_options.merge(except_options) }
          it { expect{ ::EventCal::Calendar.new(options) }.to raise_error(ArgumentError) }
        end

        context 'right ones' do
          subject { calendar.events.map(&:class) }
          context 'only and priority' do
            let(:options) { only_options.merge(priority_options) }
            it { should_not include Birthday }
            it { should_not include SomeEvent }
            it { should include HolidayEvent }
          end

          context 'expect and priority' do
            let(:options) { except_options.merge(priority_options) }
            it { should include Birthday }
            it { should include SomeEvent }
            it { should_not include HolidayEvent }
            specify { calendar.events.first.class.should == Birthday }
          end
        end
      end

    end
  end

  describe '#start_on' do
    subject { calendar.start_on }
    it { should == Date.new(2012, 12, 30) }
  end

  describe '#end_on' do
    subject { calendar.end_on }
    it { should == Date.new(2013, 2 ,2) }
  end

  describe '#base_date' do
    subject { calendar.base_date }
    it { should == base_date }
  end

  describe '#dates' do
    subject { calendar.dates }
    it { should respond_to(:each) }
    it { should have(7*5).dates }
  end

  describe 'to_param' do
    subject { calendar.to_param }
    it { should == "#{base_date.year}/#{base_date.month}/#{base_date.day}" }
  end

  describe '#fetch_events' do
    subject { calendar.events }
    context '1 subclass for ::EventCal::Event' do
      context '3 events for calendar range and 2 is out of the range' do
        before do
          class Birthday < ::EventCal::Event
            def self.all
              [ self.new(Date.new(2013, 1 ,8)),
                self.new(Date.new(2013, 1 ,18)),
                self.new(Date.new(2013, 2 ,2)),
                self.new(Date.new(2013, 2 ,3)),
                self.new(Date.new(2013, 2 ,8))
              ]
            end
          end
        end
        it { should have(3).events }

        describe '#events_on(date)' do
          subject { calendar.events_on(Date.new(2013, 1 ,8)) }
          it { should have(1).events }
        end

        context 'another subclass for ::EventCal::Event' do
          context 'has 2 events in the range' do
            before do
              class HolidayEvent < ::EventCal::Event
                def self.all
                  [ self.new(Date.new(2013, 1 ,1)),
                    self.new(Date.new(2013, 1 ,14))
                  ]
                end
              end
            end
            it { should have(3+2).events }
          end
        end
      end
    end
  end
end
